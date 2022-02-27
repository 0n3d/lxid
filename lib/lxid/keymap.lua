local Keymap = {}

-- A map for memorizing keystrokes
--
-- @example
-- local keymap = Keymap:new(lxkbd)
function Keymap:new(interface)
  local obj = {}
  setmetatable(obj, {__index = self})
  obj.id = 0
  obj.keys = {}
  obj.keydown = {}
  obj.keyup = {}
  obj.keydown_id = 0
  obj.keyup_id = 0
  obj.mousepress_id = 0
  obj.mouserelease_id = 0

  obj:register(interface)

  return obj
end

-- The plugin for an event handler
-- Only executes a function if every key in keys is pressed
--
-- @example
-- local handler = lxkbd.create_handler({keymap:ext(), event.ext.run})
function Keymap:ext()
  return function(_, ext)
    if type(ext.keys) == "table" then
      if not self:combo_pressed(ext.keys) then
        return {con = false}
      end
    end

    return {con = true}
  end
end

-- Internal function
-- Updates a key to its new state
-- true: key pressed
-- false: key not pressed
function Keymap:update_key(key, state)
  self.keys[key] = state
end

function Keymap:register(interface)
  -- Register keyboard if feature available
  if type(interface:get_namespace("keydown")) ~= "nil"
      and type(interface:get_namespace("keyup")) ~= "nil" then
    self.keydown_id = interface:insert("keydown", function(key)
      self:update_key(key, true)
    end)

    self.keyup_id = interface:insert("keyup", function(key)
      self:update_key(key, false)
    end)
  end

  -- Register mouse if feature available
  if type(interface:get_namespace("mousepress")) ~= "nil"
      and type(interface:get_namespace("mouserelease")) ~= "nil" then
    self.mousepress_id = interface:insert("mousepress", function(button)
      self:update_key(button, true)
    end)

    self.mouserelease_id = interface:insert("mouserelease", function(button)
      self:update_key(button, false)
    end)
  end
end

function Keymap:unload(interface)
  interface:remove("keydown", self.keydown_id)
  interface:remove("keyup", self.keyup_id)
end

function Keymap:pressed(key)
  return self.keys[key]
end

-- Checks if a chain of keys is pressed
function Keymap:combo_pressed(keys)
  for _,key in ipairs(keys) do
    if not self:pressed(key) then
      return false
    end
  end

  return true
end

return Keymap
