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

pub const IUnknown = w32.IUnknown;
pub const IObject = w32.IObject;

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

// functions
// ---------

pub extern "dxgi" fn CreateDXGIFactory2(UINT, *const GUID, *?*anyopaque) callconv(.winapi) HRESULT;

// com objects
// -----------

pub const IID_IDeviceSubObject = GUID.parse("{3D3E0379-F9DE-4D58-BB6C-18D62992F1A6}");
pub const IDeviceSubObject = extern struct {
    vtable: *const VTable,

    const VTable = extern struct {
        base: IObject.VTable,
        get_device: *const fn (*IDeviceSubObject, *const GUID, *?*anyopaque) callconv(.winapi) HRESULT,
    };
};

pub const IID_IOutput = GUID.parse("{AE02EEDB-C735-4690-8D52-5A8DC20213AA}");
pub const IOutput = extern struct {
    vtable: *const VTable,

    const VTable = extern struct {
        base: IObject.VTable,
        get_desc: *const fn (*IOutput, desc: *OUTPUT_DESC) callconv(.winapi) HRESULT,
        get_display_mode_list: *const fn (*IOutput, FORMAT, ENUM_MODES, *UINT, ?*MODE_DESC) callconv(.winapi) HRESULT,
        find_closest_matching_mode: *const fn (*IOutput, *const MODE_DESC, *MODE_DESC, ?*IUnknown) callconv(.winapi) HRESULT,
        wait_for_v_blank: *const fn (*IOutput) callconv(.winapi) HRESULT,
        take_ownership: *const fn (*IOutput, *IUnknown, BOOL) callconv(.winapi) HRESULT,
        release_ownership: *const fn (*IOutput) callconv(.winapi) void,
        get_gamma_control_capabilities: *const fn (*IOutput, *GAMMA_CONTROL_CAPABILITIES) callconv(.winapi) HRESULT,
        set_gamma_control: *const fn (*IOutput, *const GAMMA_CONTROL) callconv(.winapi) HRESULT,
        get_gamma_control: *const fn (*IOutput, *GAMMA_CONTROL) callconv(.winapi) HRESULT,
        set_display_surface: *const fn (*IOutput, *ISurface) callconv(.winapi) HRESULT,
        get_display_surface_data: *const fn (*IOutput, *ISurface) callconv(.winapi) HRESULT,
        get_frame_statistics: *const fn (*IOutput, *FRAME_STATISTICS) callconv(.winapi) HRESULT,
    };
};

pub const IID_IFactory = GUID.parse("{7B7166EC-21C7-44AE-B21A-C9AE321AE369}");
pub const IFactory = extern struct {
    vtable: *const VTable,

    const VTable = extern struct {
        base: IObject.VTable,
        enum_adapters: *const fn (*IFactory, UINT, *?*IAdapter) callconv(.winapi) HRESULT,
        make_window_association: *const fn (*IFactory, HWND, MWA_FLAGS) callconv(.winapi) HRESULT,
        get_window_association: *const fn (*IFactory, *HWND) callconv(.winapi) HRESULT,
        create_swap_chain: *const fn (*IFactory, *IUnknown, *SWAP_CHAIN_DESC, *?*ISwapChain) callconv(.winapi) HRESULT,
        create_software_adapter: *const fn (*IFactory, *?*IAdapter) callconv(.winapi) HRESULT,
    };
};

pub const IID_IFactory1 = GUID.parse("{770AAE78-F26F-4DBA-A829-253C83D1B387}");
pub const IFactory1 = extern struct {
    vtable: *const VTable,

    const VTable = extern struct {
        base: IFactory.VTable,
        enum_adapters1: *const fn (*IFactory1, UINT, *?*IAdapter1) callconv(.winapi) HRESULT,
        is_current: *const fn (*IFactory1) callconv(.winapi) BOOL,
    };
};

pub const IID_IFactory2 = GUID.parse("{50C83A1C-E072-4C48-87B0-3630FA36A6D0}");
pub const IFactory2 = extern struct {
    vtable: *const VTable,

    pub fn makeWindowAssociation(self: *IFactory2, window: HWND, flags: MWA_FLAGS) void {
        callCheck(self, IFactory, "make_window_association", .{ window, flags });
    }

    pub fn enumAdapters1(self: *IFactory2, index: UINT) *IAdapter1 {
        var adapter: ?*IAdapter1 = null;
        call(self, IFactory1, "enum_adapters1", .{ index, &adapter });
        return adapter.?;
    }

    pub fn createSwapchainForHWND(self: *IFactory2, pDevice: *IUnknown, hWnd: HWND, pDesc: *SWAP_CHAIN_DESC1, pFullscreenDesc: ?*SWAP_CHAIN_FULLSCREEN_DESC, pRestrictToOutput: ?*IOutput) *ISwapChain1 {
        var swapchain: ?*ISwapChain1 = null;
        call(self, IFactory2, "create_swap_chain_for_hwnd", .{ pDevice, hWnd, pDesc, pFullscreenDesc, pRestrictToOutput, &swapchain });
        return swapchain.?;
    }

    const VTable = extern struct {
        base: IFactory1.VTable,
        is_windowed_stereo_enabled: *anyopaque,
        create_swap_chain_for_hwnd: *const fn (*IFactory2, pDevice: *IUnknown, hWnd: HWND, pDesc: *SWAP_CHAIN_DESC1, pFullscreenDesc: ?*SWAP_CHAIN_FULLSCREEN_DESC, pRestrictToOutput: ?*IOutput, ppSwapChain: *?*ISwapChain1) callconv(.winapi) HRESULT,
        create_swap_chain_for_core_window: *anyopaque,
        get_shared_resource_adapter_luid: *anyopaque,
        register_stereo_status_window: *anyopaque,
        register_stereo_status_event: *anyopaque,
        unregister_stereo_status: *anyopaque,
        register_occlusion_status_window: *anyopaque,
        register_occlusion_status_event: *anyopaque,
        unregister_occlusion_status: *anyopaque,
        create_swap_chain_for_composition: *anyopaque,
    };
};

pub const IID_IFactory3 = GUID.parse("{25483823-CD46-4C7D-86CA-47AA95B837BD}");
pub const IFactory3 = extern struct {
    vtable: *const VTable,

    const VTable = extern struct {
        base: IFactory2.VTable,
        get_creation_flags: *anyopaque,
    };
};

pub const IID_IFactory4 = GUID.parse("{1BC6EA02-EF36-464F-BF0C-21CA39E5168A}");
pub const IFactory4 = extern struct {
    vtable: *const VTable,

    const VTable = extern struct {
        base: IFactory3.VTable,
        enum_adapter_by_luid: *anyopaque,
        enum_warp_adapter: *anyopaque,
    };
};

pub const IID_IAdapter = GUID.parse("{00000000-0000-0000-0000-000000000000}");
pub const IAdapter = extern struct {
    vtable: *const VTable,

    const VTable = extern struct {
        base: IObject.VTable,
        enum_outputs: *const fn (*IAdapter, UINT, *?*IOutput) callconv(.winapi) HRESULT,
        get_desc: *const fn (*IAdapter, *ADAPTER_DESC) callconv(.winapi) HRESULT,
        check_interface_support: *const fn (*IAdapter, *const GUID, *LARGE_INTEGER) callconv(.winapi) HRESULT,
    };
};
pub const IID_IAdapter1 = GUID.parse("{29038F61-3839-4626-91FD-086879011A05}");
pub const IAdapter1 = extern struct {
    vtable: *const VTable,

    pub fn checkInterfaceSupport(self: *IAdapter1, riid: *const GUID) LARGE_INTEGER {
        var version: LARGE_INTEGER = undefined;
        call(self, IAdapter, "check_interface_support", .{ riid, &version });
        return version;
    }

    pub fn getDesc1(self: *IAdapter1) ADAPTER_DESC1 {
        var desc: ADAPTER_DESC1 = undefined;
        call(self, IAdapter1, "get_desc1", .{&desc});
        return desc;
    }

    const VTable = extern struct {
        base: IAdapter.VTable,
        get_desc1: *const fn (*IAdapter1, *ADAPTER_DESC1) callconv(.winapi) HRESULT,
    };
};

pub const IID_ISurface = GUID.parse("{CAFCB56C-6AC3-4889-BF47-9E23BBD260EC}");
pub const ISurface = extern struct {
    vtable: *const VTable,

    const VTable = extern struct {
        base: IDeviceSubObject.VTable,
        get_desc: *const fn (*ISurface, *SURFACE_DESC) callconv(.winapi) HRESULT,
        map: *const fn (*ISurface, *MAPPED_RECT, MAP_FLAG) callconv(.winapi) HRESULT,
        unmap: *const fn (*ISurface) callconv(.winapi) HRESULT,
    };
};

pub const IID_ISwapChain = GUID.parse("{310D36A0-D2E7-4C0A-AA04-6A9D23B8886A}");
pub const ISwapChain = extern struct {
    vtable: *const VTable,

    const VTable = extern struct {
        base: IDeviceSubObject.VTable,
        present: *const fn (*ISwapChain, UINT, PRESENT_FLAG) callconv(.winapi) HRESULT,
        get_buffer: *const fn (*ISwapChain, u32, *const GUID, *?*anyopaque) callconv(.winapi) HRESULT,
        set_fullscreen_state: *const fn (*ISwapChain, ?*IOutput) callconv(.winapi) HRESULT,
        get_fullscreen_state: *const fn (*ISwapChain, ?*BOOL, ?*?*IOutput) callconv(.winapi) HRESULT,
        get_desc: *const fn (*ISwapChain, *SWAP_CHAIN_DESC) callconv(.winapi) HRESULT,
        resize_buffers: *const fn (*ISwapChain, UINT, UINT, UINT, FORMAT, SWAP_CHAIN_FLAG) callconv(.winapi) HRESULT,
        resize_target: *const fn (*ISwapChain, *const MODE_DESC) callconv(.winapi) HRESULT,
        get_containing_output: *const fn (*ISwapChain, *?*IOutput) callconv(.winapi) HRESULT,
        get_frame_statistics: *const fn (*ISwapChain, *FRAME_STATISTICS) callconv(.winapi) HRESULT,
        get_last_present_count: *const fn (*ISwapChain, *UINT) callconv(.winapi) HRESULT,
    };
};

pub const IID_ISwapChain1 = GUID.parse("{790A45F7-0D42-4876-983A-0A55CFE6F4AA}");
pub const ISwapChain1 = extern struct {
    vtable: *const VTable,

    pub fn getDesc1(self: *ISwapChain1) SWAP_CHAIN_DESC1 {
        var desc: SWAP_CHAIN_DESC1 = undefined;
        call(self, ISwapChain1, "get_desc1", .{&desc});
        return desc;
    }

    const VTable = extern struct {
        base: ISwapChain.VTable,
        get_desc1: *const fn (*ISwapChain1, *SWAP_CHAIN_DESC1) callconv(.winapi) HRESULT,
        get_fullscreen_desc: *anyopaque,
        get_hwnd: *anyopaque,
        get_core_window: *anyopaque,
        present1: *anyopaque,
        is_temporary_mono_supported: *anyopaque,
        get_restrict_to_output: *anyopaque,
        set_background_color: *anyopaque,
        get_background_color: *anyopaque,
        set_rotation: *anyopaque,
        get_rotation: *anyopaque,
    };
};

pub const IID_IDevice = GUID.parse("{54EC77FA-1377-44E6-8C32-88FD5F44C84C}");
pub const IDevice = extern struct {
    vtable: *const VTable,

    const VTable = extern struct {
        base: IObject.VTable,
        GetAdapter: *const fn (*IDevice, *?*IAdapter) callconv(.winapi) HRESULT,
        CreateSurface: *const fn (*IDevice, *const SURFACE_DESC, UINT, USAGE, ?*const SHARED_RESOURCE, *?*ISurface) callconv(.winapi) HRESULT,
        QueryResourceResidency: *const fn (*IDevice, *const *IUnknown, [*]RESIDENCY, UINT) callconv(.winapi) HRESULT,
        SetGPUThreadPriority: *const fn (*IDevice, INT) callconv(.winapi) HRESULT,
        GetGPUThreadPriority: *const fn (*IDevice, *INT) callconv(.winapi) HRESULT,
    };
};

inline fn call(self: anytype, comptime T: type, comptime name: []const u8, args: anytype) void {
    const interface: *T = @ptrCast(self);
    const table: *const T.VTable = @ptrCast(self.vtable);
    const function = @field(table, name);
    _ = @call(.auto, function, .{interface} ++ args);
}

inline fn callCheck(self: anytype, comptime T: type, comptime name: []const u8, args: anytype) void {
    const interface: *T = @ptrCast(self);
    const table: *const T.VTable = @ptrCast(self.vtable);
    const function = @field(table, name);
    const ret = @call(.auto, function, .{interface} ++ args);

    std.debug.assert(ret == w32.ERROR_SUCCESS);
}
