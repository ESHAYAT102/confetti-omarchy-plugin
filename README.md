# Confetti for Omarchy

A native Omarchy Quattro plugin for Raycast-style confetti on Linux. Particle
simulation and rendering run in a persistent Go process instead of QML's
JavaScript canvas.

## Install

Install the build and rendering dependencies, then install and enable the
plugin through Omarchy's Git-based plugin manager:

```sh
omarchy pkg add go gtk4-layer-shell
```

```sh
omarchy plugin add https://github.com/ESHAYAT102/confetti-omarchy-plugin.git --enable
```

If you install without `--enable`, enable the plugin before using it:

```sh
omarchy plugin enable esh.confetti
```

After installation, run this command to show the effect:

```sh
omarchy-shell esh.confetti fire
```

Confetti has no default keybinding. Pick one and bind the command in `~/.config/hypr/bindings.lua`, then run `hyprctl reload`:

```lua
o.bind(
  "SUPER + ALT + SPACE",
  "Confetti",
  "omarchy-shell esh.confetti fire"
)
```

Check `omarchy menu keybindings --print` first. If the key is already assigned,
choose another key or call `hl.unbind("SUPER + ALT + SPACE")` before the new
binding. Confirm the configuration after editing:

```sh
hyprctl reload
hyprctl configerrors
```

## Optional Omarchy menu entry

Omarchy's plugin manifest does not currently support adding actions to the
built-in menu, and `omarchy plugin add` deliberately runs no install hooks.
The plugin therefore cannot appear under **Trigger** automatically.

To explicitly add **Trigger > Confetti**, run the included helper after
installation:

```sh
~/.config/omarchy/plugins/esh.confetti/bin/confetti-menu install
```

This preserves existing JSONC comments and entries, refuses to replace an
unmanaged `trigger.confetti` entry, and reloads automatically through
Omarchy's menu file watcher.

## Usage

Run the command directly, use your configured shortcut, or choose
**Trigger > Confetti** if you installed the optional menu entry:

```sh
omarchy-shell esh.confetti fire
```

Triggering the command again while confetti is active adds another burst. The
transparent overlay stays ready between bursts but consumes no animation CPU
while idle.

## Permissions and dependencies

Omarchy plugins run unsandboxed with the current user's permissions. This
plugin does not access the network, request elevated privileges, or start
another Quickshell process. On first load, its launcher compiles the included
Go source into `~/.cache/esh.confetti/confetti`; later loads reuse that binary
until the source changes. Each trigger checks this animation preference:

```sh
gsettings get org.gnome.desktop.interface enable-animations
```

The explicit `confetti-menu install` command atomically adds one marked entry
to `~/.config/omarchy/extensions/omarchy-menu.jsonc`. It does not replace the
file or alter unrelated entries. The corresponding `remove` command deletes
only that marked entry.

## Remove

If you installed the optional menu entry, remove it before removing the
plugin:

```sh
~/.config/omarchy/plugins/esh.confetti/bin/confetti-menu remove
```

Then remove any keybinding you added and uninstall the plugin:

```sh
omarchy plugin remove esh.confetti
```

Remove the compiled cache after uninstalling if you do not plan to reinstall:

```sh
rm -rf ~/.cache/esh.confetti
```

## Development

Validate the repository root against Omarchy's manifest rules:

```sh
omarchy plugin validate .
```

Test the Go renderer and lint the QML IPC adapter:

```sh
go test ./...
go vet ./...
/usr/lib/qt6/bin/qmllint -I "${OMARCHY_PATH:-/usr/share/omarchy}/shell" Service.qml
```

For live development, copy the repository into
`~/.config/omarchy/plugins/esh.confetti/`, enable it, and
rescan the shell when needed:

```sh
omarchy plugin enable esh.confetti
omarchy-shell shell rescanPlugins
```

Saved plugin files reload automatically. Do not use symlinks inside the plugin
folder because Omarchy's validator rejects them.

## License

MIT. See [LICENSE](LICENSE).
