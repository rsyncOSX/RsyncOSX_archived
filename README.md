## RsyncOSX

The repository is source code for the macOS application RsyncOSX. The application is implemented by Swift 3.x by using Xcode version 8.x. The application is **not** depended upon any third party binary distributions. There is, however, only one third party source code included to check for TCP connections. The check is for informal use only and can be removed. All other code is stock use of Swift 3.x and libraries as part of Xcode version 8.x. 

### MacUpdate

RsyncOSX is also released on [MacUpdate](https://www.macupdate.com/app/mac/56516/rsyncosx) as well. The application is downloaded about 6,800 times from MacUpdate (all versions, January 2017). There is also a [Google Blog](https://rsyncosx.blogspot.no/) about RsyncOSX. Many users download RsyncOSX from the blog. RsyncOSX does also  inform users about new releases and link to download new version. 

To be honest, I have **no idea** how many users of RsyncOSX there is. 


### Rsync

The default version of `rsync` in macOS is old (version 2.6.9, [protocol](https://rsync.samba.org/how-rsync-works.html) version 29). Version [2.6.9](https://download.samba.org/pub/rsync/src/rsync-2.6.9-NEWS) was released in nov 2006. The current release of rsync is version [3.1.2](https://download.samba.org/pub/rsync/src/rsync-3.1.2-NEWS) protocol 31 released 21 Dec 2015. There are at least two options to get and install the current version of rsync for use in RsyncOSX:

- install Xcode and download the rsync [source](https://rsync.samba.org/) from rsync.samba.org
	- required tools are `gcc` and `make` which are part of Xcode command line tool (you might be able to install Xcode command line tool only by downloading the tools from [Apple Developer page](https://developer.apple.com/))
	- untar the source archive and use `make` to compile and install, rsync compiles without any issues on macOS
- install [homebrew](https://en.wikipedia.org/wiki/Homebrew_(package_management_software)) and then install rsync as part of homebrew

In RsyncOSX select [RsyncOSX configuration](https://github.com/rsyncOSX/Documentation/blob/master/docs/UserConfiguration.md) and set path for optional version of rsync.


### Compile

To compile the code, install Xcode and open the RsyncOSX project file. Before compiling, open in Xcode, the `RsyncOSX/General` preference page (after opening the RsyncOSX project file) and replace your own credentials in `Signing`, or just disable Signing. Then compile your own version of RsyncOSX.

## versionRsyncOSX

The file `versionRsyncOSX.plist` is checked (in a asynchron background que) by RsyncOSX at every startup. The file is hosted on Dropbox (for the moment) at URL `https://dl.dropboxusercontent.com/u/52503631/versionRsyncOSX.plist?raw=1`. The content of URL is `version number` and link to new `RsyncOSX.dmg` file. At startup RsyncOSX checks its version number compared to version numbers listed in URL. If there is a match between RsyncOSX version number and URL there is released a newer version of RsyncOSX.

### Graphics

I have uplodaded the [Gimp file](https://github.com/rsyncOSX/RsyncOSXicon) which is base for the RsyncOSX icon. [Help](https://github.com/rsyncOSX/RsyncOSXicon/issues/1) is wanted to create a better looking icon.

### Documents

There are some [documents](https://rsyncosx.github.io/Documentation/) about RsyncOSX and a short [YouTube demo](https://www.youtube.com/watch?v=ty1r7yvgExo) (about 5 minutes long) : "Downloading RsyncOSX, installing, first time configuration and using RsyncOSX for the first time. Backup (as demo) of about 120 MB of data and 4000 files to a VirtualBox FreeBSD machine."

Please use the [issues page](https://github.com/rsyncOSX/Version3.x/issues) for bugs and requests for new features.

### The code

The code is **not** example of neither writing decent Swift code, OO-development or applying the MVC-pattern. It is a personal project to learn Swift and I am learning every day. I belive coding is an art and to be really good at coding requires years of experience. My experience of coding is far from that. I am happy to share the code with anyone. Sharing of code is in my opinion the best way to get quality.

### Changelog

The [Changelog](https://github.com/rsyncOSX/Documentation/blob/master/docs/Changelog.md).
