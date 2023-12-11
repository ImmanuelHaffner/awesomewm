
--[[

     Powerarrow Darker Awesome WM config 2.0
     github.com/copycat-killer

--]]

local theme                                     = {}

-- Copycat's Theme
theme.dir                                       = os.getenv("HOME") .. "/.config/awesome/themes/powerarrow-darker"
-- Wallpaper
theme.wallpaper                                 = os.getenv("HOME") .. "/.config/awesome/wallpaper"

-- Display DPI, used for calculating pixel sizes
theme.dpi                                       = 162 -- in DPI

-- Colors
theme.green                                     = "#7AC82E"
theme.blue                                      = "#2587CC"
theme.magenta                                   = "#CD357E"
theme.lightgrey                                 = "#313131"
theme.darkgrey                                  = "#1A1A1A"

-- Font: Style, Size, Color, Background
theme.font                                      = "Source Code Pro 8"
theme.calendar_font                             = "Source Code Pro 8"
theme.fs_font                                   = "Source Code Pro 7"
theme.fg_normal                                 = theme.blue
theme.fg_focus                                  = theme.green
theme.fg_urgent                                 = theme.magenta
theme.fg_minimize                               = "#808080"
theme.bg_normal                                 = theme.darkgrey
theme.bg_focus                                  = theme.lightgrey
theme.bg_urgent                                 = theme.darkgrey
theme.border_width                              = 2
theme.border_normal                             = "#3F3F3F"
theme.border_focus                              = theme.magenta
theme.border_marked                             = "#CC9393"
theme.tasklist_bg_focus                         = theme.darkgrey
theme.tasklist_fg_focus                         = theme.green
theme.titlebar_bg_focus                         = "#FFFFFF"
theme.titlebar_bg_normal                        = "#FFFFFF"
theme.titlebar_fg_focus                         = theme.green
theme.taglist_bg_focus                          = theme.darkgrey
theme.taglist_fg_focus                          = theme.green

-- Menu
theme.menu_height                               = 25
theme.menu_width                                = 140
theme.menu_submenu_icon                         = theme.dir .. "/icons/submenu.png"

-- Layout
theme.taglist_squares_sel                       = theme.dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel                     = theme.dir .. "/icons/square_unsel.png"
theme.layout_tile                               = theme.dir .. "/icons/tile.png"
theme.layout_tilegaps                           = theme.dir .. "/icons/tilegaps.png"
theme.layout_tileleft                           = theme.dir .. "/icons/tileleft.png"
theme.layout_tilebottom                         = theme.dir .. "/icons/tilebottom.png"
theme.layout_tiletop                            = theme.dir .. "/icons/tiletop.png"
theme.layout_fairv                              = theme.dir .. "/icons/fairv.png"
theme.layout_fairh                              = theme.dir .. "/icons/fairh.png"
theme.layout_spiral                             = theme.dir .. "/icons/spiral.png"
theme.layout_dwindle                            = theme.dir .. "/icons/dwindle.png"
theme.layout_max                                = theme.dir .. "/icons/max.png"
theme.layout_fullscreen                         = theme.dir .. "/icons/fullscreen.png"
theme.layout_magnifier                          = theme.dir .. "/icons/magnifier.png"
theme.layout_floating                           = theme.dir .. "/icons/floating.png"

-- Widget
theme.widget_ac                                 = theme.dir .. "/icons/ac.png"
theme.widget_battery                            = theme.dir .. "/icons/battery.png"
theme.widget_battery_low                        = theme.dir .. "/icons/battery_low.png"
theme.widget_battery_empty                      = theme.dir .. "/icons/battery_empty.png"
theme.widget_mem                                = theme.dir .. "/icons/mem.png"
theme.widget_cpu                                = theme.dir .. "/icons/cpu.png"
theme.widget_temp                               = theme.dir .. "/icons/temp.png"
theme.widget_net                                = theme.dir .. "/icons/net.png"
theme.widget_hdd                                = theme.dir .. "/icons/hdd.png"
theme.widget_music                              = theme.dir .. "/icons/note.png"
theme.widget_music_on                           = theme.dir .. "/icons/note_on.png"
theme.widget_vol                                = theme.dir .. "/icons/vol.png"
theme.widget_vol_low                            = theme.dir .. "/icons/vol_low.png"
theme.widget_vol_no                             = theme.dir .. "/icons/vol_no.png"
theme.widget_vol_mute                           = theme.dir .. "/icons/vol_mute.png"
theme.widget_mail                               = theme.dir .. "/icons/mail.png"
theme.widget_mail_on                            = theme.dir .. "/icons/mail_on.png"

-- Tasklist
theme.tasklist_plain_task_name                  = false
theme.tasklist_disable_icon                     = true

theme.useless_gap                               = 0

-- Titlebar
theme.titlebar_close_button_focus               = theme.dir .. "/icons/titlebar/close_focus.png"
theme.titlebar_close_button_normal              = theme.dir .. "/icons/titlebar/close_normal.png"
theme.titlebar_ontop_button_focus_active        = theme.dir .. "/icons/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active       = theme.dir .. "/icons/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive      = theme.dir .. "/icons/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive     = theme.dir .. "/icons/titlebar/ontop_normal_inactive.png"
theme.titlebar_sticky_button_focus_active       = theme.dir .. "/icons/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active      = theme.dir .. "/icons/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive     = theme.dir .. "/icons/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive    = theme.dir .. "/icons/titlebar/sticky_normal_inactive.png"
theme.titlebar_floating_button_focus_active     = theme.dir .. "/icons/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active    = theme.dir .. "/icons/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive   = theme.dir .. "/icons/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive  = theme.dir .. "/icons/titlebar/floating_normal_inactive.png"
theme.titlebar_maximized_button_focus_active    = theme.dir .. "/icons/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active   = theme.dir .. "/icons/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = theme.dir .. "/icons/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme.dir .. "/icons/titlebar/maximized_normal_inactive.png"

-- Custom config
theme.weather_city_id                           = 2842647 -- Saarbrücken
theme.quake_height_relative                     = .35 -- relative
theme.mem_load_lo                               =  2000 -- in MiB
theme.mem_load_hi                               = 26000 -- in MiB
theme.cpu_load_lo                               =  5 -- in %
theme.cpu_load_hi                               = 80 -- in %
theme.temp_lo                                   = 48 -- in °C
theme.temp_hi                                   = 80 -- in °C
theme.fs_load_lo                                = 75 -- in %
theme.fs_load_hi                                = 90 -- in %
theme.bat_charge_lo                             = 10 -- in %
theme.bat_charge_hi                             = 25 -- in %
theme.net_recv_lo                               = 2000 -- in KiB/s
theme.net_recv_hi                               = 8000 -- in KiB/s
theme.net_send_lo                               =  100 -- in KiB/s
theme.net_send_hi                               =  400 -- in KiB/s
theme.temp_file                                 = "/sys/class/thermal/thermal_zone7/temp"
theme.ac_name                                   = "AC" -- name of the power plug device
theme.master_width_factor                       = .85 -- used to calculate size of magnified clients

return theme
