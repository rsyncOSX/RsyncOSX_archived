**RsyncOSX** is released for **macOS Big Sur** and later due to requirements of some features in Combine. See [the Combine part](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX.md#Combine) in the readme for RsyncOSX.

## Install by Homebrew

RsyncOSX can also be installed by Homebrew: `brew install --cask rsyncosx`

## Documents, issues and changelog

RsyncOSX is a GUI on top of the command line utility `rsync`. Rsync is a file-based synchronization and backup tool. There is no custom solution for the backup archive. You can quit utilizing RsyncOSX (and rsync) at any time and still have access to all synchronized files. RsyncOSX is compiled with support for **macOS Big Sur and later**.

- [info and guidelines about using RsyncOSX](https://rsyncosx.netlify.app/)
- [the changelog](https://rsyncosx.netlify.app/post/changelog/)

## Dependencies

The application is implemented in pure Swift, ViewControllers and Storyboard (Cocoa and Foundation classes). From the latest release there are three source code dependencies:

- check for TCP connectivity by utilizing [SwiftSocket](https://github.com/swiftsocket/SwiftSocket), some functions require connections to remote servers
- execute pre and post shellscripts by utilizing John Sundell´s [ShellOut](https://github.com/JohnSundell/ShellOut)
- utilizing John Sundell´s [Files](https://github.com/JohnSundell/Files) for reading files and catalogs

All three are available as source code and automatically included as part of building RsyncOSX.

## Tools used

The following tools are used in development:

- Xcode (the main tool)
- make to compile new versions in terminal
- [create-dmg](https://github.com/create-dmg/create-dmg) to create new releases
- [SwiftLint](https://github.com/realm/SwiftLint) to enforce Swift style and conventions
- [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) for reformatting Swift code

All the above, except Xcode are installed by using [Homebrew](https://brew.sh/).

## Signing and notarizing

RsyncOSX is [signed and notarized ](https://rsyncosx.netlify.app/post/notarized/).

## Localization

RsyncOSX is [localized](https://rsyncosx.netlify.app/post/localization/) to:

- Chinese (Simplified) -  by [StringKe (Chen)](https://github.com/StringKe)
- German - by [Andre Voigtmann](https://github.com/andre68723)
- Norwegian - by me
- English - the base language of RsyncOSX
- Italian - by [Stefano Steve Cutelle'](https://github.com/stefanocutelle)
- Dutch - by [Marcellino Santoso](https://github.com/maebs)

## Application icon

The application icon is created by [Zsolt Sándor](https://github.com/graphis). All rights reserved to Zsolt Sándor.

![](icon/rsyncosx.png)
