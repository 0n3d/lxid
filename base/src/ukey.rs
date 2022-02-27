use rdev::{ Key, Button };

pub struct UKey(pub Key);

impl UKey {
    pub fn to_int(&self) -> u16 {
        let fp = 0xf000; // Function Prefix
        let sp = 0xe000; // Special Prefix
        let dp = 0xd000; // Direction Prefix
        let wp = 0xc000; // Whitespace Prefix
        let mp = 0x0000; // Alpha Prefix
        let np = 0x1000; // Number Prefix
        let kp = 0x2000; // Keypad Prefix
        let yp = 0x3000; // Symbol Prefix
        match self.0 {
            Key::F1             => fp | 1,
            Key::F2             => fp | 2,
            Key::F3             => fp | 3,
            Key::F4             => fp | 4,
            Key::F5             => fp | 5,
            Key::F6             => fp | 6,
            Key::F7             => fp | 7,
            Key::F8             => fp | 8,
            Key::F9             => fp | 9,
            Key::F10            => fp | 10,
            Key::F11            => fp | 11,
            Key::F12            => fp | 12,

            Key::Alt            => sp | 0,
            Key::AltGr          => sp | 1,
            Key::ControlLeft    => sp | 2,
            Key::ControlRight   => sp | 3,
            Key::Escape         => sp | 4,
            Key::MetaLeft       => sp | 5,
            Key::MetaRight      => sp | 6,
            Key::ShiftLeft      => sp | 8,
            Key::ShiftRight     => sp | 9,
            Key::Home           => sp | 10,
            Key::End            => sp | 11,
            Key::PageDown       => sp | 12,
            Key::PageUp         => sp | 13,
            Key::Return         => sp | 14,
            Key::Insert         => sp | 15,
            Key::CapsLock       => sp | 16,
            Key::Delete         => sp | 17,

            Key::UpArrow        => dp | 0,
            Key::DownArrow      => dp | 1,
            Key::LeftArrow      => dp | 2,
            Key::RightArrow     => dp | 3,

            Key::Tab            => wp | 9,
            Key::Backspace      => wp | 10,
            Key::Space          => wp | 32,

            Key::Quote          => yp | 39,
            Key::Comma          => yp | 44,
            Key::Minus          => yp | 45,
            Key::Dot            => yp | 46,
            Key::Slash          => yp | 47,
            Key::SemiColon      => yp | 59,
            Key::Equal          => yp | 61,
            Key::LeftBracket    => yp | 91,
            Key::BackSlash      => yp | 92,
            Key::RightBracket   => yp | 93,

            Key::KeyA           => mp | 65,
            Key::KeyB           => mp | 66,
            Key::KeyC           => mp | 67,
            Key::KeyD           => mp | 68,
            Key::KeyE           => mp | 69,
            Key::KeyF           => mp | 70,
            Key::KeyG           => mp | 71,
            Key::KeyH           => mp | 72,
            Key::KeyI           => mp | 73,
            Key::KeyJ           => mp | 74,
            Key::KeyK           => mp | 75,
            Key::KeyL           => mp | 76,
            Key::KeyM           => mp | 77,
            Key::KeyN           => mp | 78,
            Key::KeyO           => mp | 79,
            Key::KeyP           => mp | 80,
            Key::KeyQ           => mp | 81,
            Key::KeyR           => mp | 82,
            Key::KeyS           => mp | 83,
            Key::KeyT           => mp | 84,
            Key::KeyU           => mp | 85,
            Key::KeyV           => mp | 86,
            Key::KeyW           => mp | 87,
            Key::KeyX           => mp | 88,
            Key::KeyY           => mp | 89,
            Key::KeyZ           => mp | 90,

            Key::Num0           => np | 0,
            Key::Num1           => np | 1,
            Key::Num2           => np | 2,
            Key::Num3           => np | 3,
            Key::Num4           => np | 4,
            Key::Num5           => np | 5,
            Key::Num6           => np | 6,
            Key::Num7           => np | 7,
            Key::Num8           => np | 8,
            Key::Num9           => np | 9,

            Key::Kp0            => kp | 0,
            Key::Kp1            => kp | 1,
            Key::Kp2            => kp | 2,
            Key::Kp3            => kp | 3,
            Key::Kp4            => kp | 4,
            Key::Kp5            => kp | 5,
            Key::Kp6            => kp | 6,
            Key::Kp7            => kp | 7,
            Key::Kp8            => kp | 8,
            Key::Kp9            => kp | 9,
            Key::NumLock        => kp | 10,
            Key::KpPlus         => kp | 11,
            Key::KpMinus        => kp | 12,
            Key::KpMultiply     => kp | 13,
            Key::KpDivide       => kp | 15,
            Key::KpReturn       => kp | 14,
            Key::KpDelete       => kp | 17,
            
            _ => 0x0000, // Unknown
        }
    }
}

pub struct UButton(pub Button);

impl UButton {
    pub fn to_int(&self) -> u16 {
        let mp = 0x4000;
        match self.0 {
            Button::Left => mp | 1,
            Button::Right => mp | 2,
            Button::Middle => mp | 3,
            Button::Unknown(num) => mp | num as u16,
        }
    }
}
