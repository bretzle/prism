const std = @import("std");
const w32 = @import("windows.zig");
const os = std.os.windows;

const UINT = w32.UINT;
const HWND = w32.HWND;
const BOOL = w32.BOOL;
const HRESULT = w32.HRESULT;
const GUID = w32.GUID;
const WCHAR = os.WCHAR;
const RECT = w32.RECT;
const HMONITOR = w32.HMONITOR;
const HANDLE = w32.HANDLE;
const FLOAT = os.FLOAT;
const LARGE_INTEGER = os.LARGE_INTEGER;
const INT = w32.INT;
const BYTE = os.BYTE;
const SIZE_T = w32.SIZE_T;
const LUID = w32.LUID;
const ULONG = w32.ULONG;
const POINT = w32.POINT;

pub const ERROR_NOT_FOUND = 0x887A0002;

pub const IUnknown = w32.d3dcommon.IUnknown;
pub const IObject = w32.d3dcommon.IObject;

pub const FORMAT = enum(UINT) {
    UNKNOWN = 0,
    R32G32B32A32_TYPELESS = 1,
    R32G32B32A32_FLOAT = 2,
    R32G32B32A32_UINT = 3,
    R32G32B32A32_SINT = 4,
    R32G32B32_TYPELESS = 5,
    R32G32B32_FLOAT = 6,
    R32G32B32_UINT = 7,
    R32G32B32_SINT = 8,
    R16G16B16A16_TYPELESS = 9,
    R16G16B16A16_FLOAT = 10,
    R16G16B16A16_UNORM = 11,
    R16G16B16A16_UINT = 12,
    R16G16B16A16_SNORM = 13,
    R16G16B16A16_SINT = 14,
    R32G32_TYPELESS = 15,
    R32G32_FLOAT = 16,
    R32G32_UINT = 17,
    R32G32_SINT = 18,
    R32G8X24_TYPELESS = 19,
    D32_FLOAT_S8X24_UINT = 20,
    R32_FLOAT_X8X24_TYPELESS = 21,
    X32_TYPELESS_G8X24_UINT = 22,
    R10G10B10A2_TYPELESS = 23,
    R10G10B10A2_UNORM = 24,
    R10G10B10A2_UINT = 25,
    R11G11B10_FLOAT = 26,
    R8G8B8A8_TYPELESS = 27,
    R8G8B8A8_UNORM = 28,
    R8G8B8A8_UNORM_SRGB = 29,
    R8G8B8A8_UINT = 30,
    R8G8B8A8_SNORM = 31,
    R8G8B8A8_SINT = 32,
    R16G16_TYPELESS = 33,
    R16G16_FLOAT = 34,
    R16G16_UNORM = 35,
    R16G16_UINT = 36,
    R16G16_SNORM = 37,
    R16G16_SINT = 38,
    R32_TYPELESS = 39,
    D32_FLOAT = 40,
    R32_FLOAT = 41,
    R32_UINT = 42,
    R32_SINT = 43,
    R24G8_TYPELESS = 44,
    D24_UNORM_S8_UINT = 45,
    R24_UNORM_X8_TYPELESS = 46,
    X24_TYPELESS_G8_UINT = 47,
    R8G8_TYPELESS = 48,
    R8G8_UNORM = 49,
    R8G8_UINT = 50,
    R8G8_SNORM = 51,
    R8G8_SINT = 52,
    R16_TYPELESS = 53,
    R16_FLOAT = 54,
    D16_UNORM = 55,
    R16_UNORM = 56,
    R16_UINT = 57,
    R16_SNORM = 58,
    R16_SINT = 59,
    R8_TYPELESS = 60,
    R8_UNORM = 61,
    R8_UINT = 62,
    R8_SNORM = 63,
    R8_SINT = 64,
    A8_UNORM = 65,
    R1_UNORM = 66,
    R9G9B9E5_SHAREDEXP = 67,
    R8G8_B8G8_UNORM = 68,
    G8R8_G8B8_UNORM = 69,
    BC1_TYPELESS = 70,
    BC1_UNORM = 71,
    BC1_UNORM_SRGB = 72,
    BC2_TYPELESS = 73,
    BC2_UNORM = 74,
    BC2_UNORM_SRGB = 75,
    BC3_TYPELESS = 76,
    BC3_UNORM = 77,
    BC3_UNORM_SRGB = 78,
    BC4_TYPELESS = 79,
    BC4_UNORM = 80,
    BC4_SNORM = 81,
    BC5_TYPELESS = 82,
    BC5_UNORM = 83,
    BC5_SNORM = 84,
    B5G6R5_UNORM = 85,
    B5G5R5A1_UNORM = 86,
    B8G8R8A8_UNORM = 87,
    B8G8R8X8_UNORM = 88,
    R10G10B10_XR_BIAS_A2_UNORM = 89,
    B8G8R8A8_TYPELESS = 90,
    B8G8R8A8_UNORM_SRGB = 91,
    B8G8R8X8_TYPELESS = 92,
    B8G8R8X8_UNORM_SRGB = 93,
    BC6H_TYPELESS = 94,
    BC6H_UF16 = 95,
    BC6H_SF16 = 96,
    BC7_TYPELESS = 97,
    BC7_UNORM = 98,
    BC7_UNORM_SRGB = 99,
    AYUV = 100,
    Y410 = 101,
    Y416 = 102,
    NV12 = 103,
    P010 = 104,
    P016 = 105,
    @"420_OPAQUE" = 106,
    YUY2 = 107,
    Y210 = 108,
    Y216 = 109,
    NV11 = 110,
    AI44 = 111,
    IA44 = 112,
    P8 = 113,
    A8P8 = 114,
    B4G4R4A4_UNORM = 115,
    P208 = 130,
    V208 = 131,
    V408 = 132,
    SAMPLER_FEEDBACK_MIN_MIP_OPAQUE = 189,
    SAMPLER_FEEDBACK_MIP_REGION_USED_OPAQUE = 190,

    pub fn pixelSizeInBits(format: FORMAT) u32 {
        return switch (format) {
            .R32G32B32A32_TYPELESS, .R32G32B32A32_FLOAT, .R32G32B32A32_UINT, .R32G32B32A32_SINT => 128,
            .R32G32B32_TYPELESS, .R32G32B32_FLOAT, .R32G32B32_UINT, .R32G32B32_SINT => 96,
            .R16G16B16A16_TYPELESS, .R16G16B16A16_FLOAT, .R16G16B16A16_UNORM, .R16G16B16A16_UINT, .R16G16B16A16_SNORM, .R16G16B16A16_SINT, .R32G32_TYPELESS, .R32G32_FLOAT, .R32G32_UINT, .R32G32_SINT, .R32G8X24_TYPELESS, .D32_FLOAT_S8X24_UINT, .R32_FLOAT_X8X24_TYPELESS, .X32_TYPELESS_G8X24_UINT, .Y416, .Y210, .Y216 => 64,
            .R10G10B10A2_TYPELESS, .R10G10B10A2_UNORM, .R10G10B10A2_UINT, .R11G11B10_FLOAT, .R8G8B8A8_TYPELESS, .R8G8B8A8_UNORM, .R8G8B8A8_UNORM_SRGB, .R8G8B8A8_UINT, .R8G8B8A8_SNORM, .R8G8B8A8_SINT, .R16G16_TYPELESS, .R16G16_FLOAT, .R16G16_UNORM, .R16G16_UINT, .R16G16_SNORM, .R16G16_SINT, .R32_TYPELESS, .D32_FLOAT, .R32_FLOAT, .R32_UINT, .R32_SINT, .R24G8_TYPELESS, .D24_UNORM_S8_UINT, .R24_UNORM_X8_TYPELESS, .X24_TYPELESS_G8_UINT, .R9G9B9E5_SHAREDEXP, .R8G8_B8G8_UNORM, .G8R8_G8B8_UNORM, .B8G8R8A8_UNORM, .B8G8R8X8_UNORM, .R10G10B10_XR_BIAS_A2_UNORM, .B8G8R8A8_TYPELESS, .B8G8R8A8_UNORM_SRGB, .B8G8R8X8_TYPELESS, .B8G8R8X8_UNORM_SRGB, .AYUV, .Y410, .YUY2 => 32,
            .P010, .P016, .V408 => 24,
            .R8G8_TYPELESS, .R8G8_UNORM, .R8G8_UINT, .R8G8_SNORM, .R8G8_SINT, .R16_TYPELESS, .R16_FLOAT, .D16_UNORM, .R16_UNORM, .R16_UINT, .R16_SNORM, .R16_SINT, .B5G6R5_UNORM, .B5G5R5A1_UNORM, .A8P8, .B4G4R4A4_UNORM => 16,
            .P208, .V208 => 16,
            .@"420_OPAQUE", .NV11, .NV12 => 12,
            .R8_TYPELESS, .R8_UNORM, .R8_UINT, .R8_SNORM, .R8_SINT, .A8_UNORM, .AI44, .IA44, .P8 => 8,
            .BC2_TYPELESS, .BC2_UNORM, .BC2_UNORM_SRGB, .BC3_TYPELESS, .BC3_UNORM, .BC3_UNORM_SRGB, .BC5_TYPELESS, .BC5_UNORM, .BC5_SNORM, .BC6H_TYPELESS, .BC6H_UF16, .BC6H_SF16, .BC7_TYPELESS, .BC7_UNORM, .BC7_UNORM_SRGB => 8,
            .R1_UNORM => 1,
            .BC1_TYPELESS, .BC1_UNORM, .BC1_UNORM_SRGB, .BC4_TYPELESS, .BC4_UNORM, .BC4_SNORM => 4,
            .UNKNOWN, .SAMPLER_FEEDBACK_MIP_REGION_USED_OPAQUE, .SAMPLER_FEEDBACK_MIN_MIP_OPAQUE => unreachable,
        };
    }

    pub fn isDepthStencil(format: FORMAT) bool {
        return switch (format) {
            .R32G8X24_TYPELESS, .D32_FLOAT_S8X24_UINT, .R32_FLOAT_X8X24_TYPELESS, .X32_TYPELESS_G8X24_UINT, .D32_FLOAT, .R24G8_TYPELESS, .D24_UNORM_S8_UINT, .R24_UNORM_X8_TYPELESS, .X24_TYPELESS_G8_UINT, .D16_UNORM => true,
            else => false,
        };
    }
};

pub const RATIONAL = extern struct {
    Numerator: UINT,
    Denominator: UINT,
};

// The following values are used with SAMPLE_DESC::Quality:
pub const STANDARD_MULTISAMPLE_QUALITY_PATTERN = 0xffffffff;
pub const CENTER_MULTISAMPLE_QUALITY_PATTERN = 0xfffffffe;

pub const SAMPLE_DESC = extern struct {
    Count: UINT,
    Quality: UINT,
};

pub const COLOR_SPACE_TYPE = enum(UINT) {
    RGB_FULL_G22_NONE_P709 = 0,
    RGB_FULL_G10_NONE_P709 = 1,
    RGB_STUDIO_G22_NONE_P709 = 2,
    RGB_STUDIO_G22_NONE_P2020 = 3,
    RESERVED = 4,
    YCBCR_FULL_G22_NONE_P709_X601 = 5,
    YCBCR_STUDIO_G22_LEFT_P601 = 6,
    YCBCR_FULL_G22_LEFT_P601 = 7,
    YCBCR_STUDIO_G22_LEFT_P709 = 8,
    YCBCR_FULL_G22_LEFT_P709 = 9,
    YCBCR_STUDIO_G22_LEFT_P2020 = 10,
    YCBCR_FULL_G22_LEFT_P2020 = 11,
    RGB_FULL_G2084_NONE_P2020 = 12,
    YCBCR_STUDIO_G2084_LEFT_P2020 = 13,
    RGB_STUDIO_G2084_NONE_P2020 = 14,
    YCBCR_STUDIO_G22_TOPLEFT_P2020 = 15,
    YCBCR_STUDIO_G2084_TOPLEFT_P2020 = 16,
    RGB_FULL_G22_NONE_P2020 = 17,
    YCBCR_STUDIO_GHLG_TOPLEFT_P2020 = 18,
    YCBCR_FULL_GHLG_TOPLEFT_P2020 = 19,
    RGB_STUDIO_G24_NONE_P709 = 20,
    RGB_STUDIO_G24_NONE_P2020 = 21,
    YCBCR_STUDIO_G24_LEFT_P709 = 22,
    YCBCR_STUDIO_G24_LEFT_P2020 = 23,
    YCBCR_STUDIO_G24_TOPLEFT_P2020 = 24,
    CUSTOM = 0xFFFFFFFF,
};

pub const CPU_ACCESS = enum(UINT) {
    NONE = 0,
    DYNAMIC = 1,
    READ_WRITE = 2,
    SCRATCH = 3,
    FIELD = 15,
};

pub const RGB = extern struct {
    Red: FLOAT,
    Green: FLOAT,
    Blue: FLOAT,
};

pub const D3DCOLORVALUE = extern struct {
    r: FLOAT,
    g: FLOAT,
    b: FLOAT,
    a: FLOAT,
};

pub const RGBA = D3DCOLORVALUE;

pub const GAMMA_CONTROL = extern struct {
    Scale: RGB,
    Offset: RGB,
    GammaCurve: [1025]RGB,
};

pub const GAMMA_CONTROL_CAPABILITIES = extern struct {
    ScaleAndOffsetSupported: BOOL,
    MaxConvertedValue: FLOAT,
    MinConvertedValue: FLOAT,
    NumGammaControlPoints: UINT,
    ControlPointPositions: [1025]FLOAT,
};

pub const MODE_SCANLINE_ORDER = enum(UINT) {
    UNSPECIFIED = 0,
    PROGRESSIVE = 1,
    UPPER_FIELD_FIRST = 2,
    LOWER_FIELD_FIRST = 3,
};

pub const MODE_SCALING = enum(UINT) {
    UNSPECIFIED = 0,
    CENTERED = 1,
    STRETCHED = 2,
};

pub const MODE_ROTATION = enum(UINT) {
    UNSPECIFIED = 0,
    IDENTITY = 1,
    ROTATE90 = 2,
    ROTATE180 = 3,
    ROTATE270 = 4,
};

pub const MODE_DESC = extern struct {
    Width: UINT,
    Height: UINT,
    RefreshRate: RATIONAL,
    Format: FORMAT,
    ScanlineOrdering: MODE_SCANLINE_ORDER,
    Scaling: MODE_SCALING,
};

pub const USAGE = packed struct(UINT) {
    __unused0: bool = false,
    __unused1: bool = false,
    __unused2: bool = false,
    __unused3: bool = false,
    SHADER_INPUT: bool = false,
    RENDER_TARGET_OUTPUT: bool = false,
    BACK_BUFFER: bool = false,
    SHARED: bool = false,
    READ_ONLY: bool = false,
    DISCARD_ON_PRESENT: bool = false,
    UNORDERED_ACCESS: bool = false,
    __unused: u21 = 0,
};

pub const FRAME_STATISTICS = extern struct {
    PresentCount: UINT,
    PresentRefreshCount: UINT,
    SyncRefreshCount: UINT,
    SyncQPCTime: LARGE_INTEGER,
    SyncGPUTime: LARGE_INTEGER,
};

pub const MAPPED_RECT = extern struct {
    Pitch: INT,
    pBits: *BYTE,
};

pub const ADAPTER_DESC = extern struct {
    Description: [128]WCHAR,
    VendorId: UINT,
    DeviceId: UINT,
    SubSysId: UINT,
    Revision: UINT,
    DedicatedVideoMemory: SIZE_T,
    DedicatedSystemMemory: SIZE_T,
    SharedSystemMemory: SIZE_T,
    AdapterLuid: LUID,
};

pub const OUTPUT_DESC = extern struct {
    DeviceName: [32]WCHAR,
    DesktopCoordinates: RECT,
    AttachedToDesktop: BOOL,
    Rotation: MODE_ROTATION,
    Monitor: HMONITOR,
};

pub const SHARED_RESOURCE = extern struct {
    Handle: HANDLE,
};

pub const RESOURCE_PRIORITY = enum(UINT) {
    MINIMUM = 0x28000000,
    LOW = 0x50000000,
    NORMAL = 0x78000000,
    HIGH = 0xa0000000,
    MAXIMUM = 0xc8000000,
};

pub const RESIDENCY = enum(UINT) {
    FULLY_RESIDENT = 1,
    RESIDENT_IN_SHARED_MEMORY = 2,
    EVICTED_TO_DISK = 3,
};

pub const SURFACE_DESC = extern struct {
    Width: UINT,
    Height: UINT,
    Format: FORMAT,
    SampleDesc: SAMPLE_DESC,
};

pub const SWAP_EFFECT = enum(UINT) {
    DISCARD = 0,
    SEQUENTIAL = 1,
    FLIP_SEQUENTIAL = 3,
    FLIP_DISCARD = 4,
};

pub const SWAP_CHAIN_FLAG = packed struct(UINT) {
    NONPREROTATED: bool = false,
    ALLOW_MODE_SWITCH: bool = false,
    GDI_COMPATIBLE: bool = false,
    RESTRICTED_CONTENT: bool = false,
    RESTRICT_SHARED_RESOURCE_DRIVER: bool = false,
    DISPLAY_ONLY: bool = false,
    FRAME_LATENCY_WAITABLE_OBJECT: bool = false,
    FOREGROUND_LAYER: bool = false,
    FULLSCREEN_VIDEO: bool = false,
    YUV_VIDEO: bool = false,
    HW_PROTECTED: bool = false,
    ALLOW_TEARING: bool = false,
    RESTRICTED_TO_ALL_HOLOGRAPHIC_DISPLAYS: bool = false,
    __unused: u19 = 0,
};

pub const SWAP_CHAIN_DESC = extern struct {
    BufferDesc: MODE_DESC,
    SampleDesc: SAMPLE_DESC,
    BufferUsage: USAGE,
    BufferCount: UINT,
    OutputWindow: HWND,
    Windowed: BOOL,
    SwapEffect: SWAP_EFFECT = .DISCARD,
    Flags: SWAP_CHAIN_FLAG = .{},
};

pub const ENUM_MODES = packed struct(UINT) {
    INTERLACED: bool = false,
    SCALING: bool = false,
    STEREO: bool = false,
    DISABLED_STEREO: bool = false,
    __unused: u28 = 0,
};

pub const MWA_FLAGS = packed struct(UINT) {
    NO_WINDOW_CHANGES: bool = false,
    NO_ALT_ENTER: bool = false,
    NO_PRINT_SCREEN: bool = false,
    __unused: u29 = 0,
};

pub const ADAPTER_FLAGS = packed struct(UINT) {
    REMOTE: bool = false,
    SOFTWARE: bool = false,
    __unused: u30 = 0,
};

pub const ADAPTER_DESC1 = extern struct {
    Description: [128]WCHAR,
    VendorId: UINT,
    DeviceId: UINT,
    SubSysId: UINT,
    Revision: UINT,
    DedicatedVideoMemory: SIZE_T,
    DedicatedSystemMemory: SIZE_T,
    SharedSystemMemory: SIZE_T,
    AdapterLuid: LUID,
    Flags: ADAPTER_FLAGS,
};

pub const MAP_FLAG = packed struct(UINT) {
    READ: bool = false,
    WRITE: bool = false,
    DISCARD: bool = false,
    __unused: u29 = 0,
};

pub const PRESENT_FLAG = packed struct(UINT) {
    TEST: bool = false,
    DO_NOT_SEQUENCE: bool = false,
    RESTART: bool = false,
    DO_NOT_WAIT: bool = false,
    STEREO_PREFER_RIGHT: bool = false,
    STEREO_TEMPORARY_MONO: bool = false,
    RESTRICT_TO_OUTPUT: bool = false,
    __unused7: bool = false,
    USE_DURATION: bool = false,
    ALLOW_TEARING: bool = false,
    __unused: u22 = 0,
};

pub const PRESENT_PARAMETERS = extern struct {
    DirtyRectsCount: UINT,
    pDirtyRects: ?*RECT,
    pScrollRect: *RECT,
    pScrollOffset: *POINT,
};

pub const SCALING = enum(UINT) {
    STRETCH = 0,
    NONE = 1,
    ASPECT_RATIO_STRETCH = 2,
};

pub const ALPHA_MODE = enum(UINT) {
    UNSPECIFIED = 0,
    PREMULTIPLIED = 1,
    STRAIGHT = 2,
    IGNORE = 3,
};

pub const SWAP_CHAIN_DESC1 = extern struct {
    Width: UINT,
    Height: UINT,
    Format: FORMAT,
    Stereo: BOOL,
    SampleDesc: SAMPLE_DESC,
    BufferUsage: USAGE,
    BufferCount: UINT,
    Scaling: SCALING,
    SwapEffect: SWAP_EFFECT,
    AlphaMode: ALPHA_MODE,
    Flags: SWAP_CHAIN_FLAG,
};

pub const SWAP_CHAIN_FULLSCREEN_DESC = extern struct {
    RefreshRate: RATIONAL,
    ScanlineOrdering: MODE_SCANLINE_ORDER,
    Scaling: MODE_SCALING,
    Windowed: BOOL,
};

pub const MATRIX_3X2_F = extern struct {
    _11: FLOAT,
    _12: FLOAT,
    _21: FLOAT,
    _22: FLOAT,
    _31: FLOAT,
    _32: FLOAT,
};

pub const COLOR_SPACE_SUPPORT = packed struct(u32) {
    present: bool = false,
    overlay_present: bool = false,
    _: u30 = 0,
};

pub const DEBUG_RLO_FLAGS = enum(u32) {
    // TODO: convert to bit_set
    SUMMARY = 1,
    DETAIL = 2,
    IGNORE_INTERNAL = 4,
    ALL = 7,
};

// functions
// ---------

pub extern "dxgi" fn CreateDXGIFactory2(UINT, *const GUID, *?*anyopaque) callconv(.winapi) HRESULT;
pub extern "dxgi" fn DXGIGetDebugInterface1(flags: u32, riid: *const GUID, debug: *?*anyopaque) callconv(.winapi) HRESULT;

// THIS FILE IS AUTOGENERATED BEYOND THIS POINT! DO NOT EDIT!
// ----------------------------------------------------------

pub const IOutput = extern struct {
    pub const IID = GUID.parse("{AE02EEDB-C735-4690-8D52-5A8DC20213AA}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IObject.VTable,
        get_desc: *const fn (*IOutput, desc: *OUTPUT_DESC) callconv(.winapi) HRESULT,
        get_display_mode_list: *const fn (*IOutput, format: FORMAT, flags: ENUM_MODES, num_modes: *UINT, desc: [*]MODE_DESC) callconv(.winapi) HRESULT,
        find_closest_matching_mode: *const fn (*IOutput, to_match: *const MODE_DESC, closet_match: *MODE_DESC, concerned_device: ?*IUnknown) callconv(.winapi) HRESULT,
        wait_for_v_blank: *const fn (*IOutput) callconv(.winapi) HRESULT,
        take_ownership: *const fn (*IOutput, device: *IUnknown, exclusive: BOOL) callconv(.winapi) HRESULT,
        release_ownership: *const fn (*IOutput) callconv(.winapi) void,
        get_gamma_control_capabilities: *const fn (*IOutput, gamma_caps: *GAMMA_CONTROL_CAPABILITIES) callconv(.winapi) HRESULT,
        set_gamma_control: *const fn (*IOutput, array: *const GAMMA_CONTROL) callconv(.winapi) HRESULT,
        get_gamma_control: *const fn (*IOutput, array: *GAMMA_CONTROL) callconv(.winapi) HRESULT,
        set_display_surface: *const fn (*IOutput, surface: *ISurface) callconv(.winapi) HRESULT,
        get_display_surface_data: *const fn (*IOutput, surface: *ISurface) callconv(.winapi) HRESULT,
        get_frame_statistics: *const fn (*IOutput, stats: *FRAME_STATISTICS) callconv(.winapi) HRESULT,
    };

    pub fn getDesc(self: *IOutput, desc: *OUTPUT_DESC) HRESULT {
        return (self.vtable.get_desc)(self, desc);
    }
    pub fn getDisplayModeList(self: *IOutput, format: FORMAT, flags: ENUM_MODES, num_modes: *UINT, desc: [*]MODE_DESC) HRESULT {
        return (self.vtable.get_display_mode_list)(self, format, flags, num_modes, desc);
    }
    pub fn findClosestMatchingMode(self: *IOutput, to_match: *const MODE_DESC, closet_match: *MODE_DESC, concerned_device: ?*IUnknown) HRESULT {
        return (self.vtable.find_closest_matching_mode)(self, to_match, closet_match, concerned_device);
    }
    pub fn waitForVBlank(self: *IOutput) HRESULT {
        return (self.vtable.wait_for_v_blank)(self);
    }
    pub fn takeOwnership(self: *IOutput, device: *IUnknown, exclusive: BOOL) HRESULT {
        return (self.vtable.take_ownership)(self, device, exclusive);
    }
    pub fn releaseOwnership(self: *IOutput) void {
        return (self.vtable.release_ownership)(self);
    }
    pub fn getGammaControlCapabilities(self: *IOutput, gamma_caps: *GAMMA_CONTROL_CAPABILITIES) HRESULT {
        return (self.vtable.get_gamma_control_capabilities)(self, gamma_caps);
    }
    pub fn setGammaControl(self: *IOutput, array: *const GAMMA_CONTROL) HRESULT {
        return (self.vtable.set_gamma_control)(self, array);
    }
    pub fn getGammaControl(self: *IOutput, array: *GAMMA_CONTROL) HRESULT {
        return (self.vtable.get_gamma_control)(self, array);
    }
    pub fn setDisplaySurface(self: *IOutput, surface: *ISurface) HRESULT {
        return (self.vtable.set_display_surface)(self, surface);
    }
    pub fn getDisplaySurfaceData(self: *IOutput, surface: *ISurface) HRESULT {
        return (self.vtable.get_display_surface_data)(self, surface);
    }
    pub fn getFrameStatistics(self: *IOutput, stats: *FRAME_STATISTICS) HRESULT {
        return (self.vtable.get_frame_statistics)(self, stats);
    }
    // IObject methods
    pub fn getPrivateData(self: *IOutput) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IOutput) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IOutput) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *IOutput) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IOutput, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IOutput) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IOutput) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IFactory = extern struct {
    pub const IID = GUID.parse("{7B7166EC-21C7-44AE-B21A-C9AE321AE369}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IObject.VTable,
        enum_adapters: *const fn (*IFactory, index: UINT, adapter: *?*IAdapter) callconv(.winapi) HRESULT,
        make_window_association: *const fn (*IFactory, window: HWND, flags: MWA_FLAGS) callconv(.winapi) HRESULT,
        get_window_association: *const fn (*IFactory, window: *HWND) callconv(.winapi) HRESULT,
        create_swap_chain: *const fn (*IFactory, device: *IUnknown, desc: *SWAP_CHAIN_DESC, swapchain: *?*ISwapChain) callconv(.winapi) void,
        create_software_adapter: *const fn (*IFactory, adapter: *?*IAdapter) callconv(.winapi) void,
    };

    pub fn enumAdapters(self: *IFactory, index: UINT, adapter: *?*IAdapter) HRESULT {
        return (self.vtable.enum_adapters)(self, index, adapter);
    }
    pub fn makeWindowAssociation(self: *IFactory, window: HWND, flags: MWA_FLAGS) HRESULT {
        return (self.vtable.make_window_association)(self, window, flags);
    }
    pub fn getWindowAssociation(self: *IFactory, window: *HWND) HRESULT {
        return (self.vtable.get_window_association)(self, window);
    }
    pub fn createSwapChain(self: *IFactory, device: *IUnknown, desc: *SWAP_CHAIN_DESC, swapchain: *?*ISwapChain) void {
        return (self.vtable.create_swap_chain)(self, device, desc, swapchain);
    }
    pub fn createSoftwareAdapter(self: *IFactory, adapter: *?*IAdapter) void {
        return (self.vtable.create_software_adapter)(self, adapter);
    }
    // IObject methods
    pub fn getPrivateData(self: *IFactory) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IFactory) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IFactory) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *IFactory) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IFactory, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IFactory) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IFactory) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IFactory1 = extern struct {
    pub const IID = GUID.parse("{770AAE78-F26F-4DBA-A829-253C83D1B387}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IFactory.VTable,
        enum_adapters1: *const fn (*IFactory1, index: UINT, adapter: *?*IAdapter1) callconv(.winapi) HRESULT,
        is_current: *const fn (*IFactory1) callconv(.winapi) BOOL,
    };

    pub fn enumAdapters1(self: *IFactory1, index: UINT, adapter: *?*IAdapter1) HRESULT {
        return (self.vtable.enum_adapters1)(self, index, adapter);
    }
    pub fn isCurrent(self: *IFactory1) BOOL {
        return (self.vtable.is_current)(self);
    }
    // IFactory methods
    pub fn enumAdapters(self: *IFactory1, index: UINT, adapter: *?*IAdapter) HRESULT {
        return (@as(*const IFactory.VTable, @ptrCast(self.vtable)).enum_adapters)(@ptrCast(self), index, adapter);
    }
    pub fn makeWindowAssociation(self: *IFactory1, window: HWND, flags: MWA_FLAGS) HRESULT {
        return (@as(*const IFactory.VTable, @ptrCast(self.vtable)).make_window_association)(@ptrCast(self), window, flags);
    }
    pub fn getWindowAssociation(self: *IFactory1, window: *HWND) HRESULT {
        return (@as(*const IFactory.VTable, @ptrCast(self.vtable)).get_window_association)(@ptrCast(self), window);
    }
    pub fn createSwapChain(self: *IFactory1, device: *IUnknown, desc: *SWAP_CHAIN_DESC, swapchain: *?*ISwapChain) void {
        return (@as(*const IFactory.VTable, @ptrCast(self.vtable)).create_swap_chain)(@ptrCast(self), device, desc, swapchain);
    }
    pub fn createSoftwareAdapter(self: *IFactory1, adapter: *?*IAdapter) void {
        return (@as(*const IFactory.VTable, @ptrCast(self.vtable)).create_software_adapter)(@ptrCast(self), adapter);
    }
    // IObject methods
    pub fn getPrivateData(self: *IFactory1) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IFactory1) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IFactory1) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *IFactory1) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IFactory1, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IFactory1) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IFactory1) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IFactory2 = extern struct {
    pub const IID = GUID.parse("{50C83A1C-E072-4C48-87B0-3630FA36A6D0}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IFactory1.VTable,
        is_windowed_stereo_enabled: *const fn (*IFactory2) callconv(.winapi) noreturn,
        create_swap_chain_for_hwnd: *const fn (*IFactory2, pDevice: *IUnknown, hWnd: HWND, pDesc: *SWAP_CHAIN_DESC1, pFullscreenDesc: ?*SWAP_CHAIN_FULLSCREEN_DESC, pRestrictToOutput: ?*IOutput, swapchain: *?*ISwapChain1) callconv(.winapi) HRESULT,
        create_swap_chain_for_core_window: *const fn (*IFactory2) callconv(.winapi) noreturn,
        get_shared_resource_adapter_luid: *const fn (*IFactory2) callconv(.winapi) noreturn,
        register_stereo_status_window: *const fn (*IFactory2) callconv(.winapi) noreturn,
        register_stereo_status_event: *const fn (*IFactory2) callconv(.winapi) noreturn,
        unregister_stereo_status: *const fn (*IFactory2) callconv(.winapi) noreturn,
        register_occlusion_status_window: *const fn (*IFactory2) callconv(.winapi) noreturn,
        register_occlusion_status_event: *const fn (*IFactory2) callconv(.winapi) noreturn,
        unregister_occlusion_status: *const fn (*IFactory2) callconv(.winapi) noreturn,
        create_swap_chain_for_composition: *const fn (*IFactory2) callconv(.winapi) noreturn,
    };

    pub fn isWindowedStereoEnabled(self: *IFactory2) noreturn {
        return (self.vtable.is_windowed_stereo_enabled)(self);
    }
    pub fn createSwapChainForHwnd(self: *IFactory2, pDevice: *IUnknown, hWnd: HWND, pDesc: *SWAP_CHAIN_DESC1, pFullscreenDesc: ?*SWAP_CHAIN_FULLSCREEN_DESC, pRestrictToOutput: ?*IOutput, swapchain: *?*ISwapChain1) HRESULT {
        return (self.vtable.create_swap_chain_for_hwnd)(self, pDevice, hWnd, pDesc, pFullscreenDesc, pRestrictToOutput, swapchain);
    }
    pub fn createSwapChainForCoreWindow(self: *IFactory2) noreturn {
        return (self.vtable.create_swap_chain_for_core_window)(self);
    }
    pub fn getSharedResourceAdapterLuid(self: *IFactory2) noreturn {
        return (self.vtable.get_shared_resource_adapter_luid)(self);
    }
    pub fn registerStereoStatusWindow(self: *IFactory2) noreturn {
        return (self.vtable.register_stereo_status_window)(self);
    }
    pub fn registerStereoStatusEvent(self: *IFactory2) noreturn {
        return (self.vtable.register_stereo_status_event)(self);
    }
    pub fn unregisterStereoStatus(self: *IFactory2) noreturn {
        return (self.vtable.unregister_stereo_status)(self);
    }
    pub fn registerOcclusionStatusWindow(self: *IFactory2) noreturn {
        return (self.vtable.register_occlusion_status_window)(self);
    }
    pub fn registerOcclusionStatusEvent(self: *IFactory2) noreturn {
        return (self.vtable.register_occlusion_status_event)(self);
    }
    pub fn unregisterOcclusionStatus(self: *IFactory2) noreturn {
        return (self.vtable.unregister_occlusion_status)(self);
    }
    pub fn createSwapChainForComposition(self: *IFactory2) noreturn {
        return (self.vtable.create_swap_chain_for_composition)(self);
    }
    // IFactory1 methods
    pub fn enumAdapters1(self: *IFactory2, index: UINT, adapter: *?*IAdapter1) HRESULT {
        return (@as(*const IFactory1.VTable, @ptrCast(self.vtable)).enum_adapters1)(@ptrCast(self), index, adapter);
    }
    pub fn isCurrent(self: *IFactory2) BOOL {
        return (@as(*const IFactory1.VTable, @ptrCast(self.vtable)).is_current)(@ptrCast(self));
    }
    // IFactory methods
    pub fn enumAdapters(self: *IFactory2, index: UINT, adapter: *?*IAdapter) HRESULT {
        return (@as(*const IFactory.VTable, @ptrCast(self.vtable)).enum_adapters)(@ptrCast(self), index, adapter);
    }
    pub fn makeWindowAssociation(self: *IFactory2, window: HWND, flags: MWA_FLAGS) HRESULT {
        return (@as(*const IFactory.VTable, @ptrCast(self.vtable)).make_window_association)(@ptrCast(self), window, flags);
    }
    pub fn getWindowAssociation(self: *IFactory2, window: *HWND) HRESULT {
        return (@as(*const IFactory.VTable, @ptrCast(self.vtable)).get_window_association)(@ptrCast(self), window);
    }
    pub fn createSwapChain(self: *IFactory2, device: *IUnknown, desc: *SWAP_CHAIN_DESC, swapchain: *?*ISwapChain) void {
        return (@as(*const IFactory.VTable, @ptrCast(self.vtable)).create_swap_chain)(@ptrCast(self), device, desc, swapchain);
    }
    pub fn createSoftwareAdapter(self: *IFactory2, adapter: *?*IAdapter) void {
        return (@as(*const IFactory.VTable, @ptrCast(self.vtable)).create_software_adapter)(@ptrCast(self), adapter);
    }
    // IObject methods
    pub fn getPrivateData(self: *IFactory2) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IFactory2) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IFactory2) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *IFactory2) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IFactory2, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IFactory2) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IFactory2) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IFactory3 = extern struct {
    pub const IID = GUID.parse("{25483823-CD46-4C7D-86CA-47AA95B837BD}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IFactory2.VTable,
        get_creation_flags: *const fn (*IFactory3) callconv(.winapi) noreturn,
    };

    pub fn getCreationFlags(self: *IFactory3) noreturn {
        return (self.vtable.get_creation_flags)(self);
    }
    // IFactory2 methods
    pub fn isWindowedStereoEnabled(self: *IFactory3) noreturn {
        return (@as(*const IFactory2.VTable, @ptrCast(self.vtable)).is_windowed_stereo_enabled)(@ptrCast(self));
    }
    pub fn createSwapChainForHwnd(self: *IFactory3, pDevice: *IUnknown, hWnd: HWND, pDesc: *SWAP_CHAIN_DESC1, pFullscreenDesc: ?*SWAP_CHAIN_FULLSCREEN_DESC, pRestrictToOutput: ?*IOutput, swapchain: *?*ISwapChain1) HRESULT {
        return (@as(*const IFactory2.VTable, @ptrCast(self.vtable)).create_swap_chain_for_hwnd)(@ptrCast(self), pDevice, hWnd, pDesc, pFullscreenDesc, pRestrictToOutput, swapchain);
    }
    pub fn createSwapChainForCoreWindow(self: *IFactory3) noreturn {
        return (@as(*const IFactory2.VTable, @ptrCast(self.vtable)).create_swap_chain_for_core_window)(@ptrCast(self));
    }
    pub fn getSharedResourceAdapterLuid(self: *IFactory3) noreturn {
        return (@as(*const IFactory2.VTable, @ptrCast(self.vtable)).get_shared_resource_adapter_luid)(@ptrCast(self));
    }
    pub fn registerStereoStatusWindow(self: *IFactory3) noreturn {
        return (@as(*const IFactory2.VTable, @ptrCast(self.vtable)).register_stereo_status_window)(@ptrCast(self));
    }
    pub fn registerStereoStatusEvent(self: *IFactory3) noreturn {
        return (@as(*const IFactory2.VTable, @ptrCast(self.vtable)).register_stereo_status_event)(@ptrCast(self));
    }
    pub fn unregisterStereoStatus(self: *IFactory3) noreturn {
        return (@as(*const IFactory2.VTable, @ptrCast(self.vtable)).unregister_stereo_status)(@ptrCast(self));
    }
    pub fn registerOcclusionStatusWindow(self: *IFactory3) noreturn {
        return (@as(*const IFactory2.VTable, @ptrCast(self.vtable)).register_occlusion_status_window)(@ptrCast(self));
    }
    pub fn registerOcclusionStatusEvent(self: *IFactory3) noreturn {
        return (@as(*const IFactory2.VTable, @ptrCast(self.vtable)).register_occlusion_status_event)(@ptrCast(self));
    }
    pub fn unregisterOcclusionStatus(self: *IFactory3) noreturn {
        return (@as(*const IFactory2.VTable, @ptrCast(self.vtable)).unregister_occlusion_status)(@ptrCast(self));
    }
    pub fn createSwapChainForComposition(self: *IFactory3) noreturn {
        return (@as(*const IFactory2.VTable, @ptrCast(self.vtable)).create_swap_chain_for_composition)(@ptrCast(self));
    }
    // IFactory1 methods
    pub fn enumAdapters1(self: *IFactory3, index: UINT, adapter: *?*IAdapter1) HRESULT {
        return (@as(*const IFactory1.VTable, @ptrCast(self.vtable)).enum_adapters1)(@ptrCast(self), index, adapter);
    }
    pub fn isCurrent(self: *IFactory3) BOOL {
        return (@as(*const IFactory1.VTable, @ptrCast(self.vtable)).is_current)(@ptrCast(self));
    }
    // IFactory methods
    pub fn enumAdapters(self: *IFactory3, index: UINT, adapter: *?*IAdapter) HRESULT {
        return (@as(*const IFactory.VTable, @ptrCast(self.vtable)).enum_adapters)(@ptrCast(self), index, adapter);
    }
    pub fn makeWindowAssociation(self: *IFactory3, window: HWND, flags: MWA_FLAGS) HRESULT {
        return (@as(*const IFactory.VTable, @ptrCast(self.vtable)).make_window_association)(@ptrCast(self), window, flags);
    }
    pub fn getWindowAssociation(self: *IFactory3, window: *HWND) HRESULT {
        return (@as(*const IFactory.VTable, @ptrCast(self.vtable)).get_window_association)(@ptrCast(self), window);
    }
    pub fn createSwapChain(self: *IFactory3, device: *IUnknown, desc: *SWAP_CHAIN_DESC, swapchain: *?*ISwapChain) void {
        return (@as(*const IFactory.VTable, @ptrCast(self.vtable)).create_swap_chain)(@ptrCast(self), device, desc, swapchain);
    }
    pub fn createSoftwareAdapter(self: *IFactory3, adapter: *?*IAdapter) void {
        return (@as(*const IFactory.VTable, @ptrCast(self.vtable)).create_software_adapter)(@ptrCast(self), adapter);
    }
    // IObject methods
    pub fn getPrivateData(self: *IFactory3) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IFactory3) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IFactory3) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *IFactory3) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IFactory3, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IFactory3) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IFactory3) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IFactory4 = extern struct {
    pub const IID = GUID.parse("{1BC6EA02-EF36-464F-BF0C-21CA39E5168A}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IFactory3.VTable,
        enum_adapter_by_luid: *const fn (*IFactory4) callconv(.winapi) noreturn,
        enum_warp_adapter: *const fn (*IFactory4) callconv(.winapi) noreturn,
    };

    pub fn enumAdapterByLuid(self: *IFactory4) noreturn {
        return (self.vtable.enum_adapter_by_luid)(self);
    }
    pub fn enumWarpAdapter(self: *IFactory4) noreturn {
        return (self.vtable.enum_warp_adapter)(self);
    }
    // IFactory3 methods
    pub fn getCreationFlags(self: *IFactory4) noreturn {
        return (@as(*const IFactory3.VTable, @ptrCast(self.vtable)).get_creation_flags)(@ptrCast(self));
    }
    // IFactory2 methods
    pub fn isWindowedStereoEnabled(self: *IFactory4) noreturn {
        return (@as(*const IFactory2.VTable, @ptrCast(self.vtable)).is_windowed_stereo_enabled)(@ptrCast(self));
    }
    pub fn createSwapChainForHwnd(self: *IFactory4, pDevice: *IUnknown, hWnd: HWND, pDesc: *SWAP_CHAIN_DESC1, pFullscreenDesc: ?*SWAP_CHAIN_FULLSCREEN_DESC, pRestrictToOutput: ?*IOutput, swapchain: *?*ISwapChain1) HRESULT {
        return (@as(*const IFactory2.VTable, @ptrCast(self.vtable)).create_swap_chain_for_hwnd)(@ptrCast(self), pDevice, hWnd, pDesc, pFullscreenDesc, pRestrictToOutput, swapchain);
    }
    pub fn createSwapChainForCoreWindow(self: *IFactory4) noreturn {
        return (@as(*const IFactory2.VTable, @ptrCast(self.vtable)).create_swap_chain_for_core_window)(@ptrCast(self));
    }
    pub fn getSharedResourceAdapterLuid(self: *IFactory4) noreturn {
        return (@as(*const IFactory2.VTable, @ptrCast(self.vtable)).get_shared_resource_adapter_luid)(@ptrCast(self));
    }
    pub fn registerStereoStatusWindow(self: *IFactory4) noreturn {
        return (@as(*const IFactory2.VTable, @ptrCast(self.vtable)).register_stereo_status_window)(@ptrCast(self));
    }
    pub fn registerStereoStatusEvent(self: *IFactory4) noreturn {
        return (@as(*const IFactory2.VTable, @ptrCast(self.vtable)).register_stereo_status_event)(@ptrCast(self));
    }
    pub fn unregisterStereoStatus(self: *IFactory4) noreturn {
        return (@as(*const IFactory2.VTable, @ptrCast(self.vtable)).unregister_stereo_status)(@ptrCast(self));
    }
    pub fn registerOcclusionStatusWindow(self: *IFactory4) noreturn {
        return (@as(*const IFactory2.VTable, @ptrCast(self.vtable)).register_occlusion_status_window)(@ptrCast(self));
    }
    pub fn registerOcclusionStatusEvent(self: *IFactory4) noreturn {
        return (@as(*const IFactory2.VTable, @ptrCast(self.vtable)).register_occlusion_status_event)(@ptrCast(self));
    }
    pub fn unregisterOcclusionStatus(self: *IFactory4) noreturn {
        return (@as(*const IFactory2.VTable, @ptrCast(self.vtable)).unregister_occlusion_status)(@ptrCast(self));
    }
    pub fn createSwapChainForComposition(self: *IFactory4) noreturn {
        return (@as(*const IFactory2.VTable, @ptrCast(self.vtable)).create_swap_chain_for_composition)(@ptrCast(self));
    }
    // IFactory1 methods
    pub fn enumAdapters1(self: *IFactory4, index: UINT, adapter: *?*IAdapter1) HRESULT {
        return (@as(*const IFactory1.VTable, @ptrCast(self.vtable)).enum_adapters1)(@ptrCast(self), index, adapter);
    }
    pub fn isCurrent(self: *IFactory4) BOOL {
        return (@as(*const IFactory1.VTable, @ptrCast(self.vtable)).is_current)(@ptrCast(self));
    }
    // IFactory methods
    pub fn enumAdapters(self: *IFactory4, index: UINT, adapter: *?*IAdapter) HRESULT {
        return (@as(*const IFactory.VTable, @ptrCast(self.vtable)).enum_adapters)(@ptrCast(self), index, adapter);
    }
    pub fn makeWindowAssociation(self: *IFactory4, window: HWND, flags: MWA_FLAGS) HRESULT {
        return (@as(*const IFactory.VTable, @ptrCast(self.vtable)).make_window_association)(@ptrCast(self), window, flags);
    }
    pub fn getWindowAssociation(self: *IFactory4, window: *HWND) HRESULT {
        return (@as(*const IFactory.VTable, @ptrCast(self.vtable)).get_window_association)(@ptrCast(self), window);
    }
    pub fn createSwapChain(self: *IFactory4, device: *IUnknown, desc: *SWAP_CHAIN_DESC, swapchain: *?*ISwapChain) void {
        return (@as(*const IFactory.VTable, @ptrCast(self.vtable)).create_swap_chain)(@ptrCast(self), device, desc, swapchain);
    }
    pub fn createSoftwareAdapter(self: *IFactory4, adapter: *?*IAdapter) void {
        return (@as(*const IFactory.VTable, @ptrCast(self.vtable)).create_software_adapter)(@ptrCast(self), adapter);
    }
    // IObject methods
    pub fn getPrivateData(self: *IFactory4) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IFactory4) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IFactory4) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *IFactory4) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IFactory4, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IFactory4) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IFactory4) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IAdapter = extern struct {
    pub const IID = GUID.parse("{2411E7E1-12AC-4CCF-BD14-9798E8534DC0}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IObject.VTable,
        enum_outputs: *const fn (*IAdapter, index: UINT, output: *?*IOutput) callconv(.winapi) HRESULT,
        get_desc: *const fn (*IAdapter, desc: *ADAPTER_DESC) callconv(.winapi) HRESULT,
        check_interface_support: *const fn (*IAdapter, riid: *const GUID, umd_version: *LARGE_INTEGER) callconv(.winapi) HRESULT,
    };

    pub fn enumOutputs(self: *IAdapter, index: UINT, output: *?*IOutput) HRESULT {
        return (self.vtable.enum_outputs)(self, index, output);
    }
    pub fn getDesc(self: *IAdapter, desc: *ADAPTER_DESC) HRESULT {
        return (self.vtable.get_desc)(self, desc);
    }
    pub fn checkInterfaceSupport(self: *IAdapter, riid: *const GUID, umd_version: *LARGE_INTEGER) HRESULT {
        return (self.vtable.check_interface_support)(self, riid, umd_version);
    }
    // IObject methods
    pub fn getPrivateData(self: *IAdapter) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IAdapter) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IAdapter) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *IAdapter) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IAdapter, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IAdapter) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IAdapter) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IAdapter1 = extern struct {
    pub const IID = GUID.parse("{29038F61-3839-4626-91FD-086879011A05}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IAdapter.VTable,
        get_desc1: *const fn (*IAdapter1, desc: *ADAPTER_DESC1) callconv(.winapi) HRESULT,
    };

    pub fn getDesc1(self: *IAdapter1, desc: *ADAPTER_DESC1) HRESULT {
        return (self.vtable.get_desc1)(self, desc);
    }
    // IAdapter methods
    pub fn enumOutputs(self: *IAdapter1, index: UINT, output: *?*IOutput) HRESULT {
        return (@as(*const IAdapter.VTable, @ptrCast(self.vtable)).enum_outputs)(@ptrCast(self), index, output);
    }
    pub fn getDesc(self: *IAdapter1, desc: *ADAPTER_DESC) HRESULT {
        return (@as(*const IAdapter.VTable, @ptrCast(self.vtable)).get_desc)(@ptrCast(self), desc);
    }
    pub fn checkInterfaceSupport(self: *IAdapter1, riid: *const GUID, umd_version: *LARGE_INTEGER) HRESULT {
        return (@as(*const IAdapter.VTable, @ptrCast(self.vtable)).check_interface_support)(@ptrCast(self), riid, umd_version);
    }
    // IObject methods
    pub fn getPrivateData(self: *IAdapter1) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IAdapter1) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IAdapter1) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *IAdapter1) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IAdapter1, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IAdapter1) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IAdapter1) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const ISurface = extern struct {
    pub const IID = GUID.parse("{CAFCB56C-6AC3-4889-BF47-9E23BBD260EC}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IDeviceSubObject.VTable,
        get_desc: *const fn (*ISurface, desc: *SURFACE_DESC) callconv(.winapi) HRESULT,
        map: *const fn (*ISurface, locked_rect: *MAPPED_RECT, flags: MAP_FLAG) callconv(.winapi) HRESULT,
        unmap: *const fn (*ISurface) callconv(.winapi) HRESULT,
    };

    pub fn getDesc(self: *ISurface, desc: *SURFACE_DESC) HRESULT {
        return (self.vtable.get_desc)(self, desc);
    }
    pub fn map(self: *ISurface, locked_rect: *MAPPED_RECT, flags: MAP_FLAG) HRESULT {
        return (self.vtable.map)(self, locked_rect, flags);
    }
    pub fn unmap(self: *ISurface) HRESULT {
        return (self.vtable.unmap)(self);
    }
    // IDeviceSubObject methods
    pub fn getDevice(self: *ISurface, riid: *const GUID, device: *?*anyopaque) HRESULT {
        return (@as(*const IDeviceSubObject.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), riid, device);
    }
    // IObject methods
    pub fn getPrivateData(self: *ISurface) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *ISurface) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *ISurface) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *ISurface) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *ISurface, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *ISurface) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *ISurface) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const ISwapChain = extern struct {
    pub const IID = GUID.parse("{310D36A0-D2E7-4C0A-AA04-6A9D23B8886A}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IDeviceSubObject.VTable,
        present: *const fn (*ISwapChain, interval: UINT, flags: PRESENT_FLAG) callconv(.winapi) HRESULT,
        get_buffer: *const fn (*ISwapChain, buffer: UINT, riid: *const GUID, object: *?*anyopaque) callconv(.winapi) HRESULT,
        set_fullscreen_state: *const fn (*ISwapChain, fullscreen: BOOL, target: *IOutput) callconv(.winapi) HRESULT,
        get_fullscreen_state: *const fn (*ISwapChain, fullscreen: *BOOL, target: *?*IOutput) callconv(.winapi) HRESULT,
        get_desc: *const fn (*ISwapChain, desc: *SWAP_CHAIN_DESC) callconv(.winapi) HRESULT,
        resize_buffers: *const fn (*ISwapChain, buffer_count: UINT, width: UINT, height: UINT, new_format: FORMAT, flags: SWAP_CHAIN_FLAG) callconv(.winapi) HRESULT,
        resize_target: *const fn (*ISwapChain, new_target_parameters: *const MODE_DESC) callconv(.winapi) HRESULT,
        get_containing_output: *const fn (*ISwapChain, output: *?*IOutput) callconv(.winapi) HRESULT,
        get_frame_statistics: *const fn (*ISwapChain, stats: *FRAME_STATISTICS) callconv(.winapi) HRESULT,
        get_last_present_count: *const fn (*ISwapChain, last_present_count: *UINT) callconv(.winapi) HRESULT,
    };

    pub fn present(self: *ISwapChain, interval: UINT, flags: PRESENT_FLAG) HRESULT {
        return (self.vtable.present)(self, interval, flags);
    }
    pub fn getBuffer(self: *ISwapChain, buffer: UINT, riid: *const GUID, object: *?*anyopaque) HRESULT {
        return (self.vtable.get_buffer)(self, buffer, riid, object);
    }
    pub fn setFullscreenState(self: *ISwapChain, fullscreen: BOOL, target: *IOutput) HRESULT {
        return (self.vtable.set_fullscreen_state)(self, fullscreen, target);
    }
    pub fn getFullscreenState(self: *ISwapChain, fullscreen: *BOOL, target: *?*IOutput) HRESULT {
        return (self.vtable.get_fullscreen_state)(self, fullscreen, target);
    }
    pub fn getDesc(self: *ISwapChain, desc: *SWAP_CHAIN_DESC) HRESULT {
        return (self.vtable.get_desc)(self, desc);
    }
    pub fn resizeBuffers(self: *ISwapChain, buffer_count: UINT, width: UINT, height: UINT, new_format: FORMAT, flags: SWAP_CHAIN_FLAG) HRESULT {
        return (self.vtable.resize_buffers)(self, buffer_count, width, height, new_format, flags);
    }
    pub fn resizeTarget(self: *ISwapChain, new_target_parameters: *const MODE_DESC) HRESULT {
        return (self.vtable.resize_target)(self, new_target_parameters);
    }
    pub fn getContainingOutput(self: *ISwapChain, output: *?*IOutput) HRESULT {
        return (self.vtable.get_containing_output)(self, output);
    }
    pub fn getFrameStatistics(self: *ISwapChain, stats: *FRAME_STATISTICS) HRESULT {
        return (self.vtable.get_frame_statistics)(self, stats);
    }
    pub fn getLastPresentCount(self: *ISwapChain, last_present_count: *UINT) HRESULT {
        return (self.vtable.get_last_present_count)(self, last_present_count);
    }
    // IDeviceSubObject methods
    pub fn getDevice(self: *ISwapChain, riid: *const GUID, device: *?*anyopaque) HRESULT {
        return (@as(*const IDeviceSubObject.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), riid, device);
    }
    // IObject methods
    pub fn getPrivateData(self: *ISwapChain) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *ISwapChain) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *ISwapChain) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *ISwapChain) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *ISwapChain, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *ISwapChain) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *ISwapChain) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const ISwapChain1 = extern struct {
    pub const IID = GUID.parse("{790A45F7-0D42-4876-983A-0A55CFE6F4AA}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: ISwapChain.VTable,
        get_desc1: *const fn (*ISwapChain1, desc: *SWAP_CHAIN_DESC1) callconv(.winapi) HRESULT,
        get_fullscreen_desc: *const fn (*ISwapChain1, desc: *SWAP_CHAIN_FULLSCREEN_DESC) callconv(.winapi) HRESULT,
        get_hwnd: *const fn (*ISwapChain1, hwnd: *HWND) callconv(.winapi) HRESULT,
        get_core_window: *const fn (*ISwapChain1, riid: *const GUID, unk: *?*anyopaque) callconv(.winapi) HRESULT,
        present1: *const fn (*ISwapChain1, interval: UINT, flags: PRESENT_FLAG, present_parameters: *PRESENT_PARAMETERS) callconv(.winapi) HRESULT,
        is_temporary_mono_supported: *const fn (*ISwapChain1) callconv(.winapi) BOOL,
        get_restrict_to_output: *const fn (*ISwapChain1, restrict_to_output: *?*IOutput) callconv(.winapi) HRESULT,
        set_background_color: *const fn (*ISwapChain1, color: *const D3DCOLORVALUE) callconv(.winapi) HRESULT,
        get_background_color: *const fn (*ISwapChain1, color: *D3DCOLORVALUE) callconv(.winapi) HRESULT,
        set_rotation: *const fn (*ISwapChain1, rotation: MODE_ROTATION) callconv(.winapi) HRESULT,
        get_rotation: *const fn (*ISwapChain1, rotation: *MODE_ROTATION) callconv(.winapi) HRESULT,
    };

    pub fn getDesc1(self: *ISwapChain1, desc: *SWAP_CHAIN_DESC1) HRESULT {
        return (self.vtable.get_desc1)(self, desc);
    }
    pub fn getFullscreenDesc(self: *ISwapChain1, desc: *SWAP_CHAIN_FULLSCREEN_DESC) HRESULT {
        return (self.vtable.get_fullscreen_desc)(self, desc);
    }
    pub fn getHwnd(self: *ISwapChain1, hwnd: *HWND) HRESULT {
        return (self.vtable.get_hwnd)(self, hwnd);
    }
    pub fn getCoreWindow(self: *ISwapChain1, riid: *const GUID, unk: *?*anyopaque) HRESULT {
        return (self.vtable.get_core_window)(self, riid, unk);
    }
    pub fn present1(self: *ISwapChain1, interval: UINT, flags: PRESENT_FLAG, present_parameters: *PRESENT_PARAMETERS) HRESULT {
        return (self.vtable.present1)(self, interval, flags, present_parameters);
    }
    pub fn isTemporaryMonoSupported(self: *ISwapChain1) BOOL {
        return (self.vtable.is_temporary_mono_supported)(self);
    }
    pub fn getRestrictToOutput(self: *ISwapChain1, restrict_to_output: *?*IOutput) HRESULT {
        return (self.vtable.get_restrict_to_output)(self, restrict_to_output);
    }
    pub fn setBackgroundColor(self: *ISwapChain1, color: *const D3DCOLORVALUE) HRESULT {
        return (self.vtable.set_background_color)(self, color);
    }
    pub fn getBackgroundColor(self: *ISwapChain1, color: *D3DCOLORVALUE) HRESULT {
        return (self.vtable.get_background_color)(self, color);
    }
    pub fn setRotation(self: *ISwapChain1, rotation: MODE_ROTATION) HRESULT {
        return (self.vtable.set_rotation)(self, rotation);
    }
    pub fn getRotation(self: *ISwapChain1, rotation: *MODE_ROTATION) HRESULT {
        return (self.vtable.get_rotation)(self, rotation);
    }
    // ISwapChain methods
    pub fn present(self: *ISwapChain1, interval: UINT, flags: PRESENT_FLAG) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).present)(@ptrCast(self), interval, flags);
    }
    pub fn getBuffer(self: *ISwapChain1, buffer: UINT, riid: *const GUID, object: *?*anyopaque) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).get_buffer)(@ptrCast(self), buffer, riid, object);
    }
    pub fn setFullscreenState(self: *ISwapChain1, fullscreen: BOOL, target: *IOutput) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).set_fullscreen_state)(@ptrCast(self), fullscreen, target);
    }
    pub fn getFullscreenState(self: *ISwapChain1, fullscreen: *BOOL, target: *?*IOutput) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).get_fullscreen_state)(@ptrCast(self), fullscreen, target);
    }
    pub fn getDesc(self: *ISwapChain1, desc: *SWAP_CHAIN_DESC) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).get_desc)(@ptrCast(self), desc);
    }
    pub fn resizeBuffers(self: *ISwapChain1, buffer_count: UINT, width: UINT, height: UINT, new_format: FORMAT, flags: SWAP_CHAIN_FLAG) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).resize_buffers)(@ptrCast(self), buffer_count, width, height, new_format, flags);
    }
    pub fn resizeTarget(self: *ISwapChain1, new_target_parameters: *const MODE_DESC) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).resize_target)(@ptrCast(self), new_target_parameters);
    }
    pub fn getContainingOutput(self: *ISwapChain1, output: *?*IOutput) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).get_containing_output)(@ptrCast(self), output);
    }
    pub fn getFrameStatistics(self: *ISwapChain1, stats: *FRAME_STATISTICS) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).get_frame_statistics)(@ptrCast(self), stats);
    }
    pub fn getLastPresentCount(self: *ISwapChain1, last_present_count: *UINT) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).get_last_present_count)(@ptrCast(self), last_present_count);
    }
    // IDeviceSubObject methods
    pub fn getDevice(self: *ISwapChain1, riid: *const GUID, device: *?*anyopaque) HRESULT {
        return (@as(*const IDeviceSubObject.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), riid, device);
    }
    // IObject methods
    pub fn getPrivateData(self: *ISwapChain1) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *ISwapChain1) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *ISwapChain1) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *ISwapChain1) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *ISwapChain1, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *ISwapChain1) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *ISwapChain1) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const ISwapChain2 = extern struct {
    pub const IID = GUID.parse("{A8BE2AC4-199F-4946-B331-79599FB98DE7}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: ISwapChain1.VTable,
        set_source_size: *const fn (*ISwapChain2, width: u32, height: u32) callconv(.winapi) HRESULT,
        get_source_size: *const fn (*ISwapChain2, width: *u32, height: *u32) callconv(.winapi) HRESULT,
        set_maximum_frame_latency: *const fn (*ISwapChain2, max_latency: u32) callconv(.winapi) HRESULT,
        get_maximum_frame_latency: *const fn (*ISwapChain2, max_latency: *u32) callconv(.winapi) HRESULT,
        get_frame_latency_waitable_object: *const fn (*ISwapChain2) callconv(.winapi) HANDLE,
        set_matrix_transform: *const fn (*ISwapChain2, matrix: *MATRIX_3X2_F) callconv(.winapi) HRESULT,
        get_matrix_transform: *const fn (*ISwapChain2, matrix: *MATRIX_3X2_F) callconv(.winapi) HRESULT,
    };

    pub fn setSourceSize(self: *ISwapChain2, width: u32, height: u32) HRESULT {
        return (self.vtable.set_source_size)(self, width, height);
    }
    pub fn getSourceSize(self: *ISwapChain2, width: *u32, height: *u32) HRESULT {
        return (self.vtable.get_source_size)(self, width, height);
    }
    pub fn setMaximumFrameLatency(self: *ISwapChain2, max_latency: u32) HRESULT {
        return (self.vtable.set_maximum_frame_latency)(self, max_latency);
    }
    pub fn getMaximumFrameLatency(self: *ISwapChain2, max_latency: *u32) HRESULT {
        return (self.vtable.get_maximum_frame_latency)(self, max_latency);
    }
    pub fn getFrameLatencyWaitableObject(self: *ISwapChain2) HANDLE {
        return (self.vtable.get_frame_latency_waitable_object)(self);
    }
    pub fn setMatrixTransform(self: *ISwapChain2, matrix: *MATRIX_3X2_F) HRESULT {
        return (self.vtable.set_matrix_transform)(self, matrix);
    }
    pub fn getMatrixTransform(self: *ISwapChain2, matrix: *MATRIX_3X2_F) HRESULT {
        return (self.vtable.get_matrix_transform)(self, matrix);
    }
    // ISwapChain1 methods
    pub fn getDesc1(self: *ISwapChain2, desc: *SWAP_CHAIN_DESC1) HRESULT {
        return (@as(*const ISwapChain1.VTable, @ptrCast(self.vtable)).get_desc1)(@ptrCast(self), desc);
    }
    pub fn getFullscreenDesc(self: *ISwapChain2, desc: *SWAP_CHAIN_FULLSCREEN_DESC) HRESULT {
        return (@as(*const ISwapChain1.VTable, @ptrCast(self.vtable)).get_fullscreen_desc)(@ptrCast(self), desc);
    }
    pub fn getHwnd(self: *ISwapChain2, hwnd: *HWND) HRESULT {
        return (@as(*const ISwapChain1.VTable, @ptrCast(self.vtable)).get_hwnd)(@ptrCast(self), hwnd);
    }
    pub fn getCoreWindow(self: *ISwapChain2, riid: *const GUID, unk: *?*anyopaque) HRESULT {
        return (@as(*const ISwapChain1.VTable, @ptrCast(self.vtable)).get_core_window)(@ptrCast(self), riid, unk);
    }
    pub fn present1(self: *ISwapChain2, interval: UINT, flags: PRESENT_FLAG, present_parameters: *PRESENT_PARAMETERS) HRESULT {
        return (@as(*const ISwapChain1.VTable, @ptrCast(self.vtable)).present1)(@ptrCast(self), interval, flags, present_parameters);
    }
    pub fn isTemporaryMonoSupported(self: *ISwapChain2) BOOL {
        return (@as(*const ISwapChain1.VTable, @ptrCast(self.vtable)).is_temporary_mono_supported)(@ptrCast(self));
    }
    pub fn getRestrictToOutput(self: *ISwapChain2, restrict_to_output: *?*IOutput) HRESULT {
        return (@as(*const ISwapChain1.VTable, @ptrCast(self.vtable)).get_restrict_to_output)(@ptrCast(self), restrict_to_output);
    }
    pub fn setBackgroundColor(self: *ISwapChain2, color: *const D3DCOLORVALUE) HRESULT {
        return (@as(*const ISwapChain1.VTable, @ptrCast(self.vtable)).set_background_color)(@ptrCast(self), color);
    }
    pub fn getBackgroundColor(self: *ISwapChain2, color: *D3DCOLORVALUE) HRESULT {
        return (@as(*const ISwapChain1.VTable, @ptrCast(self.vtable)).get_background_color)(@ptrCast(self), color);
    }
    pub fn setRotation(self: *ISwapChain2, rotation: MODE_ROTATION) HRESULT {
        return (@as(*const ISwapChain1.VTable, @ptrCast(self.vtable)).set_rotation)(@ptrCast(self), rotation);
    }
    pub fn getRotation(self: *ISwapChain2, rotation: *MODE_ROTATION) HRESULT {
        return (@as(*const ISwapChain1.VTable, @ptrCast(self.vtable)).get_rotation)(@ptrCast(self), rotation);
    }
    // ISwapChain methods
    pub fn present(self: *ISwapChain2, interval: UINT, flags: PRESENT_FLAG) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).present)(@ptrCast(self), interval, flags);
    }
    pub fn getBuffer(self: *ISwapChain2, buffer: UINT, riid: *const GUID, object: *?*anyopaque) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).get_buffer)(@ptrCast(self), buffer, riid, object);
    }
    pub fn setFullscreenState(self: *ISwapChain2, fullscreen: BOOL, target: *IOutput) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).set_fullscreen_state)(@ptrCast(self), fullscreen, target);
    }
    pub fn getFullscreenState(self: *ISwapChain2, fullscreen: *BOOL, target: *?*IOutput) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).get_fullscreen_state)(@ptrCast(self), fullscreen, target);
    }
    pub fn getDesc(self: *ISwapChain2, desc: *SWAP_CHAIN_DESC) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).get_desc)(@ptrCast(self), desc);
    }
    pub fn resizeBuffers(self: *ISwapChain2, buffer_count: UINT, width: UINT, height: UINT, new_format: FORMAT, flags: SWAP_CHAIN_FLAG) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).resize_buffers)(@ptrCast(self), buffer_count, width, height, new_format, flags);
    }
    pub fn resizeTarget(self: *ISwapChain2, new_target_parameters: *const MODE_DESC) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).resize_target)(@ptrCast(self), new_target_parameters);
    }
    pub fn getContainingOutput(self: *ISwapChain2, output: *?*IOutput) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).get_containing_output)(@ptrCast(self), output);
    }
    pub fn getFrameStatistics(self: *ISwapChain2, stats: *FRAME_STATISTICS) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).get_frame_statistics)(@ptrCast(self), stats);
    }
    pub fn getLastPresentCount(self: *ISwapChain2, last_present_count: *UINT) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).get_last_present_count)(@ptrCast(self), last_present_count);
    }
    // IDeviceSubObject methods
    pub fn getDevice(self: *ISwapChain2, riid: *const GUID, device: *?*anyopaque) HRESULT {
        return (@as(*const IDeviceSubObject.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), riid, device);
    }
    // IObject methods
    pub fn getPrivateData(self: *ISwapChain2) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *ISwapChain2) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *ISwapChain2) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *ISwapChain2) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *ISwapChain2, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *ISwapChain2) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *ISwapChain2) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const ISwapChain3 = extern struct {
    pub const IID = GUID.parse("{94D99BDB-F1F8-4AB0-B236-7DA0170EDAB1}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: ISwapChain2.VTable,
        get_current_back_buffer_index: *const fn (*ISwapChain3) callconv(.winapi) u32,
        check_color_space_support: *const fn (*ISwapChain3, color_space: COLOR_SPACE_TYPE, color_space_support: *COLOR_SPACE_SUPPORT) callconv(.winapi) HRESULT,
        set_color_space1: *const fn (*ISwapChain3, color_space: COLOR_SPACE_TYPE) callconv(.winapi) HRESULT,
        resize_buffers1: *const fn (*ISwapChain3, buffer_count: u32, width: u32, height: u32, format: FORMAT, flags: SWAP_CHAIN_FLAG, creation_node_mask: *u32, present_queue: *?*IUnknown) callconv(.winapi) HRESULT,
    };

    pub fn getCurrentBackBufferIndex(self: *ISwapChain3) u32 {
        return (self.vtable.get_current_back_buffer_index)(self);
    }
    pub fn checkColorSpaceSupport(self: *ISwapChain3, color_space: COLOR_SPACE_TYPE, color_space_support: *COLOR_SPACE_SUPPORT) HRESULT {
        return (self.vtable.check_color_space_support)(self, color_space, color_space_support);
    }
    pub fn setColorSpace1(self: *ISwapChain3, color_space: COLOR_SPACE_TYPE) HRESULT {
        return (self.vtable.set_color_space1)(self, color_space);
    }
    pub fn resizeBuffers1(self: *ISwapChain3, buffer_count: u32, width: u32, height: u32, format: FORMAT, flags: SWAP_CHAIN_FLAG, creation_node_mask: *u32, present_queue: *?*IUnknown) HRESULT {
        return (self.vtable.resize_buffers1)(self, buffer_count, width, height, format, flags, creation_node_mask, present_queue);
    }
    // ISwapChain2 methods
    pub fn setSourceSize(self: *ISwapChain3, width: u32, height: u32) HRESULT {
        return (@as(*const ISwapChain2.VTable, @ptrCast(self.vtable)).set_source_size)(@ptrCast(self), width, height);
    }
    pub fn getSourceSize(self: *ISwapChain3, width: *u32, height: *u32) HRESULT {
        return (@as(*const ISwapChain2.VTable, @ptrCast(self.vtable)).get_source_size)(@ptrCast(self), width, height);
    }
    pub fn setMaximumFrameLatency(self: *ISwapChain3, max_latency: u32) HRESULT {
        return (@as(*const ISwapChain2.VTable, @ptrCast(self.vtable)).set_maximum_frame_latency)(@ptrCast(self), max_latency);
    }
    pub fn getMaximumFrameLatency(self: *ISwapChain3, max_latency: *u32) HRESULT {
        return (@as(*const ISwapChain2.VTable, @ptrCast(self.vtable)).get_maximum_frame_latency)(@ptrCast(self), max_latency);
    }
    pub fn getFrameLatencyWaitableObject(self: *ISwapChain3) HANDLE {
        return (@as(*const ISwapChain2.VTable, @ptrCast(self.vtable)).get_frame_latency_waitable_object)(@ptrCast(self));
    }
    pub fn setMatrixTransform(self: *ISwapChain3, matrix: *MATRIX_3X2_F) HRESULT {
        return (@as(*const ISwapChain2.VTable, @ptrCast(self.vtable)).set_matrix_transform)(@ptrCast(self), matrix);
    }
    pub fn getMatrixTransform(self: *ISwapChain3, matrix: *MATRIX_3X2_F) HRESULT {
        return (@as(*const ISwapChain2.VTable, @ptrCast(self.vtable)).get_matrix_transform)(@ptrCast(self), matrix);
    }
    // ISwapChain1 methods
    pub fn getDesc1(self: *ISwapChain3, desc: *SWAP_CHAIN_DESC1) HRESULT {
        return (@as(*const ISwapChain1.VTable, @ptrCast(self.vtable)).get_desc1)(@ptrCast(self), desc);
    }
    pub fn getFullscreenDesc(self: *ISwapChain3, desc: *SWAP_CHAIN_FULLSCREEN_DESC) HRESULT {
        return (@as(*const ISwapChain1.VTable, @ptrCast(self.vtable)).get_fullscreen_desc)(@ptrCast(self), desc);
    }
    pub fn getHwnd(self: *ISwapChain3, hwnd: *HWND) HRESULT {
        return (@as(*const ISwapChain1.VTable, @ptrCast(self.vtable)).get_hwnd)(@ptrCast(self), hwnd);
    }
    pub fn getCoreWindow(self: *ISwapChain3, riid: *const GUID, unk: *?*anyopaque) HRESULT {
        return (@as(*const ISwapChain1.VTable, @ptrCast(self.vtable)).get_core_window)(@ptrCast(self), riid, unk);
    }
    pub fn present1(self: *ISwapChain3, interval: UINT, flags: PRESENT_FLAG, present_parameters: *PRESENT_PARAMETERS) HRESULT {
        return (@as(*const ISwapChain1.VTable, @ptrCast(self.vtable)).present1)(@ptrCast(self), interval, flags, present_parameters);
    }
    pub fn isTemporaryMonoSupported(self: *ISwapChain3) BOOL {
        return (@as(*const ISwapChain1.VTable, @ptrCast(self.vtable)).is_temporary_mono_supported)(@ptrCast(self));
    }
    pub fn getRestrictToOutput(self: *ISwapChain3, restrict_to_output: *?*IOutput) HRESULT {
        return (@as(*const ISwapChain1.VTable, @ptrCast(self.vtable)).get_restrict_to_output)(@ptrCast(self), restrict_to_output);
    }
    pub fn setBackgroundColor(self: *ISwapChain3, color: *const D3DCOLORVALUE) HRESULT {
        return (@as(*const ISwapChain1.VTable, @ptrCast(self.vtable)).set_background_color)(@ptrCast(self), color);
    }
    pub fn getBackgroundColor(self: *ISwapChain3, color: *D3DCOLORVALUE) HRESULT {
        return (@as(*const ISwapChain1.VTable, @ptrCast(self.vtable)).get_background_color)(@ptrCast(self), color);
    }
    pub fn setRotation(self: *ISwapChain3, rotation: MODE_ROTATION) HRESULT {
        return (@as(*const ISwapChain1.VTable, @ptrCast(self.vtable)).set_rotation)(@ptrCast(self), rotation);
    }
    pub fn getRotation(self: *ISwapChain3, rotation: *MODE_ROTATION) HRESULT {
        return (@as(*const ISwapChain1.VTable, @ptrCast(self.vtable)).get_rotation)(@ptrCast(self), rotation);
    }
    // ISwapChain methods
    pub fn present(self: *ISwapChain3, interval: UINT, flags: PRESENT_FLAG) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).present)(@ptrCast(self), interval, flags);
    }
    pub fn getBuffer(self: *ISwapChain3, buffer: UINT, riid: *const GUID, object: *?*anyopaque) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).get_buffer)(@ptrCast(self), buffer, riid, object);
    }
    pub fn setFullscreenState(self: *ISwapChain3, fullscreen: BOOL, target: *IOutput) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).set_fullscreen_state)(@ptrCast(self), fullscreen, target);
    }
    pub fn getFullscreenState(self: *ISwapChain3, fullscreen: *BOOL, target: *?*IOutput) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).get_fullscreen_state)(@ptrCast(self), fullscreen, target);
    }
    pub fn getDesc(self: *ISwapChain3, desc: *SWAP_CHAIN_DESC) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).get_desc)(@ptrCast(self), desc);
    }
    pub fn resizeBuffers(self: *ISwapChain3, buffer_count: UINT, width: UINT, height: UINT, new_format: FORMAT, flags: SWAP_CHAIN_FLAG) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).resize_buffers)(@ptrCast(self), buffer_count, width, height, new_format, flags);
    }
    pub fn resizeTarget(self: *ISwapChain3, new_target_parameters: *const MODE_DESC) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).resize_target)(@ptrCast(self), new_target_parameters);
    }
    pub fn getContainingOutput(self: *ISwapChain3, output: *?*IOutput) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).get_containing_output)(@ptrCast(self), output);
    }
    pub fn getFrameStatistics(self: *ISwapChain3, stats: *FRAME_STATISTICS) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).get_frame_statistics)(@ptrCast(self), stats);
    }
    pub fn getLastPresentCount(self: *ISwapChain3, last_present_count: *UINT) HRESULT {
        return (@as(*const ISwapChain.VTable, @ptrCast(self.vtable)).get_last_present_count)(@ptrCast(self), last_present_count);
    }
    // IDeviceSubObject methods
    pub fn getDevice(self: *ISwapChain3, riid: *const GUID, device: *?*anyopaque) HRESULT {
        return (@as(*const IDeviceSubObject.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), riid, device);
    }
    // IObject methods
    pub fn getPrivateData(self: *ISwapChain3) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *ISwapChain3) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *ISwapChain3) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *ISwapChain3) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *ISwapChain3, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *ISwapChain3) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *ISwapChain3) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IDeviceSubObject = extern struct {
    pub const IID = GUID.parse("{3D3E0379-F9DE-4D58-BB6C-18D62992F1A6}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IObject.VTable,
        get_device: *const fn (*IDeviceSubObject, riid: *const GUID, device: *?*anyopaque) callconv(.winapi) HRESULT,
    };

    pub fn getDevice(self: *IDeviceSubObject, riid: *const GUID, device: *?*anyopaque) HRESULT {
        return (self.vtable.get_device)(self, riid, device);
    }
    // IObject methods
    pub fn getPrivateData(self: *IDeviceSubObject) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IDeviceSubObject) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IDeviceSubObject) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *IDeviceSubObject) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IDeviceSubObject, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IDeviceSubObject) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IDeviceSubObject) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IDevice = extern struct {
    pub const IID = GUID.parse("{54EC77FA-1377-44E6-8C32-88FD5F44C84C}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IObject.VTable,
        get_adapter: *const fn (*IDevice, adapter: *?*IAdapter) callconv(.winapi) HRESULT,
        create_surface: *const fn (*IDevice, desc: *const SURFACE_DESC, num_surfaces: UINT, usage: USAGE, shared_resource: ?*const SHARED_RESOURCE, surface: *?*ISurface) callconv(.winapi) HRESULT,
        query_resource_residency: *const fn (*IDevice, resources: [*]const *IUnknown, residency_status: [*]RESIDENCY, num_resources: UINT) callconv(.winapi) HRESULT,
        set_gpu_thread_priority: *const fn (*IDevice, priority: INT) callconv(.winapi) HRESULT,
        get_gpu_thread_priority: *const fn (*IDevice, priority: *INT) callconv(.winapi) HRESULT,
    };

    pub fn getAdapter(self: *IDevice, adapter: *?*IAdapter) HRESULT {
        return (self.vtable.get_adapter)(self, adapter);
    }
    pub fn createSurface(self: *IDevice, desc: *const SURFACE_DESC, num_surfaces: UINT, usage: USAGE, shared_resource: ?*const SHARED_RESOURCE, surface: *?*ISurface) HRESULT {
        return (self.vtable.create_surface)(self, desc, num_surfaces, usage, shared_resource, surface);
    }
    pub fn queryResourceResidency(self: *IDevice, resources: [*]const *IUnknown, residency_status: [*]RESIDENCY, num_resources: UINT) HRESULT {
        return (self.vtable.query_resource_residency)(self, resources, residency_status, num_resources);
    }
    pub fn setGpuThreadPriority(self: *IDevice, priority: INT) HRESULT {
        return (self.vtable.set_gpu_thread_priority)(self, priority);
    }
    pub fn getGpuThreadPriority(self: *IDevice, priority: *INT) HRESULT {
        return (self.vtable.get_gpu_thread_priority)(self, priority);
    }
    // IObject methods
    pub fn getPrivateData(self: *IDevice) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IDevice) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IDevice) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *IDevice) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IDevice, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IDevice) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IDevice) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IDebug = extern struct {
    pub const IID = GUID.parse("{119E7452-DE9E-40fe-8806-88F90C12B441}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IUnknown.VTable,
        report_live_objects: *const fn (*IDebug, riid: *const GUID, flags: DEBUG_RLO_FLAGS) callconv(.winapi) void,
    };

    pub fn reportLiveObjects(self: *IDebug, riid: *const GUID, flags: DEBUG_RLO_FLAGS) void {
        return (self.vtable.report_live_objects)(self, riid, flags);
    }
    // IUnknown methods
    pub fn queryInterface(self: *IDebug, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IDebug) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IDebug) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};
