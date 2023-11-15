<p align="center" style="white-space: pre-line;">
  <a href="https://tlapbot.chimmie.k.vu" class="no-highlight">
    <img src="docs/tlapbot-splash-text.png" width="400" alt=":tlapbot-splash:">
  </a>
</p>

<p align="center">
  <a href="https://ci.codeberg.org/repos/12562"><img src="https://ci.codeberg.org/api/badges/12562/status.svg" alt=":workflow:" height="20" /></a>
  <a href="https://codeberg.org/GamePlayer-8/tlapbot"><img alt=":give_a_star:" src="https://img.shields.io/badge/Give_a-Star_⭐-green" height="20" /></a>
</p>

Tlapbot is an [Owncast](https://owncast.online/) bot that adds channel points and
channel point redeems to your Owncast page.

For more infomation please refer to [the original repository](https://github.com/SleepyLili/tlapbot).

# Usage of the fork

### Installation

#### Standalone binary

1. Download the AppImage or Binary file from the `pages` branch at `dists/` directory.
2. Extract it.
3. `chmod +x ./tlapbot`
4. Execute `./tlapbot`.

##### For Windows

1. Download the Binary file from the `pages` branch at `dists/windows/` directory.
2. Extract it.
3. The `tlapbot.exe` would appear after extraction.
4. Open `cmd.exe` and run it through `start <path to the EXE file>`.

#### Container

That tlapbot release supports Docker containers.

There are 2 types: `alpine` & `ubuntu`.

##### Alpine

Releases:
 - `docker pull codeberg.org/gameplayer-8/tlapbot:latest`
 - `docker pull codeberg.org/gameplayer-8/tlapbot:dev`

The developer version is unstable.

##### Ubuntu

Releases:
 - `docker pull codeberg.org/gameplayer-8/tlapbot:latest-ubuntu`
 - `docker pull codeberg.org/gameplayer-8/tlapbot:dev-ubuntu`

##### A note.

The developer version is unstable.

### Usage

You will be prompted with a basic help info. From there you can follow, what to do.

### Reporting issues

Since from a fork version, I'm coding on my own, there might be bugs somewhere around.
If you encounter some - please report them at [the issue tracker](https://codeberg.org/GamePlayer-8/tlapbot/issues).

### Contributing

All contributions are welcome! But please use the `dev` branch & pull requests on it since it's a branch where
I can test code.

### Warnings

If you're going to use custom instance path, please write the **absolute path**.
