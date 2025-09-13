// Android minimal main.rs

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
        rustdesk::rustdesk_core_main();
    }
    
    #[cfg(not(target_os = "android"))]
    {
        println!("This is an Android-only build");
    }
}