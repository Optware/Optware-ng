Note, this document is a text transcription of the web page at
http://www.rahul.net/dholmes/ctorrent/ctcs.html.  It will be much
easier to read the sample display tables there than below.
______________________________________________________________________


                          CTorrent Control Server

   CTorrent Control Server (CTCS) is an interface for monitoring and
   managing Enhanced CTorrent clients. It can manage allocation of
   bandwidth, provide status information, and allow changes to the
   running configuration of each client. Communication with CTorrent is
   via a TCP connection, and the user interface is a web browser.

   The current version is implemented in [1]Perl since that was used to
   develop the original prototype. It may be reimplemented in C at some
   later date, but the perl version is fully functional.

  Contents

     * [2]Download
     * [3]Usage
     * [4]All Torrents screen
     * [5]Torrent Details screen
     * [6]Advanced Limits screen
     * [7]Protocol (coming soon)
     _________________________________________________________________

   Download

   [8]ctcs-1.0.tar.gz: CTCS version 1.0
     _________________________________________________________________

   Usage

ctcs [-d <dlimit>] [-u <ulimit>] [-i <interval>] [-p <port>] [-P]

   -d dlimit
          Overall download bandwidth limit, in KB/s (default 100).

   -u ulimit
          Overall upload bandwidth limit, in KB/s (default 25). Use a
          value that is less than the maximum capacity of your network
          line.

   -i interval
          Bandwidth management change interval, in seconds (default 5).
          The recommended minimum value is 3. Higher values will reduce
          oscillation of individual torrent limits, but a value that is
          too high will cause very slow reactions to changes in bandwidth
          usage.

   -p port
          The TCP port on which to listen for connections (default 2780).

   -P
          Prompt for an authorization password.

   If your system does not have perl available at /usr/bin/perl, you will
   need to change the path in the first line of the file.

   To connect Enhanced CTorrent (release dnh2 or later) clients to CTCS,
   use the "-S" command-line option, e.g. "-S localhost:2780". To use a
   web browser to view or change status, enter the same host and port as
   the location, e.g. "http://localhost:2780/".

  Security

   Though there is a basic option, security is very minimal. Running CTCS
   on a computer or network with untrusted users is not recommended. It
   should go without saying that the CTCS listening port should not be
   made openly accessible from the public Internet (but there, it's said
   anyway).

   The "-P" option will cause CTCS to prompt for a password when
   starting. This password will be used to authenticate CTorrent clients.
   It is intended that the same password will be used to authenticate web
   browser connections also, but this has not yet been implemented. Using
   a colon at the end of the -S parameter to CTorrent (as in "-S
   localhost:2780:") will cause the client to prompt for a password to
   send to CTCS when connecting.
     _________________________________________________________________

   All Torrents screen

   This is the main CTCS display, which shows overall bandwidth status
   and provides a summary of each torrent.

  Bandwidth Management

   The top portion of the display provides the bandwidth management
   interface.
                    ___________________________________

             Current DL = 7 K/s       DL Limit: ____K/s Change
             Current UL = 34 K/s      UL Limit: ____K/s
                                 Change interval: ___sec

                             [9]Advanced Limits
                    ___________________________________

   The current aggregate download and upload rates are shown at the left
   (determined by adding together the rates reported by each client). To
   the right of this the overall limits and change interval can be
   changed. To do this, enter the desired values and click the Change
   button.

   The Advanced Limits function is covered further below.

  Active Torrents

   The next section of the display is a list of all active clients that
   are reporting to CTCS, and status information on the torrents they are
   running.
                    ___________________________________

   [10]Show peers

   Torrent Start Time
   Seed Leech Complete DL Rate UL Rate DL Total UL Total Limit D/U
   [11]Example 1.torrent Tue Jan 3 21:24:27 2006
   S: 0 L: 7 100% D= 0 B/s U= 11 K/s D= 393 M U= 1111 M 0 / 11 K/s
   [12]Example 2.torrent Tue Jan 3 20:24:06 2006
   S: 0 L: 44 100% D= 0 B/s U= 12 K/s D= 380 M U= 972 M 0 / 12 K/s
   [13]Example 3.torrent Wed Jan 4 22:13:55 2006
   S: 1 L: 1 20% (100% Avail) D= 7372 B/s U= 12 K/s D= 188 M U= 254 M 100
   / 12 K/s
                    ___________________________________

   Each torrent is listed in blue along with the time the client was
   started, with its status information shown below it in white. The
   first two fields are the number of seeders and leechers connected.
   This is followed by the percentage of the torrent that you have; if it
   is not complete then the amount that is currently available from all
   connected peers is shown in parentheses. The current download and
   upload rates are shown in bytes, kilobytes, or megabytes per second,
   as are the total amounts downloaded and uploaded by the client. The
   bandwidth allocated to the client is shown in the last column, in
   kilobytes per second. Note that bandwidth is managed to a finer degree
   than this, so if you see a zero value it just means that less than 1K
   has been allocated. This is also why it may appear that the total is
   wrong if you add the displayed values yourself.

   Clicking a torrent title will take you to the Torrent Details screen
   for that torrent. If CTCS has received any status messages from a
   client, the title will be highlighted in yellow. These messages can be
   read on the Torrent Details screen. Bandwidth limits may also be
   highlighted in yellow or green if they have been adjusted on the
   Advanced Limits screen.

   The "Show peers" option will list each torrent's peers below the
   torrent's status information. For more information, see the Torrent
   Details screen description below.

  Terminated Torrents

   Clients that have disconnected from CTCS (assumed to have terminated)
   are listed in the lower portion of the display.
                    ___________________________________

   [Del] Torrent                                              End Time
   Seed Leech Complete  DL Rate   UL Rate DL Total  UL Total  Limit D/U
   [_] Finished example 4.torrent             Sat Dec 24 19:09:55 2005
   S: 0 L: 5  100%     D= 0 B/s U= 16 K/s D= 720 M  U= 136 M 0 / 15 K/s
   [_] Dead example 5.torrent                  Sun Jan 1 23:37:15 2006
   S: 0 L: 13 100%     D= 0 B/s U= 14 K/s D= 435 M U= 1937 M 0 / 13 K/s

   Delete Delete All
                    ___________________________________

   This is just like the list of active torrents except that the end time
   replaces the start time. The last known status information is shown,
   which is normally the final status unless the client terminated
   abnormally.

   To remove a torrent from the list, check the box next to it and click
   the Delete button at the bottom left of the list. To clear the entire
   list, click the Delete All button at the bottom right.
     _________________________________________________________________

   Torrent Details

   This screen shows detailed information about a particular client.
                    ___________________________________

                        Upload/Download Ratio: 2.83
                  Seed time remaining: 54 hours 11 minutes
                    ___________________________________

   If nothing has been downloaded, the full size of the torrent is used
   as the amount downloaded; if you are only seeding, then the ratio
   effectively shows how many times you have uploaded the torrent.

   The time remaining is an estimate based on the current download rate,
   current upload rate and target ratio, or actual seed time remaining.

  Configuration

   Several configuration parameters can be changed in this part of the
   display.
                    ___________________________________

                               Configuration
       Verbose output [-v]  [_]  disabled
       Seed time [-e]        ___ ~hours remaining (-e 72)
       Seed ratio [-E]     _____
       Max peers [-M]        ___ Current peers: 8
       Min peers [-m]        ___ Current peers: 8
       Pause torrent        [_]  Refuse new peers & wait
       Stop when peers=0    [_]  Terminate torrent if I have no peers
                                  Submit
                    ___________________________________

   For parameters that have a corresponding command-line option, the
   option letter is shown in brackets next to the parameter name. Note
   that for "Seed time" an approximation of the number of hours remaining
   is shown, and a new value entered will be interpreted the same way.
   The total number of seed hours (as it would have been given on the
   command line when starting the program), of dubious usefulness, is
   given in parentheses.

   Other features are:

   Pause torrent
          This will cause the client to refuse connections from new
          peers, and deregister with the tracker once it has no peers. It
          will continue interacting with the peers that are already
          connected.

   Stop when peers=0
          The client will exit when no more peers are connected.

  Actions

   This section allows you to cause the client to perform an action.
                    ___________________________________

                                  Actions
               Update    (_) Update tracker stats & get peers
               Restart   (_) Restart the tracker session
               Terminate (_) Stop torrent (quit)
                                  Perform
                    ___________________________________

   Update
          Force a normal update connection to the tracker.

   Restart
          This may be handy if messages from the tracker indicate that
          your client is no longer registered. You will connect to the
          tracker as if the client just started.

   Terminate
          Stop the client in a normal manner (as when seeding has
          completed or the user hits control-c). This option is tinted
          red to help avoid accidental selection.

  Messages

   If any status messages have been received from the client, they are
   listed next.
                    ___________________________________

                                    Messages
 Tue Jan  3 23:19:04 2006 warn, received nothing from tracker! Unknown error: 0

                                     Clear
                    ___________________________________

   To acknowledge the messages (which clears the list from CTCS memory),
   click the Clear button.

  Files

   The component files of the torrent are listed next.
                    ___________________________________

                      File Name        Size Complete
                          1 Main.dat   393 M      100%
                          2 readme.txt   2 K      100%
                      Total           393 M
                    ___________________________________

   The file number, name, size (scaled to bytes, kilobytes, or
   megabytes), and percentage complete are shown. Files which are
   complete are tinted green. If operating in "get1file" mode, the
   current file in progress is tinted blue.

  Status and Peers

   This section is similar to what is displayed on the All Torrents
   screen.
                    ___________________________________

   Torrent                                                       Start Time
   Seed Leech Complete  DL Rate     UL Rate DL Total  UL Total     Limit D/U
   [14]Example 1.torrent                            Tue Jan 3 21:24:27 2006
   S: 0 L: 8  100%     D= 0 B/s   U= 15 K/s D= 393 M U= 1113 M    0 / 17 K/s
   -BC0060-0x1B5809A843282B5EE23CEC0F       00.131.203.0       BitComet 0060
    Cn   Ci        77% D= 0 B/s    U= 0 B/s   D= 0 B     U= 0 B
   -BC0060-5)0x9881006F56E31AA742F8         0.255.161.000      BitComet 0060
    Cn   Ci        20% D= 0 B/s    U= 0 B/s   D= 0 B   U= 192 K
   -BC0060-0x09645C51208ADDB8D53E29F7       00.171.219.0       BitComet 0060
    Cn   Ui         2% D= 0 B/s U= 2457 B/s   D= 0 B   U= 496 K
   -BC0060-0x01DE4ED5BB6797CC6C58EF1E       0.48.201.000       BitComet 0060
    Cn   Ui        10% D= 0 B/s U= 7372 B/s   D= 0 B  U= 4320 K
   -BC0059-0xE507A66333F2A020E7DBFC42       00.245.89.00       BitComet 0059
    Cn   Ci        65% D= 0 B/s  U= 819 B/s   D= 0 B  U= 1072 K
   exbc0x01014C4F524497240602B5B8E07B3AA3   0.95.210.00        BitLord 1.1
    Cn   Ui        23% D= 0 B/s U= 1638 B/s   D= 0 B  U= 8592 K
   -BC0059-0x9F1995D00E3BA5EF9ABEE4F8       0.74.215.00        BitComet 0059
    Cn   Ci        49% D= 0 B/s    U= 0 B/s   D= 0 B    U= 11 M
   -AZ2306-kW66DYIl3XoE                     00.183.31.0        Azureus 2306
    Cn   Ui        93% D= 0 B/s U= 5734 B/s   D= 0 B    U= 38 M
                    ___________________________________

   The currently connected peers are listed below the client status
   information. The peer ID, IP address, and software name and version
   (if identified) are tinted green. Below this (in white) is status
   information for that peer. The first field shows "C" or "U" to
   indicate whether the connection is choked or unchoked for downloading,
   followed by "i" or "n" to indicate whether your client is interested
   (or not) in downloading from the peer. The second field shows the same
   information for uploading to the peer. The third field is the
   percentage of pieces that the peer has available. The next two fields
   are your client's current download and upload rates to the peer, and
   the last two are the total amount your client has downloaded from and
   uploaded to the peer. (Note that the totals are not maintained if the
   peer connection is broken and later reestablished.)
     _________________________________________________________________

   Advanced Limits

   This screen allows fine-tuning of the client bandwidth limits.
                    ___________________________________

   Torrent Current Rate Limit Minimum Maximum Shared
   DL UL DL UL DL UL DL UL DL UL
   Example 2.torrent 0 13 ____ [_] ____ [_] ____ ____ ____ ____ [_] [_]
   Example 1.torrent 0 11 ____ [_] ____ [_] ____ ____ ____ ____ [_] [_]
   Example 3.torrent 8 12 ____ [_] ____ [_] ____ ____ ____ ____ [_] [_]

                                   Submit
                    ___________________________________

   Due to the complexity of these options, usage notes are displayed
   directly on the screen:

   Notes
     * All values are in kilobytes per second (KB/s).
     * Use caution when changing actual limits to below the current
       rate--small increments are recommended. To change a current limit,
       enter the desired value and check the adjacent box.
     * "Minimum" and "Maximum" are soft limits. They will be enforced
       when there is competition for bandwidth; otherwise the torrent is
       free to give or take unused bandwidth.
          + Minimum: If the torrent wants bandwidth up to this level, it
            will receive it at the expense of other torrents. It will not
            be forced or held below this level if it wants (is using) the
            bandwidth. Use to high-prioritize a torrent, or to guarantee
            a bandwidth allocation amount to a torrent.
          + Maximum: The torrent will be forced down to this level if
            other torrents want bandwidth. Use to low-prioritize a
            torrent, or to limit the amount of bandwidth this torrent is
            allowed to consume at the expense of other torrents.
     * "Shared" indicates whether the torrent's bandwidth is counted
       against the shared pool represented by the global limit on the
       main CTCS page. CTCS will dynamically manage the client's
       bandwidth only if the Shared option is checked.
     * Use a value of 0 to disable/remove a limit.
     * Non-default settings are highlighted in yellow and green. The
       limit field in torrent status displays will also be highlighted as
       a reminder. Red highlight indicates an unknown value; you should
       refresh before making changes.
     * After submitting changes, you may need to refresh the page after a
       second or two in order to see the resulting updates.

References

   1. http://www.perl.org/
   2. http://www.rahul.net/dholmes/ctorrent/ctcs.html#download
   3. http://www.rahul.net/dholmes/ctorrent/ctcs.html#usage
   4. http://www.rahul.net/dholmes/ctorrent/ctcs.html#alltorrents
   5. http://www.rahul.net/dholmes/ctorrent/ctcs.html#details
   6. http://www.rahul.net/dholmes/ctorrent/ctcs.html#alimits
   7. http://www.rahul.net/dholmes/ctorrent/ctcs-protocol.html
   8. http://www.rahul.net/dholmes/ctorrent/ctcs-1.0.tar.gz
   9. http://www.rahul.net/dholmes/ctorrent/ctcs.html#/alimits
  10. http://www.rahul.net/dholmes/ctorrent/ctcs.html#/peers
  11. http://www.rahul.net/dholmes/ctorrent/ctcs.html#/torrent/-CD0200-%7B0xD529E46881CF5DD4E37DF6
  12. http://www.rahul.net/dholmes/ctorrent/ctcs.html#/torrent/-CD0200-P0xE9C43CD51BA8C5B319601A
  13. http://www.rahul.net/dholmes/ctorrent/ctcs.html#/torrent/-CD0200-0xCCEFB5B7D53349B364737755
  14. http://www.rahul.net/dholmes/ctorrent/ctcs.html#/torrent/-CD0200-%7B0xD529E46881CF5DD4E37DF6
