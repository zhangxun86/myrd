#!/bin/bash

echo "🚀 创建极简Android构建版本..."

# 1. 创建极简的lib.rs
cat > /root/rustdesk/myrd/src/lib.rs << 'EOF'
// Android minimal RustDesk library
use std::ffi::{CStr, CString};
use std::os::raw::c_char;

// 基础模块
pub mod bridge_generated;

// 必需的导出函数
#[no_mangle]
pub extern "C" fn rustdesk_core_main() {
    println!("RustDesk Android minimal core initialized");
}

#[no_mangle]
pub extern "C" fn init_bridge() {
    bridge_generated::init_bridge();
}

// Flutter FFI最基本的函数
#[no_mangle]
pub extern "C" fn main_get_version() -> *mut c_char {
    let version = CString::new("1.4.2-android-minimal").unwrap();
    version.into_raw()
}

#[no_mangle]
pub extern "C" fn main_get_api_server() -> *mut c_char {
    let server = CString::new("").unwrap();
    server.into_raw()
}

#[no_mangle]
pub extern "C" fn main_get_id() -> *mut c_char {
    let id = CString::new("rustdesk_android").unwrap();
    id.into_raw()
}

#[no_mangle]
pub extern "C" fn free_rust_string(s: *mut c_char) {
    if !s.is_null() {
        unsafe {
            let _ = CString::from_raw(s);
        }
    }
}

// JNI入口点
#[cfg(target_os = "android")]
#[allow(non_snake_case)]
pub mod android {
    use super::*;
    use std::os::raw::{c_char, c_void};

    #[no_mangle]
    pub unsafe extern "C" fn Java_com_carriez_flutter_1hbb_generated_1bridge_RustLib_rustdeskCoreMain(
        _env: *mut c_void,
        _class: *mut c_void,
    ) {
        rustdesk_core_main();
    }

    #[no_mangle]
    pub unsafe extern "C" fn Java_com_carriez_flutter_1hbb_generated_1bridge_RustLib_mainGetVersion(
        _env: *mut c_void,
        _class: *mut c_void,
    ) -> *mut c_char {
        main_get_version()
    }

    #[no_mangle]
    pub unsafe extern "C" fn Java_com_carriez_flutter_1hbb_generated_1bridge_RustLib_mainGetId(
        _env: *mut c_void,
        _class: *mut c_void,
    ) -> *mut c_char {
        main_get_id()
    }
}
EOF

# 2. 简化bridge_generated.rs
cat > /root/rustdesk/myrd/src/bridge_generated.rs << 'EOF'
// Android minimal bridge generated file - ultra simplified

use std::os::raw::c_char;

pub fn init_bridge() {
    println!("Bridge initialized for Android minimal build");
}

// 最基本的函数导出
#[no_mangle]
pub extern "C" fn bridge_init() {
    init_bridge();
}

#[no_mangle]
pub extern "C" fn get_version() -> *const c_char {
    b"1.4.2-android-minimal\0".as_ptr() as *const c_char
}
EOF

# 3. 创建极简的Cargo.toml
cat > /root/rustdesk/myrd/Cargo.toml << 'EOF'
[package]
name = "rustdesk"
version = "1.4.2"
authors = ["rustdesk <info@rustdesk.com>"]
edition = "2021"
build = "build.rs"
description = "RustDesk Remote Desktop - Android Minimal"
default-run = "rustdesk"
rust-version = "1.75"

[lib]
name = "rustdesk"
crate-type = ["cdylib"]

[features]
default = []
android-minimal = []

[dependencies]
# 最小依赖集合
serde = "1.0"
serde_json = "1.0"
lazy_static = "1.4"

[target.'cfg(target_os = "android")'.dependencies]
android_logger = "0.13"

[build-dependencies]
EOF

# 4. 创建极简的build.rs
cat > /root/rustdesk/myrd/build.rs << 'EOF'
fn main() {
    println!("cargo:rerun-if-changed=build.rs");
    println!("Building Android minimal version");
}
EOF

echo "✅ 极简Android版本创建完成！"