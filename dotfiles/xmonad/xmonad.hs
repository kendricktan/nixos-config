import           Data.Default

import           Graphics.X11.ExtraTypes.XF86
import           System.Taffybar.Hooks.PagerHints (pagerHints)
import           XMonad
import           XMonad.Config.Desktop
import           XMonad.Hooks.EwmhDesktops        (ewmh)
import           XMonad.Hooks.ManageDocks
import           XMonad.Layout.Spacing
import           XMonad.Prompt
import           XMonad.Util.CustomKeys
import           XMonad.Util.SpawnOnce

import           XMonad.ManageHook
import           XMonad.Util.NamedScratchpad

import           XMonad.Actions.DynamicWorkspaces

myWorkspaces = foldl (\b a -> b ++ [(show $ length b + 1) ++ ": " ++ a]) [] ["www", "dev", "term", "irc", "music", "leisure", "office", "etc", "misc"]
myTerminal = "termite"
myBorderWidth = 3
myFocusColor = "#5294EA"

myStartupHook = do
  spawnOnce "nitrogen --restore&"
  spawnOnce "xrdb -merge ~/.XResources &"
  spawnOnce "xsetroot -cursor_name left_ptr &"
  spawnOnce "taffybar &"

delKeys :: XConfig l -> [(KeyMask, KeySym)]
delKeys conf@(XConfig {modMask = modMask}) =
  [ ((modMask,  xK_p)) ]

insKeys :: XConfig l -> [((KeyMask, KeySym), X ())]
insKeys conf@(XConfig {modMask = modMask}) =
  [ ((modMask, xK_d),      spawn "rofi -show run")
  , ((modMask, xK_Tab),    spawn "rofi -show window")
  , ((modMask, xK_Return), spawn "termite")
  , ((modMask, xK_b),	   sendMessage ToggleStruts)
  ]

main = do
  xmonad
  -- Allows xmonad to handle taffybar
  -- $ docks

  -- Gives taffy bar logger information
  $ ewmh
  $ pagerHints $

  -- xmonad config
  desktopConfig
    { terminal           = myTerminal
    , borderWidth        = myBorderWidth
    , focusedBorderColor = myFocusColor
    , startupHook        = myStartupHook -- <+> startupHook desktopConfig
    , workspaces	 = myWorkspaces
    , keys               = customKeys delKeys insKeys
    }
