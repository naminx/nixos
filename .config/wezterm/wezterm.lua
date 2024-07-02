local wezterm = require 'wezterm';

local xcursor_size = nil
local xcursor_theme = nil

local success, stdout, stderr = wezterm.run_child_process({"gsettings", "get", "org.gnome.desktop.interface", "cursor-theme"})
if success then
  xcursor_theme = stdout:gsub("'(.+)'\n", "%1")
end

local success, stdout, stderr = wezterm.run_child_process({"gsettings", "get", "org.gnome.desktop.interface", "cursor-size"})
if success then
  xcursor_size = tonumber(stdout)
end

-- Resize the window (called by event handlers)
function resize_window(window, pane, cols, rows)
  local overrides = window:get_config_overrides() or {}
  overrides.initial_cols = cols
  overrides.initial_rows = rows
  window:set_config_overrides(overrides)
  window:perform_action("ResetFontAndWindowSize", pane)
end

wezterm.on("resize-my-window", function(window, pane)
  resize_window(window, pane, 120, 32)
end)

return
  { xcursor_theme = xcursor_theme
  , xcursor_size = xcursor_size
  , font = wezterm.font_with_fallback
      ( -- base font
        { "FiraCode Nerd Font"
        -- Japanese font
        -- , "UD Gothic Round R"
        , "Minna Gothic M"
        -- Thai font
        , "DroidSans"
        }
      )
  , harfbuzz_features = {"cv02", "cv10", "ss03", "ss05", "ss06", "ss09", "cv25", "cv32"}
  , font_size = 11
  , scrollback_lines = 3000
  , enable_scroll_bar = true
  , window_padding =
      { -- left = 0
        -- This will become the scrollbar width if you have enabled the scrollbar!
        right = 20
        -- top = 0
        -- bottom = 0
      }
  , initial_cols = 120
  , initial_rows = 32
  , keys =
      { { key = "c"
        , mods = "CTRL"
        , action = wezterm.action_callback
            ( function ( window, pane )
                local has_selection = window:get_selection_text_for_pane (pane) ~= ""
                if has_selection then
                  window:perform_action
                    ( wezterm.action { CopyTo = "ClipboardAndPrimarySelection" }
                    , pane
                    )
                  window:perform_action( "ClearSelection", pane )
                else
                  window:perform_action
                    ( wezterm.action { SendKey = { key = "c", mods = "CTRL" } }
                    , pane
                    )
                end
              end
            )
        }
      , { key = "c"
        , mods = "CTRL|SHIFT"
        , action = wezterm.action { SendKey = { key = "c", mods = "CTRL" } }
        }
      , { key = "v"
        , mods = "CTRL"
        , action = wezterm.action.PasteFrom "Clipboard"
        }
      , { key = "v"
        , mods = "CTRL|SHIFT"
        , action = wezterm.action { SendKey = { key = "v", mods = "CTRL" } }
        }
      , { key = "1"
        , mods = "CTRL"
        , action = wezterm.action {EmitEvent="resize-my-window"}
        }
      }
    , hide_mouse_cursor_when_typing = false
    , enable_wayland = false
  }
