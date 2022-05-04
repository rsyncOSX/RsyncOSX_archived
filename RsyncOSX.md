[![GitHub license](https://img.shields.io/github/license/rsyncOSX/RsyncOSX)](https://github.com/rsyncOSX/RsyncOSX/blob/master/Licence.MD) ![GitHub Releases](https://img.shields.io/github/downloads/rsyncosx/RsyncOSX/v6.7.3/total) ![GitHub Releases](https://img.shields.io/github/downloads/rsyncosx/RsyncOSX/v6.7.2/total) [![Netlify Status](https://api.netlify.com/api/v1/badges/d375f6d7-dc9f-4913-ab43-bfd46d172eb2/deploy-status)](https://app.netlify.com/sites/rsyncosx/deploys) [![GitHub issues](https://img.shields.io/github/issues/rsyncOSX/RsyncOSX)](https://github.com/rsyncOSX/RsyncOSX/issues)

**RsyncOSX** is released for **macOS Big Sur** and later due to requirements of some features in Combine. See [the Combine part](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX.md#Combine) in the readme for RsyncOSX.

Content:

- [Install by Homebrew](#install-by-homebrew)
- [Documents, issues and changelog](#documents-issues-and-changelog)
- [Dependencies](#dependencies)
- [Tools used](#tools-used)
- [Scheduling](#scheduling)
- [Remote servers](#remote-servers)
- [Signing and notarizing](#signing-and-notarizing)
- [Localization](#localization)
- [Version of rsync](#version-of-rsync)
- [The source code and compile](#the-source-code-and-compile)
- [Combine](#combine)
- [Application icon](#application-icon)

### Install by Homebrew

RsyncOSX can also be installed by Homebrew: `brew install --cask rsyncosx`

### Documents, issues and changelog

RsyncOSX is a GUI on top of the command line utility `rsync`. Rsync is a file-based synchronization and backup tool. There is no custom solution for the backup archive. You can quit utilizing RsyncOSX (and rsync) at any time and still have access to all synchronized files. RsyncOSX is compiled with support for **macOS Big Sur and later**.

- [info and guidelines about using RsyncOSX](https://rsyncosx.netlify.app/)
- [the changelog](https://rsyncosx.netlify.app/post/changelog/)

The info on web is published by utilizing [Hugo](https://gohugo.io/), the Hugo theme [Hello-friend-ng](https://github.com/rhazdon/hugo-theme-hello-friend-ng) and published on [Netlify](https://rsyncosx.netlify.app/). If you want to discuss changes or report bugs please [create an issue](https://github.com/rsyncOSX/RsyncOSX/issues).

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

RsyncOSX is [signed and notarized ](https://rsyncosx.netlify.app/post/notarized/).

### Localization

RsyncOSX is [localized](https://rsyncosx.netlify.app/post/localization/) to:
- Chinese (Simplified) -  by [StringKe (Chen)](https://github.com/StringKe)
- German - by [Andre Voigtmann](https://github.com/andre68723)
- Norwegian - by me
- English - the base language of RsyncOSX
- Italian - by [Stefano Steve Cutelle'](https://github.com/stefanocutelle)
- Dutch - by [Marcellino Santoso](https://github.com/maebs)

### Version of rsync

RsyncOSX is verified with rsync versions 2.6.9 and 3.2.x. Other versions of rsync will work but numbers about transferred files is not set in logs. It is recommended to [install](https://rsyncosx.netlify.app/post/rsync/) the latest version of rsync by Homebrew.

### The source code and compile

There are [some details about source and how to compile](https://rsyncosx.netlify.app/post/compile/).

### Combine

The major work in the latest releases are **utilizing Combine** and only supporting **JSON files**. In development of [RsyncUI](https://github.com/rsyncOSX/RsyncUI), I "discovered" the new declarative framework Combine. Combine is a great framework and makes it more easy to write and read code. The publisher for encode and write data to JSON file requiere macOS BigSur or later.  Much of the code where Combine is used is shared with RsyncUI. There is also some refactor and clean up other parts of the code in this release.

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
