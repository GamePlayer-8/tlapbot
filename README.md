<p align="center" style="white-space: pre-line;">
  <a href="https://chimmie.k.vu/tlapbot" class="no-highlight">
    <img src="docs/tlapbot-splash-text.png" width="400" alt=":tlapbot-splash:">
  </a>
</p>

<p align="center">
  <a href="actions"><img src="https://github.com/GamePlayer-8/tlapbot/actions/workflows/master.yml/badge.svg?branch=main" alt=":master_workflow:" height="20" /></a>
  <a href="issues"><img alt=":github_issues:" src="https://img.shields.io/github/issues/GamePlayer-8/tlapbot" height="20" /></a>
  <a href="discussions"><img alt=":code_size:" src="https://img.shields.io/github/languages/code-size/GamePlayer-8/tlapbot" height="20" /></a>
  <a href="https://github.com/GamePlayer-8/tlapbot"><img alt=":give_a_star:" src="https://img.shields.io/badge/Give_a-Star_⭐-green" height="20" /></a>
  <a href="https://github.com/GamePlayer-8/tlapbot"><img alt=":forks:" src="https://img.shields.io/github/forks/GamePlayer-8/tlapbot" height="20" /></a>
  <a href="https://github.com/GamePlayer-8/tlapbot"><img alt=":stars:" src="https://img.shields.io/github/stars/GamePlayer-8/tlapbot" height="20" /></a>
  <a href="pulls"><img alt=":pulls:" src="https://img.shields.io/github/issues-pr/GamePlayer-8/tlapbot" height="20" /></a>
  <a href="discussions"><img alt=":discussions:" src="https://img.shields.io/github/discussions/GamePlayer-8/tlapbot" height="20" /></a>

</p>

Tlapbot is an [Owncast](https://owncast.online/) bot that adds channel points and
channel point redeems to your Owncast page.

For more infomation please refer to [the original repository](https://github.com/SleepyLili/tlapbot).

# Usage of the fork

### Installation

#### Standalone binary

1. Download the AppImage or Binary ZIP file from the Actions tab or the release tab.
2. Extract it.
3. `chmod +x ./tlapbot`
4. Execute `./tlapbot`.

##### For Windows

1. Download the Binary ZIP file from the Actions tab or the release tab.
2. Extract it.
3. The `tlapbot.exe` would appear after extraction.
4. Open `cmd.exe` and run it through `start <path to the EXE file>`.

#### Container

That tlapbot release supports Docker containers.

There are 2 types: `alpine` & `ubuntu`.

##### Alpine

Releases:
 - `docker pull ghcr.io/gameplayer-8/tlapbot-alpine:latest`
 - `docker pull ghcr.io/gameplayer-8/tlapbot-alpine:dev`

The developer version is unstable.

##### Ubuntu

Releases:
 - `docker pull ghcr.io/gameplayer-8/tlapbot-ubuntu:latest`
 - `docker pull ghcr.io/gameplayer-8/tlapbot-ubuntu:dev`

##### A note.

The developer version is unstable.

### Usage

You will be prompted with a basic help info. From there you can follow, what to do.

### Reporting issues

Since from a fork version, I'm coding on my own, there might be bugs somewhere around.
If you encounter some - please report them at [the issues tracker](https://github.com/GamePlayer-8/tlapbot/issues).

### Contributing

All contributions are welcome! But please use the `dev` branch & pull requests on it since it's a branch where
I can test code.

### Warnings

If you're going to use custom instance path, please write the **absolute path**.
