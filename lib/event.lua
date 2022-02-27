-- Events
--
-- Reason for this file
-- Most of the time an event just occurs once but needs to be shared to multiple
-- handlers. This file resolves this issue by creating a handler object that
-- calls every function that was registered to an event. This handler can also
-- register multiple types of events dynamically (See create_namespace). At
-- creation it is also possible to specify extensions that can manipulate the
-- procedure of handling events (See extensions).

--- Standard extensions for the extension function
--- An extension is simply a function wich can take
--- 1. the function
--- 2. the extension fields
--- 3. infinite amount of parameters that should be given to the handler
local extensions = {
  -- Execute the delivered function
  run = function(func, _, ...)
    func(...)
  end,
  -- Execute the delivered function like an extension
  rich_run = function(func, ext, ...)
    return func(ext, ...)
  end,
  -- Cancel the extension queue
  cancel = function(_, ext)
    if ext.cancel then
      return {
        -- Stop running extensions from the queue
        con = false,
      }
    end
  end,
  -- Remove the extension
  rem = function()
    return {
      -- With a truthy value, the event handler will unload the event
      ret = true,
    }
  end,
}

--- A Handler is a function with extra information
--- This allows extensions to perform special actions
--- which can for example remove a handler automatically
--- This function is also aliased as event.fh
---
--- @example
--- local func = ext(
---  function() print("Hello World!") end,
---  {ext = {ev.run}},
--- )
---
--- @class ExtensionInitialisationContext
--- @field ext function
--- @field fields table
---
--- @class ExtensionReturnContext
--- @field con boolean
--- @field ret any
---
--- @param func function
--- @param ext ExtensionInitialisationContext
--- @return function
local function ext(func, ext)
  local lext = ext or {ext = {extensions.run}, fields = {}}
  local fields = lext.fields or {}

  return function(...)
    local ret = nil
    for _,extension in ipairs(lext.ext) do
      local tret = extension(func, fields, ...)
      if type(tret) == "table" then
        if type(tret.con) ~= "nil" and not tret.con then
          break
        end

        if type(tret.ret) ~= "nil" then
          ret = tret
        end
      end
    end

    return ret
  end
end

--- Root EventHandler object
--- See EventHandler:new to learn how to create a new instance
---
--- @class EventHandler
--- @field id integer
--- @field callees table
local EventHandler = {}

--- A class which can share actions
--- to other procedures
---
--- @example
--- local event_handler = EventHandler:new(event.type.Normal)
---
--- @return EventHandler
function EventHandler:new()
  local obj = {}
  setmetatable(obj, {__index = self})
  obj.id = 0
  obj.callees = {}

  return obj
end

--- Creates a new number that is not in use
--- Used for identifying handlers
---
--- @return integer
function EventHandler:create_id()
  self.id = self.id + 1
  return self.id
end

--- Insert a new listener
--- handler: a handler that was created with event.create_handler
---
--- @example
--- local id = event_handler:insert(handler)
---
--- @param fh function
--- @return integer
function EventHandler:insert(fh)
  local id = self:create_id()
  self.callees[id] = fh
  return id
end

--- Remove a listener
--- namespace: a context that was created with create_namespace
--- id: a returned number by insert
---
--- @example
--- event_handler:remove("example", id)
---
--- @param id integer
function EventHandler:remove(id)
  self.callees[id] = nil
end

--- Remove all function handlers from call queue
--- Has the effect of unloading the object but
--- every event sender has the responsibility
--- stop executing the call function.
function EventHandler:remove_all()
  self.callees = {}
end

--- Call a context
--- parameters: provided parameters that will be given to the handlers
--- If a handler function returns true it will be removed from the call list
---
--- @example
--- event_handler.call("example", "Hello World!")
---
--- @return boolean
function EventHandler:call(...)
  for key,handler in pairs(self.callees) do
    if handler(...) then
      self.callees[key] = nil
    end
  end

  return false
end

--- Create a function which anonymizes the event handler
--- If the returned function is called, all events will be executed
--- like EventHandler:call
---
--- @return function
function EventHandler:create_caller()
  return function(...)
    self:call(...)
  end
end

--- A collection of event handlers
--- This makes it possible to collect
--- multiple events for complex procedures
--- like a keymap.
---
--- @class EventPool
--- @field namespaces table
local EventPool = {}

function EventPool:new()
  local obj = {}
  setmetatable(obj, {__index = self})
  obj.namespaces = {}

  return obj
end

--- Create a new event handler under a specified name
---
--- @param namespace string
--- @return EventHandler
function EventPool:create_namespace(namespace)
  local handler = EventHandler:new()
  self.namespaces[namespace] = handler
  
  return self.namespaces[namespace]
end

--- Get an event handler by the given name
---
---@param namespace string
---@return EventHandler
function EventPool:get_namespace(namespace)
  return self.namespaces[namespace]
end

--- Remove an event handler
---
--- @param namespace string
function EventPool:remove_namespace(namespace)
  self.namespaces[namespace]:remove_all()
  self.namespaces[namespace] = nil
end

--- Insert a new event into a namespace
---
--- @param namespace string
--- @param fh function
function EventPool:insert(namespace, fh)
  self.namespaces[namespace]:insert(fh)
end

--- Remove a function handler from a namespace
---
--- @param namespace string
--- @param id integer
function EventPool:remove(namespace, id)
  self.namespaces[namespace]:remove(id)
end

-- event object/namespace
return {
  EventHandler = EventHandler,
  EventPool = EventPool,
  ext = ext,
  run = extensions.run,
  cancel = extensions.cancel,
  rich_run = extensions.rich_run,
  rem = extensions.rem,
  type = {
    Default = {extensions.run},
    WithOnce = {extensions.run, extensions.once},
  }
}
