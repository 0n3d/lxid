-- ns = namespace
local ns = {
  -- Every Key is member of a category and has a prefix
  category = {
    -- F1-12 Keys
    Function = 0xf000,
    -- Control, Alt, Super, Shift, Home...
    Special = 0xe000,
    -- Arrow Keys
    Direction = 0xd000,
    -- Backspace, Space, Tab
    Whitespace = 0xc000,
    -- A, B, C...
    Alpha = 0x0000,
    -- 1, 2, 3..
    Number = 0x1000,
    -- All Keypad Keys: Multiply, Divide, 1, 2, 3...
    Keypad = 0x2000,
    -- Dot, Comma, SquareBraceOpen...
    Symbol = 0x3000,
  },
  -- Function Key Values
  -- Better use Key.func(number)
  F1  = 0xf001,
  F2  = 0xf002,
  F3  = 0xf003,
  F4  = 0xf004,
  F5  = 0xf005,
  F6  = 0xf006,
  F7  = 0xf007,
  F8  = 0xf008,
  F9  = 0xf009,
  F10 = 0xf00a,
  F11 = 0xf00b,
  F12 = 0xf00c,

  -- Special Keys
  Alt = 0xe000,
  AltGr = 0xe001,
  CtrlLeft = 0xe002,
  CtrlRight = 0xe003,
  Escape = 0xe004,
  MetaLeft = 0xe005,
  SuperLeft = 0xe005,
  MetaRight = 0xe006,
  SuperRight = 0xe006,
  ShiftLeft = 0xe008,
  ShiftRight = 0xe009,
  Home = 0xe00a,
  End = 0xe00b,
  PageDown = 0xe00c,
  PageUp = 0xe00d,
  Return = 0xe00e,
  Insert = 0xe00f,
  CapsLock = 0xe010,
  Delete = 0xe011,

  -- Directional Keys
  ArrowUp = 0xd000,
  ArrowDown = 0xd001,
  ArrowLeft = 0xd002,
  ArrowRight = 0xd003,

  -- Whitespace Keys
  -- Also possible to use Key.whitespace
  Tab = 0xc009,
  Backspace = 0xc00a,
  Space = 0xc020,

  -- Keypad extra inputs
  KeypadLock = 0x200a,
  KeypadPlus = 0x200b,
  KeypadMinus = 0x200c,
  KeypadMultiply = 0x200d,
  KeypadDivide = 0x200f,
  KeypadReturn = 0x200e,
  KeypadDelete = 0x2011,

  MouseButtonLeft = 0x4001,
  MouseButtonRight = 0x4002,
  MouseButtonMiddle = 0x4003,
}

--- Get a function key value
---
--- @example
--- Key.func(1) -- Equal to Key.F1
---
--- @param num integer
--- @return integer
function ns.func(num)
  return ns.category.Function | num
end

--- Get numeric key value
---
--- @example
--- Key.number(1) -- Gets the 1 number key value
---
--- @param num integer
--- @return integer
function ns.number(num)
  return ns.category.Number | num
end

--- Get numeric keypad value
---
--- @example
--- Key.keypad(1) -- Gets the 1 keypad value
---
--- @param num integer
--- @return integer
function ns.keypad(num)
  return ns.category.Keypad | num
end

--- Get a whitespace value
---
--- @example
--- Key.whitespace" " -- Gets the space key value
---
--- @param char string
--- @return integer
function ns.whitespace(char)
  return ns.category.Whitespace | string.byte(char)
end

--- Get a symbol value
---
--- @example
--- Key.symbol"." -- Get the dot key value
---
--- @param char string
--- @return integer
function ns.symbol(char)
  return ns.category.Symbol | string.byte(char)
end

--- Get a letter value
---
--- @example
--- Key.alpha"A" -- Gets the "a" key value
---
--- @param char string
--- @return integer
function ns.alpha(char)
  return string.byte(char)
end

--- Removes the category information from the input value
--- Without the prefix, it is possible to compare letters directly
---
--- @example
--- local val = Key.strip_prefix(input)
--- if val == "." or val == "A" then
---   print("Dot or A key")
--- end
---
--- @param key integer
--- @return integer
function ns.strip_prefix(key)
  return key & 0x0fff
end

--- Strips the key from the input value
--- With this, it is possible to compare the output
--- to a type.
---
--- @example
--- if Key.prefix(input) == Key.category.Keypad then
---   print("Pressed a key on the keypad")
--- end
---
--- @param key integer
--- @return integer
function ns.prefix(key)
  return key & 0xf000
end

return ns
