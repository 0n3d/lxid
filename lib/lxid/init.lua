-- LXID Root
--
-- Reason for this file
-- The rust api executes lua code at the start to initialize necessary
-- components. After the entries were found, they are copied to the rust
-- endpoint which makes executing events pretty static. This root document is
-- for loading and unloading call handlers dynamically.

local ev = require("event")

--- Element that is returned after setup()
--- This element only appears once because it represents
--- the lua lxid session.
local lxid = {
  pool = ev.EventPool:new(),
  options = {},
}

--- Initializes the lxid program with this library.
--- Use options adjust the root setup handlers.
---
--- @example
--- lxid_require.setup({keyboard = true}) -- Activate keyboard events
---
--- @param options table
--- @return table
local function setup(options)
  lxid.options = options
  if options.keyboard then
    lxid.pool:create_namespace("keydown")
    lxid.pool:create_namespace("keyup")

    -- Bind handlers to rust api
    _G._plxid.v1.keydown = lxid.pool:get_namespace("keydown"):create_caller()
    _G._plxid.v1.keyup = lxid.pool:get_namespace("keyup"):create_caller()
  end

  if options.click then
    lxid.pool:create_namespace("mousepress")
    lxid.pool:create_namespace("mouserelease")

    _G._plxid.v1.mousepress = lxid.pool:get_namespace("mousepress"):create_caller()
    _G._plxid.v1.mouserelease = lxid.pool:get_namespace("mouserelease"):create_caller()
  end

  if options.move then
    lxid.pool:create_namespace("mousemove")

    _G._plxid.v1.mousemove = lxid.pool:get_namespace("mousemove"):create_caller()
  end

  return lxid.pool
end

return {
  setup = setup,
  context = lxid,
}
