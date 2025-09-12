// Minimal codec implementation for Android

use std::{
    collections::HashMap,
    ops::{Deref, DerefMut},
    sync::{Arc, Mutex},
    time::Instant,
};

#[cfg(feature = "mediacodec")]
use crate::mediacodec::{MediaCodecDecoder, H264_DECODER_SUPPORT, H265_DECODER_SUPPORT};

use crate::{
    CodecFormat, EncodeInput, EncodeYuvFormat, ImageRgb,
};

use hbb_common::{
    bail,
    config::{Config, PeerConfig},
    lazy_static, log,
    message_proto::{
        Chroma, SupportedDecoding, SupportedEncoding, VideoFrame,
    },
    ResultType,
};

// Audio codec types for Android compatibility
#[allow(dead_code)]
pub enum Channels {
    Mono = 1,
    Stereo = 2,
}
pub use Channels::*;

#[allow(dead_code)]
pub enum Application {
    Voip,
    Audio,
    LowDelay,
}
pub use Application::*;

// Audio decoder/encoder stubs
pub struct AudioDecoder;

// Separate audio encoder from video encoder
pub struct AudioEncoder;

impl AudioDecoder {
    pub fn new(_sample_rate: u32, _channels: Channels) -> Result<Self, String> {
        Ok(AudioDecoder)
    }
    
    pub fn decode(&mut self, _data: &[u8], _output: &mut Vec<f32>) -> Result<usize, String> {
        Ok(0)
    }
}

impl AudioEncoder {
    pub fn new(_sample_rate: u32, _channels: Channels, _application: Application) -> Result<Self, String> {
        Ok(AudioEncoder)
    }
    
    pub fn encode(&mut self, _input: &[f32], _output: &mut Vec<u8>) -> Result<usize, String> {
        Ok(0)
    }
}

// Additional stub functions
pub fn test_av1() -> bool {
    false
}

lazy_static::lazy_static! {
    static ref PEER_DECODINGS: Arc<Mutex<HashMap<i32, SupportedDecoding>>> = Default::default();
    static ref ENCODE_CODEC_FORMAT: Arc<Mutex<CodecFormat>> = Arc::new(Mutex::new(CodecFormat::VP9));
    static ref THREAD_LOG_TIME: Arc<Mutex<Option<Instant>>> = Arc::new(Mutex::new(None));
    static ref USABLE_ENCODING: Arc<Mutex<Option<SupportedEncoding>>> = Arc::new(Mutex::new(None));
}

pub const ENCODE_NEED_SWITCH: &'static str = "ENCODE_NEED_SWITCH";

// Minimal encoder configuration for Android
#[derive(Debug, Clone)]
pub enum EncoderCfg {
    #[cfg(feature = "mediacodec")]
    MediaCodec,
    // Placeholder for other platforms
    None,
}

pub trait EncoderApi {
    fn new(cfg: EncoderCfg, i444: bool) -> ResultType<Self>
    where
        Self: Sized;

    fn encode_to_message(&mut self, frame: EncodeInput, ms: i64) -> ResultType<VideoFrame>;

    fn yuvfmt(&self) -> EncodeYuvFormat;

    fn set_quality(&mut self, ratio: f32) -> ResultType<()>;

    fn bitrate(&self) -> u32;

    fn support_changing_quality(&self) -> bool;

    fn latency_free(&self) -> bool;

    fn is_hardware(&self) -> bool;

    fn disable(&self);
}

// Minimal encoder implementation
pub struct MinimalEncoder;

impl EncoderApi for MinimalEncoder {
    fn new(_cfg: EncoderCfg, _i444: bool) -> ResultType<Self> {
        Ok(MinimalEncoder)
    }

    fn encode_to_message(&mut self, _frame: EncodeInput, _ms: i64) -> ResultType<VideoFrame> {
        bail!("Encoding not supported on Android minimal build")
    }

    fn yuvfmt(&self) -> EncodeYuvFormat {
        EncodeYuvFormat {
            pixfmt: crate::Pixfmt::I420,
            w: 640,
            h: 480,
            stride: vec![640, 320, 320],
            u: 640 * 480,
            v: 640 * 480 + 320 * 240,
        }
    }

    fn set_quality(&mut self, _ratio: f32) -> ResultType<()> {
        Ok(())
    }

    fn bitrate(&self) -> u32 {
        1000000
    }

    fn support_changing_quality(&self) -> bool {
        false
    }

    fn latency_free(&self) -> bool {
        true
    }

    fn is_hardware(&self) -> bool {
        false
    }

    fn disable(&self) {
        // No-op
    }
}

pub struct Encoder {
    pub codec: Box<dyn EncoderApi>,
}

impl Deref for Encoder {
    type Target = Box<dyn EncoderApi>;

    fn deref(&self) -> &Self::Target {
        &self.codec
    }
}

impl DerefMut for Encoder {
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.codec
    }
}

pub struct Decoder {
    #[cfg(feature = "mediacodec")]
    h264_media_codec: MediaCodecDecoder,
    #[cfg(feature = "mediacodec")]
    h265_media_codec: MediaCodecDecoder,
    format: CodecFormat,
    valid: bool,
}

#[derive(Debug, Clone)]
pub enum EncodingUpdate {
    Update(i32, SupportedDecoding),
    Remove(i32),
    NewOnlyVP9(i32),
    Check,
}

impl Encoder {
    pub fn new(config: EncoderCfg, i444: bool) -> ResultType<Encoder> {
        log::info!("new minimal encoder: {config:?}, i444: {i444}");
        Ok(Encoder {
            codec: Box::new(MinimalEncoder::new(config, i444)?),
        })
    }

    pub fn update(update: EncodingUpdate) {
        log::info!("update:{:?}", update);
        // Minimal implementation for Android
    }

    pub fn negotiated_codec() -> CodecFormat {
        CodecFormat::VP9
    }

    pub fn current_encoder() -> Arc<Mutex<Option<Encoder>>> {
        Arc::new(Mutex::new(None))
    }

    pub fn supported_encoding() -> SupportedEncoding {
        SupportedEncoding {
            vp8: true,
            ..Default::default()
        }
    }
}

impl Decoder {
    pub fn new() -> Decoder {
        Decoder {
            #[cfg(feature = "mediacodec")]
            h264_media_codec: MediaCodecDecoder::new(false),
            #[cfg(feature = "mediacodec")]
            h265_media_codec: MediaCodecDecoder::new(false),
            format: CodecFormat::VP9,
            valid: true,
        }
    }

    pub fn supported_decodings(id_for_perfer: Option<&str>) -> SupportedDecoding {
        log::debug!("Getting supported decodings for Android, id_for_perfer: {:?}", id_for_perfer);
        SupportedDecoding {
            ability_h264: 0,
            ability_h265: 0,
            ..Default::default()
        }
    }

    pub fn handle_video_frame(
        &mut self,
        _frame: &VideoFrame,
        rgb: &mut ImageRgb,
        _i420: &mut Vec<u8>,
        chroma: &mut Chroma,
    ) -> ResultType<bool> {
        log::debug!("Handling video frame in minimal decoder");
        // Minimal implementation - just return success
        *chroma = Chroma::I420;
        rgb.w = 640;
        rgb.h = 480;
        rgb.raw.resize(640 * 480 * 4, 0);
        Ok(true)
    }

    pub fn format(&self) -> CodecFormat {
        self.format
    }

    pub fn valid(&self) -> bool {
        self.valid
    }
}

// Minimal helper functions
pub fn codec_thread_num(_limit_fps: u8) -> usize {
    1
}

pub fn base_bitrate(width: u32, height: u32) -> u32 {
    (width * height / 1000).max(500)
}

pub fn enable_vram_option(_is_encode: bool) -> bool {
    false
}

pub fn check_config() {}

pub fn refresh(_display: usize) {}

pub fn disable_av1() -> bool {
    true // Disable AV1 on Android
}

pub fn enable_hwcodec_option() -> bool {
    false
}

// More stub implementations for compatibility  
pub fn try_get_config_with_codec(
    _codec: CodecFormat,
    _config: &mut Option<Config>,
    _peer_config: &PeerConfig,
) -> Option<String> {
    None
}

pub fn new_encoder(_codec: CodecFormat) -> ResultType<Encoder> {
    Encoder::new(EncoderCfg::None, false)
}

pub fn get_supported_encoding() -> SupportedEncoding {
    SupportedEncoding {
        vp8: true,
        ..Default::default()
    }
}

pub fn quality_to_bitrate(quality: u32, width: u32, height: u32) -> u32 {
    base_bitrate(width, height) * quality / 50
}

// YUV conversion functions for Android compatibility
use std::os::raw::c_int;

pub unsafe extern "C" fn I420ToRAW(
    _src_y: *const u8, _src_stride_y: c_int,
    _src_u: *const u8, _src_stride_u: c_int,
    _src_v: *const u8, _src_stride_v: c_int,
    _dst_raw: *mut u8, _dst_stride_raw: c_int,
    _width: c_int, _height: c_int
) -> c_int { 0 }

pub unsafe extern "C" fn I420ToARGB(
    _src_y: *const u8, _src_stride_y: c_int,
    _src_u: *const u8, _src_stride_u: c_int,
    _src_v: *const u8, _src_stride_v: c_int,
    _dst_argb: *mut u8, _dst_stride_argb: c_int,
    _width: c_int, _height: c_int
) -> c_int { 0 }

pub unsafe extern "C" fn I420ToABGR(
    _src_y: *const u8, _src_stride_y: c_int,
    _src_u: *const u8, _src_stride_u: c_int,
    _src_v: *const u8, _src_stride_v: c_int,
    _dst_abgr: *mut u8, _dst_stride_abgr: c_int,
    _width: c_int, _height: c_int
) -> c_int { 0 }

pub unsafe extern "C" fn I444ToARGB(
    _src_y: *const u8, _src_stride_y: c_int,
    _src_u: *const u8, _src_stride_u: c_int,
    _src_v: *const u8, _src_stride_v: c_int,
    _dst_argb: *mut u8, _dst_stride_argb: c_int,
    _width: c_int, _height: c_int
) -> c_int { 0 }

pub unsafe extern "C" fn I444ToABGR(
    _src_y: *const u8, _src_stride_y: c_int,
    _src_u: *const u8, _src_stride_u: c_int,
    _src_v: *const u8, _src_stride_v: c_int,
    _dst_abgr: *mut u8, _dst_stride_abgr: c_int,
    _width: c_int, _height: c_int
) -> c_int { 0 }