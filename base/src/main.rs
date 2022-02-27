use std::fs;
use std::sync::mpsc;

use rdev::{listen, EventType};

use mlua::prelude::*;
use mlua::{ Function, chunk };

mod ukey;
mod file;

pub enum Interaction {
    Keydown(u16),
    Keyup(u16),
    MousePress(u16),
    MouseRelease(u16),
    MouseMove(f64, f64),
}

pub struct Register<'a> {
    pub keydown: Option<Function<'a>>,
    pub keyup: Option<Function<'a>>,
    pub mousepress: Option<Function<'a>>,
    pub mouserelease: Option<Function<'a>>,
    pub mousemove: Option<Function<'a>>,
}

impl<'a> Register<'a> {
    pub fn new() -> Register<'a> {
        Register {
            keydown: None,
            keyup: None,
            mousepress: None,
            mouserelease: None,
            mousemove: None,
        }
    }
}

fn main() {
    let mut lua = Lua::new();
    let mut register = Register::new();

    let paths = match file::LuaPaths::new() {
        Ok(paths) => paths,
        Err(err) => {
            println!("{}", err);
            std::process::exit(2);
        }
    };

    match setup_lua(&mut lua, &mut register, paths) {
        Err(error) => {
            println!("Error while parsing lua:\n{}", error);
            std::process::exit(1);
        }
        Ok(_) => {}
    }

    // Lua configuration complete. Make immutable
    let register = register;

    let (tx, rx) = mpsc::channel();
    let tx = tx.clone();
    
    // Input thread
    std::thread::spawn(move || {
        if let Err(error) = listen(move |ev| {
            match ev.event_type {
                EventType::KeyPress(key) => {
                    tx.send(Interaction::Keydown(ukey::UKey(key).to_int())).ok();
                }
                EventType::KeyRelease(key) => {
                    tx.send(Interaction::Keyup(ukey::UKey(key).to_int())).ok();
                }
                EventType::ButtonPress(button) => {
                    tx.send(Interaction::MousePress(ukey::UButton(button).to_int())).ok();
                }
                EventType::ButtonRelease(button) => {
                    tx.send(Interaction::MouseRelease(ukey::UButton(button).to_int())).ok();
                }
                EventType::MouseMove {x, y} => {
                    tx.send(Interaction::MouseMove(x, y)).ok();
                }
                _ => {}
            }
        }) {
            println!("Setup for listening failed: {:?}", error);
        };
    });

    for event in rx {
        match event {
            Interaction::Keydown(code) => {
                for func in &register.keydown {
                    match func.call::<_, ()>(code) {
                        Err(error) => {
                            println!("Keydown Error\n{}", error);
                            std::process::exit(11);
                        }
                        Ok(_) => {}
                    }
                }
            }
            Interaction::Keyup(code) => {
                for func in &register.keyup {
                    match func.call::<_, ()>(code) {
                        Err(error) => {
                            println!("Keyup Error\n{}", error);
                            std::process::exit(12);
                        }
                        Ok(_) => {}
                    }
                }
            }
            Interaction::MousePress(code) => {
                for func in &register.mousepress {
                    match func.call::<_, ()>(code) {
                        Err(error) => {
                            println!("Mousepress Error\n{}", error);
                            std::process::exit(13);
                        }
                        Ok(_) => {}
                    }
                }
            }
            Interaction::MouseRelease(code) => {
                for func in &register.mouserelease {
                    match func.call::<_, ()>(code) {
                        Err(error) => {
                            println!("Mouserelease Error\n{}", error);
                            std::process::exit(14);
                        }
                        Ok(_) => {}
                    }
                }
            }
            Interaction::MouseMove(x, y) => {
                for func in &register.mousemove {
                    match func.call::<_, ()>((x, y)) {
                        Err(error) => {
                            println!("Mousemove Error\n{}", error);
                            std::process::exit(14);
                        }
                        Ok(_) => {}
                    }
                }
            }
        }
    }
}

fn setup_lua<'a>(lua: &'a mut mlua::Lua, register: &mut Register<'a>, paths: file::LuaPaths) -> LuaResult<()> {
    let content = fs::read_to_string(paths.init_file.to_str().unwrap())?;

    let config_path = paths.config_dir.to_str().unwrap();
    let library_path = paths.library_dir.to_str().unwrap();

    lua.load(chunk! {
        package.path = $config_path .. "/?.lua;" ..
            $config_path .. "/?/init.lua;" ..
            $library_path .. "/?.lua;" ..
            $library_path .. "/?/init.lua;" ..
            package.path
    }).exec()?;

    let table = lua.create_table()?;
    let v1_ns = lua.create_table()?;
    table.set("v1", v1_ns)?;
    lua.globals().set("_plxid", table)?; // Primitive Lua X Keyboard Daemon api

    lua.load(&content).set_name(paths.init_file.to_str().unwrap())?.exec()?;

    let s: LuaTable = lua.globals().get("_plxid")?;
    let v1_ns: LuaTable = s.get("v1")?;

    register.keydown = v1_ns.get("keydown").ok();
    register.keyup = v1_ns.get("keyup").ok();
    register.mousepress = v1_ns.get("mousepress").ok();
    register.mouserelease = v1_ns.get("mouserelease").ok();
    register.mousemove = v1_ns.get("mousemove").ok();

    Ok(())
}

