
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
     * Dynamic cache allocation and management, including prefetch
     * Flexible console I/O redirection
     * Interactive control commands and menus

  Documentation

   For documentation that provides a little more than the help screen,
   please see the [11]User's Guide.

   For a list of changes in the current and previous versions, see the
   [12]ChangeLog file.

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

   [13]CTorrent Control Server (CTCS) is an interface for monitoring and
   managing Enhanced CTorrent clients. It can manage allocation of
   bandwidth, provide status information, and allow changes to the
   running configuration of each client. Support for this interface was
   added in the dnh2 release.
     _________________________________________________________________

   News

   2007-04-11
          Version dnh3 is [14]released. There are several significant new
          features; release notes can be found in the [15]change log. If
          you're using [16]CTCS, you should also upgrade it to version
          1.3 so that bandwidth management will work correctly.

   2007-02-25
          A [17]patch is available to fix a bug that can cause a crash
          when reassigning a piece for download.

   2006-11-05
          Version dnh2.2 is [18]released, mostly for bug fixes. Thanks to
          those who have reported them and helped with debugging!
          A simple [19]user's guide is also available.

   2006-09-03
          Version dnh2.1 is [20]released, along with [21]CTCS 1.1. Both
          updates fix issues when using CTCS on Linux, among other
          things.

   2006-04-26
          The [22]CTCS protocol is finally documented.

   2006-04-25
          A [23]patch is available to fix a bug in my solution for the
          vfat filesystem issue. This bug can cause the client to crash
          when creating a file on any filesystem type; the patch is
          recommended for all users.

   2006-01-15
          Version dnh2 is released! This version includes a number of
          significant [24]changes, including large file support, piece
          selection, tuned request queue depth, and support for
          [25]CTorrent Control Server.
     _________________________________________________________________

   Download Newer files appear first in the list. Note that patches are
   generally intended for the version below (older than) the patch.
                    ___________________________________

   Release dnh3

   [26]Source distribution
   A complete source distribution for all platforms.
                    ___________________________________

   Patch for reassign bug

   [27]reassign patch
   This fixes a potential crash when reassigning a piece for download to
   a faster peer. It likely only shows itself on memory-constrained
   systems or particular OSs. With verbose output on, you would see
   something like this:
     Reassigning 0x81183b8 to 0x8160ef8 (#585)
     Segmentation fault

   To apply the patch, download the file into the ctorrent source
   directory and run the command:
     patch < patch-reassign.diff

   in that directory. Then recompile the program.
                    ___________________________________

   Release dnh2.2

   [28]dnh2.1 to dnh2.2 patch file
   A patch file of changes to release dnh2.1 to bring it up to dnh2.2.

   [29]Source distribution
   A complete source distribution for all platforms.
                    ___________________________________

   Release dnh2.1

   [30]dnh2 to dnh2.1 patch file
   A patch file of changes to release dnh2 to bring it up to dnh2.1.

   [31]Source distribution
   A complete source distribution for all platforms.
                    ___________________________________

   Patch for vfat bug

   [32]btfiles patch
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

   [33]dnh1.2 to dnh2 patch file
   A patch file of changes to release dnh1.2 to bring it up to dnh2.

   [34]Patch file
   A patch file of changes to the CTorrent 1.3.4 base.

   [35]Patched source
   A complete source distribution for all platforms.
                    ___________________________________

   Older Versions
   Please see the [36]Old Versions page for previous releases and
   patches.
     _________________________________________________________________

   Resources

   [37]CTorrent Home Page 
   Outdated, but you may find some useful info (particularly the FAQ).

   [38]CTorrent SourceForge Project 
   Hosts the original CTorrent codebase, bug reports, patches, and forum.

   [39]Custom CTorrent 
   A page by the author of the "get1file" patch and other fixes. It
   contains a custom version and a GUI for CTorrent.

   [40]BitTorrent 
   The official BitTorrent home page.

   [41]BitTorrent wiki 
   Various documentation.

   [42]BitTorrent protocol specification (official version)

   [43]BitTorrent protocol specification (wiki version)

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
  11. http://www.rahul.net/dholmes/ctorrent/userguide.html
  12. http://www.rahul.net/dholmes/ctorrent/changelog.html
  13. http://www.rahul.net/dholmes/ctorrent/ctcs.html
  14. http://www.rahul.net/dholmes/ctorrent/index.html#download
  15. http://www.rahul.net/dholmes/ctorrent/changelog.html
  16. http://www.rahul.net/dholmes/ctorrent/ctcs.html
  17. http://www.rahul.net/dholmes/ctorrent/index.html#download
  18. http://www.rahul.net/dholmes/ctorrent/index.html#download
  19. http://www.rahul.net/dholmes/ctorrent/userguide.html
  20. http://www.rahul.net/dholmes/ctorrent/index.html#download
  21. http://www.rahul.net/dholmes/ctorrent/ctcs.html
  22. http://www.rahul.net/dholmes/ctorrent/ctcs-protocol.html
  23. http://www.rahul.net/dholmes/ctorrent/index.html#download
  24. http://www.rahul.net/dholmes/ctorrent/changelog.html
  25. http://www.rahul.net/dholmes/ctorrent/ctcs.html
  26. http://www.rahul.net/dholmes/ctorrent/ctorrent-1.3.4-dnh3.tar.gz
  27. http://www.rahul.net/dholmes/ctorrent/patch-reassign.diff
  28. http://www.rahul.net/dholmes/ctorrent/patchset-ctorrent-dnh2.1-dnh2.2.diff
  29. http://www.rahul.net/dholmes/ctorrent/ctorrent-1.3.4-dnh2.2.tar.gz
  30. http://www.rahul.net/dholmes/ctorrent/patchset-ctorrent-dnh2-dnh2.1.diff
  31. http://www.rahul.net/dholmes/ctorrent/ctorrent-1.3.4-dnh2.1.tar.gz
  32. http://www.rahul.net/dholmes/ctorrent/patch-btfiles.cpp.diff
  33. http://www.rahul.net/dholmes/ctorrent/patchset-ctorrent-dnh1.2-dnh2.diff
  34. http://www.rahul.net/dholmes/ctorrent/patchset-ctorrent-1.3.4-dnh2.diff
  35. http://www.rahul.net/dholmes/ctorrent/ctorrent-1.3.4-dnh2.tar.gz
  36. http://www.rahul.net/dholmes/ctorrent/oldversion.html
  37. http://ctorrent.sourceforge.net/
  38. http://sourceforge.net/projects/ctorrent/
  39. http://customctorrent.ifreepages.com/
  40. http://bittorrent.com/
  41. http://wiki.theory.org/CategoryBitTorrent
  42. http://www.bittorrent.org/protocol.html
  43. http://wiki.theory.org/BitTorrentSpecification
