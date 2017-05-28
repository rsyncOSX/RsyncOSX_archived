## RsyncOSX

The repository is source code for the macOS application RsyncOSX. The application is implemented by Swift 3.x by using Xcode version 8.x. The application is **not** depended upon any third party binary distributions. There is, however, only one third party source code included to check for TCP connections. The check is for informal use only and can be removed. All other code is stock use of Swift 3.x and libraries as part of Xcode version 8.x.

### Compile

To compile the code, install Xcode and open the RsyncOSX project file. Before compiling, open in Xcode, the `RsyncOSX/General` preference page (after opening the RsyncOSX project file) and replace your own credentials in `Signing`, or just disable Signing. Then compile your own version of RsyncOSX.

### Application icon

From version 4.0.0 there is a new application icon for RsyncOSX. The new icon is created by [Forrest Walter](http://www.forrestwalter.com/).

### Changelog

The [Changelog](https://github.com/rsyncOSX/Documentation/blob/master/docs/Changelog.md).

## The code

The code is **not** example of neither writing _decent Swift code_, _OO-development_ or _applying the MVC-pattern_. It all started as a project to learn the _basics_ about Swift and Xcode. And I am still learning, every day.

**May 2017**: What is my experience after about a year into my Swift project? Writing code is fun and addicting. But I experience that parts of the code I am writing is a kind of "brute force". From time to time I am reading blogs and other resources about coding in Swift. Some ideas I do pick up, some I don´t understand and others again are like this is how I should have done it. And I am a kind of OK with that. I am not a professional programmer. The project is for fun only.

But, I will continue to refactor code whenever I have got some ideas reading other code. I will continue adding minor enhancements to RsyncOSX (at least for some time). And I use RsyncOSX every day myself.

### Rsync

The default version of `rsync` in macOS is old (version 2.6.9, [protocol](https://rsync.samba.org/how-rsync-works.html) version 29). Version [2.6.9](https://download.samba.org/pub/rsync/src/rsync-2.6.9-NEWS) was released in nov 2006. The current release of rsync is version [3.1.2](https://download.samba.org/pub/rsync/src/rsync-3.1.2-NEWS) protocol 31 released 21 Dec 2015. There are at least two options to get and install the current version of rsync for use in RsyncOSX:

- install Xcode and download the rsync [source](https://rsync.samba.org/) from rsync.samba.org
	- required tools are `gcc` and `make` which are part of Xcode command line tool (you might be able to install Xcode command line tool only by downloading the tools from [Apple Developer page](https://developer.apple.com/))
	- untar the source archive and use `make` to compile and install, rsync compiles without any issues on macOS
- install [homebrew](https://en.wikipedia.org/wiki/Homebrew_(package_management_software)) and then install rsync as part of homebrew

In RsyncOSX select [RsyncOSX configuration](https://github.com/rsyncOSX/Documentation/blob/master/docs/UserConfiguration.md) and set path for optional version of rsync.

### MacUpdate

RsyncOSX is also released on [MacUpdate](https://www.macupdate.com/app/mac/56516/rsyncosx) as well. The application is downloaded about 8000 times from MacUpdate (all versions, April 2017). RsyncOSX does also inform users about new releases and link to download new version.

To be honest, I have **no idea** how many users of RsyncOSX there is.

### How to use RsyncOSX

There are some [documents](https://rsyncosx.github.io/Documentation/) about RsyncOSX and a short [YouTube demo](https://www.youtube.com/watch?v=ty1r7yvgExo) (about 5 minutes long) : "Downloading RsyncOSX, installing, first time configuration and using RsyncOSX for the first time. Backup (as demo) of about 120 MB of data and 4000 files to a VirtualBox FreeBSD machine."

### My NAS setup

I have setup up my own [NAS](https://github.com/rsyncOSX/Documentation/blob/master/docs/DIYNAS.md). My NAS SW is now FreeNAS Corral. I am doing backups by using RsyncOSX and sharing out disk by AFP and SMB.
