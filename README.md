## RsyncOSX

The repository is source code for the macOS application RsyncOSX. The application is implemented in Swift 3.x by using Xcode version 8.x. The application is not depended upon any third party binary distributions. There is, however, a third party source code included to check for TCP connections. The check is for informal use only and can be removed. All other code is stock use of Swift 3.x and libraries as part of Xcode version 8.x. 

### Compile

To compile the code, install Xcode, open the RsyncOSX project file and compile. Before compiling open in Xcode the `RsyncOSX/General`preference page and replace whatever is needed in `Signing`. Or disable Signing.

### Documents about RsyncOSX

There are some [documents](https://rsyncosx.github.io/Documentation/) about RsyncOSX and a short [YouTube demo](https://www.youtube.com/watch?v=ty1r7yvgExo) (about 5 minutes long) : "Downloading RsyncOSX, installing, first time configuration and using RsyncOSX for the first time. Backup (as demo) of about 120 MB of data and 4000 files to a VirtualBox FreeBSD machine."

Please use the [issues page](https://github.com/rsyncOSX/Version3.x/issues) for bugs and requests for new features.

### The code

The code is **not** example of neither writing decent Swift code, OO-development or applying the MVC-pattern. It is a personal project to learn Swift and I am learning every day. I belive coding is an art and to be really good at coding requires years of experience. My experience of coding is far from that. I am happy to share the code with anyone. Sharing of code is in my opinion the best way to get quality.

The code has been refactored couple of times. The latest release of RsyncOSX is quite stable. But there are parts of code which might should be refactored.

### Changelog

The [Changelog](https://github.com/rsyncOSX/Documentation/blob/master/Docs/Changelog.md).
