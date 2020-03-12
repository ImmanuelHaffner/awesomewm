-- vim: set tabstop=2 shiftwidth=2:
--[[

     Powerarrow Darker Awesome WM config 2.0
     github.com/copycat-killer

--]]

-- {{{ Required libraries
local gears         = require("gears")
local awful         = require("awful")
require("myautofocus")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local lain          = require("lain")
--local menubar       = require("menubar")
local freedesktop   = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- }}}

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Autostart applications
local function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd))
end

run_once("urxvtd")
run_once("unclutter -root")
-- }}}

-- {{{ Variable definitions
-- beautiful init
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/theme.lua")

-- common
local modkey        = "Mod4"
local altkey        = "Mod1"
local terminal      = "/usr/bin/sakura"
local editor        = "/usr/bin/nvim"

-- user defined
local browser       = "/usr/bin/qutebrowser"
local mail          = "/usr/bin/thunderbird"
local chat          = "/usr/bin/franz"
local musicplr      = "/usr/bin/spotify"
local gui_editor    = "/usr/bin/gvim"
local graphics      = "/usr/bin/gimp"
local file_browser  = "/usr/bin/nemo"
local iptraf        = terminal .. " -e /usr/bin/bwm-ng"
local mixer         = terminal .. " -e /usr/bin/alsamixer"
local musicctl      = terminal .. " -e /usr/bin/ncmpcpp"
local alsamixer     = terminal .. " -e /usr/bin/alsamixer"
local pavuc         = "/usr/bin/pavucontrol"
local top           = terminal .. " -e /usr/bin/htop"
local screenshot    = "/usr/bin/spectacle"
local lock          = "/usr/local/bin/slock2"

local tagnames   = {"term", "web", "doc", "file", "app", "gfx", "chat"}

-- table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.fair,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.floating,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier,
    --awful.layout.suit.corner.nw,
    --awful.layout.suit.corner.ne,
    --awful.layout.suit.corner.sw,
    --awful.layout.suit.corner.se,
}

-- lain
lain.layout.termfair.nmaster        = 3
lain.layout.termfair.ncol           = 1
lain.layout.termfair.center.nmaster = 3
lain.layout.termfair.center.ncol    = 1
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end

-- Execute a command on all *other* clients on a screen
local function for_other_clients(the_screen, the_client, fn)
  for i, c in pairs(the_screen.clients) do
    if c ~= the_client then
      fn(c)
    end
  end
end
-- }}}

-- {{{ Menu
local myawesomemenu = {
    { "hotkeys", function() return false, hotkeys_popup.show_help end },
    { "manual", terminal .. " -e man awesome" },
    { "edit config", string.format("%s -e %s %s", terminal, editor, awesome.conffile) },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end }
}
local mymainmenu = freedesktop.menu.build({
    before = {
        { "Awesome", myawesomemenu, beautiful.awesome_icon },
        -- other triads can be put here
    },
    after = {
        { "Open terminal", terminal },
        -- other triads can be put here
    }
})
--menubar.utils.terminal = terminal -- Set the Menubar terminal for applications that require it
-- }}}

-- {{{ Wibox
local markup = lain.util.markup
local separators = lain.util.separators

local clockicon = wibox.widget.imagebox(beautiful.widget_clock)

local mytextclock = lain.widgets.abase({
    timeout  = 5,
    cmd      = " date +'%a %d %b %R'",
    settings = function()
        widget:set_markup(" " .. output)
    end
})

-- calendar
lain.widgets.calendar.attach(mytextclock, {
    cal = "/usr/bin/cal -m --color=always",
    notification_preset = {
        font = "Inconsolata 12",
        fg   = beautiful.fg_normal,
        bg   = beautiful.bg_normal
    }
})

-- Weather
local myweather = lain.widgets.weather({
    city_id = 2842647, -- Saarbrücken
    settings = function()
        units = math.floor(weather_now["main"]["temp"])
        widget:set_markup(" " .. units .. "° ")
    end
})
myweather.attach(myweather.icon)

-- MPD
local mpdicon = wibox.widget.imagebox(beautiful.widget_music)
mpdicon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(musicctl) end)))
local mpdwidget = lain.widgets.mpd({
    settings = function()
        if mpd_now.state == "play" then
            artist = " " .. mpd_now.artist .. " "
            title  = mpd_now.title  .. " "
            mpdicon:set_image(beautiful.widget_music_on)
        elseif mpd_now.state == "pause" then
            artist = ""
            title  = "paused "
        else
            artist = ""
            title  = ""
            mpdicon:set_image(beautiful.widget_music)
        end

        widget:set_markup(markup("#EA6F81", artist) .. title)
    end
})
local mpdbtns = awful.util.table.join(
  awful.button( {}, 1, function () awful.util.spawn_with_shell( musicctl ) end ),
  awful.button( {}, 3, function () os.execute( "/usr/bin/mpc toggle") end ))
mpdicon:buttons(mpdbtns)
mpdwidget:buttons(mpdbtns)

-- MEM
local memicon = wibox.widget.imagebox(beautiful.widget_mem)
local memwidget = lain.widgets.mem({
    settings = function()
        local mem = tonumber(mem_now.used)
        if mem < 2000 then
          widget:set_markup(markup(beautiful.blue, string.format(" %4dMB ", mem)))
        elseif mem < 26000 then
          widget:set_markup(markup(beautiful.green, string.format(" %4dMB ", mem)))
        else
          widget:set_markup(markup(beautiful.blue, string.format(" %4dMB ", mem)))
        end
    end
})

-- CPU
local cpuicon = wibox.widget.imagebox(beautiful.widget_cpu)
local cpuwidget = lain.widgets.cpu({
    settings = function()
        local usage = tonumber(cpu_now.usage)
        if usage < 5 then
            widget:set_markup(markup(beautiful.blue, string.format(" %3d%% ", usage)))
        elseif usage < 80 then
            widget:set_markup(markup(beautiful.green, string.format(" %3d%% ", usage)))
        else
            widget:set_markup(markup(beautiful.magenta, string.format(" %3d%% ", usage)))
        end
    end
})
local cpubtns = awful.util.table.join(awful.button( {}, 1, function () awful.util.spawn_with_shell( top ) end ))
cpuicon:buttons(cpubtns)
cpuwidget:buttons(cpubtns)


-- Coretemp
local tempicon = wibox.widget.imagebox(beautiful.widget_temp)
local tempwidget = lain.widgets.temp({
    settings = function()
        local temp = tonumber(coretemp_now)
        if temp < 48 then
            widget:set_markup(markup(beautiful.blue, string.format(" %3d°C ", temp)))
        elseif temp < 80 then
            widget:set_markup(markup(beautiful.green, string.format(" %3d°C ", temp)))
        else
            widget:set_markup(markup(beautiful.magenta, string.format(" %3d°C ", temp)))
        end
    end
})

-- / fs
local fsicon = wibox.widget.imagebox(beautiful.widget_hdd)
local fsroot = lain.widgets.fs({
    options  = "--exclude-type=tmpfs",
    notification_preset = {
      fg = beautiful.fg_normal,
      bg = beautiful.bg_normal,
      font = "Inconsolata 11"
    },
    settings = function()
        local used = tonumber(fs_now.used)
        if used < 75 then
            widget:set_markup(markup(beautiful.blue, string.format(" %3d%% ", used)))
        elseif used < 95 then
            widget:set_markup(markup(beautiful.green, string.format(" %3d%% ", used)))
        else
            widget:set_markup(markup(beautiful.magenta, string.format(" %3d%% ", used)))
        end
    end
})

-- Battery
local baticon = wibox.widget.imagebox(beautiful.widget_battery)
local batwidget = lain.widgets.bat({
    settings = function()
        if bat_now.status ~= "N/A" then
            if bat_now.ac_status == 1 then
                widget:set_text("")
                baticon:set_image(beautiful.widget_ac)
                return
            elseif type(bat_now.perc) == "number" then
                -- select color and icon
                local perc = bat_now.perc
                local color = beautiful.blue
                local img = beautiful.widget_battery
                if perc < 10 then
                    color = beautiful.magenta
                    img = beautiful.widget_battery_empty
                elseif perc < 25 then
                    color = beautiful.green
                    img = beautiful.widget_battery_low
                end
                -- construct text: 42% (4:20, 42W)
                s = string.format("%3d%%", perc)
                if bat_now.time ~= "00:00" then
                    s = s .. " (" .. bat_now.time
                    if tonumber(bat_now.watt) ~= 0 then
                        s = s .. " " .. bat_now.watt .. "W"
                    end
                    s = s .. ")"
                end
                widget:set_markup(markup(color, " " .. s .. " "))
                baticon:set_image(img)
            else
                widget:set_text(string.format(" %3d%% ", tonumber(bat_now.perc)))
            end
        else
            baticon:set_image(beautiful.widget_ac)
        end
    end
})

-- ALSA volume
local volicon = wibox.widget.imagebox(beautiful.widget_vol)
local volume = lain.widgets.alsa({
    settings = function()
        if volume_now.status == "off" then
            volicon:set_image(beautiful.widget_vol_mute)
        elseif tonumber(volume_now.level) == 0 then
            volicon:set_image(beautiful.widget_vol_no)
        elseif tonumber(volume_now.level) <= 50 then
            volicon:set_image(beautiful.widget_vol_low)
        else
            volicon:set_image(beautiful.widget_vol)
        end
        widget:set_text(string.format(" %3d%% ", tonumber(volume_now.level)))
    end
})
local volbtns = awful.util.table.join(
  awful.button( {}, 1, function () awful.util.spawn( pavuc ) end ),
  awful.button( {}, 4, function ()
    awful.util.spawn_with_shell("amixer -D pulse sset Master 5%+")
    volume.update()
  end ),
  awful.button( {}, 5, function ()
    awful.util.spawn_with_shell("amixer -D pulse sset Master 5%-")
    volume.update()
  end ),
  awful.button( {}, 3, function ()
    awful.util.spawn_with_shell("amixer -D pulse sset Master toggle")
    volume.update()
  end ))
volicon:buttons(volbtns)
volume:buttons(volbtns)

-- Net
local neticon = wibox.widget.imagebox(beautiful.widget_net)
local netwidget = lain.widgets.net({
  settings = function()
    local recv = tonumber(net_now.received)
    local sent = tonumber(net_now.sent)
    local color_recv = beautiful.blue
    local color_sent = beautiful.blue
    if recv > 8000 then
      color_recv = beautiful.magenta
    elseif recv > 2000 then
      color_recv = beautiful.green
    end
    if sent > 400 then
      color_sent = beautiful.magenta
    elseif sent > 100 then
      color_sent = beautiful.green
    end

    widget:set_markup(markup(color_recv, string.format('%6.1f', recv))
    .. '  '
    ..  markup(color_sent, string.format('%5.1f', sent))
    .. ' ')
  end
})
neticon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(iptraf) end)))
netwidget:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(iptraf) end)))

-- Separators
local spr     = wibox.widget.textbox(' ')
local arrl_dl = separators.arrow_left(beautiful.bg_focus, "alpha")
local arrl_ld = separators.arrow_left("alpha", beautiful.bg_focus)

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 2, function(t)
                                     if client.focus then
                                       client.focus:move_to_tag(t)
                                     end
                                   end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end)
                )

local tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                       if c.minimized then
                         c.minimized = false
                         if not c:isvisible() and c.first_tag then
                           c.first_tag:view_only()
                         end
                         client.focus = c
                         c:raise()
                       elseif client.focus == c then
                         if c.maximized then
                           c.maximized = false
                           c.maximized_horizontal = false
                           c.maximized_vertical = false
                         else
                           c.maximized = true
                           c:raise()
                         end
                       else
                         client.focus = c
                         c:raise()
                       end
                     end),
                     awful.button({ }, 3, function (c)
                       if not c.minimized then
                         c.minimized = true
                       else
                         -- Without this, the following
                         -- :isvisible() makes no sense
                         c.minimized = false
                         if not c:isvisible() and c.first_tag then
                           c.first_tag:view_only()
                         end
                       end
                     end),
                     awful.button({ }, 2, client_menu_toggle_fn()))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Quake application
    s.quake = lain.util.quake({ app = terminal, height=.35, followtag = true, argname = "--name %s", border = beautiful.border_width })

    -- Wallpaper
    set_wallpaper(s)

    -- Tags
    awful.tag(tagnames, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    local mybasewidget = wibox.layout.flex.horizontal()
    mybasewidget.fg_focus     = beautiful.fg_focus
    mybasewidget.fg_normal    = beautiful.fg_normal
    mybasewidget.fg_urgent    = beautiful.fg_urgent
    mybasewidget.fg_minimize  = "#808080"

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons, mybasewidget)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = 20 })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            spr,
            s.mytaglist,
            s.mypromptbox,
            spr,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            spr,
            arrl_ld,
            wibox.container.background(mpdicon, beautiful.bg_focus),
            wibox.container.background(mpdwidget, beautiful.bg_focus),
            arrl_dl,
            volicon,
            volume,
            arrl_ld,
            wibox.container.background(myweather.icon, beautiful.bg_focus),
            wibox.container.background(myweather, beautiful.bg_focus),
            arrl_dl,
            memicon,
            memwidget,
            arrl_ld,
            wibox.container.background(cpuicon, beautiful.bg_focus),
            wibox.container.background(cpuwidget, beautiful.bg_focus),
            arrl_dl,
            tempicon,
            tempwidget,
            arrl_ld,
            wibox.container.background(fsicon, beautiful.bg_focus),
            wibox.container.background(fsroot, beautiful.bg_focus),
            arrl_dl,
            baticon,
            batwidget,
            arrl_ld,
            wibox.container.background(neticon, beautiful.bg_focus),
            wibox.container.background(netwidget, beautiful.bg_focus),
            arrl_dl,
            mytextclock,
            spr,
            arrl_ld,
            wibox.container.background(s.mylayoutbox, beautiful.bg_focus),
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Quake terminal
    awful.key({ modkey }, "`", function() awful.screen.focused().quake:toggle() end),

    -- Lock screen
    awful.key({ modkey, altkey }, "l", function() awful.spawn(terminal .. ' -x ' .. lock) end,
              {description = "Lock screen", group = "launcher"}),

    -- Take a screenshot
    awful.key({ }, "Print", function() awful.spawn(screenshot) end),

    -- Hotkeys
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    -- Tag browsing
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    -- Non-empty tag browsing
    awful.key({ altkey }, "Left", function () lain.util.tag_view_nonempty(-1) end,
              {description = "view  previous nonempty", group = "tag"}),
    awful.key({ altkey }, "Right", function () lain.util.tag_view_nonempty(1) end,
              {description = "view  next nonempty", group = "tag"}),

    -- Default client focus
    awful.key({ altkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ altkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),

    -- By direction client focus
    awful.key({ modkey }, "j",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "k",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "h",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "l",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey, "Shift"   }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Move clients within screen
    awful.key({ modkey, "Shift"   }, "h", function () awful.client.swap.bydirection("left") end,
              {description = "swap with client left", group = "client"}),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.bydirection("down") end,
              {description = "swap with client below", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.bydirection("up") end,
              {description = "swap with client above", group = "client"}),
    awful.key({ modkey, "Shift"   }, "l", function () awful.client.swap.bydirection("right") end,
              {description = "swap with client right", group = "client"}),

    -- Change screen
    awful.key({ modkey, "Control" }, "h", function () awful.screen.focus_bydirection("left") end,
              {description = "focus the screen to the left", group = "screen"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_bydirection("down") end,
              {description = "focus the screen below", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_bydirection("up") end,
              {description = "focus the screen above", group = "screen"}),
    awful.key({ modkey, "Control" }, "l", function () awful.screen.focus_bydirection("right") end,
              {description = "focus the screen to the right", group = "screen"}),

    -- Move clients between screens
    awful.key({ modkey, "Control", "Shift" }, "h", function ()
      local c = client.focus
      awful.screen.focus_bydirection("left")
      awful.client.movetoscreen(c, mouse.screen)
      client.focus = c
      c:raise()
    end,
              {description = "move client to the screen to the left", group = "screen"}),
    awful.key({ modkey, "Control", "Shift" }, "j", function ()
      local c = client.focus
      awful.screen.focus_bydirection("down")
      awful.client.movetoscreen(c, mouse.screen)
      client.focus = c
      c:raise()
    end,
              {description = "move client to the screen below", group = "screen"}),
    awful.key({ modkey, "Control", "Shift" }, "k", function ()
      local c = client.focus
      awful.screen.focus_bydirection("up")
      awful.client.movetoscreen(c, mouse.screen)
      client.focus = c
      c:raise()
    end,
              {description = "move client to the screen above", group = "screen"}),
    awful.key({ modkey, "Control", "Shift" }, "l", function ()
      local c = client.focus
      awful.screen.focus_bydirection("right")
      awful.client.movetoscreen(c, mouse.screen)
      client.focus = c
      c:raise()
    end,
              {description = "move client to the screen to the right", group = "screen"}),

    -- Jump to *urgent* client (among all tags)
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    -- Switch focus to previously focused client on the same tag
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
        for s in screen do
            s.mywibox.visible = not s.mywibox.visible
        end
    end),

    -- On the fly useless gaps change
    --awful.key({ altkey, "Control" }, "+", function () lain.util.useless_gaps_resize(1) end),
    --awful.key({ altkey, "Control" }, "-", function () lain.util.useless_gaps_resize(-1) end),

    -- Dynamic tagging
    awful.key({ modkey, "Shift" }, "n", function () lain.util.add_tag() end,
              {description = "add new tag", group = "tag"}),
    awful.key({ modkey, "Shift" }, "r", function () lain.util.rename_tag() end,
              {description = "rename tag", group = "tag"}),
    awful.key({ modkey, "Shift" }, "Left", function () lain.util.move_tag(-1) end,
              {description = "move tag left", group = "tag"}),
    awful.key({ modkey, "Shift" }, "Right", function () lain.util.move_tag(1) end,
              {description = "move tag right", group = "tag"}),
    awful.key({ modkey, "Shift" }, "d", function () lain.util.delete_tag() end,
              {description = "delete tag", group = "tag"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "BackSpace", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    --awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              --{description = "quit awesome", group = "awesome"}),

    awful.key({ altkey, "Shift"   }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ altkey, "Shift"   }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    --awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              --{description = "increase the number of master clients", group = "layout"}),
    --awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              --{description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Dropdown application
    awful.key({ modkey, }, "z", function () awful.screen.focused().quake:toggle() end),

    -- Screen Brightness
    awful.key({}, "XF86MonBrightnessUp",
        function ()
            awful.util.spawn_with_shell("xbacklight -steps 5 -set $(($(xbacklight -get) * 1.3 + 2))")
        end),
    awful.key({}, "XF86MonBrightnessDown",
        function ()
            awful.util.spawn_with_shell("xbacklight -steps 5 -set $(($(xbacklight -get) / 1.3 - 2))")
        end),

    -- Pulse volume control
    awful.key({ modkey }, "Up",
        function ()
            awful.util.spawn_with_shell("amixer -D pulse sset Master 5%+")
            volume.update()
        end,
        {description = "increase volume", group = "pulse"}),
    awful.key({}, "XF86AudioRaiseVolume",
        function ()
            awful.util.spawn_with_shell("amixer -D pulse sset Master 5%+")
            volume.update()
        end),
    awful.key({ modkey }, "Down",
        function ()
            awful.util.spawn_with_shell("amixer -D pulse sset Master 5%-")
            volume.update()
        end,
        {description = "decrease volume", group = "pulse"}),
    awful.key({},"XF86AudioLowerVolume",
        function ()
            awful.util.spawn_with_shell("amixer -D pulse sset Master 5%-")
            volume.update()
        end),
    awful.key({ modkey }, "m",
        function ()
            awful.util.spawn_with_shell("amixer -D pulse sset Master toggle")
            volume.update()
        end,
        {description = "mute", group = "pulse"}),
    awful.key({}, "XF86AudioMute",
        function ()
            awful.util.spawn_with_shell("amixer -D pulse sset Master toggle")
            volume.update()
        end),

    -- MPD control
    -- open ncmpcpp
    awful.key({ modkey, altkey }, "n",
      function()
        awful.util.spawn_with_shell(musicctl)
      end,
      {description = "Open NCMPCPP", group = "mpd"}),
    -- toggle Pause/Play
    awful.key({ altkey, "Control" }, "p",
      function ()
        awful.util.spawn_with_shell( "mpc toggle" )
        mpdwidget.update()
      end,
      {description = "Pause/Play", group = "mpd"}),
    awful.key( {}, "XF86AudioPlay",
      function ()
        awful.util.spawn_with_shell( "mpc toggle || ncmpcpp toggle" )
        mpdwidget.update()
      end),
    awful.key( {}, "XF86AudioNext",
      function ()
        awful.util.spawn_with_shell( "mpc next || ncmpcpp next" )
        mpdwidget.update()
      end),
    awful.key( {}, "XF86AudioPrev",
      function ()
        awful.util.spawn_with_shell( "mpc prev || ncmpcpp prev" )
        mpdwidget.update()
      end),
    awful.key( {}, "XF86AudioStop",
      function ()
        awful.util.spawn_with_shell( "mpc stop || ncmpcpp stop" )
        mpdwidget.update()
      end),
    awful.key({ altkey, "Control" }, "Up",
      function ()
        awful.util.spawn_with_shell("mpc volume +5")
        mpdwidget.update()
      end,
      {description = "increase volume", group = "mpd"}),
    awful.key({ altkey, "Control" }, "Down",
      function ()
        awful.util.spawn_with_shell("mpc volume -5")
        mpdwidget.update()
      end,
      {description = "decrease volume", group = "mpd"}),
    awful.key({ altkey, "Control" }, "Left",
      function ()
        awful.util.spawn_with_shell("mpc prev || ncmpcpp prev || ncmpc prev || pms prev")
        mpdwidget.update()
      end,
      {description = "previous song", group = "mpd"}),
    awful.key({ altkey, "Control" }, "Right",
      function ()
        awful.util.spawn_with_shell("mpc next || ncmpcpp next || ncmpc next || pms next")
        mpdwidget.update()
      end,
      {description = "next song", group = "mpd"}),

    -- Copy primary to clipboard
    awful.key({ modkey }, "c", function () os.execute("xsel | xsel -b") end),

    -- User programs
    awful.key({ modkey }, "F1", function () awful.util.spawn(browser) end,
              {description = "Browser", group = "launcher"}),
    awful.key({ modkey }, "F2", function () awful.util.spawn(mail) end,
              {description = "Mail", group = "launcher"}),
    awful.key({ modkey }, "F3", function () awful.util.spawn(chat) end,
              {description = "Chat", group = "launcher"}),
    awful.key({ modkey }, "F4", function () awful.util.spawn(file_browser) end,
              {description = "File Browser", group = "launcher"}),
    awful.key({ modkey }, "F5", function () awful.util.spawn(musicplr) end,
              {description = "File Browser", group = "launcher"}),

    -- Default
    -- Prompt
    awful.key({ modkey }, "r", function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"})
    -- Menubar
    --awful.key({ modkey }, "p", function() menubar.show() end,
              --{description = "show the menubar", group = "launcher"})
    --]]

    --[[ dmenu
    --awful.key({ modkey }, "x", function ()
        --awful.spawn(string.format("dmenu_run -i -fn 'Tamsyn' -nb '%s' -nf '%s' -sb '%s' -sf '%s'",
        --beautiful.bg_normal, beautiful.fg_normal, beautiful.bg_focus, beautiful.fg_focus))
    --end)
    --]]
)

clientkeys = awful.util.table.join(
    awful.key({ altkey, "Shift"   }, "m", lain.util.magnify_client,
              {description = "magnify", group = "client"}),
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    --awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              --{description = "move to master", group = "client"}),
    --awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              --{description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,"Shift"    }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end,
        {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false
      },
      callback = function (c)
        c.screen = awful.screen.focused() or screen.primary
        awful.client.setslave(c)
        c:raise()
      end
    },

    -- Titlebars
    { rule_any = { type = { "dialog", "normal" } },
      properties = { titlebars_enabled = false } },

    -- Put spectacle on top and focus immediately
    { rule = { class = "spectacle" },
      callback =
        function (c)
          c.ontop = true
          client.focus = c
          c:raise()
        end },

    -- Nemo file transfer
    { rule = { class = "file_progress" },
      callback = function(c)
        c.ontop = true
        c:raise()
      end },

    -- place Firefox on tag 2
    { rule = { class = "Firefox" },
      properties = { tag = awful.screen.focused().tags[2] } },

    -- place qutebrowser on tag 2
    { rule = { class = "qutebrowser" },
      properties = { tag = awful.screen.focused().tags[2] } },

    -- place Thunderbird on tag 2
    { rule = { class = "Thunderbird" },
      properties = { tag = awful.screen.focused().tags[2] } },

    -- raise Password Prompts always to top
    { rule = { class = "Firefox", name = "Password Required" },
      callback =
        function (c)
          client.focus = c
          c:raise()
        end },

    { rule = { class = "Thunderbird", name = "Password Required" },
      callback =
        function (c)
          client.focus = c
          c:raise()
        end },

    -- place Messengers on the chat tag
    { rule = { class = "Franz" },
      properties = { tag = awful.screen.focused().tags[7] } },
    { rule = { class = "Rambox" },
      properties = { tag = awful.screen.focused().tags[7] } },
    { rule = { class = "discord" },
      properties = { tag = awful.screen.focused().tags[7] } },

    -- place Spotify on app tag
    { rule = { class = "Spotify" },
      properties = { tag = awful.screen.focused().tags[5] } },
    -- place Steam stuff on app tag
    { rule = { class = "Steam" },
      properties = { tag = awful.screen.focused().tags[5] } },
    -- Place Battle.net and games on app tag
    { rule = { name = "Blizzard Battle.net" },
      properties = { tag = awful.screen.focused().tags[5], floating = true } },
    { rule = { name = "Hearthstone" },
      properties = { tag = awful.screen.focused().tags[5] } },

    -- place Gimp on graphics tag
    { rule = { class = "Gimp" },
      properties = { tag = awful.screen.focused().tags[6] } },
    -- maximize image windows
    { rule = { class = "Gimp", role = "gimp-image-window" },
      properties = { maximized = true } },
    -- put the dock and toolbox ontop
    { rule = { class = "Gimp", role = "gimp-toolbox" },
      properties = { ontop = true } },
    { rule = { class = "Gimp", role = "gimp-dock" },
      properties = { ontop = true } },

    -- place Inkscape on graphics tag
    { rule = { class = "Inkscape" },
      properties = { tag = awful.screen.focused().tags[6] } },

    -- place Genymotion on apps tag and make player float
    { rule = { class = "Genymotion" },
      properties = { tag = awful.screen.focused().tags[5] } },
    { rule = { class = "Genymotion Player" },
      properties = { floating = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    local f = awful.client.focus.filter(c)
    if c ~= nil then
      awful.client.focus.history.add(f)
    end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Signal function to execute when a client disappears.
client.connect_signal("unmanage", function (c)
  awful.client.focus.history.delete(c)
  local prev = awful.client.focus.history.get(c.screen, 0, awful.client.focus.filter)
  if prev ~= nil then
    client.focus = prev
  end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c, {size = 16}) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
--client.connect_signal("mouse::enter", function(c)
    --if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        --and awful.client.focus.filter(c) then
        --client.focus = c
    --end
--end)

-- No border for maximized clients
client.connect_signal("focus", function(c)
  if c.maximized == true or #c.screen.clients == 1 then
    c.border_width = 0
  else
  --elseif #c.screen.clients > 1 then
    if #c.screen.clients == 2 then
      for_other_clients(c.screen, c, function (c)
        c.border_width = beautiful.border_width
      end)
    end
    c.border_width = beautiful.border_width
    c.border_color = beautiful.border_focus
  end
end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
