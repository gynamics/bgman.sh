# bgman.sh
A shell script for wallpaper management

## usage
```sh
source bgman.sh
```

Then you can run `bgman -h` for help.

## desktop support
- xmonad
- i3
- sway
- hyprland

## backends
- feh: for X
- swaybg: for Wayland

## features
- [X] add/del wallpaper to a list file
- [X] add all wallpapers in a directory
- [X] add all wallpapers in a directory recursively
- [X] del wallpapers from list by specify a range
- [X] select wallpaper from list by id
- [X] write configuration to your configuration file
- [X] make a backup before write configuration file

## configuration integration
To make `-s` and `-sn` take effect, make sure there is a line to be matched.
But don't worry, a backup is created before each writing, with suffix `.backup`.

### i3/sway
i3 config path: `$HOME/.config/i3/config`, 
sway config path: `$HOME/.config/sway/config`

```config
# the following line will be overwritten
set $wallpaper "/path/to/your/wallpaper"

# to use it, you can write:
exec --no-startup-id feh --no-fehbg --bg-center --bg-fill $wallpaper
```

### xmonad
xmonad config path: `$HOME/.config/xmonad/xmonad.hs`

```haskell
-- the following line will be overwritten
let wallpaper = "/path/to/your/wallpaper"

-- to use it, you can write:
spawn $ "feh --no-fehbg --bg-fill \"" ++ wallpaper ++ "\"" 
```

### hyprland
hyprland config path: `$HOME/.config/hypr/hyprland.conf`

```config
# the following line will be overwritten
$wallpaper = "/path/to/your/wallpaper"

# to use it, write:
exec-once = swaybg -m fill -i $wallpaper 
```

