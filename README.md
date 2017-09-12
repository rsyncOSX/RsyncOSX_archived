## RsyncOSX

**Important** - this version is not compliant with Xcode 8 and Swift 3. The source code for Xcode 8 (version 4.4.6) is available for download as part of the release.

Version 4.6.0 is set as master in the RsyncOSX repository. The [4.5.1 branch](https://github.com/rsyncOSX/RsyncOSX/tree/version4.5.1) will be released before this version and will be compiled from the branch as soon as Xcode 9 is released.

### Version 4.6.0 - Xcode 9, Swift 4 and macOS High Sierra

**Important** - this version still needs more testing. Use branch [4.5.1 branch](https://github.com/rsyncOSX/RsyncOSX/tree/version4.5.1) to compile the released version of RsyncOSX.

This is the source code for the macOS application RsyncOSX. The application is implemented in **Swift 4** by using **Xcode version 9**. RsyncOSX is **not** depended upon any third party binary distributions. There is, however, one third party source code included to check for TCP connections. The check is for informal use only and can be removed. All other code is stock use of Swift 4 and libraries as part of Xcode version 9.

The major work for this release is to replace the singelton objects of RsyncOSX. Version 4.6.0 will be released after version 4.5.1, which is the Xcode 9 and Swift 4 first release. The replace of singelton objects is also a major refactor and therefore need some time to test this release.

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

What is my experience after about a year into my Swift project? Writing swift code is fun and addicting. But I experience from time to time some of the code I am writing is a kind of "brute force". I am reading blogs and other resources about coding in Swift. Some ideas I do pick up, some I don´t understand and others again are like this is how I should have done it. I'm not a professional or full-time programmer and it means I have to accept that the parts of the code in RsyncOSX could have been better and more efficient. The RsyncOSX project is for fun only.

I will continue to refactor code whenever I have got some ideas reading other code. I will continue adding minor enhancements to RsyncOSX (at least for some time). And I use RsyncOSX every day myself.

Details about how RsyncOSX is built [here](https://rsyncosx.github.io/Documentation/docs/source/source.html).

### Rsync

The default version of `rsync` in macOS is old (version 2.6.9, [protocol](https://rsync.samba.org/how-rsync-works.html) version 29). Version [2.6.9](https://download.samba.org/pub/rsync/src/rsync-2.6.9-NEWS) was released in nov 2006. The current release of rsync is version [3.1.2](https://download.samba.org/pub/rsync/src/rsync-3.1.2-NEWS) protocol 31 released 21 Dec 2015. There are at least two options to get and install the current version of rsync for use in RsyncOSX:

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
