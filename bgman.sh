#!/bin/bash
# preview & set wallpaper using feh or swaybg


declare -A BGMAN_WM_CONFIG=(
  [i3]=$HOME/.config/i3/config
  [sway]=$HOME/.config/sway/config
  [xmonad]=$HOME/.config/xmonad/xmonad.hs
  [hyprland]=$HOME/.config/hypr/hyprland.conf
)

local BGMAN_WALLPAPER_LIST=${HOME}/.cache/wallpapers
local BGMAN_WM_SESSION=''

function bgman-view-wallpaper() {
  case $BGMAN_WM_SESSION in
  "sway")
    # kill all swaybg instances and substitude with a new one
    ps -ef |grep 'swaybg -m fill -i' |grep -v 'grep' |awk '{print $2}'|xargs kill -9
    swaymsg exec "swaybg -m fill -i ${1}"
    ;;
  "hyprland")
    # kill all swaybg instances and substitude with a new one
    ps -ef |grep 'swaybg -m fill -i' |grep -v 'grep' |awk '{print $2}'|xargs kill -9
    hyprctl dispatch exec  "swaybg -m fill -i ${1}"
    ;;
  "i3")
    i3msg exec "feh --no-fehbg --bg-center --bg-fill ${1}"
    ;;
  "xmonad")
    feh --no-fehbg --bg-center --bg-fill ${1}
    ;;
  "*")
    echo "unknown desktop environment"
    ;;
  esac
}

function bgman-set-wallpaper() {
  if [ -f $1 ]; then
    case $BGMAN_WM_SESSION in
    "sway"|"i3")
      awk '{ sub(/set \$wallpaper .*$/, "set \$wallpaper \"'$(realpath $1)'\"");
             print >"tmp-out" }' ${BGMAN_WM_CONFIG[$BGMAN_WM_SESSION]} 2>/dev/null
      ;;
    "hyprland")
      awk '{ sub(/\$wallpaper = .*$/, "\$wallpaper = \"'$(realpath $1)'\"");
             print >"tmp-out" }' ${BGMAN_WM_CONFIG[$BGMAN_WM_SESSION]} 2>/dev/null
      ;;
    "xmonad")
      awk '{ sub(/let wallpaper = "[^"]*"/, "let wallpaper = \"'$(realpath $1)'\"");
             print >"tmp-out" }' ${BGMAN_WM_CONFIG[$BGMAN_WM_SESSION]} 2>/dev/null
      ;;
    *)
      echo "unknown desktop environment"
      return
      ;;
    esac
    # make a backup before replace config file
    mv ${BGMAN_WM_CONFIG[$BGMAN_WM_SESSION]} ${BGMAN_WM_CONFIG[$BGMAN_WM_SESSION]}.backup
    mv tmp-out ${BGMAN_WM_CONFIG[$BGMAN_WM_SESSION]}
 else
    echo "${1} is not a file!"
    return
  fi
}

function bgman-get-desktop() {
  if [ -z $XDG_SESSION_DESKTOP ]; then
    XDG_SESSION_DESKTOP=$DESKTOP_SESSION
  fi
  case $XDG_SESSION_DESKTOP in
  "sway"|"sway-nvidia")
    BGMAN_WM_SESSION="sway"
    ;;
  "hyprland")
    BGMAN_WM_SESSION="hyprland"
    ;;
  "i3")
    BGMAN_WM_SESSION="i3"
    ;;
  "xmonad")
    BGMAN_WM_SESSION="xmonad"
    ;;
  *)
    BGMAN_WM_SESSION=""
    echo "unknow desktop environment"
    ;;
  esac
}

function bgman() {
  # get current desktop environment
  bgman-get-desktop
  # proceed arguments
  case $1 in
  "-a")
    if [ -f $2 ]; then
      echo $(realpath $2) | tee -a $BGMAN_WALLPAPER_LIST
      shift 2
    else
      echo "${2} is not a file"
      return
    fi
    ;;
  "-ad")
    if [ -d $2 ]; then
      find $(realpath $2) -maxdepth 1 -type f -regex ".*\.png\|.*\.jpg" | tee -a $BGMAN_WALLPAPER_LIST
    shift 2
    else
      echo "${2} is not a directory name"
      return
    fi
    ;;
  "-aR")
    if [ -d $2 ]; then
      find $(realpath $2) -type f -regex ".*\.png\|.*\.jpg" | tee -a $BGMAN_WALLPAPER_LIST
      shift 2
    else
      echo "${2} is not a directory name"
      return
    fi
    ;;
  "-c")
    if [ -r $2 ]; then
      BGMAN_WALLPAPER_LIST=$(realpath "$2")
      shift 1
    else
      echo "${2} is not accessible"
      return
    fi
    ;;
  "-clr")
    :>$BGMAN_WALLPAPER_LIST
    shift 1
    ;;
  "-d")
    if [ $2 -gt 0 ]&&[ $2 -le $(wc -l $BGMAN_WALLPAPER_LIST|awk '{print $1}') ]
    then
      sed -i ${2}'d' $BGMAN_WALLPAPER_LIST
      shift 2
    else
      echo "-d needs a valid line number"
      return
    fi
    ;;
  "-dr")
    if [ $2 -gt 0 ]&&[ $2 -le $(wc -l $BGMAN_WALLPAPER_LIST|awk '{print $1}') ]&&
       [ $3 -gt 0 ]&&[ $3 -le $(wc -l $BGMAN_WALLPAPER_LIST|awk '{print $1}') ]&&[ $2 -le $3 ]
    then
      sed -i ${2}','${3}'d' $BGMAN_WALLPAPER_LIST
      shift 3
    else
      echo "-dr needs two valid line numbers"
      return
    fi
    ;;
  "-h"|"--help")
    echo "BGMAN_WM_SESSION=${BGMAN_WM_SESSION}"
    echo "BGMAN_WM_CONFIG=${BGMAN_WM_CONFIG[$BGMAN_WM_SESSION]}"
    echo "BGMAN_WALLPAPER_LIST=${BGMAN_WALLPAPER_LIST}"
    echo "\t-a  [PATH]      add a wallpaper into \$BGMAN_WALLPAPER_LIST"
    echo "\t-ad [PATH]      add all jpg/png in a directory into \$BGMAN_WALLPAPER_LIST"
    echo "\t-aR [PATH]      add all jpg/png in a directory into \$BGMAN_WALLPAPER_LIST  recursively"
    echo "\t-c  [PATH]      change \$BGMAN_WALLPAPER_LIST temporarily"
    echo "\t-clr            clear content in \$BGMAN_WALLPAPER_LIST"
    echo "\t-d  [ID]        delete a wallpaper from \$BGMAN_WALLPAPER_LIST by line number"
    echo "\t-dr [FROM] [TO] delete a range in \$BGMAN_WALLPAPER_LIST by line number"
    echo "\t-h              show this help"
    echo "\t-l              list wallpapers saved in \$BGMAN_WALLPAPER_LIST"
    echo "\t-m              merge duplicated items in \$BGMAN_WALLPAPER_LIST"
    echo "\t-p  [PATH]      preview with swaybg"
    echo "\t-pn [ID]        preview a wallpaper from \$BGMAN_WALLPAPER_LIST by line number"
    echo "\t-r              randomly pick a wallpaper from \$BGMAN_WALLPAPER_LIST"
    echo "\t-s  [PATH]      set \$wallpaper to [PATH] configuration file"
    echo "\t-sn [ID]        set \$wallpaper with a path in \$BGMAN_WALLPAPER_LIST by line number"
    echo "  HINT: support multiple parameters, e. g. bgman -aR [PATH] -sn [ID] -m"
    shift 1
    ;;
  "-l")
    cat -n $BGMAN_WALLPAPER_LIST
    shift 1
    ;;
  "-m")
    sort $BGMAN_WALLPAPER_LIST |uniq |tee $BGMAN_WALLPAPER_LIST
    shift 1
    ;;
  "-p")
    if [ -f $2 ]; then
      bgman-view-wallpaper $(realpath "$2")
      shift 2
    else
      echo "${2} is not a file"
      return
    fi
    ;;
  "-pn")
    if [ $2 -gt 0 ]&&[ $2 -le $(wc -l $BGMAN_WALLPAPER_LIST|awk '{print $1}') ]
    then
      bgman-view-wallpaper $(sed -n ${2}'p' $BGMAN_WALLPAPER_LIST)
      shift 2
    else
      echo "-pn needs a valid line number"
      return
    fi
    ;;
  "-r")
    bgman-view-wallpaper $(sed -n $(wc -l $BGMAN_WALLPAPER_LIST|
      awk 'BEGIN{srand()} {print int($1 *rand())+1}')'p' $BGMAN_WALLPAPER_LIST)
    shift 1
    ;;
  "-s")
      bgman-set-wallpaper $2
      shift 2
    ;;
  "-sn")
    if [ $2 -gt 0 ]&&[ $2 -le $(wc -l $BGMAN_WALLPAPER_LIST|awk '{print $1}') ]
    then
      bgman-set-wallpaper $(sed -n $2'p' $BGMAN_WALLPAPER_LIST)
      shift 2
    else
      echo "-sn needs a valid line number"
      return
    fi
    ;;
  *)
    if [ -z ${1} ]; then
      echo " no argument provided. -h for help"
    else
      echo "${1}: invalid argument. -h for help"
    fi
    return
    ;;
  esac
  # get parameters recursively
  if [ $# -gt 0 ]; then
    bgman $@
  fi
}
