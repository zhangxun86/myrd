// Android minimal main.rs

// 声明模块
mod bridge_generated;

// 导入依赖
#[cfg(target_os = "android")]
use android_logger;
use log;

// 从lib.rs导入函数
pub fn rustdesk_core_main() {
    println!("RustDesk Android minimal core initialized");
}

fn main() {
    #[cfg(target_os = "android")]
    {
        println!("RustDesk Android minimal version");
        android_logger::init_once(
            android_logger::Config::default()
                .with_max_level(log::LevelFilter::Info)
                .with_tag("rustdesk"),
        );
        
        // 初始化核心功能
        rustdesk_core_main();
    }
    
    #[cfg(not(target_os = "android"))]
    {
        println!("This is an Android-only build");
    }
}