## RsyncOSX

![](icon/rsyncosx.png)

[Please read the Changelog](https://rsyncosx.github.io/Changelog). If you want to discuss changes or report bugs please create an [Issue](https://github.com/rsyncOSX/RsyncOSX/issues).

**Important:** read about the --delete parameter (see below) to rsync **before** using rsync and RsyncOSX.

A short [intro to RsyncOSX](https://rsyncosx.github.io/Intro) and full [documentation of RsyncOSX](https://rsyncosx.github.io/AboutRsyncOSX).

RsyncOSX is a GUI on top of the command line utility `rsync`. Rsync is a file-based synchronization and backup tool. There is no custom solution for the backup archive. You can quit utilizing RsyncOSX (and rsync) at any time and still have access to all synchronized files.

RsyncOSX is compiled with support for macOS El Capitan version 10.11 - macOS Catalina version 10.15. The application is implemented in Swift 5 by using Xcode 11. RsyncOSX is not depended upon any third party binary distributions. There is, however, [one third party source code](https://github.com/swiftsocket/SwiftSocket) included to check for TCP connections.

Scheduled tasks are added and deleted within RsyncOSX. Executing the scheduled tasks is by the [menu app](https://github.com/rsyncOSX/RsyncOSXsched).

RsyncOSX is dependent on [setting up password less logins for remote servers](https://rsyncosx.github.io/Remotelogins). Both ssh-keys and rsync daemon setup are enabled. It is advised utilizing ssh-keys.

### Signing and notarizing

The app is signed with my Apple ID developer certificate and [notarized](https://support.apple.com/en-us/HT202491) by Apple. See [signing and notarizing](https://rsyncosx.github.io/Notarized) for info.

**Important**: from macOS 10.15 Catalina, notarization is required by default for all software. RsyncOSX is signed and notarized and a new signed and notarized release will be available shortly after release of macOS 10.15.

### Localization

[RsyncOSX speaks new languages](https://rsyncosx.github.io/Localization). RsyncOSX is localized to:
- Chinese (Simplified) -  by [StringKe](https://github.com/StringKe)
- Norwegian - by me
- English - the base language of RsyncOSX

RsyncOSX is prepared for new languages. Translating RsyncOSX is done by utilizing the [Xlifftool](https://github.com/remuslazar/osx-xliff-tool). The tool reads a xliff file, which I prepare, for translating. The xliff file is imported into RsyncOSX by Xcode.

### Version of rsync

RsyncOSX is only verified with rsync versions 2.6.9, 3.1.2 and 3.1.3. Other versions of rsync will work but numbers about transferred files is not set in logs. It is recommended to [install](https://rsyncosx.github.io/Install) the latest version of rsync.

### The --delete parameter

```
Caution about RsyncOSX and the `--delete` parameter. The `--delete` is a default parameter.
The parameter instructs rsync to keep the source and destination synchronized (equal).
The parameter instructs rsync to delete all files in the destination which are not present
in the source.

Every time you add a new task to RsyncOSX, execute an estimation run (--dry-run parameter)
and inspect the result before executing a real run. If you by accident  set an empty catalog as
source RsyncOSX will delete all files in the destination.

To save deleted and changes files either utilize snapshots (https://rsyncosx.github.io/Snapshots)
or the `--backup` feature (https://rsyncosx.github.io/Parameters).

The --delete parameter and other default parameters might be deleted if wanted.
```

### Main view

The main view of RsyncOSX.
![](images/main1.png)
Prepare for synchronizing tasks.
![](images/main2.png)

### A Sandboxed version

[There is also released a minor version, RsyncGUI](https://itunes.apple.com/us/app/rsyncgui/id1449707783?l=nb&ls=1&mt=12) of RsyncOSX on Apple Mac App Store. See the [changelog](https://rsyncosx.github.io/RsyncGUIChangelog). RsyncGUI utilizes stock version of rsync in macOS and RsyncGUI only supports synchronize task (no snapshots).

### About bugs and crash?

What happens [if bugs occurs during execution of tasks in RsyncOSX?](https://rsyncosx.github.io/Bugs). Fighting bugs are difficult. I am not able to test RsyncOSX for all possible user interactions and use. From time to time I discover new bugs. But I also need support from other users discovering bugs or not expected results. If you discover a bug please use the [issues](https://github.com/rsyncOSX/RsyncOSX/issues) and report it.

### About restoring files to a temporary restore catalog

If you do a **restore** from the `remote` to the `source`, some files in the source might be deleted. This is due to how rsync works in `synchronize` mode. As a precaution **never** do a restore directly from the `remote` to the `source`, always do a restore to a temporary restore catalog.

### Application icon

The application icon is created by [Zsolt Sándor](https://github.com/graphis). All rights reserved to Zsolt Sándor.

### How to use RsyncOSX - YouTube videos

There are four short YouTube videos of RsyncOSX:

- [getting](https://youtu.be/MrT8NzdF9dE) RsyncOSX and installing it
  - the video also shows how to create the two local ssh certificates for password less logins to remote server
- adding and executing the [first backup](https://youtu.be/8oe1lKgiDx8)
- doing a full [restore](https://youtu.be/-R6n_8fl6Ls) to a temporary local restore catalogs
- how to change [version of rsync](https://youtu.be/mVFL25-lo6Y) utilized by RsyncOSX

#### SwiftLint

As part of this version of RsyncOSX I am using [SwiftLint](https://github.com/realm/SwiftLint) as tool for writing more readable code. There are about 120 classes with 15,000 lines of code in RsyncOSX. I am also using Paul Taykalo´s [swift-scripts](https://github.com/PaulTaykalo/swift-scripts) to find and delete not used code.

### Compile

To compile the code, install Xcode and open the RsyncOSX project file. Before compiling, open in Xcode the `RsyncOSX/General` preference page and replace with your own credentials in `Signing`, or disable Signing.

There are two ways to compile, either utilize `make` or compile by Xcode. `make release` will compile the `RsyncOSX.app` and `make dmg` will make a dmg file to be released.  The build of dmg files are by utilizing [andreyvit](https://github.com/andreyvit/create-dmg) script for creating dmg and [syncthing-macos](https://github.com/syncthing/syncthing-macos) setup.

#### XCTest

XCTest configurations are in [development](https://github.com/rsyncOSX/RsyncOSX/blob/master/XCTestconfiguration/XCTest.md).
