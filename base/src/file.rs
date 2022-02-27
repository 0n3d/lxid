use std::path::PathBuf;

use home::home_dir;

fn exists(path: PathBuf) -> Option<PathBuf> {
    if path.exists() {
        Some(path)
    } else {
        None
    }
}

pub fn config_path() -> Option<PathBuf> {
    exists(home_dir()?.join(".config/lxid"))
}

pub fn library_path() -> Option<PathBuf> {
    exists(PathBuf::from("/usr/share/lxid/lib"))
}

pub fn append_init(dir: &PathBuf) -> Option<PathBuf> {
    exists(dir.join("init.lua"))
}

pub struct LuaPaths {
    pub config_dir: PathBuf,
    pub init_file: PathBuf,
    pub library_dir: PathBuf,
}

impl LuaPaths {
    pub fn new() -> Result<LuaPaths, String> {
        let config_dir = match config_path() {
            Some(path) => path,
            None => return Err("No Config dir found".to_string()),
        };

        let init_file = match append_init(&config_dir) {
            Some(path) => path,
            None => return Err("No init.lua not found in configuration directory".to_string()),
        };

        let library_dir = match library_path() {
            Some(path) => path,
            None => return Err("Libraries not found".to_string()),
        };

        Ok(LuaPaths {
            config_dir,
            init_file,
            library_dir,
        })
    }
}
