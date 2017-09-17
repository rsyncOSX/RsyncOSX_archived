## RsyncOSX

**Important** - this version is **not** compliant with Xcode 8 and Swift 3.

This is source for version 4.6.5 of RsyncOSX. RsyncOSX is compiled with support for macOS 10.11 - macOS 10.13 by using Xcode 9 and Swift 4.

This version also require some more testing. Use code in [release 4.5.1](https://github.com/rsyncOSX/RsyncOSX/releases) to compile the released version of RsyncOSX.

### Version 4.6.5

This is the source code for the macOS application RsyncOSX. The application is implemented in **Swift 4** by using **Xcode 9**. RsyncOSX is *not* depended upon any third party binary distributions. There is, however, one third party source code included to check for TCP connections. The check is for informal use only and can be removed.

The major work for release [4.6.0](https://github.com/rsyncOSX/RsyncOSX/tree/version4.6.0) is to replace the singelton objects in previous versions of RsyncOSX. Version 4.6.0 will be released some time after version [4.5.1](https://github.com/rsyncOSX/RsyncOSX/releases), which is the first release built by Xcode 9. The refactor is also a major change in code and therefore need some time for testing.

#### SwiftLint

As part of this version of RsyncOSX I am using [SwiftLint](https://github.com/realm/SwiftLint) as tool for writing more readable code. Adapting RsyncOSX to SwiftLint rules will take some time. There are about 11,000 lines of code in RsyncOSX (too many?). Many changes in code has been applied, but there are still some more to do before RsyncOSX is more compliant to SwiftLint rules.

### Compile

To compile the code, install Xcode and open the RsyncOSX project file. Before compiling, open in Xcode, the `RsyncOSX/General` preference page (after opening the RsyncOSX project file) and replace your own credentials in `Signing`, or just disable Signing. Then compile your own version of RsyncOSX.

### Application icon

The application icon is created by [Forrest Walter](http://www.forrestwalter.com/). All rights reserved to Forrest Walter.

### Changelog

The [Changelog](https://github.com/rsyncOSX/Documentation/blob/master/docs/Changelog.md).

### How to use RsyncOSX

There are some [documents](https://rsyncosx.github.io/Documentation/) about RsyncOSX and a short [YouTube demo](https://www.youtube.com/watch?v=ty1r7yvgExo) (about 5 minutes long) : "Downloading RsyncOSX, installing, first time configuration and using RsyncOSX for the first time. Backup (as demo) of about 120 MB of data and 4000 files to a VirtualBox FreeBSD machine."

### Development

Details about how RsyncOSX is built is [here](https://rsyncosx.github.io/Documentation/docs/source/source.html).

### Rsync

In last updated release candidate image (RsyncOSX.dmg) there is a rsync-3.1.2.dmg which includes a built version of latest version of rsync. To install this version of rsync please make a catalog in your home directory (or use /usr/local/bin) and make RsyncOSX aware of using the new rsync in [userconfig](https://rsyncosx.github.io/Documentation/docs/UserConfiguration.html). A compiled version of rsync will be included in every coming release of RsyncOSX.

The default version of `rsync` in macOS is old (version 2.6.9, [protocol](https://rsync.samba.org/how-rsync-works.html) version 29). Version [2.6.9](https://download.samba.org/pub/rsync/src/rsync-2.6.9-NEWS) was released in nov 2006. The current release of rsync is version [3.1.2](https://download.samba.org/pub/rsync/src/rsync-3.1.2-NEWS) protocol 31 released 21 Dec 2015. There are at least three options to get and install the current version of rsync for use in RsyncOSX:

- use the `rsync-3.1.2.dmg` within `RsyncOSX.dmg`to install the latest version of rsync
- install Xcode and download the rsync [source](https://rsync.samba.org/) from rsync.samba.org
	- required tools are `gcc` and `make` which are part of Xcode command line tool (you might be able to install Xcode command line tool only by downloading the tools from [Apple Developer page](https://developer.apple.com/))
	- untar the source archive and use `make` to compile and install, rsync compiles without any issues on macOS
- install [homebrew](https://en.wikipedia.org/wiki/Homebrew_(package_management_software)) and then install rsync as part of homebrew

In RsyncOSX select [RsyncOSX configuration](https://github.com/rsyncOSX/Documentation/blob/master/docs/UserConfiguration.md) and set path for optional version of rsync.

### MacUpdate and Softpedia

RsyncOSX is also released on [MacUpdate](https://www.macupdate.com/app/mac/56516/rsyncosx) and linked for download on [Softpedia](http://mac.softpedia.com/get/Internet-Utilities/RsyncOSX.shtml) as well. The application is downloaded about 9300 times from MacUpdate and 2400 times from Softpedia (all versions, July 2017). RsyncOSX does also inform users about new releases and link to download new version.

To be honest, I have **no idea** how many users of RsyncOSX there are. And I am very happy that some users find it useful.

### My NAS setup

I have setup up my own [NAS](https://github.com/rsyncOSX/Documentation/blob/master/docs/DIYNAS.md). My NAS SW is now FreeNAS. I am doing backups by using RsyncOSX and sharing out disk by AFP and SMB.
