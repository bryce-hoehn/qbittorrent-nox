# qbittorrent-nox

Featureful free software BitTorrent client (headless/WebUI only).

Upstream: [qbittorrent/qBittorrent](https://github.com/qbittorrent/qBittorrent)  
Documentation: [qbittorrent wiki](https://github.com/qbittorrent/qBittorrent/wiki)

## Ports

- `8080` — Web UI
- `6881` — BitTorrent listening port

## Volumes

- `/config` — Configuration files
- `/downloads` — Default download directory

## Environment Variables

These are read directly by the `qbittorrent-nox` binary. The naming convention is `QBT_<OPTION_NAME>` — the CLI option name uppercased with `-` replaced by `_`. Boolean flags accept `1` or `TRUE` to enable.

### General

| Variable | Default | Description |
| --- | --- | --- |
| `QBT_WEBUI_PORT` | _(config default: 8080)_ | Web UI port (1–65535) |
| `QBT_TORRENTING_PORT` | _(config default: 6881)_ | BitTorrent listening port (1–65535) |
| `QBT_PROFILE` | _(empty)_ | Store configuration files in this directory (absolute path) |
| `QBT_CONFIGURATION` | _(empty)_ | Store config in `qBittorrent_<name>` subdirectories |
| `QBT_DAEMON` | _(unset)_ | Run in daemon mode (background) |
| `QBT_RELATIVE_FASTRESUME` | _(unset)_ | Make libtorrent fastresume paths relative to profile |
| `QBT_CONFIRM_LEGAL_NOTICE` | _(unset)_ | Confirm the legal notice |

### Torrent-Adding (applied to torrents passed on command line at startup)

| Variable | Default | Description |
| --- | --- | --- |
| `QBT_SAVE_PATH` | _(empty)_ | Torrent save path |
| `QBT_ADD_STOPPED` | `true` | Add torrents as stopped (`true`/`false`) |
| `QBT_SKIP_HASH_CHECK` | _(unset)_ | Skip hash check |
| `QBT_CATEGORY` | _(empty)_ | Assign torrents to category (creates if missing) |
| `QBT_SEQUENTIAL` | _(unset)_ | Download files in sequential order |
| `QBT_FIRST_AND_LAST` | _(unset)_ | Download first and last pieces first |
| `QBT_SKIP_DIALOG` | `true` | Suppress "Add New Torrent" dialog (`true`/`false`) |
