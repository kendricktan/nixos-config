import           System.Exit
import           System.IO

import           Data.Default
import           XMonad
import           XMonad.Actions.NoBorders         (toggleBorder)
import           XMonad.Config.Desktop
import           XMonad.Core                      (io)
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.ManageHelpers       (doFullFloat, isFullscreen)
import           XMonad.Layout.Fullscreen
import           XMonad.Layout.IndependentScreens (countScreens)
import           XMonad.Layout.Minimize
import           XMonad.Layout.Named
import           XMonad.Layout.NoBorders
import           XMonad.Operations                (kill, refresh, restart,
                                                   reveal, withFocused)
import           XMonad.Prompt                    (quit)
import           XMonad.Util.CustomKeys
import           XMonad.Util.Dmenu
import           XMonad.Util.Run                  (spawnPipe)
import           XMonad.Util.SpawnOnce

import           Control.Monad                    (when)


myWorkspaces = foldl (\b a -> b ++ [(show $ length b + 1) ++ ": " ++ a]) [] ["www", "dev", "term", "irc", "ops", "music", "leisure", "office", "misc"]
myTerminal = "termite"
myBorderWidth = 3
myFocusColor = "#2ecc71"

confirm :: String -> X () -> X ()
confirm m f = do
  result <- dmenu [m, "y", "n"]
  when (result == "y") f

myStartupHook = do
  -- Spawn system tray
  spawn "kill -9 $(ps aux | grep -e \"trayer\" | awk ' { print $2 } ') &"
  spawn "trayer --edge top --align right --SetDockType true --SetPartialStrut true --expand true --width 10 --transparent true --alpha 0 --tint 0x000000 --height 16 &"
  -- spawn "stalonetray &"
  -- Set color themes
  spawn "xrdb -merge ~/.XResources &"
  -- Set cursor
  spawn "xsetroot -cursor_name left_ptr &"
  -- Set wallpaper
  spawn "feh --bg-center $HOME/Pictures/Background/background002.jpg &"
  -- Kill duplicate process
  spawn "kill -9 $(ps aux | grep -e \"nm-applet\" | awk ' { print $2 } ') &"
  spawn "kill -9 $(ps aux | grep -e \"dropbox\" | awk ' { print $2 } ') &"
  -- Spawn process
  spawn "dropbox &"
  spawn "nm-applet &"

delKeys :: XConfig l -> [(KeyMask, KeySym)]
delKeys conf@(XConfig {modMask = modMask}) =
  [ ((modMask, xK_p))
  , ((modMask, xK_q))
  , ((modMask .|. shiftMask, xK_q))
  , ((modMask .|. shiftMask, xK_c))
  ]

insKeys :: XConfig l -> [((KeyMask, KeySym), X ())]
insKeys conf@(XConfig {modMask = modMask}) =
  [ ((modMask, xK_d),      spawn "rofi -show run")
  , ((modMask, xK_Tab),    spawn "rofi -show window")
  , ((modMask, xK_Return), spawn "termite")
  , ((modMask, xK_r),	   refresh)
  , ((modMask, xK_b),	   sendMessage ToggleStruts) -- Toggles xmobar visibility
  , ((modMask, xK_m),	   withFocused toggleBorder) -- Toggles border display
  , ((modMask, xK_x),	   withFocused minimizeWindow)
  , ((modMask, xK_z),	   sendMessage RestoreNextMinimizedWin)
  , ((0, 0xff61),	   spawn "gnome-screenshot -f ~/Pictures/\"Screenshot-$(date '+%d-%m-%Y-%H:%M:%S').png\"")
  , ((0, 0x1008ff12),	   spawn "amixer set Master toggle")
  , ((0, 0x1008ff13),	   spawn "amixer -q sset Master 8%+")
  , ((0, 0x1008ff11),	   spawn "amixer -q sset Master 8%-")
  , ((0, 0x1008ffb2),	   spawn "amixer set Capture toggle")
  , ((0, 0x1008ff02),	   spawn "xbacklight -inc 10")
  , ((0, 0x1008ff03),	   spawn "xbacklight -dec 10")
  , ((0 .|. shiftMask, 0xff61),	   spawn "gnome-screenshot -a -f ~/Pictures/\"Screenshot-$(date '+%d-%m-%Y-%H:%M:%S').png\"")
  , ((modMask .|. shiftMask, xK_q), kill)
  , ((modMask .|. shiftMask, xK_r), confirm "Restart" $ restart "xmonad" True)
  , ((modMask .|. shiftMask, xK_e), confirm "Exit" $ io (exitWith ExitSuccess))
  , ((modMask .|. controlMask, xK_l), spawn "i3lock-fancy")
  ]

main = do
  -- Automatically configure screens for home
  nScreens <- countScreens

  -- if nScreens >= 2
  --    then spawn "xrandr --output DP2-1 --auto --rotate left --right-of DP2-3 --output DP2-3 --primary --output eDP1 --off"
  --    else spawn "xrandr --output DP2-1 --rotate left --right-of DP2-3 --output DP2-3 --primary --output eDP1 --off"

  -- Manage xmobar's process
  xmproc <- spawnPipe "xmobar"

  xmonad $ desktopConfig
    { manageHook = manageDocks <+> manageHook defaultConfig
    , layoutHook = avoidStruts (layoutHook defaultConfig) ||| (named "[_]" (noBorders (fullscreenFull Full)))
    , logHook = dynamicLogWithPP xmobarPP
	{ ppOutput = hPutStrLn xmproc
	, ppTitle = xmobarColor "green" "" . shorten 50
	}
    , workspaces = myWorkspaces
    , terminal = myTerminal
    , borderWidth = myBorderWidth
    , focusedBorderColor = myFocusColor
    , startupHook = myStartupHook <+> startupHook defaultConfig
    , keys = customKeys delKeys insKeys
    }
