## RsyncOSX

**Important** - this version is **not** compliant with Xcode 8 and Swift 3.

This repository is the source code for the macOS app RsyncOSX. RsyncOSX is compiled with support for macOS version 10.11 - 10.13. The application is implemented in **Swift 4** by using **Xcode 9**. RsyncOSX is *not* depended upon any third party binary distributions. There is, however, one third party source code included to check for TCP connections. The check is for informal use only and can be removed.

RsyncOSX is released in version 4.7.5. The major work (refactor) for this version was to remove the singelton objects. And some minor enhancements and bug fixes as well.

#### SwiftLint

As part of this version of RsyncOSX I am using [SwiftLint](https://github.com/realm/SwiftLint) as tool for writing more readable code. Adapting RsyncOSX to SwiftLint rules will take some time. There are about 10,000 lines of code in RsyncOSX (too many?). Many changes in code has been applied, but there are still some more to do before RsyncOSX is more compliant to SwiftLint rules.

### Compile

To compile the code, install Xcode and open the RsyncOSX project file. Before compiling, open in Xcode the `RsyncOSX/General` preference page (after opening the RsyncOSX project file) and replace your own credentials in `Signing`, or disable Signing. Then compile your own version of RsyncOSX.

### Application icon

The application icon is created by [Forrest Walter](http://www.forrestwalter.com/). All rights reserved to Forrest Walter.

### Changelog

The [Changelog](https://github.com/rsyncOSX/Documentation/blob/master/docs/Changelog.md).

### How to use RsyncOSX

There are some [documents](https://rsyncosx.github.io/Documentation/) about RsyncOSX and a short [YouTube demo](https://www.youtube.com/watch?v=ty1r7yvgExo) (about 5 minutes long) : "Downloading RsyncOSX, installing, first time configuration and using RsyncOSX for the first time. Backup (as demo) of about 120 MB of data and 4000 files to a VirtualBox FreeBSD machine."

### Development

Details about how RsyncOSX is built is [here](https://rsyncosx.github.io/Documentation/docs/source/source.html).

### Rsync

In last release image (RsyncOSX.dmg) there is a `rsync-3.1.2.dmg` which includes a built version of latest version of rsync. To install this version of rsync please make a catalog on your mac (e.g. `/usr/local/bin`) and make RsyncOSX aware of using the new rsync in [userconfig](https://rsyncosx.github.io/Documentation/docs/UserConfiguration.html). A compiled version of rsync will be included in every coming release of RsyncOSX.

The default version of `rsync` in macOS is old (version 2.6.9, [protocol](https://rsync.samba.org/how-rsync-works.html) version 29). Version [2.6.9](https://download.samba.org/pub/rsync/src/rsync-2.6.9-NEWS) was released in nov 2006. The current release of rsync is version [3.1.2](https://download.samba.org/pub/rsync/src/rsync-3.1.2-NEWS) protocol 31 released 21 Dec 2015. There are at least three options to get and install the current version of rsync for use in RsyncOSX:

- use the `rsync-3.1.2.dmg` within `RsyncOSX.dmg`to install the latest version of rsync
- install Xcode and download the rsync [source](https://rsync.samba.org/) from rsync.samba.org
	- required tools are `gcc` and `make` which are part of Xcode command line tool (you might be able to install Xcode command line tool only by downloading the tools from [Apple Developer page](https://developer.apple.com/))
	- untar the source archive and use `make` to compile and install, rsync compiles without any issues on macOS
- install [homebrew](https://en.wikipedia.org/wiki/Homebrew_(package_management_software)) and then install rsync as part of homebrew

In RsyncOSX select [RsyncOSX configuration](https://github.com/rsyncOSX/Documentation/blob/master/docs/UserConfiguration.md) and set path for optional version of rsync.

### MacUpdate and Softpedia

RsyncOSX is also released on [MacUpdate](https://www.macupdate.com/app/mac/56516/rsyncosx) and linked for download on [Softpedia](http://mac.softpedia.com/get/Internet-Utilities/RsyncOSX.shtml) as well. The application is downloaded about 10,000 times from MacUpdate and 2650 times from Softpedia (all versions, Oct 2017).

To be honest, I have **no idea** how many users of RsyncOSX there are. And I am very happy that some users find it useful.

### My NAS setup

I have setup up my own [NAS](https://github.com/rsyncOSX/Documentation/blob/master/docs/DIYNAS.md). My NAS SW is now FreeNAS. I am doing backups by using RsyncOSX and sharing out disk by AFP and SMB.
