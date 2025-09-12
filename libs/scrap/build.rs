use std::{
    env, fs,
    path::{Path, PathBuf},
    println,
};

#[cfg(all(target_os = "linux", feature = "linux-pkg-config"))]
fn link_pkg_config(name: &str) -> Vec<PathBuf> {
    // sometimes an override is needed
    let pc_name = match name {
        "libvpx" => "vpx",
        _ => name,
    };
    let lib = pkg_config::probe_library(pc_name)
        .expect(format!(
            "unable to find '{pc_name}' development headers with pkg-config (feature linux-pkg-config is enabled).
            try installing '{pc_name}-dev' from your system package manager.").as_str());

    lib.include_paths
}
#[cfg(not(all(target_os = "linux", feature = "linux-pkg-config")))]
fn link_pkg_config(_name: &str) -> Vec<PathBuf> {
    unimplemented!()
}

/// Link vcpkg package.
fn link_vcpkg(mut path: PathBuf, name: &str) -> PathBuf {
    let target_os = std::env::var("CARGO_CFG_TARGET_OS").unwrap();
    let mut target_arch = std::env::var("CARGO_CFG_TARGET_ARCH").unwrap();
    if target_arch == "x86_64" {
        target_arch = "x64".to_owned();
    } else if target_arch == "x86" {
        target_arch = "x86".to_owned();
    } else if target_arch == "loongarch64" {
        target_arch = "loongarch64".to_owned();
    } else if target_arch == "aarch64" {
        target_arch = "arm64".to_owned();
    } else {
        target_arch = "arm".to_owned();
    }
    let mut target = if target_os == "macos" {
        if target_arch == "x64" {
            "x64-osx".to_owned()
        } else if target_arch == "arm64" {
            "arm64-osx".to_owned()
        } else {
            format!("{}-{}", target_arch, target_os)
        }
    } else if target_os == "windows" {
        "x64-windows-static".to_owned()
    } else {
        format!("{}-{}", target_arch, target_os)
    };
    if target_arch == "x86" {
        target = target.replace("x64", "x86");
    }
    println!("cargo:info={}", target);
    if let Ok(vcpkg_root) = std::env::var("VCPKG_INSTALLED_ROOT") {
        path = vcpkg_root.into();
    } else {
        path.push("installed");
    }
    path.push(target);
    println!(
        "cargo:rustc-link-lib=static={}",
        name.trim_start_matches("lib")
    );
    println!(
        "cargo:rustc-link-search={}",
        path.join("lib").to_str().unwrap()
    );
    let include = path.join("include");
    println!("cargo:include={}", include.to_str().unwrap());
    include
}

/// Link homebrew package(for Mac M1).
fn link_homebrew_m1(name: &str) -> PathBuf {
    let target_os = std::env::var("CARGO_CFG_TARGET_OS").unwrap();
    let target_arch = std::env::var("CARGO_CFG_TARGET_ARCH").unwrap();
    if target_os != "macos" || target_arch != "aarch64" {
        panic!("Couldn't find VCPKG_ROOT, also can't fallback to homebrew because it's only for macos aarch64.");
    }
    let mut path = PathBuf::from("/opt/homebrew/Cellar");
    path.push(name);
    let entries = if let Ok(dir) = std::fs::read_dir(&path) {
        dir
    } else {
        panic!("Could not find package in {}. Make sure your homebrew and package {} are all installed.", path.to_str().unwrap(),&name);
    };
    let mut directories = entries
        .into_iter()
        .filter(|x| x.is_ok())
        .map(|x| x.unwrap().path())
        .filter(|x| x.is_dir())
        .collect::<Vec<_>>();
    // Find the newest version.
    directories.sort_unstable();
    if directories.is_empty() {
        panic!(
            "There's no installed version of {} in /opt/homebrew/Cellar",
            name
        );
    }
    path.push(directories.pop().unwrap());
    // Link the library.
    println!(
        "cargo:rustc-link-lib=static={}",
        name.trim_start_matches("lib")
    );
    // Add the library path.
    println!(
        "cargo:rustc-link-search={}",
        path.join("lib").to_str().unwrap()
    );
    // Add the include path.
    let include = path.join("include");
    println!("cargo:include={}", include.to_str().unwrap());
    include
}

/// Find package. By default, it will try to find vcpkg first, then homebrew(currently only for Mac M1).
/// If building for linux and feature "linux-pkg-config" is enabled, will try to use pkg-config
/// unless check fails (e.g. NO_PKG_CONFIG_libyuv=1)
fn find_package(name: &str) -> Vec<PathBuf> {
    let target_os = std::env::var("CARGO_CFG_TARGET_OS").unwrap();
    
    // For Android, skip package finding and return empty paths
    if target_os == "android" {
        println!("cargo:info=Skipping package {} for Android target", name);
        return vec![PathBuf::new()];
    }
    
    let no_pkg_config_var_name = format!("NO_PKG_CONFIG_{name}");
    println!("cargo:rerun-if-env-changed={no_pkg_config_var_name}");
    if cfg!(all(target_os = "linux", feature = "linux-pkg-config"))
        && std::env::var(no_pkg_config_var_name).as_deref() != Ok("1")
    {
        link_pkg_config(name)
    } else if let Ok(vcpkg_root) = std::env::var("VCPKG_ROOT") {
        vec![link_vcpkg(vcpkg_root.into(), name)]
    } else {
        // Try using homebrew
        vec![link_homebrew_m1(name)]
    }
}

fn generate_bindings(
    ffi_header: &Path,
    include_paths: &[PathBuf],
    ffi_rs: &Path,
    exact_file: &Path,
    regex: &str,
) {
    let mut b = bindgen::builder()
        .header(ffi_header.to_str().unwrap())
        .allowlist_type(regex)
        .allowlist_var(regex)
        .allowlist_function(regex)
        .rustified_enum(regex)
        .trust_clang_mangling(false)
        .layout_tests(false) // breaks 32/64-bit compat
        .generate_comments(false); // comments have prefix /*!\

    for dir in include_paths {
        b = b.clang_arg(format!("-I{}", dir.display()));
    }

    b.generate().unwrap().write_to_file(ffi_rs).unwrap();
    fs::copy(ffi_rs, exact_file).ok(); // ignore failure
}

fn gen_vcpkg_package(package: &str, ffi_header: &str, generated: &str, regex: &str) {
    let target_os = std::env::var("CARGO_CFG_TARGET_OS").unwrap();
    
    // For Android, create minimal stub files
    if target_os == "android" {
        println!("cargo:info=Creating stub {} for Android target", generated);
        
        let out_dir = env::var_os("OUT_DIR").unwrap();
        let out_dir = Path::new(&out_dir);
        let ffi_rs = out_dir.join(generated);
        
        // Create a minimal stub file
        let stub_content = match package {
            "libyuv" => r#"
// Stub YUV functions for Android
use std::os::raw::c_int;

pub unsafe extern "C" fn ARGBToI420(
    _src_argb: *const u8, _src_stride_argb: c_int,
    _dst_y: *mut u8, _dst_stride_y: c_int,
    _dst_u: *mut u8, _dst_stride_u: c_int,
    _dst_v: *mut u8, _dst_stride_v: c_int,
    _width: c_int, _height: c_int
) -> c_int { 0 }

pub unsafe extern "C" fn ABGRToI420(
    _src_abgr: *const u8, _src_stride_abgr: c_int,
    _dst_y: *mut u8, _dst_stride_y: c_int,
    _dst_u: *mut u8, _dst_stride_u: c_int,
    _dst_v: *mut u8, _dst_stride_v: c_int,
    _width: c_int, _height: c_int
) -> c_int { 0 }

pub unsafe extern "C" fn RGB565ToI420(
    _src_rgb565: *const u8, _src_stride_rgb565: c_int,
    _dst_y: *mut u8, _dst_stride_y: c_int,
    _dst_u: *mut u8, _dst_stride_u: c_int,
    _dst_v: *mut u8, _dst_stride_v: c_int,
    _width: c_int, _height: c_int
) -> c_int { 0 }

pub unsafe extern "C" fn ARGBToNV12(
    _src_argb: *const u8, _src_stride_argb: c_int,
    _dst_y: *mut u8, _dst_stride_y: c_int,
    _dst_uv: *mut u8, _dst_stride_uv: c_int,
    _width: c_int, _height: c_int
) -> c_int { 0 }

pub unsafe extern "C" fn ABGRToNV12(
    _src_abgr: *const u8, _src_stride_abgr: c_int,
    _dst_y: *mut u8, _dst_stride_y: c_int,
    _dst_uv: *mut u8, _dst_stride_uv: c_int,
    _width: c_int, _height: c_int
) -> c_int { 0 }

pub unsafe extern "C" fn RGB565ToARGB(
    _src_rgb565: *const u8, _src_stride_rgb565: c_int,
    _dst_argb: *mut u8, _dst_stride_argb: c_int,
    _width: c_int, _height: c_int
) -> c_int { 0 }

pub unsafe extern "C" fn ABGRToARGB(
    _src_abgr: *const u8, _src_stride_abgr: c_int,
    _dst_argb: *mut u8, _dst_stride_argb: c_int,
    _width: c_int, _height: c_int
) -> c_int { 0 }

pub unsafe extern "C" fn ARGBToI444(
    _src_argb: *const u8, _src_stride_argb: c_int,
    _dst_y: *mut u8, _dst_stride_y: c_int,
    _dst_u: *mut u8, _dst_stride_u: c_int,
    _dst_v: *mut u8, _dst_stride_v: c_int,
    _width: c_int, _height: c_int
) -> c_int { 0 }
"#,
            "libvpx" => r#"
// Stub VPX functions for Android
use std::os::raw::{c_int, c_long, c_uint, c_void};

pub mod vp8e_enc_control_id {
    use super::*;
    pub const VP8E_SET_CPUUSED: c_int = 13;
    pub const VP8E_SET_ENABLEAUTOALTREF: c_int = 14;
    pub const VP8E_SET_NOISE_SENSITIVITY: c_int = 15;
    pub const VP8E_SET_SHARPNESS: c_int = 16;
    pub const VP8E_SET_STATIC_THRESHOLD: c_int = 17;
    pub const VP8E_SET_TOKEN_PARTITIONS: c_int = 18;
}

pub mod vpx_codec_err_t {
    use super::*;
    pub const VPX_CODEC_OK: c_int = 0;
    pub const VPX_CODEC_ERROR: c_int = 1;
    pub const VPX_CODEC_MEM_ERROR: c_int = 2;
    pub const VPX_CODEC_ABI_MISMATCH: c_int = 3;
    pub const VPX_CODEC_INCAPABLE: c_int = 4;
    pub const VPX_CODEC_UNSUP_BITSTREAM: c_int = 5;
    pub const VPX_CODEC_UNSUP_FEATURE: c_int = 6;
    pub const VPX_CODEC_CORRUPT_FRAME: c_int = 7;
    pub const VPX_CODEC_INVALID_PARAM: c_int = 8;
    pub const VPX_CODEC_LIST_END: c_int = 9;
}

#[repr(C)]
pub struct vpx_codec_ctx_t {
    pub name: *const u8,
    pub iface: *mut c_void,
    pub err: c_int,
    pub err_detail: *const u8,
    pub init_flags: c_long,
    pub config: vpx_codec_ctx_cfg,
    pub priv_: *mut c_void,
}

#[repr(C)]
pub struct vpx_codec_ctx_cfg {
    pub w: c_uint,
    pub h: c_uint,
}

#[repr(C)]
pub struct vpx_image_t {
    pub fmt: c_uint,
    pub w: c_uint,
    pub h: c_uint,
    pub d_w: c_uint,
    pub d_h: c_uint,
    pub x_chroma_shift: c_uint,
    pub y_chroma_shift: c_uint,
    pub planes: [*mut u8; 4],
    pub stride: [c_int; 4],
    pub bps: c_int,
    pub user_priv: *mut c_void,
    pub img_data: *mut u8,
    pub img_data_owner: c_int,
    pub self_allocd: c_int,
}

pub unsafe extern "C" fn vpx_codec_encode(_ctx: *mut vpx_codec_ctx_t, _img: *const vpx_image_t, _pts: i64, _duration: c_long, _flags: c_long, _deadline: c_long) -> c_int { 0 }
pub unsafe extern "C" fn vpx_codec_control_(_ctx: *mut vpx_codec_ctx_t, _ctrl_id: c_int, ...) -> c_int { 0 }
"#,
            "aom" => r#"
// Stub AOM functions for Android
use std::os::raw::{c_int, c_long, c_uint, c_void};

pub mod aom_superblock_size {
    use super::*;
    pub const AOM_SUPERBLOCK_SIZE_64X64: c_int = 0;
    pub const AOM_SUPERBLOCK_SIZE_128X128: c_int = 1;
    pub const AOM_SUPERBLOCK_SIZE_DYNAMIC: c_int = 2;
}

pub mod aom_tune_content {
    use super::*;
    pub const AOM_CONTENT_DEFAULT: c_int = 0;
    pub const AOM_CONTENT_SCREEN: c_int = 1;
    pub const AOM_CONTENT_FILM: c_int = 2;
}

pub mod aome_enc_control_id {
    use super::*;
    pub const AOME_SET_CPUUSED: c_int = 13;
    pub const AOME_SET_ENABLEAUTOALTREF: c_int = 14;
    pub const AOME_SET_SHARPNESS: c_int = 16;
    pub const AV1E_SET_COLOR_PRIMARIES: c_int = 21;
    pub const AV1E_SET_TRANSFER_CHARACTERISTICS: c_int = 22;
    pub const AV1E_SET_MATRIX_COEFFICIENTS: c_int = 23;
    pub const AV1E_SET_CHROMA_SAMPLE_POSITION: c_int = 24;
    pub const AV1E_SET_COLOR_RANGE: c_int = 25;
    pub const AV1E_SET_NOISE_SENSITIVITY: c_int = 26;
    pub const AV1E_SET_MIN_GF_INTERVAL: c_int = 27;
    pub const AV1E_SET_MAX_GF_INTERVAL: c_int = 28;
    pub const AV1E_SET_GF_CBR_BOOST_PCT: c_int = 29;
    pub const AV1E_SET_LOSSLESS: c_int = 30;
    pub const AV1E_SET_ROW_MT: c_int = 31;
    pub const AV1E_SET_TILE_COLUMNS: c_int = 32;
    pub const AV1E_SET_TILE_ROWS: c_int = 33;
    pub const AV1E_SET_ENABLE_TPL_MODEL: c_int = 34;
    pub const AV1E_SET_ENABLE_KEYFRAME_FILTERING: c_int = 35;
    pub const AV1E_SET_FRAME_PARALLEL_DECODING: c_int = 36;
    pub const AV1E_SET_ERROR_RESILIENT_MODE: c_int = 37;
    pub const AV1E_SET_S_FRAME_MODE: c_int = 38;
    pub const AV1E_SET_AQ_MODE: c_int = 39;
    pub const AV1E_SET_FRAME_PERIODIC_BOOST: c_int = 40;
    pub const AV1E_SET_TUNE_CONTENT: c_int = 41;
    pub const AV1E_SET_CDF_UPDATE_MODE: c_int = 42;
    pub const AV1E_SET_COLOR_PRIMARIES_FROM_CHROMA_FORMAT: c_int = 43;
    pub const AV1E_SET_CHROMA_SUBSAMPLING_X: c_int = 44;
    pub const AV1E_SET_CHROMA_SUBSAMPLING_Y: c_int = 45;
    pub const AV1E_SET_REDUCED_TX_TYPE_SET: c_int = 46;
    pub const AV1E_SET_INTRA_DCT_ONLY: c_int = 47;
    pub const AV1E_SET_INTER_DCT_ONLY: c_int = 48;
    pub const AV1E_SET_INTRA_DEFAULT_TX_ONLY: c_int = 49;
    pub const AV1E_SET_QUANT_B_ADAPT: c_int = 50;
    pub const AV1E_SET_COEFF_COST_UPD_FREQ: c_int = 51;
    pub const AV1E_SET_MODE_COST_UPD_FREQ: c_int = 52;
    pub const AV1E_SET_MV_COST_UPD_FREQ: c_int = 53;
    pub const AV1E_SET_TIER_MASK: c_int = 54;
    pub const AV1E_SET_MIN_CR: c_int = 55;
    pub const AV1E_SET_SVC_LAYER_ID: c_int = 56;
    pub const AV1E_SET_SVC_PARAMS: c_int = 57;
    pub const AV1E_SET_SVC_REF_FRAME_CONFIG: c_int = 58;
    pub const AV1E_REGISTER_CX_CALLBACK: c_int = 59;
    pub const AV1E_SET_SVC_REF_FRAME_COMP_PRED: c_int = 60;
    pub const AV1E_SET_SVC_REF_FRAME_OUTPUT_IDS: c_int = 61;
    pub const AV1E_SET_DELTA_Q_UV: c_int = 62;
    pub const AV1E_SET_DELTAQ_STRENGTH: c_int = 63;
    pub const AV1E_SET_LOOPFILTER_CONTROL: c_int = 64;
    pub const AV1E_SET_RATE_DISTRIBUTION_INFO: c_int = 65;
    pub const AV1E_SET_FILM_GRAIN_TEST_VECTOR: c_int = 66;
    pub const AV1E_SET_FILM_GRAIN_TABLE: c_int = 67;
    pub const AV1E_SET_DENOISE_NOISE_LEVEL: c_int = 68;
    pub const AV1E_SET_DENOISE_BLOCK_SIZE: c_int = 69;
    pub const AV1E_SET_ENABLE_GLOBAL_MOTION: c_int = 70;
    pub const AV1E_SET_ENABLE_WARPED_MOTION: c_int = 71;
    pub const AV1E_SET_ALLOW_WARPED_MOTION: c_int = 72;
    pub const AV1E_SET_ENABLE_GLOBAL_MOTION_SEARCH: c_int = 73;
    pub const AV1E_SET_ENABLE_REF_FRAME_MVS: c_int = 74;
    pub const AV1E_SET_ENABLE_REDUCED_REFERENCE_SET: c_int = 75;
    pub const AV1E_SET_ENABLE_OBMC: c_int = 76;
    pub const AV1E_SET_DISABLE_TRELLIS_QUANT: c_int = 77;
    pub const AV1E_SET_ENABLE_QM: c_int = 78;
    pub const AV1E_SET_QM_Y: c_int = 79;
    pub const AV1E_SET_QM_U: c_int = 80;
    pub const AV1E_SET_QM_V: c_int = 81;
    pub const AV1E_SET_QM_MIN: c_int = 82;
    pub const AV1E_SET_QM_MAX: c_int = 83;
    pub const AV1E_SET_MAX_INTRA_RATE_PCT: c_int = 84;
    pub const AV1E_SET_MAX_INTER_RATE_PCT: c_int = 85;
    pub const AV1E_SET_GF_CBR_BOOST_PCT: c_int = 86;
    pub const AV1E_SET_LOSSLESS: c_int = 87;
    pub const AV1E_SET_ENABLE_CDEF: c_int = 88;
    pub const AV1E_SET_ENABLE_RESTORATION: c_int = 89;
    pub const AV1E_SET_ENABLE_RECT_PARTITIONS: c_int = 90;
    pub const AV1E_SET_ENABLE_AB_PARTITIONS: c_int = 91;
    pub const AV1E_SET_ENABLE_1TO4_PARTITIONS: c_int = 92;
    pub const AV1E_SET_MIN_PARTITION_SIZE: c_int = 93;
    pub const AV1E_SET_MAX_PARTITION_SIZE: c_int = 94;
    pub const AV1E_SET_ENABLE_DUAL_FILTER: c_int = 95;
    pub const AV1E_SET_ENABLE_CHROMA_DELTAQ: c_int = 96;
    pub const AV1E_SET_ENABLE_INTRA_EDGE_FILTER: c_int = 97;
    pub const AV1E_SET_ENABLE_ORDER_HINT: c_int = 98;
    pub const AV1E_SET_ENABLE_TX64: c_int = 99;
    pub const AV1E_SET_ENABLE_FLIP_IDTX: c_int = 100;
    pub const AV1E_SET_ENABLE_RECT_TX: c_int = 101;
    pub const AV1E_SET_ENABLE_DIST_WTD_COMP: c_int = 102;
    pub const AV1E_SET_ENABLE_REF_FRAME_MVS: c_int = 103;
    pub const AV1E_SET_ALLOW_REF_FRAME_MVS: c_int = 104;
    pub const AV1E_SET_ENABLE_DUAL_FILTER: c_int = 105;
    pub const AV1E_SET_ENABLE_MASKED_COMP: c_int = 106;
    pub const AV1E_SET_ENABLE_ONESIDED_COMP: c_int = 107;
    pub const AV1E_SET_ENABLE_INTERINTRA_COMP: c_int = 108;
    pub const AV1E_SET_ENABLE_SMOOTH_INTERINTRA: c_int = 109;
    pub const AV1E_SET_ENABLE_DIFF_WTD_COMP: c_int = 110;
    pub const AV1E_SET_ENABLE_INTERINTER_WEDGE: c_int = 111;
    pub const AV1E_SET_ENABLE_INTERINTRA_WEDGE: c_int = 112;
    pub const AV1E_SET_ENABLE_PALETTE: c_int = 113;
    pub const AV1E_SET_ENABLE_INTRABC: c_int = 114;
    pub const AV1E_SET_ENABLE_ANGLE_DELTA: c_int = 115;
    pub const AV1E_SET_DISABLE_TRELLIS_QUANT: c_int = 116;
    pub const AV1E_SET_ENABLE_FILTER_INTRA: c_int = 117;
    pub const AV1E_SET_ENABLE_SMOOTH_INTRA: c_int = 118;
    pub const AV1E_SET_ENABLE_PAETH_INTRA: c_int = 119;
    pub const AV1E_SET_ENABLE_CFL_INTRA: c_int = 120;
    pub const AV1E_SET_ENABLE_SUPERRES: c_int = 121;
    pub const AV1E_SET_ENABLE_OVERLAY: c_int = 122;
    pub const AV1E_SET_ENABLE_PALETTE: c_int = 123;
    pub const AV1E_SET_ENABLE_INTRABC: c_int = 124;
    pub const AV1E_SET_DELTALF_MODE: c_int = 125;
    pub const AV1E_SET_SINGLE_TILE_DECODING: c_int = 126;
    pub const AV1E_SET_FILM_GRAIN_TEST_VECTOR: c_int = 127;
    pub const AV1E_SET_FILM_GRAIN_TABLE: c_int = 128;
    pub const AV1E_SET_REDUCED_REFERENCE_SET: c_int = 129;
    pub const AV1E_SET_REDUCED_TX_TYPE_SET: c_int = 130;
    pub const AV1E_SET_INTRA_DCT_ONLY: c_int = 131;
    pub const AV1E_SET_INTER_DCT_ONLY: c_int = 132;
    pub const AV1E_SET_INTRA_DEFAULT_TX_ONLY: c_int = 133;
    pub const AV1E_SET_ADAPTIVE_QP_MODE: c_int = 134;
    pub const AV1E_SET_ENABLE_CONV_SEARCH: c_int = 135;
    pub const AV1E_SET_SKIP_POSTPROC_FILTERING: c_int = 136;
    pub const AV1E_SET_ENABLE_WIENER_DENOISE: c_int = 137;
    pub const AV1E_SET_ENABLE_GLOBAL_MOTION_REFINE: c_int = 138;
    pub const AV1E_SET_ENABLE_WARPED_MOTION_REFINE: c_int = 139;
    pub const AV1E_SET_ENABLE_DIRECTIONAL_INTRA: c_int = 140;
    pub const AV1E_SET_CHROMA_SUBSAMPLING_X: c_int = 141;
    pub const AV1E_SET_CHROMA_SUBSAMPLING_Y: c_int = 142;
    pub const AV1E_SET_REDUCED_REFERENCE_SET: c_int = 143;
    pub const AV1E_SET_ENABLE_TPL_MODEL: c_int = 144;
    pub const AV1E_SET_ENABLE_KEYFRAME_FILTERING: c_int = 145;
    pub const AV1E_SET_ARNR_MAXFRAMES: c_int = 146;
    pub const AV1E_SET_ARNR_STRENGTH: c_int = 147;
    pub const AV1E_SET_TUNE_CONTENT: c_int = 148;
    pub const AV1E_SET_CDF_UPDATE_MODE: c_int = 149;
    pub const AV1E_SET_SUPERBLOCK_SIZE: c_int = 150;
}

#[repr(C)]
pub struct aom_codec_ctx_t {
    pub name: *const u8,
    pub iface: *mut c_void,
    pub err: c_int,
    pub err_detail: *const u8,
    pub init_flags: c_long,
    pub config: aom_codec_ctx_cfg,
    pub priv_: *mut c_void,
}

#[repr(C)]
pub struct aom_codec_ctx_cfg {
    pub w: c_uint,
    pub h: c_uint,
}

#[repr(C)]
pub struct aom_image_t {
    pub fmt: c_uint,
    pub w: c_uint,
    pub h: c_uint,
    pub d_w: c_uint,
    pub d_h: c_uint,
    pub x_chroma_shift: c_uint,
    pub y_chroma_shift: c_uint,
    pub planes: [*mut u8; 4],
    pub stride: [c_int; 4],
    pub bps: c_int,
    pub user_priv: *mut c_void,
    pub img_data: *mut u8,
    pub img_data_owner: c_int,
    pub self_allocd: c_int,
}

pub unsafe extern "C" fn aom_codec_encode(_ctx: *mut aom_codec_ctx_t, _img: *const aom_image_t, _pts: i64, _duration: c_long, _flags: c_long, _deadline: c_long) -> c_int { 0 }
pub unsafe extern "C" fn aom_codec_control(_ctx: *mut aom_codec_ctx_t, _ctrl_id: c_int, ...) -> c_int { 0 }

// Additional missing structures and functions for AOM
pub mod aom_kf_mode {
    use super::*;
    pub const AOM_KF_FIXED: c_int = 0;
    pub const AOM_KF_AUTO: c_int = 1;
    pub const AOM_KF_DISABLED: c_int = 2;
}

pub mod aom_rc_mode {
    use super::*;
    pub const AOM_VBR: c_int = 0;
    pub const AOM_CBR: c_int = 1;
    pub const AOM_CQ: c_int = 2;
    pub const AOM_Q: c_int = 3;
}

pub mod aom_enc_pass {
    use super::*;
    pub const AOM_RC_ONE_PASS: c_int = 0;
    pub const AOM_RC_FIRST_PASS: c_int = 1;
    pub const AOM_RC_LAST_PASS: c_int = 2;
}

pub mod aom_superblock_size_t {
    use super::*;
    pub const AOM_SUPERBLOCK_SIZE_64X64: c_int = 0;
    pub const AOM_SUPERBLOCK_SIZE_128X128: c_int = 1;
    pub const AOM_SUPERBLOCK_SIZE_DYNAMIC: c_int = 2;
}

pub const AOM_USAGE_REALTIME: u32 = 1;

#[repr(C)]
pub struct aom_codec_enc_cfg {
    pub g_usage: c_uint,
    pub g_threads: c_uint,
    pub g_profile: c_uint,
    pub g_w: c_uint,
    pub g_h: c_uint,
    pub g_bit_depth: c_uint,
    pub g_input_bit_depth: c_uint,
    pub g_timebase: aom_rational_t,
    pub g_error_resilient: c_uint,
    pub g_pass: c_int,
    pub g_lag_in_frames: c_uint,
    pub rc_dropframe_thresh: c_uint,
    pub rc_resize_allowed: c_uint,
    pub rc_scaled_width: c_uint,
    pub rc_scaled_height: c_uint,
    pub rc_resize_up_thresh: c_uint,
    pub rc_resize_down_thresh: c_uint,
    pub rc_end_usage: c_int,
    pub rc_target_bitrate: c_uint,
    pub rc_min_quantizer: c_uint,
    pub rc_max_quantizer: c_uint,
    pub rc_undershoot_pct: c_uint,
    pub rc_overshoot_pct: c_uint,
    pub rc_buf_sz: c_uint,
    pub rc_buf_initial_sz: c_uint,
    pub rc_buf_optimal_sz: c_uint,
    pub rc_2pass_vbr_bias_pct: c_uint,
    pub rc_2pass_vbr_minsection_pct: c_uint,
    pub rc_2pass_vbr_maxsection_pct: c_uint,
    pub kf_mode: c_int,
    pub kf_min_dist: c_uint,
    pub kf_max_dist: c_uint,
    pub ss_number_layers: c_uint,
    pub ts_number_layers: c_uint,
    pub ts_target_bitrate: [c_uint; 5],
    pub ts_rate_decimator: [c_uint; 5],
    pub ts_periodicity: c_uint,
    pub ts_layer_id: [c_uint; 16],
    pub layer_target_bitrate: [c_uint; 12],
}

#[repr(C)]
pub struct aom_rational_t {
    pub num: c_int,
    pub den: c_int,
}

#[repr(C)]
pub struct aom_codec_iface {
    pub name: *const u8,
}

#[repr(C)]
pub struct aom_codec_iter_t {
    pub _unused: *mut c_void,
}

#[repr(C)]
pub struct aom_codec_pkt_t {
    pub kind: c_int,
    pub data: aom_codec_pkt_data,
}

#[repr(C)]
pub union aom_codec_pkt_data {
    pub frame: aom_codec_cx_pkt,
    pub twopass_stats: aom_codec_pkt_t__bindgen_ty_1,
    pub firstpass_mb_stats: aom_codec_pkt_t__bindgen_ty_2,
    pub psnr: aom_codec_pkt_t__bindgen_ty_3,
    pub raw: aom_codec_pkt_t__bindgen_ty_4,
}

#[repr(C)]
pub struct aom_codec_cx_pkt {
    pub data: aom_codec_cx_pkt_data,
    pub sz: usize,
    pub pts: i64,
    pub duration: c_long,
    pub flags: c_uint,
    pub partition_id: c_int,
}

#[repr(C)]
pub union aom_codec_cx_pkt_data {
    pub buf: *mut c_void,
    pub frame: *mut aom_image_t,
}

#[repr(C)]
pub struct aom_codec_pkt_t__bindgen_ty_1 {
    pub buf: *mut c_void,
    pub sz: usize,
}

#[repr(C)]
pub struct aom_codec_pkt_t__bindgen_ty_2 {
    pub buf: *mut c_void,
    pub sz: usize,
}

#[repr(C)]
pub struct aom_codec_pkt_t__bindgen_ty_3 {
    pub samples: [c_uint; 4],
    pub sse: [u64; 4],
    pub psnr: [f64; 4],
}

#[repr(C)]
pub struct aom_codec_pkt_t__bindgen_ty_4 {
    pub buf: *mut c_void,
    pub sz: usize,
}

pub unsafe extern "C" fn aom_codec_enc_config_default(_iface: *const aom_codec_iface, _cfg: *mut aom_codec_enc_cfg, _usage: c_uint) -> c_int { 0 }
pub unsafe extern "C" fn aom_codec_enc_init_ver(_ctx: *mut aom_codec_ctx_t, _iface: *const aom_codec_iface, _cfg: *const aom_codec_enc_cfg, _flags: c_long, _ver: c_int) -> c_int { 0 }
pub unsafe extern "C" fn aom_codec_get_cx_data(_ctx: *mut aom_codec_ctx_t, _iter: *mut aom_codec_iter_t) -> *const aom_codec_pkt_t { std::ptr::null() }
pub unsafe extern "C" fn aom_codec_destroy(_ctx: *mut aom_codec_ctx_t) -> c_int { 0 }
pub unsafe extern "C" fn aom_img_fmt_to_str(_fmt: c_uint) -> *const u8 { b"YUV420P\0".as_ptr() }
pub unsafe extern "C" fn aom_img_alloc(_img: *mut aom_image_t, _fmt: c_uint, _d_w: c_uint, _d_h: c_uint, _align: c_uint) -> *mut aom_image_t { std::ptr::null_mut() }
pub unsafe extern "C" fn aom_img_free(_img: *mut aom_image_t) {}

// Interface functions
pub fn aom_codec_av1_cx() -> *const aom_codec_iface {
    static IFACE: aom_codec_iface = aom_codec_iface {
        name: b"av1\0".as_ptr(),
    };
    &IFACE
}
"#,
            _ => "// Stub file for Android\n",
        };
        
        std::fs::write(&ffi_rs, stub_content).unwrap();
        return;
    }
    
    let includes = find_package(package);
    let src_dir = env::var_os("CARGO_MANIFEST_DIR").unwrap();
    let src_dir = Path::new(&src_dir);
    let out_dir = env::var_os("OUT_DIR").unwrap();
    let out_dir = Path::new(&out_dir);

    let ffi_header = src_dir.join("src").join("bindings").join(ffi_header);
    println!("rerun-if-changed={}", ffi_header.display());
    for dir in &includes {
        println!("rerun-if-changed={}", dir.display());
    }

    let ffi_rs = out_dir.join(generated);
    let exact_file = src_dir.join("generated").join(generated);
    generate_bindings(&ffi_header, &includes, &ffi_rs, &exact_file, regex);
}

// If you have problems installing ffmpeg, you can download $VCPKG_ROOT/installed from ci
// Linux require link in hwcodec
/*
fn ffmpeg() {
    // ffmpeg
    let target_os = std::env::var("CARGO_CFG_TARGET_OS").unwrap();
    let target_arch = std::env::var("CARGO_CFG_TARGET_ARCH").unwrap();
    let static_libs = vec!["avcodec", "avutil", "avformat"];
    static_libs.iter().for_each(|lib| {
        find_package(lib);
    });
    if target_os == "windows" {
        println!("cargo:rustc-link-lib=static=libmfx");
    }

    // os
    let dyn_libs: Vec<&str> = if target_os == "windows" {
        ["User32", "bcrypt", "ole32", "advapi32"].to_vec()
    } else if target_os == "linux" {
        let mut v = ["va", "va-drm", "va-x11", "vdpau", "X11", "stdc++"].to_vec();
        if target_arch == "x86_64" {
            v.push("z");
        }
        v
    } else if target_os == "macos" || target_os == "ios" {
        ["c++", "m"].to_vec()
    } else if target_os == "android" {
        ["z", "m", "android", "atomic"].to_vec()
    } else {
        panic!("unsupported os");
    };
    dyn_libs
        .iter()
        .map(|lib| println!("cargo:rustc-link-lib={}", lib))
        .count();

    if target_os == "macos" || target_os == "ios" {
        println!("cargo:rustc-link-lib=framework=CoreFoundation");
        println!("cargo:rustc-link-lib=framework=CoreVideo");
        println!("cargo:rustc-link-lib=framework=CoreMedia");
        println!("cargo:rustc-link-lib=framework=VideoToolbox");
        println!("cargo:rustc-link-lib=framework=AVFoundation");
    }
}
*/

fn main() {
    // there is problem with cfg(target_os) in build.rs, so use our workaround
    let target_os = std::env::var("CARGO_CFG_TARGET_OS").unwrap();

    // For Android, do minimal configuration and exit early
    if target_os == "android" {
        println!("cargo:info=Android minimal build - skipping codec generation");
        println!("cargo:rustc-cfg=android");
        return;
    }

    // We check if is macos, because macos uses rust 1.8.1.
    // `cargo::rustc-check-cfg` is new with Cargo 1.80.
    // No need to run `cargo version` to get the version here, because:
    // The following lines are used to suppress the lint warnings.
    //          warning: unexpected `cfg` condition name: `quartz`
    if cfg!(target_os = "macos") {
        if target_os != "ios" {
            println!("cargo::rustc-check-cfg=cfg(android)");
            println!("cargo::rustc-check-cfg=cfg(dxgi)");
            println!("cargo::rustc-check-cfg=cfg(quartz)");
            println!("cargo::rustc-check-cfg=cfg(x11)");
            //        ^^^^^^^^^^^^^^^^^^^^^^ new with Cargo 1.80
        }
    }

    // note: all link symbol names in x86 (32-bit) are prefixed wth "_".
    // run "rustup show" to show current default toolchain, if it is stable-x86-pc-windows-msvc,
    // please install x64 toolchain by "rustup toolchain install stable-x86_64-pc-windows-msvc",
    // then set x64 to default by "rustup default stable-x86_64-pc-windows-msvc"
    let target = target_build_utils::TargetInfo::new();
    if target.unwrap().target_pointer_width() != "64" {
        // panic!("Only support 64bit system");
    }
    env::remove_var("CARGO_CFG_TARGET_FEATURE");
    env::set_var("CARGO_CFG_TARGET_FEATURE", "crt-static");

    find_package("libyuv");
    gen_vcpkg_package("libvpx", "vpx_ffi.h", "vpx_ffi.rs", "^[vV].*");
    gen_vcpkg_package("aom", "aom_ffi.h", "aom_ffi.rs", "^(aom|AOM|OBU|AV1).*");
    gen_vcpkg_package("libyuv", "yuv_ffi.h", "yuv_ffi.rs", ".*");
    // ffmpeg();

    if target_os == "ios" {
        // nothing
    } else if target_os == "android" {
        println!("cargo:rustc-cfg=android");
    } else if cfg!(windows) {
        // The first choice is Windows because DXGI is amazing.
        println!("cargo:rustc-cfg=dxgi");
    } else if cfg!(target_os = "macos") {
        // Quartz is second because macOS is the (annoying) exception.
        println!("cargo:rustc-cfg=quartz");
    } else if cfg!(unix) {
        // On UNIX we pray that X11 (with XCB) is available.
        println!("cargo:rustc-cfg=x11");
    }
}
