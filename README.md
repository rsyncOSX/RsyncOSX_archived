## RsyncOSX

[![Join the chat at https://gitter.im/RsyncOSX/community](https://badges.gitter.im/RsyncOSX/community.svg)](https://gitter.im/RsyncOSX/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

![](icon/rsyncosx.png)

A short [intro to RsyncOSX](https://rsyncosx.github.io/Intro) and full [documentation of RsyncOSX](https://rsyncosx.github.io/AboutRsyncOSX).

RsyncOSX is a GUI on top of the command line utility `rsync`. Rsync is a file-based synchronization and backup tool. There is no custom solution for the backup archive. You can quit utilizing RsyncOSX (and rsync) at any time and still have access to all synchronized files.

RsyncOSX is compiled with support for macOS El Capitan version 10.11 - macOS Mojave version 10.14 (and macOS Catalina 10.15 when released). The application is implemented in Swift 5 by using Xcode 10. RsyncOSX is not depended upon any third party binary distributions. There is, however, one third party source code included to check for TCP connections. The check is for informal use only and can be removed.

Scheduled tasks are added and deleted within RsyncOSX. Executing the scheduled tasks is by the [menu app](https://github.com/rsyncOSX/RsyncOSXsched).

RsyncOSX is dependent on [setting up password less logins](https://rsyncosx.github.io/AboutRsyncOSX). Both ssh-keys and rsync daemon setup are enabled. It is advised utilizing ssh-keys.

### Signing and notarizing

The app is signed with my Apple ID developer certificate and [notarized](https://support.apple.com/en-us/HT202491) by Apple. See [signing and notarizing](https://rsyncosx.github.io/Notarized) for info.

**Important**: from macOS 10.15 Catalina, notarization is required by default for all software. RsyncOSX is signed and notarized and a new signed and notarized release will be available shortly after release of macOS 10.15.

### Changelog

The [Changelog](https://rsyncosx.github.io/Changelog).

### Localization

From version 5.8.6 RsyncOSX [speaks new languages](https://rsyncosx.github.io/Localization). RsyncOSX is localized to:
- Chinese (Simplified) -  by [StringKe](https://github.com/StringKe)
- Norwegian - by me
- English - the base language of RsyncOSX

RsyncOSX is prepared for new languages and volunteers for translating to other languages are wanted. Translating RsyncOSX is done by utilizing the [Xlifftool](https://github.com/remuslazar/osx-xliff-tool). The tool reads a xliff file, which I prepare, for translating. The xliff file is imported into RsyncOSX by Xcode.

### Version of rsync

RsyncOSX is only verified with rsync versions 2.6.9, 3.1.2 and 3.1.3. Other versions of rsync will work but numbers about transferred files is not set in logs. It is recommended to [install](https://rsyncosx.github.io/Install) the latest version of rsync.

### The --delete parameter

Caution about RsyncOSX and the `--delete` parameter. The `--delete` is a [default parameter](https://rsyncosx.github.io/RsyncParameters). The parameter instructs rsync to delete all files in the destination which are not present in the source. Every time you add a new task to RsyncOSX, execute an estimation run (`--dry-run` parameter) and inspect the result before executing a real run. If you by accident set an empty catalog as source RsyncOSX will delete all files in the destination. To save deleted and changes files either utilize [snapshots](https://rsyncosx.github.io/Snapshots) or the `--backup` [feature](https://rsyncosx.github.io/Parameters).

### Fighting bugs

Fighting bugs are difficult. I am not able to test RsyncOSX for all possible user interactions and use. From time to time I discover new bugs. But I also need support from other users discovering bugs or not expected results. If you discover a bug please use the [issues](https://github.com/rsyncOSX/RsyncOSX/issues) and report it.

### Main view

The main view of RsyncOSX.
![](images/main1.png)
Prepare for synchronizing tasks.
![](images/main2.png)

### About crash?

What happens if bugs occurs during execution of tasks in RsyncOSX? The command line tool `rsync` is designed to continue where rsync is by any reason, stopped or killed. Users can abort execution of tasks at any time. To continue an aborted task execute the task again and rsync will restart and complete the task. This is also true if a bug in RsyncOSX occurs during execution of a task.

If RsyncOSX does halt or crash during operation there is no damage to files or deletion of files in the `source`. The `source` is only read during `synchronize` and `snapshot` tasks.

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

As part of this version of RsyncOSX I am using [SwiftLint](https://github.com/realm/SwiftLint) as tool for writing more readable code. There are about 120 classes with 15,300 lines of code in RsyncOSX (probably too many?). I am also using Paul Taykalo´s [swift-scripts](https://github.com/PaulTaykalo/swift-scripts) to find and delete not used code.

### Compile

To compile the code, install Xcode and open the RsyncOSX project file. Before compiling, open in Xcode the `RsyncOSX/General` preference page (after opening the RsyncOSX project file) and replace your own credentials in `Signing`, or disable Signing.

There are two ways to compile, either utilize `make` or compile by Xcode. `make release` will compile the `RsyncOSX.app` and `make dmg` will make a dmg file to be released.  The build of dmg files are by utilizing [andreyvit](https://github.com/andreyvit/create-dmg) script for creating dmg and [syncthing-macos](https://github.com/syncthing/syncthing-macos) setup.

#### XCTest

XCTest configurations are in [development](https://github.com/rsyncOSX/RsyncOSX/blob/master/XCTestconfiguration/XCTest.md).
