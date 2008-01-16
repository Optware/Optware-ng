# -*- cperl -*-

BEGIN {
    use Config;

    if ($] == 5.008 && $ENV{"LANG"} ne "C") {
	$ENV{LANG} = "C";
	print STDERR "\n\n\n\$ENV{LANG} is not 'C' execing 'perl Makefile.PL'".
	" with ENV{LANG} == 'C'\n You can skip this check by: 'export ".
	"LANG='C' before running 'perl Makefile.PL or by upgrading your Perl'\n\n\n";

	sleep(5);
        exec ("$Config{perlpath} $0", @ARGV )|| die $!;
    }
}
use strict;
BEGIN { $^W = 1; }
use Getopt::Long();
use ExtUtils::MakeMaker();
use Data::Dumper ();
use File::Path;
use File::Copy;
#require DBI::DBD;

my $TESTDB = "test";

use vars qw($opt);
$opt = { "help" => \&Usage, };

Getopt::Long::GetOptions(
    $opt,
    "help",
    "testdb=s",
    "testhost=s",
    "testport=s",
    "testuser=s",
    "testpassword=s",
    "testsocket=s",
    "cflags=s",
    "libs=s",
    "verbose",
    "ps-protocol",
    "nocatchstderr",
    "ssl!",
    "nofoundrows!",
    "embedded=s",
    "mysql_config=s",
    "force-embedded"
    ) || die Usage();

my $source = {};

if ($^O !~ /mswin32/i)
{
  #Check for mysql_config first
  $source->{'mysql_config'}="guessed";
  if ($opt->{'mysql_config'})
  {  
    if (-f $opt->{'mysql_config'})
    {
      $source->{'mysql_config'} = "Users choice";
    }
    else
    {
      print <<"MSG";

Specified mysql configuration script '$opt->{'mysql_config'}' doesn't exist. 
Please check path/permissions. Will try to use default mysql_config 
script found through PATH.
MSG
      $opt->{'mysql_config'}= "mysql_config";
    }
  }
  else
  {
    if (! `mysql_config`)
    {
      print <<MSG;

Cannot find the file 'mysql_config'! Your execution PATH doesn't seem 
not contain the path to mysql_config. Resorting to guessed values!
MSG
    }
    $opt->{'mysql_config'} = "mysql_config";
  }
}

foreach my $key (qw/testdb testhost testuser testpassword testsocket 
                    cflags embedded libs nocatchstderr ssl nofoundrows
                    ps-protocol force-embedded/)
{
  Configure($opt, $source, $key);
}

#We have to rename/move Makefile.PL in mysqlEmb directory
#since MakeMaker will find it and will try to execute it.
if (-f "mysqlEmb/Makefile.PL")
{
  eval { require File::Copy };
  move ("mysqlEmb/Makefile.PL", "mysqlEmb/Makefile.PL.old");
}

#Disable of building of dbd::mysqlEmb driver by default
$opt->{'embedded'}="" if !$opt->{'force-embedded'};

if ($opt->{'embedded'})
{
  if ($source->{'embedded'} eq 'mysql_config')
  {
    #We have to use libmygcc to resolve linking problem  
    $opt->{'embedded'} .= " -lmygcc";
  }

  my @files = ($^O =~ /mswin32/i) ? qw(mysqlclient.lib) :
               qw(libmysqld.a);

  my @dirs = $opt->{'embedded'} =~ /-L(.*?)(?:\s|$)/g;

  if( !(SearchFor('lib', @files)) && !(SearchFor2(\@files,\@dirs)) )
  {
     warn <<"MSG";

You intended to build DBD::mysqlEmb driver by using option:
--embedded=$opt->{'embedded'}.
But we failed to determine directory of @files. Building of DBD::mysqlEmb
driver was disabled.

Please use

  perl Makefile.PL --embedded="-L<dir> <flags>"

to set correct directory. For details see the INSTALL.html file,
section "Linker flags" or type

  perl Makefile.PL --help
MSG
     $source->{'embedded'} = "guessed";
     $opt->{'embedded'}="";
  }
}

if ($opt->{'embedded'} && !check_include_version($opt->{'cflags'}, 40003)) {
  die <<"MSG";

WARNING: Wrong version or unable to check version of mysql include files.
To build embedded  version of DBD you ought to be sure that you use include
files from MySQL server >= 4.0.3.

MSG
}

print <<"MSG";
I will use the following settings for compiling and testing:

MSG

delete $opt->{'help'};
my $keylen = 0;
foreach my $key (keys %$opt)
{
  $keylen = length($key) if length($key) > $keylen;
}
my $slen = 0;
foreach my $val (values %$source)
{
  $slen = length($val) if length($val) > $slen;
}

foreach my $key (sort { $a cmp $b} keys %$opt)
{
  printf("  %-" . $keylen . "s (%-" . $slen . "s) = %s\n",
	 $key, $source->{$key}, $opt->{$key})
}

print <<"MSG";

To change these settings, see 'perl Makefile.PL --help' and
'perldoc INSTALL'.

MSG

sleep 5;

eval { require File::Spec };
my $fileName = $@ ?
  "t/mysql.mtest" : File::Spec->catfile("t", "mysql.mtest");
(open(FILE, ">$fileName") &&
 (print FILE ("{ local " . Data::Dumper->Dump([$opt], ["opt"]) .
	      "\$::test_host = \$opt->{'testhost'};\n" .
	      "\$::test_port = \$opt->{'testport'};\n" .
	      "\$::test_user = \$opt->{'testuser'};\n" .
              "\$::test_socket = \$opt->{'testsocket'};\n" .
	      "\$::test_password = \$opt->{'testpassword'};\n" .
	      "\$::test_db = \$opt->{'testdb'};\n" .
	      "\$::test_dsn = \"DBI:mysql:\$::test_db\";\n" .
	      "\$::test_dsn .= \";mysql_socket=\$::test_socket\" if \$::test_socket;\n" .
              "\$::test_dsn .= \":\$::test_host\" if \$::test_host;\n" .
	      "\$::test_dsn .= \":\$::test_port\" if \$::test_port;\n" .
              "\$::test_dsn .= \":mysql_server_prepare=1\" if \$opt->{'ps-protcol'} || \$ENV{'MYSQL_SERVER_PREPARE'};\n" .
	      "} 1;\n"))  &&
  close(FILE))  ||  die "Failed to create $fileName: $!";


my $cflags = "-I\$(DBI_INSTARCH_DIR) $opt->{'cflags'}";
$cflags .= " -DDBD_MYSQL_WITH_SSL" if $opt->{'ssl'};
$cflags .= " -DDBD_MYSQL_INSERT_ID_IS_GOOD" if $DBI::VERSION > 1.42;
$cflags .= " -DDBD_NO_CLIENT_FOUND_ROWS" if $opt->{'nofoundrows'};
$cflags .= " -g ";
my %o = ( 'NAME' => 'DBD::mysql',
	  'INC' => $cflags,
	  'dist'         => { 'SUFFIX'       => ".gz",
			      'DIST_DEFAULT' => 'all installhtml tardist',
			      'COMPRESS'     => "gzip -9f" },
	  'clean' => { 'FILES' => '*.xsi' },
          'C' => ["dbdimp.c", "mysql.c"],
          'XS' => {'mysql.xs' => 'mysql.c'},
	  'OBJECT' => '$(O_FILES)',
	  'LIBS' => $opt->{'libs'},
	  'VERSION_FROM' => 'lib/DBD/mysql.pm'
	);

my %embedded_files=();

if ($opt->{'embedded'})
{

 %embedded_files = ( 'mysql.xs' => { filename  => 'mysqlEmb/mysqlEmb.xs',
                                       replace   => { ':mysql'    => ':mysqlEmb',
                                                      'mysql.xsi' => 'mysqlEmb.xsi'},
                                       makedir => 'mysqlEmb'
                                     },
                       'lib/DBD/mysql.pm' => { filename => 'mysqlEmb/lib/DBD/mysqlEmb.pm',
                                               replace  => { ':mysql'   => ':mysqlEmb',
                                                    '=> \'mysql\'' => '=> \'mysqlEmb\''},
                                               makedir => 'mysqlEmb/lib/DBD'
                                             },
                       'lib/DBD/mysql/GetInfo.pm' => { filename => 'mysqlEmb/lib/DBD/mysqlEmb/GetInfo.pm',
                                                       replace => {':mysql'   => ':mysqlEmb',
                                                    '\'mysql\'' => '\'mysqlEmb\''},
                                                       makedir => 'mysqlEmb/lib/DBD/mysqlEmb'
                                                     },
                       't/mysql.dbtest' => { filename => 'mysqlEmb/t/mysqlEmb.dbtest',
                                             makedir => 'mysqlEmb/t' 
                                           },
                       't/mysql.mtest' => { filename => 'mysqlEmb/t/mysqlEmb.mtest',
                                             makedir => 'mysqlEmb/t',
                                             replace =>  { 'DBI:mysql'=> 'DBI:mysqlEmb', 
                                                            'test_db";' => 'test_db;mysql_embedded_options=--datadir=./t,--skip-innodb,--skip-bdb";'
                                                         }
                                           },
                       't/lib.pl' => { filename => 'mysqlEmb/t/lib.pl',
                                       replace =>  { '\$mdriver =.*' => "\$mdriver =\'mysqlEmb\';"},
                                       makedir => 'mysqlEmb/t'
                                    },
                       't/10dsnlist.t' => { filename => 'mysqlEmb/t/10dsnlist.t',
                                            makedir => 'mysqlEmb/t'
                                          },
                       't/20createdrop.t' => { filename => 'mysqlEmb/t/20createdrop.t',
                                               makedir => 'mysqlEmb/t'
                                             },
                       't/30insertfetch.t' => { filename => 'mysqlEmb/t/30insertfetch.t',
                                                makedir => 'mysqlEmb/t'
                                              },
                       't/40bindparam.t' => { filename => 'mysqlEmb/t/40bindparam.t',
                                              makedir => 'mysqlEmb/t'
                                             },
                       't/40blobs.t' => { filename => 'mysqlEmb/t/40blobs.t',
                                                                    makedir => 'mysqlEmb/t'
                                                                  },
                       't/40listfields.t' => { filename => 'mysqlEmb/t/40listfields.t',
                                                                    makedir => 'mysqlEmb/t'
                                                                  },
                       't/40nulls.t' => { filename => 'mysqlEmb/t/40nulls.t',
                                                                    makedir => 'mysqlEmb/t'
                                                                  },
                       't/40numrows.t' => { filename => 'mysqlEmb/t/40numrows.t',
                                                                    makedir => 'mysqlEmb/t'
                                                                  },
                       't/50chopblanks.t' => { filename => 'mysqlEmb/t/50chopblanks.t',
                                                                    makedir => 'mysqlEmb/t'
                                                                  },
                       't/50commit.t' => { filename => 'mysqlEmb/t/50commit.t',
                                                                    makedir => 'mysqlEmb/t'
                                                                  },
                       't/60leaks.t' => { filename => 'mysqlEmb/t/60leaks.t',
                                                                    makedir => 'mysqlEmb/t'
                                                                  },
                       't/ak-dbd.t' => { filename => 'mysqlEmb/t/ak-dbd.t',
                                                                    makedir => 'mysqlEmb/t'
                                                                  },
                       't/akmisc.t' => { filename => 'mysqlEmb/t/akmisc.t',
                                                                    makedir => 'mysqlEmb/t'
                                                                  },
                       't/dbdadmin.t' => { filename => 'mysqlEmb/t/dbdadmin.t',
                                                                    makedir => 'mysqlEmb/t'
                                                                  },
                       't/insertid.t' => { filename => 'mysqlEmb/t/insertid.t',
                                                                    makedir => 'mysqlEmb/t'
                                                                  },
                       't/mysql.t' => { filename => 'mysqlEmb/t/mysql.t',
                                                                    makedir => 'mysqlEmb/t'
                                                                  },
                       't/mysql2.t' => { filename => 'mysqlEmb/t/mysql2.t',
                                                                    makedir => 'mysqlEmb/t'
                                                                  },
                       't/00base.t' => { filename => 'mysqlEmb/t/00base.t',
                                                                    makedir => 'mysqlEmb/t'
                                                                  },

                       'myld' => { filename => 'mysqlEmb/myld',
                                   makedir => 'mysqlEmb'
                                 },
                       'dbdimp.c' => { filename => 'mysqlEmb/dbdimp.c',
                                   makedir => 'mysqlEmb'
                                 },
                       'dbdimp.h' => { filename => 'mysqlEmb/dbdimp.h',
                                   makedir => 'mysqlEmb'
                                 },
                       'constants.h' => { filename => 'mysqlEmb/constants.h',
                                   makedir => 'mysqlEmb'
                                 },
                       'Makefile.PL.embedded' => { filename => 'mysqlEmb/Makefile.PL',
                                   makedir => 'mysqlEmb'
                                 },
            );


  #Create embedded files from original ones
  prepare_files(\%embedded_files);

  my %e=%o;

  $o{'clean'}->{'FILES'} .= " ./mysqlEmb";
  $o{'DIR'}=['mysqlEmb'];

  $e{'NAME'} = 'DBD::mysqlEmb';
  $e{'C'} = ["dbdimp.c", "mysqlEmb.c"];
  $e{'XS'} = {'mysqlEmb.xs' => 'mysqlEmb.c'};
  $e{'VERSION_FROM'} = 'lib/DBD/mysqlEmb.pm';
  $e{'LIBS'} = $opt->{'embedded'};

  $e{'INC'} .= " -DDBD_MYSQL_EMBEDDED";

  #Create Makefile.conf for mysqlEmb Makefile.PL
  create_makefile(Data::Dumper->Dump([\%e], ["o"]));

}

if ($ExtUtils::MakeMaker::VERSION >= 5.43) {
  $o{'CAPI'} = 'TRUE'
    if ($ExtUtils::MakeMaker::VERSION >= 5.43
	&&  $Config::Config{'archname'} =~ /-object\b/i);
  $o{'AUTHOR'} = 'Rudy Lippan <rlippan@remotelinux.com>';
  $o{'ABSTRACT'} =
    'A MySQL driver for the Perl5 Database Interface (DBI)';
  $o{'PREREQ_PM'} = { 'DBI' => 1.08,
		      'Data::Dumper' => 0 };
}

ExtUtils::MakeMaker::WriteMakefile(%o);
exit 0;


############################################################################
#
#   Name:    Usage
#
#   Purpose: Print Usage message and exit with error status.
#
############################################################################

sub Usage {
  print STDERR <<"USAGE";
Usage: perl $0 [options]

Possible options are:

  --cflags=<flags>       Use <flags> for running the C compiler; defaults
                         to the value of "mysql_config --cflags" or a gussed
                         value
  --libs=<libs>          Use <libs> for running the linker; defaults
                         to the value of "mysql_config --libs" or a guessed
                         value
  --embedded=<libs>      Build embedded version of DBD and use <libs> for this;
                         defaults to the value of "mysql_config --embedded" 
                         (default: off)
  --testdb=<db>          Use the database <db> for running the test suite;
                         defaults to $TESTDB
  --testuser=<user>      Use the username <user> for running the test suite;
                         defaults to no username
  --testpassword=<pwd>   Use the password <pwd> for running the test suite;
                         defaults to no password
  --testhost=<host>      Use <host> as a database server for running the
                         test suite; defaults to localhost.
  --testport=<port>      Use <port> as the port number of the database;
                         by default the port number is choosen from the
                         mysqlclient library
  --mysql_config=<path>  Specify <path> for mysql_config script
                         (Not supported on Win32)
  --nocatchstderr        Supress using the "myld" script that redirects
                         STDERR while running the linker.
  --nofoundrows          Change the behavoiur of \$sth->rows() so that it
  			 returns the number of rows physically modified 
			 instead of the rows matched
  --ps-protocol    	 Toggle the use of server-side prepare, requires 
                         MySQL server version 4.1.3 if set to 1 
  --force-embedded       Force to build embedded version of driver
  --ssl			 Enable SSL support
  --help                 Print this message and exit

All options may be configured on the command line. If they are
not present on the command line, then mysql_config is called (if
it can be found):

  mysql_config --cflags
  mysql_config --libs
  mysql_config --embedded
  mysql_config --testdb

and so on. See the INSTALL.html file for details.
USAGE
  exit 1;
}


############################################################################
#
#   Name:    Configure
#
#   Purpose: Automatic configuration
#
#   Inputs:  $param - Name of the parameter being configured
#
#   Returns: Generated value, never undef
#
############################################################################

sub Configure
{
  my($opt, $source, $param) = @_;

  if (exists($opt->{$param}))
  {
    $source->{$param} = "User's choice";
    return;
  }

  if ($^O !~ /mswin32/i)
  {
    # First try to get options values from mysql_config
    my $command = $opt->{'mysql_config'} . " --$param";
    eval 
    {
      open(PIPE, "$command |") or die "Can't find mysql_config.";
    };

    if (!$@)
    {
      my $str = "";
      while (defined(my $line = <PIPE>)) 
      {
      $str .= $line;
      }
      if ($str ne ""  &&  $str !~ /Options:/) 
      {
        $str =~ s/\s+$//s;
        $str =~ s/^\s+//s;

        # Unfortunately ExtUtils::MakeMaker doesn't deal very well
        # with -L'...'
        $str =~ s/\-L\'(.*?)\'/-L$1/sg;
        $str =~ s/\-L\"(.*?)\"/-L$1/sg;

        $opt->{$param} = $str;
        $source->{$param} = "mysql_config";
        return;
      }
    }
    else
    {
      #print "Can't find mysql_config. Use --mysql_config option to specify where mysql_config is located\n";
    }
  }

  # Ok, mysql_config doesn't work. We need to do our best
  if ($param eq "nocatchstderr" || $param eq "nofoundrows")
  {
    $source->{$param} = "default";
    $opt->{$param} = 0;
  }
  elsif ($param eq "testdb") 
  {
    $source->{$param} = "default";
    $opt->{$param} = $TESTDB;
  }
  elsif ($param eq "testhost"  ||  $param eq "testuser"  ||
         $param eq "testport"  ||  $param eq "testpassword" || 
         $param eq "testsocket" 
         )
  {
    $source->{$param} = "default";
    $opt->{$param} = "";
  }
  elsif($param eq 'ps-protocol' || $param eq 'force-embedded')
  {
    $source->{$param} = $opt->{$param} ? "default" : 'not set';
  }
  elsif ($param eq "cflags") 
  {
    $source->{$param} = "guessed";
    my $dir = SearchFor('include', 'mysql.h');
    if ($dir) {
      $opt->{$param} = "-I$dir";
      return;
    }
    die <<"MSG";
Failed to determine directory of mysql.h. Use

  perl Makefile.PL --cflags=-I<dir>

to set this directory. For details see the INSTALL.html file,
section "C Compiler flags" or type

  perl Makefile.PL --help
MSG
  }
  elsif ($param eq "libs" || $param eq "embedded") 
  {
    $source->{$param} = "guessed";

    if ($param eq "embedded" && !$opt->{'embedded'})
    {
      $opt->{$param}="";
      return;
    }

    my @files=();
    my $default_libs;
    if ($param eq "embedded")
    {
      $default_libs= "-lmysqld -lpthread -lz -lm -lcrypt -lnsl";
      @files = ($^O =~ /mswin32/i) ? qw(mysqlclient.lib) :
			qw(libmysqld.a);
    }
    else
    {
      $default_libs= "-lmysqlclient -lz -lm -lcrypt -lnsl";
      @files = ($^O =~ /mswin32/i) ? qw(mysqlclient.lib) :
			qw(libmysqlclient.a libmysqlclient.so);
    }

    my $dir = SearchFor('lib', @files);

    if ($dir) {
        $opt->{$param} = "-L$dir $default_libs";
      return;
    }
    my $f = join("|", @files);
    die <<"MSG";
Failed to determine directory of $f. Use

  perl Makefile.PL "--$param=-L<dir> $default_libs"

to set this directory. For details see the INSTALL.html file,
section "Linker flags" or type

  perl Makefile.PL --help
MSG
  } 
  elsif ($param eq "ssl") 
  {
    $opt->{$param} = ($opt->{"libs"} =~ /ssl/) ? 1 : 0;
    $source->{$param} = "guessed";
  } 
  else 
  {
    die "Unknown configuration parameter: $param";
  }
}

my $haveFileSpec;
my $fineDir;
sub SearchFor {
  my($subdir, @files) = @_;
  $haveFileSpec = eval { require File::Spec } unless defined($haveFileSpec);

  my @dirs = ($^O =~ /mswin32/i) ? qw(C:) : qw(/usr/local /usr /opt);
  unshift(@dirs, $fineDir) if defined($fineDir);

  foreach my $f (@files) {
    foreach my $dir (@dirs) {
      my $try1 = $haveFileSpec ?
	File::Spec->catdir($dir, $subdir) : "$dir/$subdir";
      my $try2 = $haveFileSpec ?
	File::Spec->catdir($dir, "mysql") : "$dir/mysql";
      my $try3 = $haveFileSpec ?
	File::Spec->catdir($try1, "mysql") : "$try1/mysql";
      my $try4 = $haveFileSpec ?
	File::Spec->catdir($try2, $subdir) : "$try2/$subdir";
      foreach my $path ($try3, $try4, $try2, $try1, $dir) {
	my $file = $haveFileSpec ?
	  File::Spec->catfile($path, $f) : "$path/$f";
	if (-f $file) {
	  $fineDir = $dir;
	  return $path;
	}
      }
    }
  }
}

sub SearchFor2 {
  my($files, $dirs) = @_;

  foreach my $f (@{$files}) 
  {
    foreach my $dir (@{$dirs}) 
    {
      my $file = $haveFileSpec ?  File::Spec->catfile($dir, $f) : "$dir/$f";
      if (-f $file) 
      {
        $fineDir = $dir;
        return $dir;
      }
    }
  }
}


sub check_include_version {
  
  my ($dir, $ver) = @_;

  my $headerfile;

  $dir =~ s/-I//;
  $dir =~ s/'//g;
  $dir =~ s/\s.*//g;

  open(HEADERFILE ,"<${dir}/mysql_version.h") or
  (print "Unable to open header file ${dir}/mysql_version.h" && exit(0));
  {
    local undef $/;
    $headerfile = <HEADERFILE>;
  }
  close(HEADERFILE);

  my ($version_id) = ($headerfile =~ /MYSQL_VERSION_ID[\t\s]+(\d+)[\n\r]/);

  if ($version_id < $ver)
  {
    print  <<"MSG";

Version of MySQL include files in $dir - $1
MSG
    return 0;
  }
  return 1;
}

sub replace
{
  my ($str, $ref)=@_;

  foreach my $find (keys %{$ref})
  {
    $str =~ s/$find/$ref->{$find}/g;
  }
  $str;
}

sub prepare_files
{
  my ($files)= @_;
  my $line;
  my @lib;

  foreach my $file (keys %{$files})
  {

    if ($files->{$file}->{makedir})
    {
      mkpath $files->{$file}->{makedir} or die "Can't create dir $files->{$file}->{makedir}"
      unless (-e $files->{$file}->{makedir} && -d $files->{$file}->{makedir});
    }

    my $replace=$files->{$file}->{replace};

    if ($replace)
    {
       open(FILE, $file) or die "Can't open file $file";
       @lib= map { $replace ? replace($_, $replace) : $_; }  <FILE>;
       close(FILE);

       open(FILE, ">".$files->{$file}->{filename}) or die "Can't open file $files->{$file}->{filename}";
       print FILE @lib;
       close(FILE);
    }
    else
    {
       if(!copy($file, $files->{$file}->{filename}))
       {
         die "Unable to copy $file to $files->{$file}->{filename}\n";
       }
    }
  }
}

sub create_makefile
{
  my ($cnf)=@_;

  open(LOG, ">mysqlEmb/Makefile.conf") or die "Can't write to file mysqlEmb/Makefile.conf";
  print LOG $cnf;
  close(LOG);
}

package MY;

sub libscan {
    my($self, $path) = @_;
    if ($path =~ /~$|SCCS/) { return undef; }
    $path;
}

sub postamble {
  "\n" . <<"POSTAMBLE";
# --- This section was generated by DBI::DBD::dbd_postamble()
DBI_INSTARCH_DIR=/opt/lib/perl5/site_perl/PERL_VERSION/PERL_ARCH/auto/DBI
DBI_DRIVER_XST=/opt/lib/perl5/site_perl/PERL_VERSION/PERL_ARCH/auto/DBI/Driver.xst

# The main dependancy (technically correct but probably not used)
\$(BASEEXT).c: \$(BASEEXT).xsi

# This dependancy is needed since MakeMaker uses the .xs.o rule
\$(BASEEXT)\$(OBJ_EXT): \$(BASEEXT).xsi

\$(BASEEXT).xsi: \$(DBI_DRIVER_XST)
\t\$(PERL) -p -e "s/~DRIVER~/\$(BASEEXT)/g" \$(DBI_DRIVER_XST) > \$(BASEEXT).xsi


installhtml: lib/DBD/mysql/INSTALL.pod
\tpod2html --infile=lib/DBD/mysql/INSTALL.pod --outfile=INSTALL.html

POSTAMBLE
};

sub dynamic_lib {
  my $self = shift;
  my $result = $self->SUPER::dynamic_lib(@_);
  if (!$::opt->{nocatchstderr}  &&  $result =~ /\$\(LD\)/) {
    $result =~ s/(\$\(LD\))/\$\(PERL\) myld \$(LD)/sg;
  }
  return $result;
}
