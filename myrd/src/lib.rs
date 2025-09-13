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
