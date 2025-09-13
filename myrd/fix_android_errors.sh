#!/bin/bash

echo "🔧 修复Android编译的关键错误..."

# 1. 修复audio_service.rs中的导入错误
echo "修复audio_service.rs..."
sed -i 's/use Encoder;//g' /root/rustdesk/myrd/src/server/audio_service.rs
sed -i 's/use Stereo;//g' /root/rustdesk/myrd/src/server/audio_service.rs
sed -i 's/use LowDelay;//g' /root/rustdesk/myrd/src/server/audio_service.rs

# 在audio_service.rs开头添加条件编译的音频编码器占位符
cat > /tmp/audio_service_fix.rs << 'EOF'
// Android minimal audio encoder placeholder
#[cfg(feature = "android-minimal")]
struct Encoder;

#[cfg(feature = "android-minimal")]
#[derive(Copy, Clone)]
struct Stereo;

#[cfg(feature = "android-minimal")]
#[derive(Copy, Clone)]
struct LowDelay;

#[cfg(feature = "android-minimal")]
impl Encoder {
    fn new(_sample_rate: u32, _channels: Stereo, _mode: LowDelay) -> Result<Self, Box<dyn std::error::Error>> {
        Ok(Encoder)
    }
    
    fn encode(&mut self, _input: &[f32], _output: &mut [u8]) -> Result<usize, Box<dyn std::error::Error>> {
        Ok(0)
    }
}

#[cfg(not(feature = "android-minimal"))]
use scrap::{Encoder, Stereo, LowDelay};

EOF

# 将修复代码插入到audio_service.rs的开头
sed -i '1r /tmp/audio_service_fix.rs' /root/rustdesk/myrd/src/server/audio_service.rs

# 2. 修复client.rs中的音频解码器错误
echo "修复client.rs..."
cat > /tmp/client_fix.rs << 'EOF'
// Android minimal audio decoder placeholder
#[cfg(feature = "android-minimal")]
struct AudioDecoder;

#[cfg(feature = "android-minimal")]
#[derive(Copy, Clone)]
struct Mono;

#[cfg(feature = "android-minimal")]
impl AudioDecoder {
    fn new(_sample_rate: u32, _channels: impl Copy) -> Result<Self, Box<dyn std::error::Error>> {
        Ok(AudioDecoder)
    }
    
    fn decode(&mut self, _input: &[u8], _output: &mut Vec<f32>) -> Result<(), Box<dyn std::error::Error>> {
        Ok(())
    }
}

#[cfg(not(feature = "android-minimal"))]
use scrap::{AudioDecoder, Mono};

// Android minimal audio resample function
#[cfg(feature = "android-minimal")]
fn audio_resample(_input: Vec<f32>, _input_sample_rate: u32, _output_sample_rate: u32, _channels: u16) -> Vec<f32> {
    _input // 简单返回原始数据
}

EOF

sed -i '1r /tmp/client_fix.rs' /root/rustdesk/myrd/src/client.rs

# 3. 修复video_service.rs中的编码器错误  
echo "修复video_service.rs..."
cat > /tmp/video_service_fix.rs << 'EOF'
// Android minimal video encoder placeholders
#[cfg(feature = "android-minimal")]
use scrap::codec::{Encoder, EncoderCfg, Decoder};

#[cfg(feature = "android-minimal")]
impl Encoder {
    fn set_fallback(_cfg: &EncoderCfg) {
        // 占位符实现
    }
    
    fn use_i444(_cfg: &EncoderCfg) -> bool {
        false
    }
}

#[cfg(feature = "android-minimal")]
#[derive(Clone)]
enum AndroidEncoderCfg {
    Hardware(HardwareEncoderConfig),
}

#[cfg(feature = "android-minimal")]
#[derive(Clone)]
struct HardwareEncoderConfig {
    pub width: u32,
    pub height: u32,
    pub quality: u32,
    pub keyframe_interval: Option<u32>,
}

EOF

sed -i '1r /tmp/video_service_fix.rs' /root/rustdesk/myrd/src/server/video_service.rs

# 4. 修复flutter.rs中的事件流错误
echo "修复flutter.rs..."
sed -i 's/GLOBAL_EVENT_STREAM\.read()/GLOBAL_EVENT_STREAM.try_read()/g' /root/rustdesk/myrd/src/flutter.rs
sed -i 's/GLOBAL_EVENT_STREAM\.write()/GLOBAL_EVENT_STREAM.try_write()/g' /root/rustdesk/myrd/src/flutter.rs

# 5. 添加缺失的函数占位符到ui_interface.rs
echo "修复ui_interface.rs..."
cat > /tmp/ui_interface_fix.rs << 'EOF'
// Android minimal UI interface placeholders
#[cfg(feature = "android-minimal")]
pub fn peer_exists(_id: &str) -> bool { false }

#[cfg(feature = "android-minimal")]
pub fn peer_to_map(_id: String, _p: crate::config::PeerConfig) -> std::collections::HashMap<&'static str, String> {
    std::collections::HashMap::new()
}

#[cfg(feature = "android-minimal")]
pub fn set_user_default_option(_key: String, _value: String) {}

#[cfg(feature = "android-minimal")]
pub fn get_user_default_option(_key: String) -> String { String::new() }

#[cfg(feature = "android-minimal")]
pub fn supported_hwdecodings() -> (bool, bool) { (false, false) }

#[cfg(feature = "android-minimal")]
pub fn get_unlock_pin() -> String { String::new() }

#[cfg(feature = "android-minimal")]
pub fn set_unlock_pin(_pin: String) -> String { String::new() }

#[cfg(feature = "android-minimal")]
pub fn is_can_input_monitoring(_prompt: bool) -> bool { false }

#[cfg(feature = "android-minimal")]
pub fn account_auth(_op: String, _id: String, _uuid: String, _remember_me: bool) {}

#[cfg(feature = "android-minimal")]
pub fn account_auth_cancel() {}

#[cfg(feature = "android-minimal")]
pub fn account_auth_result() -> String { String::new() }

#[cfg(feature = "android-minimal")]
pub fn get_hard_option(_key: String) -> String { String::new() }

#[cfg(feature = "android-minimal")]
pub fn get_trusted_devices() -> String { String::new() }

#[cfg(feature = "android-minimal")]
pub fn remove_trusted_devices(_json: &str) {}

#[cfg(feature = "android-minimal")]
pub fn clear_trusted_devices() {}

#[cfg(feature = "android-minimal")]
pub fn max_encrypt_len() -> usize { 1024 }

#[cfg(feature = "android-minimal")]
pub fn get_kb_layout_type() -> String { String::new() }

#[cfg(feature = "android-minimal")]
pub fn set_kb_layout_type(_kb_layout_type: String) {}

EOF

echo "$(/tmp/ui_interface_fix.rs)" >> /root/rustdesk/myrd/src/ui_interface.rs

# 6. 清理临时文件
rm -f /tmp/audio_service_fix.rs /tmp/client_fix.rs /tmp/video_service_fix.rs /tmp/ui_interface_fix.rs

echo "✅ 关键错误修复完成！"