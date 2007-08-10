
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

  Platform

   Enhanced CTorrent is intended to run on any Unix-like system,
   including FreeBSD, Linux, Mac OS X, Solaris, Cygwin, etc. If it
   doesn't build or run properly without modification on your system,
   please [11]send details.

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
   please see the [12]User's Guide.

   For a list of changes in the current and previous versions, see the
   [13]ChangeLog file.

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

   [14]CTorrent Control Server (CTCS) is an interface for monitoring and
   managing Enhanced CTorrent clients. It can manage allocation of
   bandwidth, provide status information, and allow changes to the
   running configuration of each client. Support for this interface was
   added in the dnh2 release.
     _________________________________________________________________

   News

   2007-07-23
          Version dnh3.2 is [15]released. This release includes a number
          of bug fixes and some optimizations; details are in the
          [16]change log.

   2007-06-13
          The timestamp on one of the autoconf files was incorrect, which
          may have caused build problems for some people. The dnh3.1
          release package has been updated to correct this.

   2007-06-10
          A possible crash when exiting the program has been corrected.
          The bug is essentially harmless except that you might have a
          core file created as a result. The dnh3.1 release package has
          been updated below to correct this.

   2007-06-05
          Version dnh3.1 is [17]released. There are several new features
          and bug fixes; details can be found in the [18]change log. If
          you're using [19]CTCS, you should also upgrade it to version
          1.4 in order to use new client configuration options.

   2007-05-23
          The dnh3-update patch has been updated to fix a potential
          crash, and a rate measurement issue on some devices.

   2007-04-27
          A couple more critical issues in release dnh3 have been found
          and fixed. To reduce any confusion or inconvenience in the
          tracking and application of patches, all such fixes will now be
          distributed in a single patch file that will be updated as
          necessary, while its name will not change. See the [20]Download
          section for more details.

   2007-04-18
          Two [21]patches are available for dnh3; one corrects a general
          problem and the other provides support for Mac OSX.

   2007-04-11
          Version dnh3 is [22]released. There are several significant new
          features; release notes can be found in the [23]change log. If
          you're using [24]CTCS, you should also upgrade it to version
          1.3 so that bandwidth management will work correctly.

   2007-02-25
          A [25]patch is available to fix a bug that can cause a crash
          when reassigning a piece for download.

   2006-11-05
          Version dnh2.2 is [26]released, mostly for bug fixes. Thanks to
          those who have reported them and helped with debugging!
          A simple [27]user's guide is also available.

   2006-09-03
          Version dnh2.1 is [28]released, along with [29]CTCS 1.1. Both
          updates fix issues when using CTCS on Linux, among other
          things.

   2006-04-26
          The [30]CTCS protocol is finally documented.

   2006-04-25
          A [31]patch is available to fix a bug in my solution for the
          vfat filesystem issue. This bug can cause the client to crash
          when creating a file on any filesystem type; the patch is
          recommended for all users.

   2006-01-15
          Version dnh2 is released! This version includes a number of
          significant [32]changes, including large file support, piece
          selection, tuned request queue depth, and support for
          [33]CTorrent Control Server.
     _________________________________________________________________

   Download

   Newer files appear first in the list. Note that patches are generally
   intended for the version below (older than) the patch.
                    ___________________________________

   Release dnh3.2

   [34]Source distribution
   A complete source distribution for all platforms.
                    ___________________________________

   Release dnh3.1

   [35]Source distribution
   A complete source distribution for all platforms.
                    ___________________________________

   Release dnh3 Update Patch

   [36]dnh3_update patch (23 May 2007)
   This patch provides critical updates to release dnh3. The patch file
   will be updated here as necessary if additional such issues are found.

   This patch file contains the following component patches (not all were
   previously posted individually):

   msg
          Fixes a potential crash recording or reporting the type of
          message received from a peer. This could happen on multiple
          message types but may be likeliest to happen upon download
          completion (becoming seed).

   bwrate
          A problem has been observed with bandwidth rate measurement on
          NSLU2 devices. This appears to be due to a compiler or platform
          bug of some sort, but the root cause is not yet known. As such,
          it's possible that it may affect builds for other ARM devices
          or builds that use the same versions of build tools. While the
          problem is cosmetic with respect to bandwidth limiting, it can
          affect client operation in other ways. This patch provides a
          permanent workaround for this particular issue, but note that
          similar types of calculations are used in other parts of the
          program that cannot be fixed in this manner.

   flush
          Fixes a problem flushing downloaded data to disk in certain
          situations. If you have downloaded any torrents with
          dnh3-release, please check them with the "-c" option to confirm
          that all of the data was saved!

   console
          This fixes my interpretation of the description of the stdarg
          facility, which is at best unclear in most documentation that I
          have checked. The problem could cause crashes or incorrect
          behavior in the new console code.

   clock_gettime
          This patch emulates the clock_gettime function (well enough for
          this program's needs) using gettimeofday if clock_gettime is
          not present in the system libraries. This is needed in order to
          compile on Mac OSX and can also be used on other systems that
          do not have this function. (You'll know because configure exits
          with an error.)

   maxfd
          This corrects initialization of the maxfd variable in the main
          loop; the bug can result in abnormally high CPU utilization.

   To apply the patch, download the file into the ctorrent source
   directory and run the command:
     patch < patch-dnh3_update.diff

   in that directory. Then re-run configure and make.
                    ___________________________________

   Release dnh3

   [37]Source distribution
   A complete source distribution for all platforms.
                    ___________________________________

   Patch for reassign bug

   [38]reassign patch
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

   [39]dnh2.1 to dnh2.2 patch file
   A patch file of changes to release dnh2.1 to bring it up to dnh2.2.

   [40]Source distribution
   A complete source distribution for all platforms.
                    ___________________________________

   Release dnh2.1

   [41]dnh2 to dnh2.1 patch file
   A patch file of changes to release dnh2 to bring it up to dnh2.1.

   [42]Source distribution
   A complete source distribution for all platforms.
                    ___________________________________

   Patch for vfat bug

   [43]btfiles patch
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

   [44]dnh1.2 to dnh2 patch file
   A patch file of changes to release dnh1.2 to bring it up to dnh2.

   [45]Patch file
   A patch file of changes to the CTorrent 1.3.4 base.

   [46]Patched source
   A complete source distribution for all platforms.
                    ___________________________________

   Older Versions
   Please see the [47]Old Versions page for previous releases and
   patches.
     _________________________________________________________________

   Resources

   [48]CTorrent Home Page 
   Outdated, but you may find some useful info (particularly the FAQ).

   [49]CTorrent SourceForge Project 
   Hosts the original CTorrent codebase, bug reports, patches, and forum.

   [50]Custom CTorrent 
   A page by the author of the "get1file" patch and other fixes. It
   contains a custom version and a GUI for CTorrent.

   [51]BitTorrent 
   The official BitTorrent home page.

   [52]BitTorrent wiki 
   Various documentation.

   [53]BitTorrent protocol specification (official version)

   [54]BitTorrent protocol specification (wiki version)

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
  11. mailto:dholmes@ct.boxmail.com
  12. http://www.rahul.net/dholmes/ctorrent/userguide.html
  13. http://www.rahul.net/dholmes/ctorrent/changelog.html
  14. http://www.rahul.net/dholmes/ctorrent/ctcs.html
  15. http://www.rahul.net/dholmes/ctorrent/index.html#download
  16. http://www.rahul.net/dholmes/ctorrent/changelog.html
  17. http://www.rahul.net/dholmes/ctorrent/index.html#download
  18. http://www.rahul.net/dholmes/ctorrent/changelog.html
  19. http://www.rahul.net/dholmes/ctorrent/ctcs.html
  20. http://www.rahul.net/dholmes/ctorrent/index.html#download
  21. http://www.rahul.net/dholmes/ctorrent/index.html#download
  22. http://www.rahul.net/dholmes/ctorrent/index.html#download
  23. http://www.rahul.net/dholmes/ctorrent/changelog.html
  24. http://www.rahul.net/dholmes/ctorrent/ctcs.html
  25. http://www.rahul.net/dholmes/ctorrent/index.html#download
  26. http://www.rahul.net/dholmes/ctorrent/index.html#download
  27. http://www.rahul.net/dholmes/ctorrent/userguide.html
  28. http://www.rahul.net/dholmes/ctorrent/index.html#download
  29. http://www.rahul.net/dholmes/ctorrent/ctcs.html
  30. http://www.rahul.net/dholmes/ctorrent/ctcs-protocol.html
  31. http://www.rahul.net/dholmes/ctorrent/index.html#download
  32. http://www.rahul.net/dholmes/ctorrent/changelog.html
  33. http://www.rahul.net/dholmes/ctorrent/ctcs.html
  34. http://www.rahul.net/dholmes/ctorrent/ctorrent-dnh3.2.tar.gz
  35. http://www.rahul.net/dholmes/ctorrent/ctorrent-dnh3.1.tar.gz
  36. http://www.rahul.net/dholmes/ctorrent/patch-dnh3_update.diff
  37. http://www.rahul.net/dholmes/ctorrent/ctorrent-1.3.4-dnh3.tar.gz
  38. http://www.rahul.net/dholmes/ctorrent/patch-reassign.diff
  39. http://www.rahul.net/dholmes/ctorrent/patchset-ctorrent-dnh2.1-dnh2.2.diff
  40. http://www.rahul.net/dholmes/ctorrent/ctorrent-1.3.4-dnh2.2.tar.gz
  41. http://www.rahul.net/dholmes/ctorrent/patchset-ctorrent-dnh2-dnh2.1.diff
  42. http://www.rahul.net/dholmes/ctorrent/ctorrent-1.3.4-dnh2.1.tar.gz
  43. http://www.rahul.net/dholmes/ctorrent/patch-btfiles.cpp.diff
  44. http://www.rahul.net/dholmes/ctorrent/patchset-ctorrent-dnh1.2-dnh2.diff
  45. http://www.rahul.net/dholmes/ctorrent/patchset-ctorrent-1.3.4-dnh2.diff
  46. http://www.rahul.net/dholmes/ctorrent/ctorrent-1.3.4-dnh2.tar.gz
  47. http://www.rahul.net/dholmes/ctorrent/oldversion.html
  48. http://ctorrent.sourceforge.net/
  49. http://sourceforge.net/projects/ctorrent/
  50. http://customctorrent.ifreepages.com/
  51. http://bittorrent.com/
  52. http://wiki.theory.org/CategoryBitTorrent
  53. http://www.bittorrent.org/protocol.html
  54. http://wiki.theory.org/BitTorrentSpecification
