-- profile_menu.lua
-- Ctrl+P: mở menu chọn video profile (Film / Anime / BW / Fast / Safe)

local mp = require "mp"

-- Danh sách profile video hiện tại của bạn
local profiles = {
    { name = "Film",             label = "Film (default)" },
    { name = "Film_HQ",          label = "Film HQ" },
    { name = "Film_BW_Upscale",  label = "Film B/W Upscale" },
    { name = "Anime_HQ",         label = "Anime HQ" },
    { name = "Anime_LQ",         label = "Anime LQ" },
    { name = "Fast",             label = "Fast (low GPU)" },
    { name = "Safe_NoShader",    label = "Safe (no shader)" },
}

local menu_active = false
local selected_index = 1
local active_profile = "Film"
local was_paused = false

local function render_menu()
    local lines = {}
    table.insert(lines, "=== VIDEO PROFILE MENU ===")
    table.insert(lines, "")

    for i, p in ipairs(profiles) do
        local selector = (i == selected_index) and ">" or " "
        local mark = (p.name == active_profile) and "[*]" or "[ ]"
        local line = string.format("%s %s  %d) %s", selector, mark, i, p.label)
        table.insert(lines, line)
    end

    table.insert(lines, "")
    table.insert(lines, "↑/↓: chọn  |  Enter: áp dụng  |  Esc/Ctrl+P: thoát")

    mp.osd_message(table.concat(lines, "\n"), 10)
end

local function close_menu()
    menu_active = false
    mp.osd_message("", 0)

    mp.remove_key_binding("profile_menu_up")
    mp.remove_key_binding("profile_menu_down")
    mp.remove_key_binding("profile_menu_enter")
    mp.remove_key_binding("profile_menu_escape")

    mp.set_property_bool("pause", was_paused)
end

local function apply_selected_profile()
    local p = profiles[selected_index]
    if not p then return end

    mp.commandv("apply-profile", p.name)
    active_profile = p.name
    mp.osd_message("Applied: " .. p.label, 1.5)
end

local function toggle_menu()
    if menu_active then
        close_menu()
        return
    end

    menu_active = true
    was_paused = mp.get_property_bool("pause", false)
    mp.set_property_bool("pause", true)

    -- chọn dòng đang active nếu có
    for i, p in ipairs(profiles) do
        if p.name == active_profile then
            selected_index = i
            break
        end
    end

    mp.add_forced_key_binding("UP", "profile_menu_up", function()
        if not menu_active then return end
        selected_index = selected_index - 1
        if selected_index < 1 then selected_index = #profiles end
        render_menu()
    end, "repeatable")

    mp.add_forced_key_binding("DOWN", "profile_menu_down", function()
        if not menu_active then return end
        selected_index = selected_index + 1
        if selected_index > #profiles then selected_index = 1 end
        render_menu()
    end, "repeatable")

    mp.add_forced_key_binding("ENTER", "profile_menu_enter", function()
        if not menu_active then return end
        apply_selected_profile()
        close_menu()
    end)

    mp.add_forced_key_binding("ESC", "profile_menu_escape", function()
        if not menu_active then return end
        close_menu()
    end)

    render_menu()
end

-- Ctrl+P để mở/đóng menu
mp.add_key_binding("Ctrl+p", "toggle_profile_menu", toggle_menu)
