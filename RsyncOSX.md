[![GitHub license](https://img.shields.io/github/license/rsyncOSX/RsyncOSX)](https://github.com/rsyncOSX/RsyncOSX/blob/master/Licence.MD) ![GitHub Releases](https://img.shields.io/github/downloads/rsyncosx/RsyncOSX/v6.6.0/total) ![GitHub Releases](https://img.shields.io/github/downloads/rsyncosx/RsyncOSX/v6.5.8/total) [![Crowdin](https://badges.crowdin.net/rsyncosx/localized.svg)](https://crowdin.com/project/rsyncosx) [![Netlify Status](https://api.netlify.com/api/v1/badges/d375f6d7-dc9f-4913-ab43-bfd46d172eb2/deploy-status)](https://app.netlify.com/sites/rsyncosx/deploys) [![GitHub issues](https://img.shields.io/github/issues/rsyncOSX/RsyncOSX)](https://github.com/rsyncOSX/RsyncOSX/issues)

**RsyncOSX version 6.5.8** is released for macOS Catalina 10.15 and later versions of macOS.

**RsyncOSX version 6.6.0** is released for **macOS Big Sur** only. The major work in this release is integrating Combine. Due to requirements of some features in Combine, version 6.6.0 is build for **macOS Big Sur** only. See [the Combine part](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX.md#Combine) in the readme for RsyncOSX.
[The work on a SwiftUI based version of RsyncOSX](https://rsyncui.netlify.app/) has commenced. The new app is called RsyncUI and will be released as a **new application** and not as an upgrade.

The RsyncOSX repository contains two branches, the branch `version 6.6.0-combine-json` is also updated to the main branch.

- branch `version 6.6.0-combine-json`
- branch `version 6.5.8`

The version 6.6.0 branch will only execute on macOS Big Sur. See the [Combine](#combine) part for more info. Branch version 6.5.8 require macOS Catalina 10.15 and later versions of macOS.

- [Install by Homebrew](#install-by-homebrew)
- [Documents, issues and changelog](#documents-issues-and-changelog)
- [Dependencies](#dependencies)
- [Tools used](#tools-used)
- [Scheduling](#scheduling)
- [Remote servers](#remote-servers)
- [Signing and notarizing](#signing-and-notarizing)
- [Localization](#localization)
- [Version of rsync](#version-of-rsync)
- [Some words about RsyncOSX](#some-words-about-rsyncosx)
- [The --delete parameter](#the---delete-parameter)
- [The source code and compile](#the-source-code-and-compile)
- [A Sandboxed version](#a-sandboxed-version)
- [About bugs](#about-bugs)
- [About restoring files to a temporary restore catalog](#about-restoring-files-to-a-temporary-restore-catalog)
- [Combine](#combine)
- [Application icon](#application-icon)

### Install by Homebrew

RsyncOSX can also be installed by Homebrew: `brew install --cask rsyncosx`

### Documents, issues and changelog

RsyncOSX is a GUI on top of the command line utility `rsync`. Rsync is a file-based synchronization and backup tool. There is no custom solution for the backup archive. You can quit utilizing RsyncOSX (and rsync) at any time and still have access to all synchronized files. RsyncOSX is compiled with support for **macOS Catalina 10.15 and later versions**.

- [info and guidelines about using RsyncOSX](https://rsyncosx.netlify.app/)
- [the changelog](https://rsyncosx.netlify.app/post/changelog/)

The above docs are based on [Hugo](https://gohugo.io/), the Hugo theme [Even](https://github.com/olOwOlo/hugo-theme-even), Markdown and published on [Netlify](https://rsyncosx.netlify.app/). If you want to discuss changes or report bugs please [create an issue](https://github.com/rsyncOSX/RsyncOSX/issues).

### Dependencies

The application is implemented in pure Swift, ViewControllers and Storyboard(Cocoa and Foundation classes). From the latest release there are three source code dependencies:

- check for TCP connectivity by utilizing [SwiftSocket](https://github.com/swiftsocket/SwiftSocket), some functions require connections to remote servers
- execute pre and post shellscripts by utilizing John Sundell´s [ShellOut](https://github.com/JohnSundell/ShellOut)
- utilizing John Sundell´s [Files](https://github.com/JohnSundell/Files) for reading files and catalogs

All three are available as source code and automatically included as part of building RsyncOSX.

Working with JSON require to encode and decode the JSON file. The tool [JSONExport](https://github.com/Ahmed-Ali/JSONExport) is used to create the required Swift structs ([configurations](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX/DecodeConfiguration.swift), [schedules and logs](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX/DecodeSchedule.swift)) for decode JSON file into the approriate Swift structs.

### Tools used

The following tools are used in development:

- Xcode (the main tool)
- make to compile new versions in terminal
- [create-dmg](https://github.com/sindresorhus/create-dmg) to create new releases
- [SwiftLint](https://github.com/realm/SwiftLint) to enforce Swift style and conventions
- [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) for reformatting Swift code

All the above, except Xcode are installed by using [Homebrew](https://brew.sh/).

### Scheduling

Scheduled tasks are added and deleted within RsyncOSX. Executing the scheduled tasks is by the [menu app](https://rsyncosx.netlify.app/post/menuapp/).

### Remote servers

If destination is a **remote server**, RsyncOSX is dependent on [setting up password-less logins](https://rsyncosx.netlify.app/post/remotelogins/). Both ssh-keys and rsync daemon setup are possible. It is advised utilizing ssh-keys because communication between source and destination (client and server) is encrypted.

If destination is a **local attached volume**, the above is not relevant.

### Signing and notarizing

The app is signed with my Apple ID developer certificate and [notarized](https://support.apple.com/en-us/HT202491) by Apple. See [signing and notarizing](https://rsyncosx.netlify.app/post/notarized/) for info. Signing and notarizing is required to run on macOS Catalina.

### Localization

[RsyncOSX speaks new languages](https://rsyncosx.netlify.app/post/localization/). RsyncOSX is localized to:
- Chinese (Simplified) -  by [StringKe (Chen)](https://github.com/StringKe)
- German - by [Andre Voigtmann](https://github.com/andre68723)
- Norwegian - by me
- English - the base language of RsyncOSX
- Italian - by [Stefano Steve Cutelle'](https://github.com/stefanocutelle)
- Dutch - by [Marcellino Santoso](https://github.com/maebs)

Localization is done by utilizing [Crowdin](https://crowdin.com/project/rsyncosx) to translate the xliff files which are imported into Xcode after translating. Xcode then creates the required language strings. [Crowdin is free for open source projects](https://crowdin.com/page/open-source-project-setup-request).

### Version of rsync

RsyncOSX is verified with rsync versions 2.6.9, 3.1.2, 3.1.3 and 3.2.x. Other versions of rsync will work but numbers about transferred files is not set in logs. It is recommended to [install](https://rsyncosx.netlify.app/post/rsync/) the latest version of rsync.

If you are only looking for utilizing stock version of rsync (version 2.6.9) and only synchronize data to either local attached disks or remote servers, [there is a minor version (RsynGUI) available on Mac App Store](https://itunes.apple.com/us/app/rsyncgui/id1449707783?l=nb&ls=1&mt=12). RsyncGUI does **not** support snapshots or scheduling task.

### Some words about RsyncOSX

RsyncOSX is not developed to be an easy to use synchronize and backup tool. The main purpose is to assist and ease the use of `rsync` to synchronize files on your Mac to remote FreeBSD and Linux servers. And of course restore files from those remote servers.

The UI of RsyncOSX can for users who dont know rsync, be difficult or complex to understand. Using RsyncOSX requires some knowledge of `rsync`. The main objective for RsyncOSX is to ease the use of `rsync`, not teach macOS users how to use `rsync`. That is beyond the scope of RsyncOSX. Setting the wrong parameters to rsync can result in deleted data. And RsyncOSX will not stop you for doing so. That is why it is very important to execute a simulated run (`--dry-run`) and inspect what happens before a real run.

RsyncOSX supports **synchronize** and **snapshots** of files.

If your plan is to use RsyncOSX as your main tool for backup of files, please investigate and understand the limits of it. RsyncOSX is quite powerful, but it is might not the primary backup tool for the average user of macOS.

### The --delete parameter
```
Caution about RsyncOSX and the `--delete` parameter. The `--delete` is a default parameter.
The parameter instructs rsync to keep the source and destination synchronized (in sync).
The parameter instructs rsync to delete all files in the destination which are not present
in the source.

Every time you add a new task to RsyncOSX, execute an estimation run (--dry-run) and inspect
the result before executing a real run. If you by accident set an empty catalog as source
RsyncOSX (rsync) will delete all files in the destination.
```
To save deleted and changes files either utilize [snapshots](https://rsyncosx.netlify.app/post/snapshots/)
or [the --backup parameter](https://rsyncosx.netlify.app/post/userparameters/). The --delete parameter and other default parameters might be deleted if wanted.

### The source code and compile

There are [some details about source and how to compile](https://rsyncosx.netlify.app/post/compile/).

### A Sandboxed version

[There is also released a minor version, RsyncGUI](https://itunes.apple.com/us/app/rsyncgui/id1449707783?l=nb&ls=1&mt=12) of RsyncOSX on Apple Mac App Store. See the [changelog](https://rsyncosx.netlify.app/post/rsyncguichangelog/). RsyncGUI utilizes stock version of rsync in macOS and RsyncGUI only supports synchronize task (no snapshots).

### About bugs

 Over the years most bugs are smoked out. Thanks to users who reports bugs. Fighting bugs are difficult. I am not able to test RsyncOSX for all possible user interactions and use. I need support from other users discovering bugs or not expected results. If you discover a bug [please report it](https://github.com/rsyncOSX/RsyncOSX/issues).

### About restoring files to a temporary restore catalog

If you do a restore from the `remote` to the `source`, some files in the source might be deleted. This is due to how rsync works in `synchronize` mode. As a precaution **never** do a restore directly from the `remote` to the `source`, always do a restore to a temporary restore catalog.

### Combine

RsyncOSX **version 6.6.0** is released as an update for users on **macOS Big Sur**.

The major work in this release are **utilizing Combine** and only supporting **JSON files**. In development of [RsyncUI](https://github.com/rsyncOSX/RsyncUI), I "discovered" the new declarative framework Combine. Combine is also a great framework and makes the code easy to write and easy to read. It is most likely that RsyncOSX will avaliable for some years and why not upgrade RsyncOSX to utilize Combine.

There are though some restrictions. In the Combine code for encode and write data to JSON file, the publiser requiere macOS BigSur or later. This release will only be avaliable for **macOS BigSur** and later.

Much of the code where Combine is used is shared with RsyncUI. There is also some refactor and clean up other parts of the code in this release.

Combine is used in the following code:

- [read](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX/ReadUserConfigurationPLIST.swift) user configurations from permanent store
- [read](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX/ReadConfigurationJSON.swift) and [write](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX/WriteConfigurationJSON.swift) configurations
- [read](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX/ReadScheduleJSON.swift) and [write](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX/WriteScheduleJSON.swift) schedules and logs
- read and convert [configurations](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX/ReadConfigurationsPLIST.swift) and [schedules](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX/ReadSchedulesPLIST.swift) from PLIST format to JSON format
- [the process object](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX/RsyncProcess.swift), executing tasks
- preparing [the output](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX/TrimTwo.swift) from rsync process

### Application icon

The application icon is created by [Zsolt Sándor](https://github.com/graphis). All rights reserved to Zsolt Sándor.

![](icon/rsyncosx.png)
