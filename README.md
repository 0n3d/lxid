# LXID (Lua X Input Daemon)

This is a minimal, performant and modular implementation of a hotkey daemon powered with Rust and Lua.
I made it for myself to load and unload keyboard hotkeys more dynamically than
sxhkd supports it. It also provides mouse support.

## Installation

**This project is still in development.**

Build the base using cargo.

```bash
cd base
cargo build --release
```

To use the standard libraries, install them using
the Makefile (Root privileges are needed).

```
make install-lib
```

## Configuration

LXID needs to be started by a user with a home directory. The initialization
file should be located at `~/.config/lxid/init.lua`.

All Lua 5.4 features are supported. To get started, include `lxid` and
initialize the features that will be used.

```lua
-- Beside keyboard, other available features are: click, move
local lxid = require"lxid".setup({keyboard = true})
```

This will initialize keyboard events. Add a new event listener using the insert
function.

```lua
lxid:insert("keydown", function(key)
  print("Key pressed: " .. key)
end)
```

Key signals are numbers that consist out of a category and local id.
To evaluate them more easily, use the lxid.key object.

```lua
local Key = require"lxid.key"
```

It is for example now possible to check if the `A` key on the keyboard was
released.

```lua
lxid:insert("keyup", function(key)
  if key == Key.alpha"A" then -- Always use uppercase keys
    print("A Key was released")
  end
end)
```

It is also possible to filter events. This is useful if multiple keystates
should be checked.

Use a `Keymap` to save the keystate of every key.

```lua
local keymap = require"lxid.keymap":new(lxid)
```

The keymap can now be used as an event extension. To create a new extended
function include the `event` module.

```lua
local ev = require"event"

-- If meta+Enter are pressed, open a terminal
lxid:insert("keydown", ev.ext(function()
  os.execute("alacritty")
end, {
  -- Call the keyboard extension and then run the event
  -- if not canceled
  ext = {keymap:ext(), ev.run},
  -- Extension information
  fields = {
    -- Execute the function if meta+E are pressed
    keys = {Key.SuperLeft, Key.Return},
  },
}))
```

Use the remove extension if an event should only be executed once.

```lua
local ev = require"event"

lxid:insert("keydown", ev.ext(function(key)
  print("Key pressed: " .. key)
end), {ext = {ev.run, ev.rem}}) -- Run and then remove the listener
```

Events can also be unloaded externally.

```lua
local listener_id = lxid:insert("keydown", function(key)
end)

lxid:remove("keydown", listener_id)
```

It is also possible to create custom event handlers. This will for example
merge the mousepress and keydown listener to one event.

```lua
local lxid = require"lxid".setup({keyboard = true, click = true})
local Key = require"lxid.key"
local ev = require"event"

-- Create a new event handler
local handler = ev.EventHandler:new()

-- Create a function that will refer to all registered listeners
local caller = handler:create_caller()

lxid:insert("keydown", caller)
lxid:insert("mousepress", caller)

handler:insert(function(key)
  -- Check if the key is in category mouse
  if Key.prefix(key) == Key.category.Mouse then
    print("Mousepress")
  else
    print("Keydown")
  end
end)
```

To create a collection of event handlers, use an event pool. `lxid` is also an
instance of this object.

```lua
local ev = require"event"

local pool = ev.EventPool:new()
-- Create a new event handler with the name "event"
pool:create_namespace("event")
-- Get the event handler and create a caller function
local caller = pool:get_namespace("event"):create_caller()

pool:insert("event", function(message)
  print("Listener called with message: " .. message)
end)

caller("Hello World!")
```
```
Listener called with message: Hello World!
```

Every library (including lxid itself) is optional and can be 
changed/extended/replaced with another implementation in Lua.
