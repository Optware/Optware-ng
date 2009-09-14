#include "dat.h"
#include "fns.h"
#include "error.h"
#include "audio.h"
#include <sys/ioctl.h>
#include <sys/soundcard.h>

#define 	Audio_Mic_Val		SOUND_MIXER_MIC
#define 	Audio_Linein_Val	SOUND_MIXER_LINE

#define		Audio_Speaker_Val	SOUND_MIXER_PCM // SOUND_MIXER_VOLUME
#define		Audio_Headphone_Val	SOUND_MIXER_ALTPCM
#define		Audio_Lineout_Val	SOUND_MIXER_CD

#define 	Audio_Pcm_Val		AFMT_S16_LE
#define 	Audio_Ulaw_Val		AFMT_MU_LAW
#define 	Audio_Alaw_Val		AFMT_A_LAW

#define 	Audio_Max_Queue		8

#include "audio-tbls.c"
#define	min(a,b)	((a) < (b) ? (a) : (b))

enum {
	A_Pause,
	A_UnPause
};
enum {
	A_In,
	A_Out
};

static QLock inlock;
static QLock outlock;

static int afd_in = -1;		/* audio fd in */
static int afd_out = -1;	/* audio fd out */
static int cfd = -1;		/* control fd */

static int	audio_in_pause = A_UnPause;
static Audio_t av;

static int audio_open(int omode);
static int audio_pause(int fd, int f);
static int audio_flush(int fd, int d);
static int audio_set_info(int fd, Audio_d *i, int d);
void audiodevsetvol(int what, int left, int right);
//static void audio_swap_endian(char*, int);

static void
dprint (char* fmt, ...){
	static int debug = 0;
	static char *progname = __FILE__;
	va_list args;

	if (debug) {
		fprint(2, "%s: ", progname);
		
		va_start(args, fmt);
		fprint(2, fmt, args);
		va_end(args);

		if (fmt[0] != '\0' && fmt[strlen(fmt)-1] == ':')
			fprint(2, "%s", strerror(errno));
		fprint(2,"\n");
	}
}

void 
audio_file_init ()
{
	dprint("audio_file_init %d %d\n", afd_in, afd_out);
	cfd = -1;
	cfd = open("/dev/mixer", ORDWR);
	if(cfd < 0){
		// oserror() produces a sigsegv in arm
		fprint(2, "can't open mixer device: %s\n", strerror(errno));
		close(cfd);
		cfd = -1;
	}
	
	audio_info_init(&av);
}

void
audio_file_open(Chan *c, int omode)
{
	dprint("audio_file_open %d %d\n", afd_in, afd_out);
	switch(omode){
	case OREAD:
		qlock(&inlock);
		if(waserror()){
			qunlock(&inlock);
			nexterror();
		}

		if(afd_in >= 0)
			error(Einuse);
		if((afd_in = audio_open(omode)) < 0)
			oserror();

		poperror();
		qunlock(&inlock);
		break;
	case OWRITE:
		qlock(&outlock);
		if(waserror()){
			qunlock(&outlock);
			nexterror();
		}
		if(afd_out >= 0)
			error(Einuse);
		if((afd_out = audio_open(omode)) < 0)
			oserror();
		
		poperror();
		qunlock(&outlock);
		break;
	case ORDWR:
		qlock(&inlock);
		qlock(&outlock);
		if(waserror()){
			qunlock(&inlock);
			qunlock(&outlock);
			nexterror();
		}
		if(afd_in >= 0 || afd_out >= 0)
			error(Einuse);

		if((afd_in = audio_open(omode)) < 0)
			oserror();
		if(waserror()){
			close(afd_in);
			afd_in = -1;
			nexterror();
		}
		afd_out = afd_in;

		poperror();
		qunlock(&inlock);
		qunlock(&outlock);
		break;
	}
}

void    
audio_file_close(Chan *c)
{
	dprint("audio_file_close %d %d\n", afd_in, afd_out);
	switch(c->mode){
	case OREAD:
		qlock(&inlock);
		close (afd_in);
		afd_in = -1;
		qunlock(&inlock);
		break;
	case OWRITE:
		qlock(&outlock);
		close(afd_out);
		afd_out = -1;
		qunlock(&outlock);
		break;
	case ORDWR:
		qlock(&inlock);
		qlock(&outlock);
		close(afd_in);
		//close(afd_out);
		afd_in = -1;
		afd_out = -1;
		qunlock(&inlock);
		qunlock(&outlock);
		break;
	}

}

long    
audio_file_read(Chan *c, void *va, long count, vlong offset)
{
	long ba, status, chunk, total;

	dprint("audio_file_read %d %d\n", afd_in, afd_out);
	qlock(&inlock);
	if(waserror()){
		qunlock(&inlock);
		nexterror();
	}

	if(afd_in < 0)
		error(Eperm);

	/* check block alignment */
	ba = av.in.bits * av.in.chan / Bits_Per_Byte;

	if(count % ba)
		error(Ebadarg);
		
	if(!audio_pause(afd_in, A_UnPause))
		error(Eio);
	
	total = 0;
	while (total < count) {
		chunk = count - total;
		status = read (afd_in, va + total, chunk);
		if (status < 0)
			error(Eio);
		total += status;
	}
	
	if (total != count)
		error(Eio);

	poperror();
	qunlock(&inlock);
	
	return count;
}

long                                            
audio_file_write(Chan *c, void *va, long count, vlong offset)
{
	long status = -1;
	long ba, total, chunk, bufsz;
	
	dprint("audio_file_write %d %d\n", afd_in, afd_out);
	qlock(&outlock);
	if(waserror()){
		qunlock(&outlock);
		nexterror();
	}
	
	if(afd_out < 0)
		error(Eperm);
	
	/* check block alignment */
	ba = av.out.bits * av.out.chan / Bits_Per_Byte;

	if(count % ba)
		error(Ebadarg);

	total = 0;
	bufsz = av.out.buf * Audio_Max_Buf / Audio_Max_Val;

	if(bufsz == 0)
		error(Ebadarg);

	while(total < count) {
		chunk = min(bufsz, count - total);
		status = write(afd_out, va, chunk);
		if(status <= 0)
			error(Eio);
		total += status;
	}

	poperror();
	qunlock(&outlock);

	return count;	
}

long
audio_ctl_write(Chan *c, void *va, long count, vlong offset)
{
	Audio_t tmpav = av;
	int force_open = 0;

	tmpav.in.flags = 0;
	tmpav.out.flags = 0;
	
	dprint ("audio_ctl_write %X %X %X\n", afd_in, afd_out);
	if (!audioparse(va, count, &tmpav))
		error(Ebadarg);

	qlock(&inlock);
	if (waserror()){
		qunlock(&inlock);
		nexterror();
	}

	/* afd needs to be opened to issue a write to /dev/audioctl */
	if (afd_in == -1 && afd_out == -1){
		force_open=1;
		afd_in = afd_out = open("/dev/dsp", O_RDONLY|O_NONBLOCK);
	}

	if (afd_in >= 0 && (tmpav.in.flags & AUDIO_MOD_FLAG)) {
		if (!audio_pause(afd_in, A_Pause))
			error(Ebadarg);
		if (!audio_flush(afd_in, A_In))
			error(Ebadarg);
		if (!audio_set_info(afd_in, &tmpav.in, A_In))
			error(Ebadarg);
	}
	poperror();
	qunlock(&inlock);
	
	qlock(&outlock);
	if (waserror()) {
		qunlock(&outlock);
		nexterror();
	}
	
	if (afd_out >= 0 && (tmpav.out.flags & AUDIO_MOD_FLAG)){
		if (!audio_pause(afd_out, A_Out))
			error(Ebadarg);
		if (!audio_set_info(afd_out, &tmpav.out, A_Out))
			error(Ebadarg);
	}
	poperror();
	qunlock(&outlock);

	tmpav.in.flags = 0;
	tmpav.out.flags = 0;

	av = tmpav;
	if (force_open) {
		close(afd_in);
		afd_in = -1;
		afd_out = -1;
	}
	return count;
}

static int
audio_set_info(int fd, Audio_d *i, int d)
{
	int status;
	int	dev, arg, fmtmask;
	
	dprint("audio_set_info (%d) %d %d\n", fd, afd_in, afd_out);
	if (fd < 0)
		return 0;

	/* sample rate */
	if (i->flags & AUDIO_RATE_FLAG){
		arg = i->rate;
		status = ioctl(fd, SNDCTL_DSP_SPEED, &arg);
	}
	
	/* channels */
	if(i->flags & AUDIO_CHAN_FLAG){
		arg = i->chan;
		status = ioctl(fd, SNDCTL_DSP_CHANNELS, &arg);
	}

	/* precision */
	if(i->flags & AUDIO_BITS_FLAG){
		arg = i->bits;
		status = ioctl(fd, SNDCTL_DSP_SAMPLESIZE, &arg);
	}
	
	/* encoding */
	if(i->flags & AUDIO_ENC_FLAG){
		status = ioctl(fd, SNDCTL_DSP_GETFMTS, &fmtmask);

		arg = i->enc;
		if (fmtmask && arg)
			status = ioctl(fd, SNDCTL_DSP_SETFMT, &arg);
		else{ // encoding not supported
			dprint ("dev %X: enc 0x%X not supported (not in 0x%X)\n",i->dev, i->enc, fmtmask);
		}
	}
	
	/* dev volume */ 
	if(i->flags & (AUDIO_LEFT_FLAG|AUDIO_VOL_FLAG))
		audiodevsetvol (i->dev, i->left, i->right);

	return 1;
}

Audio_t*
getaudiodev(void)
{
	dprint("getaudiodev %d %d\n", afd_in, afd_out);
	return &av;
}

/* oss specific stuff */
void
audiodevsetvol(int what, int left, int right)
{
	int can, v;
	
	dprint("audiodevsetvol cfd%d what%X left%d right%d\n", cfd, what, left, right);
	if(cfd < 0)
		error("audio device not open");

	if(ioctl(cfd, SOUND_MIXER_READ_DEVMASK, &can) < 0)
		can = ~0;

	dprint("audiodevsetvol %X can mix 0x%X (mask %X)\n",what, (can & (1<<what)), can);
	if(!(can & (1<<what)))
		return;
	v = left | (right<<8);
	if(ioctl(cfd, MIXER_WRITE(what), &v) < 0)
		oserror();
}

static int audio_open (int omode)
{
	int fd, val;
	
	dprint("audio_open %d %d\n", afd_in, afd_out);
	/* open non-blocking in case someone already has it open */
	/* otherwise we would block until they close! */
	switch (omode){
	case OREAD:
		fd = open("/dev/dsp", O_RDONLY|O_NONBLOCK);
		break;
	case OWRITE:
		fd = open("/dev/dsp", O_WRONLY|O_NONBLOCK);
		break;
	case ORDWR:
		fd = open("/dev/dsp", O_RDWR|O_NONBLOCK);
		break;
	}

	if(fd < 0)
		oserror();

	/* change device to be blocking */
	if((val = fcntl(fd, F_GETFL, 0)) == -1)
		return 0;
	
	val &= ~O_NONBLOCK;
	if(fcntl(fd, F_SETFL, val) < 0) {
		close(fd);
		error(Eio);
	}

	if(!audio_pause(fd, A_Pause)) {
		close(fd);
		error(Eio);
	}

	if(!audio_flush(fd, A_In)) {
		close(fd);
		error(Eio);
	}

	/* set audio info */
	av.in.flags = ~0;
	av.out.flags = 0;

	if(!audio_set_info(fd, &av.in, A_In)) {
		close(fd);
		error(Ebadarg);
	}

	av.in.flags = 0;

	/* tada, we're open, blocking, paused and flushed */
	return fd;
}

static int audio_pause (int fd, int f)
{
	int status, foo;

	dprint ("audio_pause (%d) %d %d\n", fd, afd_in, afd_out);
	if (fd < 0)
		return 0;
	
	if (fd == afd_in && audio_in_pause == f)
		return 1;

	// as stated in OSS guide, produces bad sound
	status = ioctl(fd, SNDCTL_DSP_RESET, &foo);
	if (status < 0)
		return 0;
		
	audio_in_pause = f;
	return 1;
}

static int
audio_flush(int fd, int d)
{
	int	foo = 0;
	int status;

	// as stated in OSS guide, produces bad sound
	dprint ("audio_flush (%d) %d %d\n", fd, afd_in, afd_out);
	status = ioctl(fd, SNDCTL_DSP_SYNC, &foo);

	if(status == -1) 
		return 0;
	return 1;
	
}
