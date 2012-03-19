--
-- xmonad example config file.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--
-- vim :fdm=marker sw=4 sts=4 ts=4 et ai:

import XMonad
-- import XMonad.Actions.RotView    ( rotView )
import XMonad.Layout             ( (|||), Full(..) )
import XMonad.Layout.NoBorders   (noBorders)
import XMonad.Layout.PerWorkspace
import XMonad.Layout.LayoutHints
import XMonad.Layout.ThreeColumns
import XMonad.Layout.LayoutHints ( layoutHints )
import XMonad.Hooks.DynamicLog   ( PP(..), dynamicLogWithPP, dzenColor, wrap, defaultPP )
import XMonad.Hooks.UrgencyHook
import XMonad.Prompt             ( defaultXPConfig, XPConfig(..), XPPosition(..) )
import XMonad.Prompt.Shell       ( shellPrompt )
import XMonad.Util.Run


import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import Data.Ratio
import Graphics.X11
import System.IO

import System.Exit

-- Control Center {{{
-- Colour scheme {{{
myNormalBGColor     = "#2e3436"
myFocusedBGColor    = "#414141"
myNormalFGColor     = "#babdb6"
myFocusedFGColor    = "#73d216"
myUrgentFGColor     = "#f57900"
myUrgentBGColor     = myNormalBGColor
mySeperatorColor    = "#2e3436"
-- }}}
-- Icon packs can be found here:
-- http://robm.selfip.net/wiki.sh/-main/DzenIconPacks
myBitmapsDir        = "/home/andreas/.share/icons/dzen"
myFont              = "-*-terminus-medium-*-*-*-12-*-*-*-*-*-iso8859-1"
-- }}}


-- statusBarCmd= "dzen2 -e '' -w 1024 -ta l -fg white -bg \"#222222\" -fn \"-*-terminus-*-r-*-*-12-*-*-*-*-*-iso8859-1\""
statusBarCmd= "dzen2 -p -h 16 -ta l -bg '" ++ myNormalBGColor ++ "' -fg '" ++ myNormalFGColor ++ "' -w 640 -sa c -fn '" ++ myFont ++ "'"


main = do
    statusBarPipe <- spawnPipe statusBarCmd
    xmonad $ defaultConfig {
          modMask            = mod1Mask
        , borderWidth        = 1
        , normalBorderColor  = myNormalBGColor
        , focusedBorderColor = myFocusedFGColor
        , terminal           = "x-terminal-emulator"
        , workspaces         = ["main","net","www"]
                               ++ map show [4..9]
        , defaultGaps        = [(16,0,0,0)]
        , logHook            = dynamicLogWithPP $ myPP statusBarPipe
        , mouseBindings      = \c -> myMouse c `M.union` mouseBindings defaultConfig c
        , keys               = \c -> myKeys c `M.union` keys defaultConfig c
	, manageHook         = manageHook defaultConfig <+> myManageHook
        }


myManageHook = composeAll [
        className   =? "Firefox-bin"        --> doF(W.shift "internet"),
        className   =? "Gajim.py"           --> doF(W.shift "chat"),
 
        title       =? "Gajim"              --> doFloat,
        title       =? "Iceweasel Preferences" --> doFloat,
        title       =? "Add-ons"            --> doFloat,
        className   =? "Ayttm"              --> doFloat,
        className   =? "Totem"              --> doFloat,
        className   =? "xine"               --> doFloat,
        className   =? "Pidgin"             --> doFloat,
        className   =? "Skype"              --> doFloat,
        className   =? "stalonetray"        --> doIgnore,
        className   =? "trayer"             --> doIgnore
    ]




myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
  [ ((modMask, xK_p), spawn ("exec `dmenu_path | dmenu -fn '" ++ myFont ++ "' -nb '" ++ myNormalBGColor ++ "' -nf '" ++ myNormalFGColor ++ "' -sb '" ++ myFocusedBGColor ++ "' -sf '" ++ myFocusedFGColor ++ "'`"))
  , ((modMask .|. shiftMask, xK_plus ), spawn "amixer -q set PCM 2dB+")
  , ((modMask .|. shiftMask, xK_minus ), spawn "amixer -q set PCM 2dB-")
--  , ((0, 0x1008ff12), spawn "amixer -q set Front toggle")
--  , ((0, 0x1008ff13), spawn "amixer -q set PCM 2dB+")
--  , ((0, 0x1008ff11), spawn "amixer -q set PCM 2dB-")
  ]
 
-- myPromptConfig = defaultXPConfig
--                   { position = Top
--                   , promptBorderWidth = 0
--                   }

myMouse (XConfig {XMonad.modMask = modMask}) = M.fromList $
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2), (\w -> focus w >> windows W.swapMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]
 
-- myMouse (XConfig {XMonad.modMask = modMask}) = M.fromList $
--    [ ((modMask, button4), (\_ -> rotView True))
--    , ((modMask, button5), (\_ -> rotView False))
--    ]

myPP handle = defaultPP {
    ppCurrent = wrap ("^fg(" ++ myFocusedFGColor ++ ")^bg(" ++ myFocusedBGColor ++ ")^p(4)") "^p(4)^fg()^bg()",
    ppUrgent = wrap ("^fg(" ++ myUrgentFGColor ++ ")^bg(" ++ myUrgentBGColor ++ ")^p(4)") "^p(4)^fg()^bg()",
    ppVisible = wrap ("^fg(" ++ myNormalFGColor ++ ")^bg(" ++ myNormalBGColor ++ ")^p(4)") "^p(4)^fg()^bg()",
    ppSep     = "^fg(" ++ mySeperatorColor ++ ")^r(3x3)^fg()",
    ppLayout  = (\x -> case x of
        "Tall"          -> " ^i(" ++ myBitmapsDir ++ "/tall.xbm) "
        "Mirror Tall"   -> " ^i(" ++ myBitmapsDir ++ "/mtall.xbm) "
        "Full"          -> " ^i(" ++ myBitmapsDir ++ "/full.xbm) "
        "ThreeCol"      -> " ^i(" ++ myBitmapsDir ++ "/threecol.xbm) "
        "Hinted Tall"          -> " ^i(" ++ myBitmapsDir ++ "/tall.xbm) "
        "Hinted Mirror Tall"   -> " ^i(" ++ myBitmapsDir ++ "/mtall.xbm) "
        "Hinted Full"          -> " ^i(" ++ myBitmapsDir ++ "/full.xbm) "
        "Hinted ThreeCol"      -> " ^i(" ++ myBitmapsDir ++ "/threecol.xbm) "
        _               -> " " ++ x ++ " "
        ),
        ppTitle   = wrap ("^fg(" ++ myFocusedFGColor ++ ")") "^fg()" ,
        ppOutput  = hPutStrLn handle
}

-- myPP handle = defaultPP
--          { ppCurrent  = dzenColor "white" "#cd8b00" . pad
--          , ppVisible  = dzenColor "white" "#666666" . pad
--          , ppHidden   = dzenColor "black" "#cccccc" . pad
--          , ppHiddenNoWindows = dzenColor "#999999" "#cccccc" . pad
--          , ppWsSep    = dzenColor "#bbbbbb" "#cccccc" "^r(1x18)"
--          , ppSep      = dzenColor "#bbbbbb" "#cccccc" "^r(1x18)"
--          , ppLayout   = dzenColor "black" "#cccccc" . pad
--          , ppTitle    = (' ':) . escape
--          , ppOutput   = hPutStrLn handle
--          }
--   where
--   	escape = concatMap (\x -> if x == '^' then "^^" else [x])
--   	pad = wrap " " " "



------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
-- myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
-- 
--   --   -- launch a terminal
--     [ ((modMask .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
-- 
--     -- launch dmenu
--     , ((modMask,               xK_p     ), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")
-- 
--     -- launch gmrun
--     , ((modMask .|. shiftMask, xK_p     ), spawn "gmrun")
-- 
--     -- close focused window 
--     , ((modMask .|. shiftMask, xK_c     ), kill)
-- 
--      -- Rotate through the available layout algorithms
--     , ((modMask,               xK_space ), sendMessage NextLayout)
-- 
--     --  Reset the layouts on the current workspace to default
--     , ((modMask .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
-- 
--     -- Resize viewed windows to the correct size
--     , ((modMask,               xK_n     ), refresh)
-- 
--     -- Move focus to the next window
--     , ((modMask,               xK_Tab   ), windows W.focusDown)
-- 
--     -- Move focus to the next window
--     , ((modMask,               xK_j     ), windows W.focusDown)
-- 
--     -- Move focus to the previous window
--     , ((modMask,               xK_k     ), windows W.focusUp  )
-- 
--     -- Move focus to the master window
--     , ((modMask,               xK_m     ), windows W.focusMaster  )
-- 
--     -- Swap the focused window and the master window
--     , ((modMask,               xK_Return), windows W.swapMaster)
-- 
--     -- Swap the focused window with the next window
--     , ((modMask .|. shiftMask, xK_j     ), windows W.swapDown  )
-- 
--     -- Swap the focused window with the previous window
--     , ((modMask .|. shiftMask, xK_k     ), windows W.swapUp    )
-- 
--     -- Shrink the master area
--     , ((modMask,               xK_h     ), sendMessage Shrink)
-- 
--     -- Expand the master area
--     , ((modMask,               xK_l     ), sendMessage Expand)
-- 
--     -- Push window back into tiling
--     , ((modMask,               xK_t     ), withFocused $ windows . W.sink)
-- 
--     -- Increment the number of windows in the master area
--     , ((modMask              , xK_comma ), sendMessage (IncMasterN 1))
-- 
--     -- Deincrement the number of windows in the master area
--     , ((modMask              , xK_period), sendMessage (IncMasterN (-1)))
-- 
--     -- toggle the status bar gap
--     , ((modMask              , xK_b     ),
--           modifyGap (\i n -> let x = (XMonad.defaultGaps conf ++ repeat (0,0,0,0)) !! i
--                              in if n == x then (0,0,0,0) else x))
-- 
--     -- Quit xmonad
--     , ((modMask .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))
-- 
--     -- Restart xmonad
--     , ((modMask              , xK_q     ), restart "xmonad" True)
--     ]
--     ++
-- 
--     --
--     -- mod-[1..9], Switch to workspace N
--     -- mod-shift-[1..9], Move client to workspace N
--     --
--     [((m .|. modMask, k), windows $ f i)
--         | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
--         , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
--     ++
-- 
--     --
--     -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
--     -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
--     --
--     [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
--         | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
--         , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
-- 
-- 
-- ------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
-- myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
-- 
--     -- mod-button1, Set the window to floating mode and move by dragging
--     [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w))
-- 
--     -- mod-button2, Raise the window to the top of the stack
--     , ((modMask, button2), (\w -> focus w >> windows W.swapMaster))
-- 
--     -- mod-button3, Set the window to floating mode and resize by dragging
--     , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w))
-- 
--   --   -- you may also bind events to the mouse scroll wheel (button4 and button5)
--     ]

