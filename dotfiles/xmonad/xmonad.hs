import           System.Exit
import           System.IO

import           Data.Default
import           XMonad
import           XMonad.Config.Desktop
import           XMonad.Core              (io)
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.ManageDocks
import           XMonad.Operations        (hide, kill, restart, reveal,
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
myFocusColor = "#ff3f34"

confirm :: String -> X () -> X ()
confirm m f = do
  result <- dmenu [m, "y", "n"]
  when (init result == m) f

myStartupHook = do
  spawn "stalonetray &"
  spawn "xrdb -merge ~/.XResources &"
  spawn "xsetroot -cursor_name left_ptr &"
  spawn "feh --bg-fill $HOME/Pictures/bike.jpg &"
  spawn "nm-applet &"
  spawn "pasystray &"

delKeys :: XConfig l -> [(KeyMask, KeySym)]
delKeys conf@(XConfig {modMask = modMask}) =
  [ ((modMask, xK_p))
  , ((modMask .|. shiftMask, xK_q))
  , ((modMask, xK_q))
  ]

insKeys :: XConfig l -> [((KeyMask, KeySym), X ())]
insKeys conf@(XConfig {modMask = modMask}) =
  [ ((modMask, xK_d),      spawn "rofi -show run")
  , ((modMask, xK_Tab),    spawn "rofi -show window")
  , ((modMask, xK_Return), spawn "termite")
  , ((modMask, xK_b),	   sendMessage ToggleStruts)
  , ((modMask, xK_x),	   withFocused hide)
  , ((modMask, xK_z),	   withFocused reveal)
  , ((modMask .|. shiftMask, xK_q), kill)
  , ((modMask .|. shiftMask, xK_r), restart "xmonad" True)
  , ((modMask .|. shiftMask, xK_e), confirm "Exit" $ io (exitWith ExitSuccess))
  ]

main = do
  xmproc <- spawnPipe "xmobar"

  xmonad $ desktopConfig
    { manageHook = manageDocks <+> manageHook defaultConfig
    , layoutHook = avoidStruts  $  layoutHook defaultConfig
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
