## Hi there 👋

RsyncOSX and RsyncUI are GUI´s on the Apple macOS plattform for the command line tool [rsync](https://github.com/WayneD/rsync). 

| App      | Lines & files | Code | Latest version  |  Version 1.0 | 
| ----------- | ----------- |   ----------- | -------- |  -------- |
| RsyncOSX   | about 11K, 121  | Storyboard, Swift, imperativ   | 6.8.0 - 13 April 2023 |	14 March 2016 | 
| RsyncUI   | about 14K, 168       | SwiftUI, Swift, declarativ     | 1.6.5 - 16 July 2023  | 6 May 2021  | 

It is `rsync` which executes the synchronize task. The GUI´s are only for setting parameters and make it more easy to use `rsync`, which is a fantastic tool.

### Install by Homebrew

Both apps might be installed by Homebrew

- RsyncOSX: `brew install --cask rsyncosx` (support for **macOS Big Sur** and later)
- RsyncUI: `brew install --cask rsyncui` (support for **macOS Monterey** and later)

Both apps might be used in parallell, but not at the same time due to locking of files. Data is read and updated from the same location on storage.

### Important to verify

The UI of RsyncOSX and RsyncUI can for users who dont know `rsync` be difficult to understand. Setting wrong parameters to rsync can result in deleted data. RsyncOSX nor RsyncUI will not stop you for doing so. That is why it is **very** important to execute a simulated run, a `--dry-run`, and **verify** the result before the real run.

Please read  the [documentation of RsyncOSX](https://rsyncosx.netlify.app/post/rsyncosxdocs/) or [documentation of RsyncUI](https://rsyncui.netlify.app/post/rsyncuidocs/) for how to add a task and how to execute a simulated run, a `--dry-run`, to verify a task. 

### External task executing rsync 

Please be aware it is an external task **not controlled** by RsyncOSX nor RsyncUI which [executes](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX/RsyncProcessAsync.swift) the command line tool `rsync`. RsyncOSX and RsyncUI are monitoring the task for progress and termination. The user can abort a task at any time. Please let the abort to finish and cleanup properly before starting a new task. It might take a few seconds. If not the apps might become unresponsive.

### Parameters to rsync

`rsync` supports a ton of parameters and most likely the advanced user of `rsync` wants to apply parameters and verify the effect. I am **not** an advanced user of `rsync`, but both RsyncOSX and RsyncUI supports adding parameters. The GUI for verifying parameters is better within RsyncUI than RsyncOSX. Both apps can be used in parallell and if you prefer RsyncOSX you might still use RsyncUI to add and test parameters for `rsync`. The `rsync` command line is dynamically updated when updating parameters and presented in RsyncUI and there is a verify button for testing before saving. 

### RsyncOSX

[![GitHub license](https://img.shields.io/github/license/rsyncOSX/RsyncOSX)](https://github.com/rsyncOSX/RsyncOSX/blob/master/Licence.MD) ![GitHub Releases](https://img.shields.io/github/downloads/rsyncosx/RsyncOSX/v6.8.0/total) [![Netlify Status](https://api.netlify.com/api/v1/badges/d375f6d7-dc9f-4913-ab43-bfd46d172eb2/deploy-status)](https://app.netlify.com/sites/rsyncosx/deploys) [![GitHub issues](https://img.shields.io/github/issues/rsyncOSX/RsyncOSX)](https://github.com/rsyncOSX/RsyncOSX/issues)

**RsyncOSX** is released for **macOS Big Sur** and later. Latest build is [13 April 2023](https://github.com/rsyncOSX/RsyncOSX/releases).

- the [documentation of RsyncOSX](https://rsyncosx.netlify.app/)
- the [readme for RsyncOSX](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX.md)
- the [changelog](https://rsyncosx.netlify.app/post/changelog/)

![](images/rsyncosx.png)

### RsyncUI

[![GitHub license](https://img.shields.io/github/license/rsyncOSX/RsyncUI)](https://github.com/rsyncOSX/RsyncUI/blob/main/Licence.MD) ![GitHub Releases](https://img.shields.io/github/downloads/rsyncosx/RsyncUI/v1.6.5/total) ![GitHub Releases](https://img.shields.io/github/downloads/rsyncosx/RsyncUI/v1.6.3/total) [![Netlify Status](https://api.netlify.com/api/v1/badges/1d14d49b-ff14-4142-b135-771db071b58a/deploy-status)](https://app.netlify.com/sites/rsyncui/deploys) [![GitHub issues](https://img.shields.io/github/issues/rsyncOSX/RsyncUI)](https://github.com/rsyncOSX/RsyncUI/issues)

**RsyncUI** is released for **macOS Monterey** and later. Latest build is [16 July 2023](https://github.com/rsyncOSX/RsyncUI/releases).

- the [documentation of RsyncUI](https://rsyncui.netlify.app/)
- the [readme for RsyncUI](https://github.com/rsyncOSX/RsyncUI/)
- the [changelog](https://rsyncui.netlify.app/post/changelog/)

![](images/rsyncui.png)

![My github stats](https://github-readme-stats.vercel.app/api?username=rsyncOSX&show_icons=true&hide_border=true&theme=dark)

![Metrics](https://metrics.lecoq.io/rsyncOSX?template=classic&config.timezone=Europe%2FOslo)
