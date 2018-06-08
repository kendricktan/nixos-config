import           Data.Maybe                           (fromMaybe)
import           System.Environment                   (lookupEnv)

import           System.Taffybar

import           System.Taffybar.Pager
import           System.Taffybar.TaffyPager
import           System.Taffybar.WindowSwitcher
import           System.Taffybar.WorkspaceSwitcher

import           System.Taffybar.Battery
import           System.Taffybar.MPRIS2
import           System.Taffybar.SimpleClock
import           System.Taffybar.Systray

import           System.Taffybar.Widgets.PollingBar
import           System.Taffybar.Widgets.PollingGraph

import           System.Information.CPU
import           System.Information.Memory


import           Control.Applicative                  ((<$>))

pagerCfg = defaultPagerConfig
  { emptyWorkspace = colorize "#6b6b6b" "" . escape . wrap "[" "]"
  , activeWorkspace  = colorize "#429942" "" . escape . wrap "<" ">"
  }

main = do
    scr <- maybe 0 read <$> lookupEnv "TAFFY_SCREEN"

    pager <- pagerNew pagerCfg

    let wss = wspaceSwitcherNew pager
        wnd = windowSwitcherNew pager

        clock = textClockNew Nothing "<span fgcolor='orange'>%a %b %_d %H:%M</span>" 1
        mpris = mpris2New
        battery = textBatteryNew "$percentage$%/$time$" 60
        tray = systrayNew
        -- vol = volumeW

        mem = pollingGraphNew memCfg 1 memCallback
            where
                memCallback = do
                    mi <- parseMeminfo
                    return [memoryUsedRatio mi]
                memCfg = defaultGraphConfig
                    { graphDataColors = [(1, 0, 0, 1)]
                    , graphLabel = Nothing
                    , graphDirection = RIGHT_TO_LEFT
                    }

        cpu = pollingGraphNew cpuCfg 1 cpuCallback
            where
                cpuCallback = do
                    (_, _, totalLoad) <- cpuLoad
                    return [totalLoad]
                cpuCfg = defaultGraphConfig
                    { graphDataColors = [(0, 1, 0, 1)]
                    , graphLabel = Nothing
                    , graphDirection = RIGHT_TO_LEFT
                    }

    defaultTaffybar defaultTaffybarConfig
        { barHeight = 20
        , monitorNumber = scr
        -- , startWidgets = [wss, wnd]
        , startWidgets = [wss]
        , endWidgets = reverse $ if scr == 0
            then [mpris, cpu, mem, battery, clock, tray]
            else [clock]
        }
