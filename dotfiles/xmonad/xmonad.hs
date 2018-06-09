import           System.Exit
import           System.IO

import           Data.Default
import           XMonad
import           XMonad.Config.Desktop
import           XMonad.Core              (io)
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.ManageDocks
import           XMonad.Layout.Minimize
import           XMonad.Operations        (kill, refresh, restart, reveal,
                                           withFocused)
import           XMonad.Prompt            (quit)
import           XMonad.Util.CustomKeys
import           XMonad.Util.Dmenu
import           XMonad.Util.Run          (spawnPipe)
import           XMonad.Util.SpawnOnce

import           Control.Monad            (when)


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
  spawn "stalonetray &"
  -- Set color themes
  spawn "xrdb -merge ~/.XResources &"
  -- Set cursor
  spawn "xsetroot -cursor_name left_ptr &"
  -- Set wallpaper
  spawn "feh --bg-fill $HOME/Pictures/Background/background001.jpg &"
  -- Kill duplicate process
  spawn "kill -9 $(ps aux | grep -e \"nm-applet\" | awk ' { print $2 } ') &"
  spawn "kill -9 $(ps aux | grep -e \"pasystray\" | awk ' { print $2 } ') &"
  spawn "kill -9 $(ps aux | grep -e \"dropbox\" | awk ' { print $2 } ') &"
  -- Spawn process
  spawn "pasystray &"
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
  , ((modMask, xK_b),	   sendMessage ToggleStruts)
  , ((modMask, xK_x),	   withFocused minimizeWindow)
  , ((modMask, xK_z),	   sendMessage RestoreNextMinimizedWin)
  , ((modMask .|. shiftMask, xK_q), kill)
  , ((modMask .|. shiftMask, xK_r), confirm "Restart" $ restart "xmonad" True)
  , ((modMask .|. shiftMask, xK_e), confirm "Exit" $ io (exitWith ExitSuccess))
  ]

main = do
  xmproc <- spawnPipe "xmobar"

  xmonad $ desktopConfig
    { manageHook = manageDocks <+> manageHook defaultConfig
    , layoutHook = avoidStruts $ (minimize (Tall 1 (3/100) (1/2)) ||| layoutHook defaultConfig)
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
