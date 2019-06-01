require "mod-gui"

DEBUG = false
CAMERA_TOGGLE_BUTTON = "camera_toggle"
TARGET_BUTTONS_PREFIX = "button_camera_target_"


-- Events --

script.on_init(function(event)
  global.show = {}
  global.target = {}
end)

-- Init a player's ui
script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]

  mod_gui.get_button_flow(player).add({
    type = "button",
    name = CAMERA_TOGGLE_BUTTON,
    caption = "Camera"
  })
end)

-- Update all guis when a player joins
script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.players[event.player_index]

  -- Show camera by default
  set_show_state(player, true)

  -- Add button for the player for all current players
  for _,other_player in pairs(game.players) do
    if other_player.connected and other_player ~= player then
      add_target_button(other_player, player)
    end
  end
end)

-- Update all guis when a player leaves
script.on_event(defines.events.on_player_left_game, function(event)
  local player = game.players[event.player_index]

  -- Remove the camera frame so it gets refreshed if the player comes back online
  set_show_state(player, false)

  -- Remove the target button from all players
  for _,other_player in pairs(game.players) do
    if other_player.connected and other_player ~= player then
      remove_target_button(other_player, player)
    end
  end
end)

-- Handle button clicks
script.on_event(defines.events.on_gui_click, function(event)
  local clicker = game.players[event.player_index]
  local element_name = event.element.name
  -- Clicked element is a player target button
  if element_name:sub(1, #TARGET_BUTTONS_PREFIX) == TARGET_BUTTONS_PREFIX then
    local target_name = element_name:sub(#TARGET_BUTTONS_PREFIX + 1)
    set_target_for(clicker, game.get_player(target_name))
  -- Clicked on camera toggle button
  elseif element_name == CAMERA_TOGGLE_BUTTON then
    set_show_state(clicker, not get_show_state(clicker))
  end
end)

-- Update camera loop
script.on_event(defines.events.on_tick, function(event)
  update_camera_element()
end)


-- Functions --


function get_show_state(player)
  return global.show[player.index]
end

function set_show_state(player, state)
  if get_show_state(player) ~= state then
    global.show[player.index] = state

    if get_show_state(player) then
      create_camera_frame(player)
    else
      destroy_camera_frame(player)
    end
  end
end

function get_button_name(player)
  return TARGET_BUTTONS_PREFIX .. player.name
end

function get_target_for(player)
  return game.players[global.target[player.index]]
end

function set_target_for(player, target)
  global.target[player.index] = target.index
end

-- Create the camera frame
function create_camera_frame(player)
  local root_element = player.gui.left

  -- Frame holding all mod ui elements
  local frame = mod_gui.get_frame_flow(player).add {type = "frame", name="camera_frame", direction = "vertical"}
  local base_element = frame.add { type = "flow", name = "element_flow", direction = "vertical" }
  local PADDING = 8
  base_element.style.top_padding = PADDING
  base_element.style.left_padding = PADDING
  base_element.style.right_padding = PADDING
  base_element.style.bottom_padding = PADDING
  base_element.style.maximal_width = 280 + PADDING*2

  local camera_element = base_element.add {type = "camera", name="camera", position = player.position, surface_index = player.surface.index, zoom = 0.25}
  camera_element.style.width = 280
  camera_element.style.height = 280

  -- Set a default camera target
  set_target_for(player, player) 

  -- Add buttons for all connected players
  for _,other_player in pairs(game.players) do
    if other_player.connected then
      add_target_button(player, other_player)
    end
  end

  return camera_element
end

-- Remove the camera from for a given player
function destroy_camera_frame(player)
  get_frame(player).destroy()
end

function get_frame(player)
  return mod_gui.get_frame_flow(player).camera_frame
end

function get_base_element(player)
  return get_frame(player).element_flow
end

-- Add button
function add_target_button(player, target)
  local base_element = get_base_element(player)
  local button = base_element.add{type = "button", name = get_button_name(target), caption = target.name}
  button.style.maximal_width = 280
end

-- Remove button
function remove_target_button(player, target)
  local base_element = get_button_name(player)
  base_element[get_button_name(target)].destroy()
end

-- Update the camera position
function update_camera_element()
  for _,player in pairs(game.players) do
    if player.connected and global.show[player.index] then
      local camera_element = get_base_element(player).camera
      local target = get_target_for(player)
      camera_element.position = target.position
      camera_element.surface_index = target.surface.index
    end
  end
end


-- Utilities --


function has_value(table, value)
  for _,v in pairs(table) do
      if v == value then
          return true
      end
  end
  return false
end

function print_to(player, message)
  if DEBUG then
    player.print(serpent.block(message))
  end
end

-- vim: et:sw=2:ts=2
