## Hi there 👋

RsyncUI is a GUI on the Apple macOS platform for the command line tool [rsync](https://github.com/WayneD/rsync). It is `rsync` which executes the synchronize data tasks. The GUI is only for organizing tasks, setting parameters to `rsync` and make it easier to use `rsync`. 

If you are on macOS Sonoma and later **use RsyncUI**.


### Install by Homebrew

The apps might be installed by Homebrew or by direct Download. The apps are signed and notarized by Apple.

| App      | Homebrew | macOS |  Documentation |
| ----------- | ----------- |   ----------- |  ----------- |
| RsyncUI   | `brew install --cask rsyncui`    | macOS Sonoma and later |   [rsyncui.netlify.app](https://rsyncui.netlify.app/post/rsyncuidocs/) |
| RsyncOSX   | `brew install --cask rsyncosx`  |  macOS Big Sur and later, *not maintained, repository is  archived and readonly*  |  [rsyncosx.netlify.app](https://rsyncosx.netlify.app/post/rsyncosxdocs/) |


### Why two apps 

The development of RsyncOSX commenced in *2015* as a project to learn Swift. In *2019*, Apple released SwiftUI. SwiftUI quickly became very popular and I commenced another project, RsyncUI, to learn SwiftUI.

| App      | Storage  | UI | Latest version  |  Version 1.0.0 |
| ----------- | ----------- |   -------- | -------- | -------- |
| RsyncUI   | JSON  | SwiftUI, declarativ     | v1.9.2 - [11 June 2024](https://github.com/rsyncOSX/RsyncUI/releases)  | 6 May 2021  |
| RsyncOSX  | JSON | Storyboard, imperativ   | v6.8.0 - [13 April 2023](https://github.com/rsyncOSX/RsyncOSX/releases) |	14 March 2016 |

### Important to verify new tasks

The UI of RsyncUI can for users who dont know `rsync` be difficult and complex to understand. Setting wrong parameters to `rsync` can result in deleted data. *For your own safety* it is important to execute a simulated run, a `--dry-run`, and verify the result before the real run.

### External task executing rsync

Please be aware it is an external task *not controlled* by RsyncUI, which executes the command-line tool rsync. The progress and termination of the external rsync task are monitored. The user can abort the task at any time. Please let the abort finish and cleanup properly before starting a new task. It might take a few seconds. If not, the apps might become unresponsive.

### RsyncUI (Swift, SwiftUI)

[![GitHub license](https://img.shields.io/github/license/rsyncOSX/RsyncUI)](https://github.com/rsyncOSX/RsyncUI/blob/main/Licence.MD) ![GitHub Releases](https://img.shields.io/github/downloads/rsyncosx/RsyncUI/v1.9.2/total)  [![GitHub issues](https://img.shields.io/github/issues/rsyncOSX/RsyncUI)](https://github.com/rsyncOSX/RsyncUI/issues)

**RsyncUI** is released for *macOS Sonoma and later*. Latest build is [11 June 2024](https://github.com/rsyncOSX/RsyncUI/releases) and release candidate version 2.1.0 (b110) was released 21 August 2024.

- the [user guide for RsyncUI](https://rsyncui.netlify.app/)
- the [changelog](https://rsyncui.netlify.app/post/changelog/)

![](images/rsyncui.png)

### RsyncOSX (Swift, Storyboard) - archived, not maintained

[![GitHub license](https://img.shields.io/github/license/rsyncOSX/RsyncOSX)](https://github.com/rsyncOSX/RsyncOSX/blob/master/Licence.MD) ![GitHub Releases](https://img.shields.io/github/downloads/rsyncosx/RsyncOSX/v6.8.0/total)

**RsyncOSX** was released for *macOS Big Sur* and later. Please be aware of the repository for RsyncOSX is archived and not maintained.

- the [user guide for RsyncOSX](https://rsyncosx.netlify.app/)
