local default_style = data.raw["gui-style"].default

local PADDING = 8
local WIDTH = 280

default_style["camerasan_container"] = {
  type = "vertical_flow_style",
  padding_top    = PADDING,
  padding_bottom = PADDING,
  padding_left   = PADDING,
  padding_right  = PADDING,
  maximal_width  = WIDTH + PADDING*2
}

default_style["camerasan_camera"] = {
  type = "camera_style",
  width = WIDTH,
  height = WIDTH
}

default_style["camerasan_target_button"] = {
  type = "button_style",
  maximal_width = WIDTH
}
