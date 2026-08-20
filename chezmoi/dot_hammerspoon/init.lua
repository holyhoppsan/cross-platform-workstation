-- Managed by cross-platform-workstation. Hammerspoon requires Accessibility
-- permission before it can receive this global hotkey.
local wezterm = "/opt/homebrew/bin/wezterm"
if not hs.fs.attributes(wezterm) then wezterm = "/Applications/WezTerm.app/Contents/MacOS/wezterm" end

local quake_title = "wezterm-quake"
local width_ratio, height_ratio = 0.95, 1.00
local retry_count = 0
local quake_window_id = nil

hs.window.animationDuration = 0

local function focused_screen()
  local window = hs.window.focusedWindow()
  return (window and window:screen()) or hs.screen.mainScreen()
end

local function quake_window()
  if quake_window_id then
    local remembered = hs.window.get(quake_window_id)
    if remembered then return remembered end
    quake_window_id = nil
  end
  for _, window in ipairs(hs.window.allWindows()) do
    if window:title():find(quake_title, 1, true) then
      quake_window_id = window:id()
      return window
    end
  end
end

local function place_and_focus(window, screen)
  local frame = screen:frame()
  local width = math.floor(frame.w * width_ratio)
  window:unminimize()
  window:setFrame({ x = frame.x + math.floor((frame.w - width) / 2), y = frame.y, w = width, h = math.floor(frame.h * height_ratio) }, 0)
  window:focus()
end

local function reveal_after_launch(screen)
  local window = quake_window()
  if window then
    retry_count = 0
    place_and_focus(window, screen)
    return
  end
  retry_count = retry_count + 1
  if retry_count < 20 then hs.timer.doAfter(0.1, function() reveal_after_launch(screen) end) end
end

local function launch_quake(screen)
  retry_count = 0
  local command = "printf '\\033]0;" .. quake_title .. "\\007'; exec /opt/homebrew/bin/bash --login -i"
  local task = hs.task.new(wezterm, function() end, { "start", "--always-new-process", "--workspace", "quake", "--", "/opt/homebrew/bin/bash", "--login", "-i", "-c", command })
  if task and task:start() then hs.timer.doAfter(0.1, function() reveal_after_launch(screen) end) else hs.alert.show("Unable to launch WezTerm Quake window") end
end

hs.hotkey.bind({ "ctrl" }, "`", function()
  local window = quake_window()
  local focused = hs.window.focusedWindow()
  if window and focused and window:id() == focused:id() then
    window:minimize()
  elseif window then
    place_and_focus(window, focused_screen())
  else
    launch_quake(focused_screen())
  end
end)
