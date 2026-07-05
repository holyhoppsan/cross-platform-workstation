local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder and wezterm.config_builder() or {}

local function agent_state_from_title(title)
  title = title:lower()
  for _, state in ipairs { 'running', 'waiting', 'complete', 'failed' } do
    if title:find('agent:' .. state, 1, true) then return state end
  end
  return nil
end

config.default_prog = nil
if wezterm.target_triple:find('windows') then
  local program_files = os.getenv('ProgramFiles') or 'C:/Program Files'
  local local_app_data = os.getenv('LOCALAPPDATA') or ''
  local candidates = {
    program_files .. '/Git/bin/bash.exe',
    program_files .. '/Git/usr/bin/bash.exe',
    local_app_data .. '/Programs/Git/bin/bash.exe',
  }
  for _, candidate in ipairs(candidates) do
    local file = io.open(candidate, 'r')
    if file then
      file:close()
      config.default_prog = { candidate, '--login', '-i' }
      break
    end
  end
elseif wezterm.target_triple:find('apple') then
  for _, candidate in ipairs({ '/opt/homebrew/bin/bash', '/usr/local/bin/bash', '/bin/bash' }) do
    local file = io.open(candidate, 'r')
    if file then
      file:close()
      config.default_prog = { candidate, '--login' }
      break
    end
  end
else
  config.default_prog = { '/bin/bash', '--login' }
end

config.font = wezterm.font_with_fallback {
  'JetBrains Mono', 'Cascadia Mono', 'Menlo', 'DejaVu Sans Mono', 'monospace',
}
config.font_size = 11.0
config.color_scheme = 'Builtin Solarized Dark'
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.window_decorations = 'RESIZE'
config.animation_fps = 1
config.cursor_blink_rate = 0
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1500 }

config.keys = {
  { key = '|', mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
  { key = 'H', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'J', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Down', 5 } },
  { key = 'K', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Up', 5 } },
  { key = 'L', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Right', 5 } },
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
  { key = 'w', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
  { key = 'p', mods = 'LEADER', action = act.PromptInputLine {
      description = 'Project directory (creates/switches workspace)',
      action = wezterm.action_callback(function(window, pane, line)
        if line and line ~= '' then
          local name = line:gsub('[/\\]+$', ''):match('([^/\\]+)$') or 'project'
          window:perform_action(act.SwitchToWorkspace { name = name, spawn = { cwd = line } }, pane)
        end
      end),
    } },
  { key = 'q', mods = 'LEADER', action = act.SwitchToWorkspace { name = 'quake' } },
  { key = 'r', mods = 'LEADER', action = act.PromptInputLine {
      description = 'Rename workspace',
      action = wezterm.action_callback(function(window, pane, line)
        if line then wezterm.mux.rename_workspace(window:active_workspace(), line) end
      end),
    } },
  { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },
  { key = 'a', mods = 'LEADER', action = act.SendKey { key = 'a', mods = 'CTRL' } },
  { key = 'u', mods = 'LEADER', action = act.EmitEvent 'workstation-next-agent' },
}

for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i), mods = 'LEADER', action = act.ActivateTab(i - 1),
  })
end

wezterm.on('workstation-next-agent', function(window, pane)
  local panes = window:active_tab():panes()
  local current_id = pane:pane_id()
  local after_current = false
  local first_attention = nil
  for _, candidate in ipairs(panes) do
    local state = agent_state_from_title(candidate:get_title())
    local needs_attention = state == 'waiting' or state == 'complete' or state == 'failed'
    if needs_attention and not first_attention then first_attention = candidate end
    if after_current and needs_attention then
      candidate:activate()
      return
    end
    if candidate:pane_id() == current_id then after_current = true end
  end
  if first_attention then first_attention:activate() end
end)

wezterm.on('update-right-status', function(window, pane)
  local agent_state = agent_state_from_title(pane:get_title()) or 'idle'
  window:set_right_status(wezterm.format {
    { Foreground = { Color = '#93a1a1' } },
    { Text = ' workspace: ' .. window:active_workspace() .. ' | agent: ' .. agent_state .. ' ' },
  })
end)

return config
