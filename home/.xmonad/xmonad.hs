import XMonad
import           Graphics.X11.ExtraTypes
import           XMonad.Prompt.Shell
import qualified Data.Map        as M
import qualified XMonad.StackSet as W
import           XMonad.Prompt
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageHelpers
import XMonad.Actions.CycleWS
import XMonad.Hooks.SetWMName (setWMName)
import           XMonad.Actions.SpawnOn
import System.Exit

main = xmonad . modConf =<< statusBar "taffybar" def toggleStatusBarVisibilityKey conf
  where
    toggleStatusBarVisibilityKey xc = (modMask xc, xK_b)

    modConf cnf = cnf { manageHook = manageSpawn <+> manageHook cnf }

    conf =
      def
        { keys = myKeys
        , modMask = mod4Mask
        , startupHook = myStartupHook
        , workspaces = map show [1..9]
        , manageHook = mconcat
            [ isFullscreen                   --> doFullFloat
            , className =? "Gimp"            --> doFloat
            , className =? "Telegram"        --> doShift "IM"
            , className =? "vlc"             --> doCenterFloat
            , transience'
            , isDialog                       --> doCenterFloat
            , role      =? "pop-up"          --> doCenterFloat
            ]
        }
    role = stringProperty "WM_WINDOW_ROLE"

myStartupHook =
  spawn "compton --backend glx --xrender-sync --xrender-sync-fence -fcCz -l -17 -t -17"
  <+> spawn "trayer --edge top --height 48 --width 5 --align left --margin 30 --transparent true --alpha 157 --tint 0x000000"
  <+> setWMName "LG3D"
  <+> spawn "konsole -e tmux"
  <+> spawn "telegram-desktop"

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- close focused window
    , ((modm , xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- floating layer stuff
    , ((modm .|. shiftMask                                    , xK_f     ), withFocused $ windows . W.sink)
    , ((modm                                                  , xK_f     ), withFocused $ windows . (flip W.float) (W.RationalRect (0) (1/50) (1/1) (1/1)))
    , ((modm                                                  , xK_z     ), toggleWS)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    , ((modm              , xK_r     ), shellPrompt def)

    -- Mute volume
    , ( (0, xF86XK_AudioMute), spawn $ ".xmonad/volume.sh mute" )
    -- Decrease volume
    , ( (0, xF86XK_AudioLowerVolume), spawn $ ".xmonad/volume.sh dec" )
    -- Increase volume
    , ( (0, xF86XK_AudioRaiseVolume), spawn $ ".xmonad/volume.sh inc" )
    -- Decrease brightness
    , ( (0, xF86XK_MonBrightnessDown), spawn "xbacklight -dec 10")
    -- Increase brightness
    , ((0, xF86XK_MonBrightnessUp), spawn "xbacklight -inc 10")
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
