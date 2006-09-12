
                             Enhanced CTorrent

       [ [1]Overview | [2]News | [3]Changes | [4]CTCS | [5]Download |
                        [6]Resources | [7]Contact ] 
     _________________________________________________________________

   Overview

   [8]CTorrent is a [9]BitTorrent client implemented in C++ to be
   lightweight and quick. The original has fallen a little behind in
   updates and bug fixes though.

   The files here contain the good work of those who wrote the original
   CTorrent base code and a number of patches that provide fixes and
   enhancements, as well as additional fixes and enhancements that I am
   contributing. I am not the original author, current maintainer, or any
   other official representative of CTorrent. The files on this page are
   not the original or official CTorrent distribution. I encourage you to
   visit the [10]CTorrent project page on SourceForge for further
   information.

  Features

   The purpose of the Enhanced CTorrent effort is to fix problems that
   remain in the code, modernize existing features and algorithms, and
   implement new features while maintaining low overhead requirements and
   a high standard of performance (both part of the original CTorrent
   design philosophy). Highlights of the enhanced client include:
     * Support for large files (>2GB) and large torrents (>255 files)
     * Strategic selection of pieces to request for download
     * Continuous queueing of download requests, tuned based on latency
       and throughput for each peer
     * Improved download performance, including parallel requests in
       initial and endgame modes
     * Improved bandwidth regulation
     * Improved compatibility with other peers
     * Performance optimization and bug fixes
     * An interface for monitoring and managing multiple clients

  Status Line

   The status line that is output by the client has changed since the
   original and deserves some explanation.

       / 0/33/110 [672/672/672] 0MB,1130MB | 0,20K/s | 0,0K E:0,31
       - - -- ---  --- --- ---  --- ------   - --      - -    - --
       A B  C  D    E   F   G    H     I     J  K      L M    N  O

   A: Ticker; this character changes to indicate that the client is
   running.
   B: Number of seeders (complete peers) to which you are connected.
   C: Number of leechers (incomplete peers) to which you are connected.
   D: Total number of peers in the swarm, as last reported by the
   tracker.
   E: Number of pieces of the torrent that you have completed.
   F: Total number of pieces in the torrent.
   G: Number of pieces currently available from you and your connected
   peers.
   H: Total amount of data you have downloaded.
   I: Total amount of data you have uploaded.
   J: Your current total download rate.
   K: Your current total upload rate.
   L: Amount of data downloaded since the last status line update.
   M: Amount of data uploaded since the last status line update.
   N: Number of tracker connection errors.
   O: Number of successful tracker connections.

  Peer ID

   Beginning with dnh1.1 the default peer ID has been changed for
   convenience, as some other clients and trackers assume that Ctorrent
   is "buggy" and won't cooperate with it. [Guess what, there are plenty
   of others with bugs too.] The -P option is still available if you wish
   to use a different peer ID, but it is no longer necessary to do so in
   order to avoid this "ban".

   The new default peer ID prefix is "-CDversion-", where version is an
   indication of the version number (0101 for dnh1.1).

  CTCS

   [11]CTorrent Control Server (CTCS) is an interface for monitoring and
   managing Enhanced CTorrent clients. It can manage allocation of
   bandwidth, provide status information, and allow changes to the
   running configuration of each client. Support for this interface was
   added in the dnh2 release.
     _________________________________________________________________

   News

   2006-09-03
          Version dnh2.1 is [12]released, along with [13]CTCS 1.1. Both
          updates fix issues when using CTCS on Linux, among other
          things.

   2006-04-26
          The [14]CTCS protocol is finally documented.

   2006-04-25
          A [15]patch is available to fix a bug in my solution for the
          vfat filesystem issue. This bug can cause the client to crash
          when creating a file on any filesystem type; the patch is
          recommended for all users.

   2006-01-15
          Version dnh2 is released! This version includes a number of
          significant [16]changes, including large file support, piece
          selection, tuned request queue depth, and support for
          [17]CTorrent Control Server.
     _________________________________________________________________

   Changes

   For a list of changes in the current and previous versions, see the
   [18]ChangeLog file.
     _________________________________________________________________

   Download

   Release dnh2.1

   [19]dnh2 to dnh2.1 patch file
   A patch file of changes to release dnh2 to bring it up to dnh2.1.

   [20]Source distribution
   A complete source distribution for all platforms.
                    ___________________________________

   Patch for vfat bug

   [21]btfiles patch
   This fixes a coding bug in my solution for the vfat filesystem issue.
   This bug can cause the client to crash when creating a file on any
   filesystem type; the patch is recommended for all users of release
   dnh2.

   To apply the patch, download the file into the ctorrent source
   directory and run the command:
     patch < patch-btfiles.cpp.diff

   in that directory. Then recompile the program.
                    ___________________________________

   Release dnh2
   The patch files for this version are significantly larger than in
   previous releases. It will be faster and easier to just download the
   patched source distribution below.

   [22]dnh1.2 to dnh2 patch file
   A patch file of changes to release dnh1.2 to bring it up to dnh2.

   [23]Patch file
   A patch file of changes to the CTorrent 1.3.4 base.

   [24]Patched source
   A complete source distribution for all platforms.
                    ___________________________________

   Release dnh1.2
   Note: If you get a message about needing to install OpenSSL, you might
   want to try the FreeBSD patch/version even if you are not using
   FreeBSD.

   [25]dnh1.1 to dnh1.2 patch file
   A patch file of changes to release dnh1.1 to bring it up to dnh1.2.

   [26]FreeBSD patch file
   A patch file of changes to the CTorrent 1.3.4 base, including the
   patches from the FreeBSD ports tree.

   [27]Patch file
   A patch file of changes to the CTorrent 1.3.4 base.

   [28]FreeBSD patched source
   This includes the patches from the FreeBSD ports tree.

   [29]Linux/Windows/Other patched source
   Please [30]let me know if you encounter any portability issues, as I
   don't have a test environment set up for these platforms.
                    ___________________________________

   Bitfield::Invert patch

   [31]Bitfield::Invert patch
   See notes in the change log; this is needed if you are using dnh1.1,
   dnh1, or ctorrent-1.3.4.
                    ___________________________________

   Release dnh1.1

   [32]dnh1 to dnh1.1 patch file
   A patch file of changes to release dnh1 to bring it up to dnh1.1.
                    ___________________________________

   Release dnh1

   [33]FreeBSD patch file
   A patch file of changes to the CTorrent 1.3.4 base, including the
   patches from the FreeBSD ports tree.
   Note: Thanks to Florent Thoumie, as of 29 Jul 2005 this patchset is
   included in the FreeBSD port. If you update your ports tree (or at
   least net/ctorrent) and install from there, you will have these
   updates without downloading the file and patching manually.

   [34]Patch file
   A patch file of changes to the CTorrent 1.3.4 base.

   [35]FreeBSD patched source
   This includes the patches from the FreeBSD ports tree.

   [36]Linux/Windows/Other patched source
   Please [37]let me know if you encounter any portability issues, as I
   don't have a test environment set up for these platforms.
     _________________________________________________________________

   Resources

   [38]CTorrent Home Page 
   Outdated, but you may find some useful info (particularly the FAQ).

   [39]CTorrent SourceForge Project 
   Hosts the original CTorrent codebase, bug reports, patches, and forum.

   [40]Custom CTorrent 
   A page by the author of the "get1file" patch and other fixes. It
   contains a custom version and a GUI for CTorrent.

   [41]BitTorrent 
   The official BitTorrent home page.

   [42]BitTorrent wiki 
   Various documentation.

   [43]BitTorrent protocol specification (official version)

   [44]BitTorrent protocol specification (wiki version)

References

   1. http://www.rahul.net/dholmes/ctorrent/index.html#info
   2. http://www.rahul.net/dholmes/ctorrent/index.html#news
   3. http://www.rahul.net/dholmes/ctorrent/changelog.html
   4. http://www.rahul.net/dholmes/ctorrent/ctcs.html
   5. http://www.rahul.net/dholmes/ctorrent/index.html#download
   6. http://www.rahul.net/dholmes/ctorrent/index.html#resources
   7. mailto:dholmes@ct.boxmail.com
   8. http://ctorrent.sourceforge.net/
   9. http://www.bittorrent.com/
  10. http://sourceforge.net/projects/ctorrent/
  11. http://www.rahul.net/dholmes/ctorrent/ctcs.html
  12. http://www.rahul.net/dholmes/ctorrent/index.html#download
  13. http://www.rahul.net/dholmes/ctorrent/ctcs.html
  14. http://www.rahul.net/dholmes/ctorrent/ctcs-protocol.html
  15. http://www.rahul.net/dholmes/ctorrent/index.html#download
  16. http://www.rahul.net/dholmes/ctorrent/changelog.html
  17. http://www.rahul.net/dholmes/ctorrent/ctcs.html
  18. http://www.rahul.net/dholmes/ctorrent/changelog.html
  19. http://www.rahul.net/dholmes/ctorrent/patchset-ctorrent-dnh2-dnh2.1.diff
  20. http://www.rahul.net/dholmes/ctorrent/ctorrent-1.3.4-dnh2.1.tar.gz
  21. http://www.rahul.net/dholmes/ctorrent/patch-btfiles.cpp.diff
  22. http://www.rahul.net/dholmes/ctorrent/patchset-ctorrent-dnh1.2-dnh2.diff
  23. http://www.rahul.net/dholmes/ctorrent/patchset-ctorrent-1.3.4-dnh2.diff
  24. http://www.rahul.net/dholmes/ctorrent/ctorrent-1.3.4-dnh2.tar.gz
  25. http://www.rahul.net/dholmes/ctorrent/patchset-ctorrent-dnh1.1-dnh1.2.diff
  26. http://www.rahul.net/dholmes/ctorrent/patchset-ctorrent-1.3.4-dnh1.2-fbsd.diff
  27. http://www.rahul.net/dholmes/ctorrent/patchset-ctorrent-1.3.4-dnh1.2.diff
  28. http://www.rahul.net/dholmes/ctorrent/ctorrent-1.3.4-dnh1.2-fbsd.tar.gz
  29. http://www.rahul.net/dholmes/ctorrent/ctorrent-1.3.4-dnh1.2.tar.gz
  30. mailto:dholmes@ct.boxmail.com
  31. http://www.rahul.net/dholmes/ctorrent/patch-invert.diff
  32. http://www.rahul.net/dholmes/ctorrent/patchset-ctorrent-dnh1-dnh1.1.diff
  33. http://www.rahul.net/dholmes/ctorrent/patchset-ctorrent-1.3.4-dnh1-fbsd.diff
  34. http://www.rahul.net/dholmes/ctorrent/patchset-ctorrent-1.3.4-dnh1.diff
  35. http://www.rahul.net/dholmes/ctorrent/ctorrent-1.3.4-dnh1-fbsd.tar.gz
  36. http://www.rahul.net/dholmes/ctorrent/ctorrent-1.3.4-dnh1.tar.gz
  37. mailto:dholmes@ct.boxmail.com
  38. http://ctorrent.sourceforge.net/
  39. http://sourceforge.net/projects/ctorrent/
  40. http://customctorrent.ifreepages.com/
  41. http://bittorrent.com/
  42. http://wiki.theory.org/CategoryBitTorrent
  43. http://www.bittorrent.com/protocol.html
  44. http://wiki.theory.org/BitTorrentSpecification
