const std = @import("std");
const w32 = @import("windows.zig");
const dxgi = @import("dxgi.zig");
const d3dcommon = @import("d3dcommon.zig");
const os = std.os.windows;

const GUID = w32.GUID;
const ULONG = w32.ULONG;
const HRESULT = w32.HRESULT;
const HMODULE = w32.HMODULE;
const BOOL = w32.BOOL;
const SIZE_T = w32.SIZE_T;
const LPCSTR = w32.LPCSTR;

pub const IUnknown = d3dcommon.IUnknown;
pub const IObject = d3dcommon.IObject;
pub const RECT = w32.RECT;

pub const SDK_VERSION = 7;

// functions
// ---------

// HRESULT D3D11CreateDevice(
//   [in, optional]  IDXGIAdapter            *pAdapter,
//                   D3D_DRIVER_TYPE         DriverType,
//                   HMODULE                 Software,
//                   UINT                    Flags,
//   [in, optional]  const D3D_FEATURE_LEVEL *pFeatureLevels,
//                   UINT                    FeatureLevels,
//                   UINT                    SDKVersion,
//   [out, optional] ID3D11Device            **ppDevice,
//   [out, optional] D3D_FEATURE_LEVEL       *pFeatureLevel,
//   [out, optional] ID3D11DeviceContext     **ppImmediateContext
// );

pub extern "d3d11" fn D3D11CreateDevice(
    adapter: ?*dxgi.IAdapter,
    driver_type: d3dcommon.DRIVER_TYPE,
    software: ?HMODULE,
    flags: CREATE_DEVICE_FLAG,
    feature_levels: ?[*]const d3dcommon.FEATURE_LEVEL,
    feature_levels_count: u32,
    sdk_version: u32,
    device: ?*?*IDevice,
    feature_level: ?*d3dcommon.FEATURE_LEVEL,
    immediate_context: ?*?*IDeviceContext,
) callconv(.winapi) HRESULT;

// pub extern "d3d11" fn D3D11CreateDeviceAndSwapChain(
//     pAdapter: ?*dxgi.IAdapter,
//     DriverType: DRIVER_TYPE,
//     Software: ?HINSTANCE,
//     Flags: CREATE_DEVICE_FLAG,
//     pFeatureLevels: ?[*]const FEATURE_LEVEL,
//     FeatureLevels: UINT,
//     SDKVersion: UINT,
//     pSwapChainDesc: ?*const dxgi.SWAP_CHAIN_DESC,
//     ppSwapChain: ?*?*dxgi.ISwapChain,
//     ppDevice: ?*?*IDevice,
//     pFeatureLevel: ?*FEATURE_LEVEL,
//     ppImmediateContext: ?*?*IDeviceContext,
// ) callconv(WINAPI) HRESULT;

// types
// -----

pub const CREATE_DEVICE_FLAG = packed struct(u32) {
    SINGLETHREADED: bool = false,
    DEBUG: bool = false,
    SWITCH_TO_REF: bool = false,
    PREVENT_INTERNAL_THREADING_OPTIMIZATIONS: bool = false,
    __unused4: bool = false,
    BGRA_SUPPORT: bool = false,
    DEBUGGABLE: bool = false,
    PREVENT_ALTERING_LAYER_SETTINGS_FROM_REGISTRY: bool = false,
    DISABLE_GPU_TIMEOUT: bool = false,
    __unused9: bool = false,
    __unused10: bool = false,
    VIDEO_SUPPORT: bool = false,
    __unused: u20 = 0,
};

pub const FEATURE = enum(u32) {
    OPTIONS = 0,
    ARCHITECTURE = 1,
    FEATURE_LEVELS = 2,
    FORMAT_SUPPORT = 3,
    MULTISAMPLE_QUALITY_LEVELS = 4,
    FORMAT_INFO = 5,
    GPU_VIRTUAL_ADDRESS_SUPPORT = 6,
    SHADER_MODEL = 7,
    OPTIONS1 = 8,
    PROTECTED_RESOURCE_SESSION_SUPPORT = 10,
    ROOT_SIGNATURE = 12,
    ARCHITECTURE1 = 16,
    OPTIONS2 = 18,
    SHADER_CACHE = 19,
    COMMAND_QUEUE_PRIORITY = 20,
    OPTIONS3 = 21,
    EXISTING_HEAPS = 22,
    OPTIONS4 = 23,
    SERIALIZATION = 24,
    CROSS_NODE = 25,
    OPTIONS5 = 27,
    DISPLAYABLE = 28,
    OPTIONS6 = 30,
    QUERY_META_COMMAND = 31,
    OPTIONS7 = 32,
    PROTECTED_RESOURCE_SESSION_TYPE_COUNT = 33,
    PROTECTED_RESOURCE_SESSION_TYPES = 34,
    OPTIONS8 = 36,
    OPTIONS9 = 37,
    OPTIONS10 = 39,
    OPTIONS11 = 40,
    OPTIONS12 = 41,
    OPTIONS13 = 42,
    OPTIONS14 = 43,
    OPTIONS15 = 44,
    OPTIONS16 = 45,
    OPTIONS17 = 46,
    OPTIONS18 = 47,
    OPTIONS19 = 48,
    OPTIONS20 = 49,
};

pub const FEATURE_DATA_ARCHITECTURE = extern struct {
    NodeIndex: u32 = 0,
    TileBasedRenderer: BOOL = 0,
    UMA: BOOL = 0,
    CacheCoherentUMA: BOOL = 0,
};

pub const BIND_FLAG = packed struct(u32) {
    VERTEX_BUFFER: bool = false,
    INDEX_BUFFER: bool = false,
    CONSTANT_BUFFER: bool = false,
    SHADER_RESOURCE: bool = false,
    STREAM_OUTPUT: bool = false,
    RENDER_TARGET: bool = false,
    DEPTH_STENCIL: bool = false,
    UNORDERED_ACCESS: bool = false,
    __unused8: bool = false,
    DECODER: bool = false,
    VIDEO_ENCODER: bool = false,
    __unused: u21 = 0,
};

// pub const RESOURCE_DIMENSION = enum(UINT) {
//     UNKNOWN = 0,
//     BUFFER = 1,
//     TEXTURE1D = 2,
//     TEXTURE2D = 3,
//     TEXTURE3D = 4,
// };

pub const RTV_DIMENSION = enum(u32) {
    UNKNOWN = 0,
    BUFFER = 1,
    TEXTURE1D = 2,
    TEXTURE1DARRAY = 3,
    TEXTURE2D = 4,
    TEXTURE2DARRAY = 5,
    TEXTURE2DMS = 6,
    TEXTURE2DMSARRAY = 7,
    TEXTURE3D = 8,
};

// pub const BOX = extern struct {
//     left: UINT,
//     top: UINT,
//     front: UINT,
//     right: UINT,
//     bottom: UINT,
//     back: UINT,
// };

pub const BUFFER_RTV = extern struct {
    u0: extern union {
        FirstElement: u32,
        ElementOffset: u32,
    },
    u1: extern union {
        NumElements: u32,
        ElementWidth: u32,
    },
};

pub const TEX1D_RTV = extern struct {
    MipSlice: u32,
};

pub const TEX1D_ARRAY_RTV = extern struct {
    MipSlice: u32,
    FirstArraySlice: u32,
    ArraySize: u32,
};

pub const TEX2D_RTV = extern struct {
    MipSlice: u32,
};

pub const TEX2D_ARRAY_RTV = extern struct {
    MipSlice: u32,
    FirstArraySlice: u32,
    ArraySize: u32,
};

pub const TEX2DMS_RTV = extern struct {
    UnusedField_NothingToDefine: u32 = undefined,
};

pub const TEX2DMS_ARRAY_RTV = extern struct {
    FirstArraySlice: u32,
    ArraySlice: u32,
};

pub const TEX3D_RTV = extern struct {
    MipSlice: u32,
    FirstWSlice: u32,
    WSize: u32,
};

pub const RENDER_TARGET_VIEW_DESC = extern struct {
    Format: dxgi.FORMAT,
    ViewDimension: RTV_DIMENSION,
    u: extern union {
        Buffer: BUFFER_RTV,
        Texture1D: TEX1D_RTV,
        Texture1DArray: TEX1D_ARRAY_RTV,
        Texture2D: TEX2D_RTV,
        Texture2DArray: TEX2D_ARRAY_RTV,
        Texture2DMS: TEX2DMS_RTV,
        Texture2DMSArray: TEX2DMS_ARRAY_RTV,
        Texture3D: TEX3D_RTV,
    },
};

pub const INPUT_CLASSIFICATION = enum(u32) {
    INPUT_PER_VERTEX_DATA = 0,
    INPUT_PER_INSTANCE_DATA = 1,
};

// pub const APPEND_ALIGNED_ELEMENT: UINT = 0xffffffff;

pub const INPUT_ELEMENT_DESC = extern struct {
    SemanticName: LPCSTR,
    SemanticIndex: u32,
    Format: dxgi.FORMAT,
    InputSlot: u32,
    AlignedByteOffset: u32,
    InputSlotClass: INPUT_CLASSIFICATION,
    InstanceDataStepRate: u32,
};

pub const SUBRESOURCE_DATA = extern struct {
    pSysMem: ?*const anyopaque,
    SysMemPitch: u32 = 0,
    SysMemSlicePitch: u32 = 0,
};

pub const USAGE = enum(u32) {
    DEFAULT,
    IMMUTABLE,
    DYNAMIC,
    STAGING,
};

pub const CPU_ACCCESS_FLAG = packed struct(u32) {
    __unused0: u16 = 0,
    WRITE: bool = false,
    READ: bool = false,
    __unused: u14 = 0,
};

pub const RESOURCE_MISC_FLAG = packed struct(u32) {
    GENERATE_MIPS: bool = false,
    SHARED: bool = false,
    TEXTURECUBE: bool = false,
    __unused3: bool = false,
    DRAWINDIRECT_ARGS: bool = false,
    BUFFER_ALLOW_RAW_VIEWS: bool = false,
    BUFFER_STRUCTURED: bool = false,
    RESOURCE_CLAMP: bool = false,
    SHARED_KEYEDMUTEX: bool = false,
    GDI_COMPATIBLE: bool = false,
    __unused10: bool = false,
    SHARED_NTHANDLE: bool = false,
    RESTRICTED_CONTENT: bool = false,
    RESTRICT_SHARED_RESOURCE: bool = false,
    RESTRICT_SHARED_RESOURCE_DRIVER: bool = false,
    GUARDED: bool = false,
    __unused16: bool = false,
    TILE_POOL: bool = false,
    TILED: bool = false,
    HW_PROTECTED: bool = false,
    __unused: u12 = 0,
};

pub const BUFFER_DESC = extern struct {
    ByteWidth: u32,
    Usage: USAGE,
    BindFlags: BIND_FLAG,
    CPUAccessFlags: CPU_ACCCESS_FLAG = .{},
    MiscFlags: RESOURCE_MISC_FLAG = .{},
    StructureByteStride: u32 = 0,
};

pub const VIEWPORT = extern struct {
    TopLeftX: f32,
    TopLeftY: f32,
    Width: f32,
    Height: f32,
    MinDepth: f32,
    MaxDepth: f32,
};

// pub const CPU_DESCRIPTOR_HANDLE = extern struct {
//     ptr: SIZE_T,
// };

pub const MAP = enum(u32) {
    READ = 1,
    WRITE = 2,
    READ_WRITE = 3,
    WRITE_DISCARD = 4,
    WRITE_NO_OVERWRITE = 5,
};

pub const MAP_FLAG = packed struct(u32) {
    DO_NOT_WAIT: bool = false,
    __unused: u31 = 0,
};

pub const MAPPED_SUBRESOURCE = extern struct {
    pData: *anyopaque,
    RowPitch: u32,
    DepthPitch: u32,
};

pub const FILL_MODE = enum(u32) {
    WIREFRAME = 2,
    SOLID = 3,
};

pub const CULL_MODE = enum(u32) {
    NONE = 1,
    FRONT = 2,
    BACK = 3,
};

pub const RASTERIZER_DESC = extern struct {
    FillMode: FILL_MODE = .SOLID,
    CullMode: CULL_MODE = .BACK,
    FrontCounterClockwise: BOOL = 0,
    DepthBias: i32 = 0,
    DepthBiasClamp: f32 = 0,
    SlopeScaledDepthBias: f32 = 0,
    DepthClipEnable: BOOL = 1,
    ScissorEnable: BOOL = 0,
    MultisampleEnable: BOOL = 0,
    AntialiasedLineEnable: BOOL = 0,
};

pub const BLEND = enum(u32) {
    ZERO = 1,
    ONE = 2,
    SRC_COLOR = 3,
    INV_SRC_COLOR = 4,
    SRC_ALPHA = 5,
    INV_SRC_ALPHA = 6,
    DEST_ALPHA = 7,
    INV_DEST_ALPHA = 8,
    DEST_COLOR = 9,
    INV_DEST_COLOR = 10,
    SRC_ALPHA_SAT = 11,
    BLEND_FACTOR = 14,
    INV_BLEND_FACTOR = 15,
    SRC1_COLOR = 16,
    INV_SRC1_COLOR = 17,
    SRC1_ALPHA = 18,
    INV_SRC1_ALPHA = 19,
};

pub const BLEND_OP = enum(u32) {
    ADD = 1,
    SUBTRACT = 2,
    REV_SUBTRACT = 3,
    MIN = 4,
    MAX = 5,
};

pub const COLOR_WRITE_ENABLE = packed struct(u8) {
    RED: bool = false,
    GREEN: bool = false,
    BLUE: bool = false,
    ALPHA: bool = false,
    _: u4 = 0,

    pub const ALL = COLOR_WRITE_ENABLE{ .RED = true, .GREEN = true, .BLUE = true, .ALPHA = true };
};

pub const RENDER_TARGET_BLEND_DESC = extern struct {
    BlendEnable: BOOL,
    SrcBlend: BLEND,
    DestBlend: BLEND,
    BlendOp: BLEND_OP,
    SrcBlendAlpha: BLEND,
    DestBlendAlpha: BLEND,
    BlendOpAlpha: BLEND_OP,
    RenderTargetWriteMask: COLOR_WRITE_ENABLE,
};

pub const BLEND_DESC = extern struct {
    AlphaToCoverageEnable: BOOL,
    IndependentBlendEnable: BOOL,
    RenderTarget: [8]RENDER_TARGET_BLEND_DESC,
};

// pub const TEXTURE2D_DESC = struct {
//     Width: UINT,
//     Height: UINT,
//     MipLevels: UINT,
//     ArraySize: UINT,
//     Format: dxgi.FORMAT,
//     SampleDesc: dxgi.SAMPLE_DESC,
//     Usage: USAGE,
//     BindFlags: BIND_FLAG,
//     CPUAccessFlags: CPU_ACCCESS_FLAG,
//     MiscFlags: RESOURCE_MISC_FLAG,
// };

// pub const BUFFER_SRV = extern struct {
//     FirstElement: UINT,
//     NumElements: UINT,
// };

// pub const TEX1D_SRV = extern struct {
//     MostDetailedMip: UINT,
//     MipLevels: UINT,
// };

// pub const TEX1D_ARRAY_SRV = extern struct {
//     MostDetailedMip: UINT,
//     MipLevels: UINT,
//     FirstArraySlice: UINT,
//     ArraySize: UINT,
// };

// pub const TEX2D_SRV = extern struct {
//     MostDetailedMip: UINT,
//     MipLevels: UINT,
// };

// pub const TEX2D_ARRAY_SRV = extern struct {
//     MostDetailedMip: UINT,
//     MipLevels: UINT,
//     FirstArraySlice: UINT,
//     ArraySize: UINT,
// };

// pub const TEX3D_SRV = extern struct {
//     MostDetailedMip: UINT,
//     MipLevels: UINT,
// };

// pub const TEXCUBE_SRV = extern struct {
//     MostDetailedMip: UINT,
//     MipLevels: UINT,
// };

// pub const TEXCUBE_ARRAY_SRV = extern struct {
//     MostDetailedMip: UINT,
//     MipLevels: UINT,
//     First2DArrayFace: UINT,
//     NumCubes: UINT,
// };

// pub const TEX2DMS_SRV = extern struct {
//     UnusedField_NothingToDefine: UINT,
// };

// pub const TEX2DMS_ARRAY_SRV = extern struct {
//     FirstArraySlice: UINT,
//     ArraySize: UINT,
// };

// pub const BUFFEREX_SRV_FLAG = packed struct(UINT) {
//     RAW: bool = false,
//     __unused: u31 = 0,
// };

// pub const BUFFEREX_SRV = extern struct {
//     FirstElement: UINT,
//     NumElements: UINT,
//     Flags: BUFFEREX_SRV_FLAG,
// };

// pub const SRV_DIMENSION = enum(UINT) {
//     UNKNOWN = 0,
//     BUFFER = 1,
//     TEXTURE1D = 2,
//     TEXTURE1DARRAY = 3,
//     TEXTURE2D = 4,
//     TEXTURE2DARRAY = 5,
//     TEXTURE2DMS = 6,
//     TEXTURE2DMSARRAY = 7,
//     TEXTURE3D = 8,
//     TEXTURECUBE = 9,
//     TEXTURECUBEARRAY = 10,
//     BUFFEREX = 11,
// };

// pub const SHADER_RESOURCE_VIEW_DESC = extern struct {
//     Format: dxgi.FORMAT,
//     ViewDimension: SRV_DIMENSION,
//     u: extern union {
//         Buffer: BUFFER_SRV,
//         Texture1D: TEX1D_SRV,
//         Texture1DArray: TEX1D_ARRAY_SRV,
//         Texture2D: TEX2D_SRV,
//         Texture2DArray: TEX2D_ARRAY_SRV,
//         Texture2DMS: TEX2DMS_SRV,
//         Texture2DMSArray: TEX2DMS_ARRAY_SRV,
//         Texture3D: TEX3D_SRV,
//         TextureCube: TEXCUBE_SRV,
//         TextureCubeArray: TEXCUBE_ARRAY_SRV,
//         BufferEx: BUFFEREX_SRV,
//     },
// };

// pub const FILTER = enum(UINT) {
//     MIN_MAG_MIP_POINT = 0,
//     MIN_MAG_POINT_MIP_LINEAR = 0x1,
//     MIN_POINT_MAG_LINEAR_MIP_POINT = 0x4,
//     MIN_POINT_MAG_MIP_LINEAR = 0x5,
//     MIN_LINEAR_MAG_MIP_POINT = 0x10,
//     MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x11,
//     MIN_MAG_LINEAR_MIP_POINT = 0x14,
//     MIN_MAG_MIP_LINEAR = 0x15,
//     ANISOTROPIC = 0x55,
//     COMPARISON_MIN_MAG_MIP_POINT = 0x80,
//     COMPARISON_MIN_MAG_POINT_MIP_LINEAR = 0x81,
//     COMPARISON_MIN_POINT_MAG_LINEAR_MIP_POINT = 0x84,
//     COMPARISON_MIN_POINT_MAG_MIP_LINEAR = 0x85,
//     COMPARISON_MIN_LINEAR_MAG_MIP_POINT = 0x90,
//     COMPARISON_MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x91,
//     COMPARISON_MIN_MAG_LINEAR_MIP_POINT = 0x94,
//     COMPARISON_MIN_MAG_MIP_LINEAR = 0x95,
//     COMPARISON_ANISOTROPIC = 0xd5,
//     MINIMUM_MIN_MAG_MIP_POINT = 0x100,
//     MINIMUM_MIN_MAG_POINT_MIP_LINEAR = 0x101,
//     MINIMUM_MIN_POINT_MAG_LINEAR_MIP_POINT = 0x104,
//     MINIMUM_MIN_POINT_MAG_MIP_LINEAR = 0x105,
//     MINIMUM_MIN_LINEAR_MAG_MIP_POINT = 0x110,
//     MINIMUM_MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x111,
//     MINIMUM_MIN_MAG_LINEAR_MIP_POINT = 0x114,
//     MINIMUM_MIN_MAG_MIP_LINEAR = 0x115,
//     MINIMUM_ANISOTROPIC = 0x155,
//     MAXIMUM_MIN_MAG_MIP_POINT = 0x180,
//     MAXIMUM_MIN_MAG_POINT_MIP_LINEAR = 0x181,
//     MAXIMUM_MIN_POINT_MAG_LINEAR_MIP_POINT = 0x184,
//     MAXIMUM_MIN_POINT_MAG_MIP_LINEAR = 0x185,
//     MAXIMUM_MIN_LINEAR_MAG_MIP_POINT = 0x190,
//     MAXIMUM_MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x191,
//     MAXIMUM_MIN_MAG_LINEAR_MIP_POINT = 0x194,
//     MAXIMUM_MIN_MAG_MIP_LINEAR = 0x195,
//     MAXIMUM_ANISOTROPIC = 0x1d5,
// };

// pub const TEXTURE_ADDRESS_MODE = enum(UINT) {
//     WRAP = 1,
//     MIRROR = 2,
//     CLAMP = 3,
//     BORDER = 4,
//     MIRROR_ONCE = 5,
// };

pub const COMPARISON_FUNC = enum(u32) {
    NEVER = 1,
    LESS = 2,
    EQUAL = 3,
    LESS_EQUAL = 4,
    GREATER = 5,
    NOT_EQUAL = 6,
    GREATER_EQUAL = 7,
    ALWAYS = 8,
};

// pub const SAMPLER_DESC = extern struct {
//     Filter: FILTER,
//     AddressU: TEXTURE_ADDRESS_MODE,
//     AddressV: TEXTURE_ADDRESS_MODE,
//     AddressW: TEXTURE_ADDRESS_MODE,
//     MipLODBias: FLOAT = 0,
//     MaxAnisotropy: UINT = 0,
//     ComparisonFunc: COMPARISON_FUNC,
//     BorderColor: [4]FLOAT = .{ 0, 0, 0, 0 },
//     MinLOD: FLOAT = 0,
//     MaxLOD: FLOAT = 0,
// };

// pub extern "d3d11" fn D3D11CreateDeviceAndSwapChain(
//     pAdapter: ?*dxgi.IAdapter,
//     DriverType: DRIVER_TYPE,
//     Software: ?HINSTANCE,
//     Flags: CREATE_DEVICE_FLAG,
//     pFeatureLevels: ?[*]const FEATURE_LEVEL,
//     FeatureLevels: UINT,
//     SDKVersion: UINT,
//     pSwapChainDesc: ?*const dxgi.SWAP_CHAIN_DESC,
//     ppSwapChain: ?*?*dxgi.ISwapChain,
//     ppDevice: ?*?*IDevice,
//     pFeatureLevel: ?*FEATURE_LEVEL,
//     ppImmediateContext: ?*?*IDeviceContext,
// ) callconv(WINAPI) HRESULT;

// // Return codes as defined here:
// // https://docs.microsoft.com/en-us/windows/win32/direct3d11/d3d11-graphics-reference-returnvalues
// pub const ERROR_FILE_NOT_FOUND = @as(HRESULT, @bitCast(@as(c_ulong, 0x887C0002)));
// pub const ERROR_TOO_MANY_UNIQUE_STATE_OBJECTS = @as(HRESULT, @bitCast(@as(c_ulong, 0x887C0001)));
// pub const ERROR_TOO_MANY_UNIQUE_VIEW_OBJECTS = @as(HRESULT, @bitCast(@as(c_ulong, 0x887C0003)));
// pub const ERROR_DEFERRED_CONTEXT_MAP_WITHOUT_INITIAL_DISCARD = @as(HRESULT, @bitCast(@as(c_ulong, 0x887C0004)));

// // error set corresponding to the above return codes
// pub const Error = error{
//     FILE_NOT_FOUND,
//     TOO_MANY_UNIQUE_STATE_OBJECTS,
//     TOO_MANY_UNIQUE_VIEW_OBJECTS,
//     DEFERRED_CONTEXT_MAP_WITHOUT_INITIAL_DISCARD,
// };

pub const DEPTH_WRITE_MASK = enum(u32) {
    ZERO = 0,
    ALL = 1,
};

pub const STENCIL_OP = enum(u32) {
    KEEP = 1,
    ZERO = 2,
    REPLACE = 3,
    INCR_SAT = 4,
    DECR_SAT = 5,
    INVERT = 6,
    INCR = 7,
    DECR = 8,
};

pub const DEPTH_STENCILOP_DESC = extern struct {
    StencilFailOp: STENCIL_OP,
    StencilDepthFailOp: STENCIL_OP,
    StencilPassOp: STENCIL_OP,
    StencilFunc: COMPARISON_FUNC,
};

pub const DEPTH_STENCIL_DESC = extern struct {
    DepthEnable: BOOL,
    DepthWriteMask: DEPTH_WRITE_MASK,
    DepthFunc: COMPARISON_FUNC,
    StencilEnable: BOOL = 0,
    StencilReadMask: u8 = 0,
    StencilWriteMask: u8 = 0,
    FrontFace: DEPTH_STENCILOP_DESC = std.mem.zeroes(DEPTH_STENCILOP_DESC),
    BackFace: DEPTH_STENCILOP_DESC = std.mem.zeroes(DEPTH_STENCILOP_DESC),
};

// pub const SHADER_DESC = extern struct {
//     Version: UINT,
//     Creator: LPCSTR,
//     Flags: UINT,
//     ConstantBuffers: UINT,
//     BoundResources: UINT,
//     InputParameters: UINT,
//     OutputParameters: UINT,
//     InstructionCount: UINT,
//     TempRegisterCount: UINT,
//     TempArrayCount: UINT,
//     DefCount: UINT,
//     DclCount: UINT,
//     TextureNormalInstructions: UINT,
//     TextureLoadInstructions: UINT,
//     TextureCompInstructions: UINT,
//     TextureBiasInstructions: UINT,
//     TextureGradientInstructions: UINT,
//     FloatInstructionCount: UINT,
//     IntInstructionCount: UINT,
//     UintInstructionCount: UINT,
//     StaticFlowControlCount: UINT,
//     DynamicFlowControlCount: UINT,
//     MacroInstructionCount: UINT,
//     ArrayInstructionCount: UINT,
//     CutInstructionCount: UINT,
//     EmitInstructionCount: UINT,
//     GSOutputTopology: PRIMITIVE_TOPOLOGY,
//     GSMaxOutputVertexCount: UINT,
//     InputPrimitive: PRIMITIVE,
//     PatchConstantParameters: UINT,
//     cGSInstanceCount: UINT,
//     cControlPoints: UINT,
//     HSOutputPrimitive: TESSELLATOR_OUTPUT_PRIMITIVE,
//     HSPartitioning: TESSELLATOR_PARTITIONING,
//     TessellatorDomain: TESSELLATOR_DOMAIN,
//     cBarrierInstructions: UINT,
//     cInterlockedInstructions: UINT,
//     cTextureStoreInstructions: UINT,
// };

// pub const SHADER_BUFFER_DESC = extern struct {
//     Name: LPCSTR,
//     Type: CBUFFER_TYPE,
//     Variables: UINT,
//     Size: UINT,
//     uFlags: UINT,
// };

// pub const SHADER_VARIABLE_DESC = extern struct {
//     Name: LPCSTR,
//     StartOffset: UINT,
//     Size: UINT,
//     uFlags: UINT,
//     DefaultValue: *anyopaque,
//     StartTexture: UINT,
//     TextureSize: UINT,
//     StartSampler: UINT,
//     SamplerSize: UINT,
// };

// pub const SHADER_TYPE_DESC = extern struct {
//     Class: SHADER_VARIABLE_CLASS,
//     Type: SHADER_VARIABLE_TYPE,
//     Rows: UINT,
//     Columns: UINT,
//     Elements: UINT,
//     Members: UINT,
//     Offset: UINT,
//     Name: LPCSTR,
// };

// // TODO move these to d3dcommon
// pub const PRIMITIVE = enum(UINT) {};

// pub const TESSELLATOR_OUTPUT_PRIMITIVE = enum(UINT) {};

// pub const TESSELLATOR_PARTITIONING = enum(UINT) {};

// pub const TESSELLATOR_DOMAIN = enum(UINT) {
//     UNDEFINED = 0,
//     ISOLINE = 1,
//     TRI = 2,
//     QUAD = 3,
// };

// pub const SHADER_INPUT_BIND_DESC = extern struct {
//     Name: LPCSTR,
//     Type: SHADER_INPUT_TYPE,
//     BindPoint: UINT,
//     BindCount: UINT,

//     uFlags: UINT,
//     ReturnType: RESOURCE_RETURN_TYPE,
//     Dimension: SRV_DIMENSION,
//     NumSamples: UINT,
// };

// pub const SHADER_INPUT_TYPE = enum(UINT) {
//     CBUFFER = 0,
//     TBUFFER = 1,
//     TEXTURE = 2,
//     SAMPLER = 3,
//     UAV_RWTYPED = 4,
//     STRUCTURED = 5,
//     UAV_RWSTRUCTURED = 6,
//     BYTEADDRESS = 7,
//     UAV_RWBYTEADDRESS = 8,
//     UAV_APPEND_STRUCTURED = 9,
//     UAV_CONSUME_STRUCTURED = 10,
//     UAV_RWSTRUCTURED_WITH_COUNTER = 11,
//     RTACCELERATIONSTRUCTURE = 12,
//     UAV_FEEDBACKTEXTURE = 13,
// };

// pub const RESOURCE_RETURN_TYPE = enum(UINT) {
//     UNORM = 1,
//     SNORM = 2,
//     SINT = 3,
//     UINT = 4,
//     FLOAT = 5,
//     MIXED = 6,
//     DOUBLE = 7,
//     CONTINUED = 8,
// };

// pub const CBUFFER_TYPE = enum(UINT) {
//     CBUFFER = 0,
//     TBUFFER = 1,
//     INTERFACE_POINTERS = 2,
//     RESOURCE_BIND_INFO = 3,
// };

// pub const SHADER_VARIABLE_CLASS = enum(UINT) {
//     SCALAR = 0,
//     VECTOR = 1,
//     MATRIX_ROWS = 2,
//     MATRIX_COLUMNS = 3,
//     OBJECT = 4,
//     STRUCT = 5,
//     INTERFACE_CLASS = 6,
//     INTERFACE_POINTER = 7,
// };

// pub const SHADER_VARIABLE_TYPE = enum(UINT) {
//     VOID = 0,
//     BOOL = 1,
//     INT = 2,
//     FLOAT = 3,
//     STRING = 4,
//     TEXTURE = 5,
//     TEXTURE1D = 6,
//     TEXTURE2D = 7,
//     TEXTURE3D = 8,
//     TEXTURECUBE = 9,
//     SAMPLER = 10,
//     SAMPLER1D = 11,
//     SAMPLER2D = 12,
//     SAMPLER3D = 13,
//     SAMPLERCUBE = 14,
//     PIXELSHADER = 15,
//     VERTEXSHADER = 16,
//     PIXELFRAGMENT = 17,
//     VERTEXFRAGMENT = 18,
//     UINT = 19,
//     UINT8 = 20,
//     GEOMETRYSHADER = 21,
//     RASTERIZER = 22,
//     DEPTHSTENCIL = 23,
//     BLEND = 24,
//     BUFFER = 25,
//     CBUFFER = 26,
//     TBUFFER = 27,
//     TEXTURE1DARRAY = 28,
//     TEXTURE2DARRAY = 29,
//     RENDERTARGETVIEW = 30,
//     DEPTHSTENCILVIEW = 31,
//     TEXTURE2DMS = 32,
//     TEXTURE2DMSARRAY = 33,
//     TEXTURECUBEARRAY = 34,
//     HULLSHADER = 35,
//     DOMAINSHADER = 36,
//     INTERFACE_POINTER = 37,
//     COMPUTESHADER = 38,
//     DOUBLE = 39,
//     RWTEXTURE1D = 40,
//     RWTEXTURE1DARRAY = 41,
//     RWTEXTURE2D = 42,
//     RWTEXTURE2DARRAY = 43,
//     RWTEXTURE3D = 44,
//     RWBUFFER = 45,
//     BYTEADDRESS_BUFFER = 46,
//     RWBYTEADDRESS_BUFFER = 47,
//     STRUCTURED_BUFFER = 48,
//     RWSTRUCTURED_BUFFER = 49,
//     APPEND_STRUCTURED_BUFFER = 50,
//     CONSUME_STRUCTURED_BUFFER = 51,
//     MIN8FLOAT = 52,
//     MIN10FLOAT = 53,
//     MIN16FLOAT = 54,
//     MIN12INT = 55,
//     MIN16INT = 56,
//     MIN16UINT = 57,
//     INT16 = 58,
//     UINT16 = 59,
//     FLOAT16 = 60,
//     INT64 = 61,
//     UINT64 = 62,
// };

pub const MESSAGE_SEVERITY = enum(u32) {
    CORRUPTION = 0,
    ERROR = 1,
    WARNING = 2,
    INFO = 3,
    MESSAGE = 4,
};

pub const MESSAGE_CATEGORY = enum(u32) {
    APPLICATION_DEFINED,
    MISCELLANEOUS,
    INITIALIZATION,
    CLEANUP,
    COMPILATION,
    STATE_CREATION,
    STATE_SETTING,
    STATE_GETTING,
    RESOURCE_MANIPULATION,
    EXECUTION,
    SHADER, // Not supported until D3D 11.1
};

pub const MESSAGE_ID = enum(u32) { _ };

pub const MESSAGE = extern struct {
    Category: MESSAGE_CATEGORY,
    Severity: MESSAGE_SEVERITY,
    ID: MESSAGE_ID,
    pDescription: [*c]const u8,
    DescriptionByteLength: u32,
};

pub const DEBUG_FEATURES = packed struct(u32) {
    flush_per_render_op: bool = false,
    finish_per_render_op: bool = false,
    feature_present_per_render_op: bool = false,
    _: u29 = 0,
};

pub const RLDO_FLAGS = packed struct(u32) {
    summary: bool = false,
    detail: bool = false,
    ignore_internal: bool = false,
    _: u29 = 0,
};

// THIS FILE IS AUTOGENERATED BEYOND THIS POINT! DO NOT EDIT!
// ----------------------------------------------------------

pub const IDevice = extern struct {
    pub const IID = GUID.parse("{DB6F6DDB-AC77-4E88-8253-819DF9BBF140}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IUnknown.VTable,
        create_buffer: *const fn (*IDevice, desc: *const BUFFER_DESC, initial_data: ?*const SUBRESOURCE_DATA, buffer: *?*IBuffer) callconv(.winapi) HRESULT,
        create_texture1_d: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_texture2_d: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_texture3_d: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_shader_resource_view: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_unordered_access_view: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_render_target_view: *const fn (*IDevice, resource: ?*IResource, desc: ?*const RENDER_TARGET_VIEW_DESC, view: ?*?*IRenderTargetView) callconv(.winapi) HRESULT,
        create_depth_stencil_view: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_input_layout: *const fn (*IDevice, element_descs: ?[*]const INPUT_ELEMENT_DESC, num: u32, shader_bytecode: *const anyopaque, bytecode_length: SIZE_T, layout: *?*IInputLayout) callconv(.winapi) HRESULT,
        create_vertex_shader: *const fn (*IDevice, bytecode: *const anyopaque, length: SIZE_T, class_linkage: ?*IClassLinkage, shader: *?*IVertexShader) callconv(.winapi) HRESULT,
        create_geometry_shader: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_geometry_shader_with_stream_output: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_pixel_shader: *const fn (*IDevice, bytecode: *const anyopaque, length: SIZE_T, class_linkage: ?*IClassLinkage, shader: *?*IPixelShader) callconv(.winapi) HRESULT,
        create_hull_shader: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_domain_shader: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_compute_shader: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_class_linkage: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_blend_state: *const fn (*IDevice, desc: *const BLEND_DESC, state: *?*IBlendState) callconv(.winapi) HRESULT,
        create_depth_stencil_state: *const fn (*IDevice, desc: *const DEPTH_STENCIL_DESC, state: *?*IDepthStencilState) callconv(.winapi) HRESULT,
        create_rasterizer_state: *const fn (*IDevice, desc: *const RASTERIZER_DESC, state: *?*IRasterizerState) callconv(.winapi) HRESULT,
        create_sampler_state: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_query: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_predicate: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_counter: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_deferred_context: *const fn (*IDevice, flags: u32, context: *?*IDeviceContext) callconv(.winapi) HRESULT,
        open_shared_resource: *const fn (*IDevice) callconv(.winapi) noreturn,
        check_format_support: *const fn (*IDevice) callconv(.winapi) noreturn,
        check_multisample_quality_levels: *const fn (*IDevice) callconv(.winapi) noreturn,
        check_counter_info: *const fn (*IDevice) callconv(.winapi) noreturn,
        check_counter: *const fn (*IDevice) callconv(.winapi) noreturn,
        check_feature_support: *const fn (*IDevice, feature: FEATURE, data: *anyopaque, size: u32) callconv(.winapi) HRESULT,
        get_private_data: *const fn (*IDevice) callconv(.winapi) noreturn,
        set_private_data: *const fn (*IDevice) callconv(.winapi) noreturn,
        set_private_data_interface: *const fn (*IDevice) callconv(.winapi) noreturn,
        get_feature_level: *const fn (*IDevice) callconv(.winapi) noreturn,
        get_creation_flags: *const fn (*IDevice) callconv(.winapi) noreturn,
        get_device_removed_reason: *const fn (*IDevice) callconv(.winapi) noreturn,
        get_immediate_context: *const fn (*IDevice) callconv(.winapi) noreturn,
        set_exception_mode: *const fn (*IDevice) callconv(.winapi) noreturn,
        get_exception_mode: *const fn (*IDevice) callconv(.winapi) noreturn,
    };

    pub fn createBuffer(self: *IDevice, desc: *const BUFFER_DESC, initial_data: ?*const SUBRESOURCE_DATA, buffer: *?*IBuffer) HRESULT {
        return (self.vtable.create_buffer)(self, desc, initial_data, buffer);
    }
    pub fn createTexture1D(self: *IDevice) noreturn {
        return (self.vtable.create_texture1_d)(self);
    }
    pub fn createTexture2D(self: *IDevice) noreturn {
        return (self.vtable.create_texture2_d)(self);
    }
    pub fn createTexture3D(self: *IDevice) noreturn {
        return (self.vtable.create_texture3_d)(self);
    }
    pub fn createShaderResourceView(self: *IDevice) noreturn {
        return (self.vtable.create_shader_resource_view)(self);
    }
    pub fn createUnorderedAccessView(self: *IDevice) noreturn {
        return (self.vtable.create_unordered_access_view)(self);
    }
    pub fn createRenderTargetView(self: *IDevice, resource: ?*IResource, desc: ?*const RENDER_TARGET_VIEW_DESC, view: ?*?*IRenderTargetView) HRESULT {
        return (self.vtable.create_render_target_view)(self, resource, desc, view);
    }
    pub fn createDepthStencilView(self: *IDevice) noreturn {
        return (self.vtable.create_depth_stencil_view)(self);
    }
    pub fn createInputLayout(self: *IDevice, element_descs: ?[*]const INPUT_ELEMENT_DESC, num: u32, shader_bytecode: *const anyopaque, bytecode_length: SIZE_T, layout: *?*IInputLayout) HRESULT {
        return (self.vtable.create_input_layout)(self, element_descs, num, shader_bytecode, bytecode_length, layout);
    }
    pub fn createVertexShader(self: *IDevice, bytecode: *const anyopaque, length: SIZE_T, class_linkage: ?*IClassLinkage, shader: *?*IVertexShader) HRESULT {
        return (self.vtable.create_vertex_shader)(self, bytecode, length, class_linkage, shader);
    }
    pub fn createGeometryShader(self: *IDevice) noreturn {
        return (self.vtable.create_geometry_shader)(self);
    }
    pub fn createGeometryShaderWithStreamOutput(self: *IDevice) noreturn {
        return (self.vtable.create_geometry_shader_with_stream_output)(self);
    }
    pub fn createPixelShader(self: *IDevice, bytecode: *const anyopaque, length: SIZE_T, class_linkage: ?*IClassLinkage, shader: *?*IPixelShader) HRESULT {
        return (self.vtable.create_pixel_shader)(self, bytecode, length, class_linkage, shader);
    }
    pub fn createHullShader(self: *IDevice) noreturn {
        return (self.vtable.create_hull_shader)(self);
    }
    pub fn createDomainShader(self: *IDevice) noreturn {
        return (self.vtable.create_domain_shader)(self);
    }
    pub fn createComputeShader(self: *IDevice) noreturn {
        return (self.vtable.create_compute_shader)(self);
    }
    pub fn createClassLinkage(self: *IDevice) noreturn {
        return (self.vtable.create_class_linkage)(self);
    }
    pub fn createBlendState(self: *IDevice, desc: *const BLEND_DESC, state: *?*IBlendState) HRESULT {
        return (self.vtable.create_blend_state)(self, desc, state);
    }
    pub fn createDepthStencilState(self: *IDevice, desc: *const DEPTH_STENCIL_DESC, state: *?*IDepthStencilState) HRESULT {
        return (self.vtable.create_depth_stencil_state)(self, desc, state);
    }
    pub fn createRasterizerState(self: *IDevice, desc: *const RASTERIZER_DESC, state: *?*IRasterizerState) HRESULT {
        return (self.vtable.create_rasterizer_state)(self, desc, state);
    }
    pub fn createSamplerState(self: *IDevice) noreturn {
        return (self.vtable.create_sampler_state)(self);
    }
    pub fn createQuery(self: *IDevice) noreturn {
        return (self.vtable.create_query)(self);
    }
    pub fn createPredicate(self: *IDevice) noreturn {
        return (self.vtable.create_predicate)(self);
    }
    pub fn createCounter(self: *IDevice) noreturn {
        return (self.vtable.create_counter)(self);
    }
    pub fn createDeferredContext(self: *IDevice, flags: u32, context: *?*IDeviceContext) HRESULT {
        return (self.vtable.create_deferred_context)(self, flags, context);
    }
    pub fn openSharedResource(self: *IDevice) noreturn {
        return (self.vtable.open_shared_resource)(self);
    }
    pub fn checkFormatSupport(self: *IDevice) noreturn {
        return (self.vtable.check_format_support)(self);
    }
    pub fn checkMultisampleQualityLevels(self: *IDevice) noreturn {
        return (self.vtable.check_multisample_quality_levels)(self);
    }
    pub fn checkCounterInfo(self: *IDevice) noreturn {
        return (self.vtable.check_counter_info)(self);
    }
    pub fn checkCounter(self: *IDevice) noreturn {
        return (self.vtable.check_counter)(self);
    }
    pub fn checkFeatureSupport(self: *IDevice, feature: FEATURE, data: *anyopaque, size: u32) HRESULT {
        return (self.vtable.check_feature_support)(self, feature, data, size);
    }
    pub fn getPrivateData(self: *IDevice) noreturn {
        return (self.vtable.get_private_data)(self);
    }
    pub fn setPrivateData(self: *IDevice) noreturn {
        return (self.vtable.set_private_data)(self);
    }
    pub fn setPrivateDataInterface(self: *IDevice) noreturn {
        return (self.vtable.set_private_data_interface)(self);
    }
    pub fn getFeatureLevel(self: *IDevice) noreturn {
        return (self.vtable.get_feature_level)(self);
    }
    pub fn getCreationFlags(self: *IDevice) noreturn {
        return (self.vtable.get_creation_flags)(self);
    }
    pub fn getDeviceRemovedReason(self: *IDevice) noreturn {
        return (self.vtable.get_device_removed_reason)(self);
    }
    pub fn getImmediateContext(self: *IDevice) noreturn {
        return (self.vtable.get_immediate_context)(self);
    }
    pub fn setExceptionMode(self: *IDevice) noreturn {
        return (self.vtable.set_exception_mode)(self);
    }
    pub fn getExceptionMode(self: *IDevice) noreturn {
        return (self.vtable.get_exception_mode)(self);
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

pub const IDeviceChild = extern struct {
    pub const IID = GUID.parse("{1841E5C8-16B0-489B-BCC8-44CFB0D5DEAE}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IUnknown.VTable,
        get_device: *const fn (*IDeviceChild, device: *?*IDevice) callconv(.winapi) void,
        get_private_data: *const fn (*IDeviceChild) callconv(.winapi) noreturn,
        set_private_data: *const fn (*IDeviceChild) callconv(.winapi) noreturn,
        set_private_data_interface: *const fn (*IDeviceChild) callconv(.winapi) noreturn,
    };

    pub fn getDevice(self: *IDeviceChild, device: *?*IDevice) void {
        return (self.vtable.get_device)(self, device);
    }
    pub fn getPrivateData(self: *IDeviceChild) noreturn {
        return (self.vtable.get_private_data)(self);
    }
    pub fn setPrivateData(self: *IDeviceChild) noreturn {
        return (self.vtable.set_private_data)(self);
    }
    pub fn setPrivateDataInterface(self: *IDeviceChild) noreturn {
        return (self.vtable.set_private_data_interface)(self);
    }
    // IUnknown methods
    pub fn queryInterface(self: *IDeviceChild, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IDeviceChild) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IDeviceChild) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IDeviceContext = extern struct {
    pub const IID = GUID.parse("{C0BFA96C-E089-44FB-8EAF-26F8796190DA}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IDeviceChild.VTable,
        vs_set_constant_buffers: *const fn (*IDeviceContext, slot: u32, num: u32, buffers: [*]*IBuffer) callconv(.winapi) void,
        ps_set_shader_resources: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        ps_set_shader: *const fn (*IDeviceContext, shader: ?*IPixelShader, class_instance: ?[*]const *IClassInstance, num: u32) callconv(.winapi) void,
        ps_set_samplers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        vs_set_shader: *const fn (*IDeviceContext, shader: ?*IVertexShader, class_instance: ?[*]const *IClassInstance, num: u32) callconv(.winapi) void,
        draw_indexed: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        draw: *const fn (*IDeviceContext, vertex_count: u32, start_vertex_location: u32) callconv(.winapi) void,
        map: *const fn (*IDeviceContext, resource: *IResource, subresource: u32, map_type: MAP, map_flags: MAP_FLAG, mapped_resource: *MAPPED_SUBRESOURCE) callconv(.winapi) HRESULT,
        unmap: *const fn (*IDeviceContext, resource: *IResource, subresource: u32) callconv(.winapi) void,
        ps_set_constant_buffers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        ia_set_input_layout: *const fn (*IDeviceContext, layout: ?*IInputLayout) callconv(.winapi) void,
        ia_set_vertex_buffers: *const fn (*IDeviceContext, start_slot: u32, num: u32, buffers: ?[*]*IBuffer, strides: ?[*]const u32, offsets: ?[*]const u32) callconv(.winapi) void,
        ia_set_index_buffer: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        draw_indexed_instanced: *const fn (*IDeviceContext, index_count_per_instance: u32, instance_count: u32, start_index_location: u32, base_vertex_location: i32, start_instance_location: u32) callconv(.winapi) void,
        draw_instanced: *const fn (*IDeviceContext, vertex_count_per_instance: u32, instance_count: u32, start_vertex_location: u32, start_instance_location: u32) callconv(.winapi) void,
        gs_set_constant_buffers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        gs_set_shader: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        ia_set_primitive_topology: *const fn (*IDeviceContext, topology: d3dcommon.PRIMITIVE_TOPOLOGY) callconv(.winapi) void,
        vs_set_shader_resources: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        vs_set_samplers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        begin: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        end: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        get_data: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        set_predication: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        gs_set_shader_resources: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        gs_set_samplers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        om_set_render_targets: *const fn (*IDeviceContext, num: u32, render_target_views: ?[*]const *IRenderTargetView, depth_stencil_view: ?*IDepthStencilView) callconv(.winapi) void,
        om_set_render_targets_and_unordered_access_views: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        om_set_blend_state: *const fn (*IDeviceContext, state: ?*IBlendState, factor: ?*const [4]f32, sample_mask: u32) callconv(.winapi) void,
        om_set_depth_stencil_state: *const fn (*IDeviceContext, state: ?*IDepthStencilState, stencil_ref: u32) callconv(.winapi) void,
        so_set_targets: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        draw_auto: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        draw_indexed_instanced_indirect: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        draw_instanced_indirect: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        dispatch: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        dispatch_indirect: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        rs_set_state: *const fn (*IDeviceContext, state: ?*IRasterizerState) callconv(.winapi) void,
        rs_set_viewports: *const fn (*IDeviceContext, num: u32, viewports: ?[*]const VIEWPORT) callconv(.winapi) void,
        rs_set_scissor_rects: *const fn (*IDeviceContext, num: u32, rects: ?[*]const RECT) callconv(.winapi) void,
        copy_subresource_region: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        copy_resource: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        update_subresource: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        copy_structure_count: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        clear_render_target_view: *const fn (*IDeviceContext, target: *IRenderTargetView, color: *const [4]f32) callconv(.winapi) void,
        clear_unordered_access_view_uint: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        clear_unordered_access_view_float: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        clear_depth_stencil_view: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        generate_mips: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        set_resource_min_lod: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        get_resource_min_lod: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        resolve_subresource: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        execute_command_list: *const fn (*IDeviceContext, command_list: *ICommandList, restore: BOOL) callconv(.winapi) void,
        hs_set_shader_resources: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        hs_set_shader: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        hs_set_samplers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        hs_set_constant_buffers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        ds_set_shader_resources: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        ds_set_shader: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        ds_set_samplers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        ds_set_constant_buffers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        cs_set_shader_resources: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        cs_set_unordered_access_views: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        cs_set_shader: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        cs_set_samplers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        cs_set_constant_buffers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        vs_get_constant_buffers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        ps_get_shader_resources: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        ps_get_shader: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        ps_get_samplers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        vs_get_shader: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        ps_get_constant_buffers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        ia_get_input_layout: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        ia_get_vertex_buffers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        ia_get_index_buffer: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        gs_get_constant_buffers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        gs_get_shader: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        ia_get_primitive_topology: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        vs_get_shader_resources: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        vs_get_samplers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        get_predication: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        gs_get_shader_resources: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        gs_get_samplers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        om_get_render_targets: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        om_get_render_targets_and_unordered_access_views: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        om_get_blend_state: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        om_get_depth_stencil_state: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        so_get_targets: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        rs_get_state: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        rs_get_viewports: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        rs_get_scissor_rects: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        hs_get_shader_resources: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        hs_get_shader: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        hs_get_samplers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        hs_get_constant_buffers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        ds_get_shader_resources: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        ds_get_shader: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        ds_get_samplers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        ds_get_constant_buffers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        cs_get_shader_resources: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        cs_get_unordered_access_views: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        cs_get_shader: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        cs_get_samplers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        cs_get_constant_buffers: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        clear_state: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        flush: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        get_type: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        get_context_flags: *const fn (*IDeviceContext) callconv(.winapi) noreturn,
        finish_command_list: *const fn (*IDeviceContext, restore: BOOL, command_list: *?*ICommandList) callconv(.winapi) HRESULT,
    };

    pub fn vsSetConstantBuffers(self: *IDeviceContext, slot: u32, num: u32, buffers: [*]*IBuffer) void {
        return (self.vtable.vs_set_constant_buffers)(self, slot, num, buffers);
    }
    pub fn psSetShaderResources(self: *IDeviceContext) noreturn {
        return (self.vtable.ps_set_shader_resources)(self);
    }
    pub fn psSetShader(self: *IDeviceContext, shader: ?*IPixelShader, class_instance: ?[*]const *IClassInstance, num: u32) void {
        return (self.vtable.ps_set_shader)(self, shader, class_instance, num);
    }
    pub fn psSetSamplers(self: *IDeviceContext) noreturn {
        return (self.vtable.ps_set_samplers)(self);
    }
    pub fn vsSetShader(self: *IDeviceContext, shader: ?*IVertexShader, class_instance: ?[*]const *IClassInstance, num: u32) void {
        return (self.vtable.vs_set_shader)(self, shader, class_instance, num);
    }
    pub fn drawIndexed(self: *IDeviceContext) noreturn {
        return (self.vtable.draw_indexed)(self);
    }
    pub fn draw(self: *IDeviceContext, vertex_count: u32, start_vertex_location: u32) void {
        return (self.vtable.draw)(self, vertex_count, start_vertex_location);
    }
    pub fn map(self: *IDeviceContext, resource: *IResource, subresource: u32, map_type: MAP, map_flags: MAP_FLAG, mapped_resource: *MAPPED_SUBRESOURCE) HRESULT {
        return (self.vtable.map)(self, resource, subresource, map_type, map_flags, mapped_resource);
    }
    pub fn unmap(self: *IDeviceContext, resource: *IResource, subresource: u32) void {
        return (self.vtable.unmap)(self, resource, subresource);
    }
    pub fn psSetConstantBuffers(self: *IDeviceContext) noreturn {
        return (self.vtable.ps_set_constant_buffers)(self);
    }
    pub fn iaSetInputLayout(self: *IDeviceContext, layout: ?*IInputLayout) void {
        return (self.vtable.ia_set_input_layout)(self, layout);
    }
    pub fn iaSetVertexBuffers(self: *IDeviceContext, start_slot: u32, num: u32, buffers: ?[*]*IBuffer, strides: ?[*]const u32, offsets: ?[*]const u32) void {
        return (self.vtable.ia_set_vertex_buffers)(self, start_slot, num, buffers, strides, offsets);
    }
    pub fn iaSetIndexBuffer(self: *IDeviceContext) noreturn {
        return (self.vtable.ia_set_index_buffer)(self);
    }
    pub fn drawIndexedInstanced(self: *IDeviceContext, index_count_per_instance: u32, instance_count: u32, start_index_location: u32, base_vertex_location: i32, start_instance_location: u32) void {
        return (self.vtable.draw_indexed_instanced)(self, index_count_per_instance, instance_count, start_index_location, base_vertex_location, start_instance_location);
    }
    pub fn drawInstanced(self: *IDeviceContext, vertex_count_per_instance: u32, instance_count: u32, start_vertex_location: u32, start_instance_location: u32) void {
        return (self.vtable.draw_instanced)(self, vertex_count_per_instance, instance_count, start_vertex_location, start_instance_location);
    }
    pub fn gsSetConstantBuffers(self: *IDeviceContext) noreturn {
        return (self.vtable.gs_set_constant_buffers)(self);
    }
    pub fn gsSetShader(self: *IDeviceContext) noreturn {
        return (self.vtable.gs_set_shader)(self);
    }
    pub fn iaSetPrimitiveTopology(self: *IDeviceContext, topology: d3dcommon.PRIMITIVE_TOPOLOGY) void {
        return (self.vtable.ia_set_primitive_topology)(self, topology);
    }
    pub fn vsSetShaderResources(self: *IDeviceContext) noreturn {
        return (self.vtable.vs_set_shader_resources)(self);
    }
    pub fn vsSetSamplers(self: *IDeviceContext) noreturn {
        return (self.vtable.vs_set_samplers)(self);
    }
    pub fn begin(self: *IDeviceContext) noreturn {
        return (self.vtable.begin)(self);
    }
    pub fn end(self: *IDeviceContext) noreturn {
        return (self.vtable.end)(self);
    }
    pub fn getData(self: *IDeviceContext) noreturn {
        return (self.vtable.get_data)(self);
    }
    pub fn setPredication(self: *IDeviceContext) noreturn {
        return (self.vtable.set_predication)(self);
    }
    pub fn gsSetShaderResources(self: *IDeviceContext) noreturn {
        return (self.vtable.gs_set_shader_resources)(self);
    }
    pub fn gsSetSamplers(self: *IDeviceContext) noreturn {
        return (self.vtable.gs_set_samplers)(self);
    }
    pub fn omSetRenderTargets(self: *IDeviceContext, num: u32, render_target_views: ?[*]const *IRenderTargetView, depth_stencil_view: ?*IDepthStencilView) void {
        return (self.vtable.om_set_render_targets)(self, num, render_target_views, depth_stencil_view);
    }
    pub fn omSetRenderTargetsAndUnorderedAccessViews(self: *IDeviceContext) noreturn {
        return (self.vtable.om_set_render_targets_and_unordered_access_views)(self);
    }
    pub fn omSetBlendState(self: *IDeviceContext, state: ?*IBlendState, factor: ?*const [4]f32, sample_mask: u32) void {
        return (self.vtable.om_set_blend_state)(self, state, factor, sample_mask);
    }
    pub fn omSetDepthStencilState(self: *IDeviceContext, state: ?*IDepthStencilState, stencil_ref: u32) void {
        return (self.vtable.om_set_depth_stencil_state)(self, state, stencil_ref);
    }
    pub fn soSetTargets(self: *IDeviceContext) noreturn {
        return (self.vtable.so_set_targets)(self);
    }
    pub fn drawAuto(self: *IDeviceContext) noreturn {
        return (self.vtable.draw_auto)(self);
    }
    pub fn drawIndexedInstancedIndirect(self: *IDeviceContext) noreturn {
        return (self.vtable.draw_indexed_instanced_indirect)(self);
    }
    pub fn drawInstancedIndirect(self: *IDeviceContext) noreturn {
        return (self.vtable.draw_instanced_indirect)(self);
    }
    pub fn dispatch(self: *IDeviceContext) noreturn {
        return (self.vtable.dispatch)(self);
    }
    pub fn dispatchIndirect(self: *IDeviceContext) noreturn {
        return (self.vtable.dispatch_indirect)(self);
    }
    pub fn rsSetState(self: *IDeviceContext, state: ?*IRasterizerState) void {
        return (self.vtable.rs_set_state)(self, state);
    }
    pub fn rsSetViewports(self: *IDeviceContext, num: u32, viewports: ?[*]const VIEWPORT) void {
        return (self.vtable.rs_set_viewports)(self, num, viewports);
    }
    pub fn rsSetScissorRects(self: *IDeviceContext, num: u32, rects: ?[*]const RECT) void {
        return (self.vtable.rs_set_scissor_rects)(self, num, rects);
    }
    pub fn copySubresourceRegion(self: *IDeviceContext) noreturn {
        return (self.vtable.copy_subresource_region)(self);
    }
    pub fn copyResource(self: *IDeviceContext) noreturn {
        return (self.vtable.copy_resource)(self);
    }
    pub fn updateSubresource(self: *IDeviceContext) noreturn {
        return (self.vtable.update_subresource)(self);
    }
    pub fn copyStructureCount(self: *IDeviceContext) noreturn {
        return (self.vtable.copy_structure_count)(self);
    }
    pub fn clearRenderTargetView(self: *IDeviceContext, target: *IRenderTargetView, color: *const [4]f32) void {
        return (self.vtable.clear_render_target_view)(self, target, color);
    }
    pub fn clearUnorderedAccessViewUint(self: *IDeviceContext) noreturn {
        return (self.vtable.clear_unordered_access_view_uint)(self);
    }
    pub fn clearUnorderedAccessViewFloat(self: *IDeviceContext) noreturn {
        return (self.vtable.clear_unordered_access_view_float)(self);
    }
    pub fn clearDepthStencilView(self: *IDeviceContext) noreturn {
        return (self.vtable.clear_depth_stencil_view)(self);
    }
    pub fn generateMips(self: *IDeviceContext) noreturn {
        return (self.vtable.generate_mips)(self);
    }
    pub fn setResourceMinLod(self: *IDeviceContext) noreturn {
        return (self.vtable.set_resource_min_lod)(self);
    }
    pub fn getResourceMinLod(self: *IDeviceContext) noreturn {
        return (self.vtable.get_resource_min_lod)(self);
    }
    pub fn resolveSubresource(self: *IDeviceContext) noreturn {
        return (self.vtable.resolve_subresource)(self);
    }
    pub fn executeCommandList(self: *IDeviceContext, command_list: *ICommandList, restore: BOOL) void {
        return (self.vtable.execute_command_list)(self, command_list, restore);
    }
    pub fn hsSetShaderResources(self: *IDeviceContext) noreturn {
        return (self.vtable.hs_set_shader_resources)(self);
    }
    pub fn hsSetShader(self: *IDeviceContext) noreturn {
        return (self.vtable.hs_set_shader)(self);
    }
    pub fn hsSetSamplers(self: *IDeviceContext) noreturn {
        return (self.vtable.hs_set_samplers)(self);
    }
    pub fn hsSetConstantBuffers(self: *IDeviceContext) noreturn {
        return (self.vtable.hs_set_constant_buffers)(self);
    }
    pub fn dsSetShaderResources(self: *IDeviceContext) noreturn {
        return (self.vtable.ds_set_shader_resources)(self);
    }
    pub fn dsSetShader(self: *IDeviceContext) noreturn {
        return (self.vtable.ds_set_shader)(self);
    }
    pub fn dsSetSamplers(self: *IDeviceContext) noreturn {
        return (self.vtable.ds_set_samplers)(self);
    }
    pub fn dsSetConstantBuffers(self: *IDeviceContext) noreturn {
        return (self.vtable.ds_set_constant_buffers)(self);
    }
    pub fn csSetShaderResources(self: *IDeviceContext) noreturn {
        return (self.vtable.cs_set_shader_resources)(self);
    }
    pub fn csSetUnorderedAccessViews(self: *IDeviceContext) noreturn {
        return (self.vtable.cs_set_unordered_access_views)(self);
    }
    pub fn csSetShader(self: *IDeviceContext) noreturn {
        return (self.vtable.cs_set_shader)(self);
    }
    pub fn csSetSamplers(self: *IDeviceContext) noreturn {
        return (self.vtable.cs_set_samplers)(self);
    }
    pub fn csSetConstantBuffers(self: *IDeviceContext) noreturn {
        return (self.vtable.cs_set_constant_buffers)(self);
    }
    pub fn vsGetConstantBuffers(self: *IDeviceContext) noreturn {
        return (self.vtable.vs_get_constant_buffers)(self);
    }
    pub fn psGetShaderResources(self: *IDeviceContext) noreturn {
        return (self.vtable.ps_get_shader_resources)(self);
    }
    pub fn psGetShader(self: *IDeviceContext) noreturn {
        return (self.vtable.ps_get_shader)(self);
    }
    pub fn psGetSamplers(self: *IDeviceContext) noreturn {
        return (self.vtable.ps_get_samplers)(self);
    }
    pub fn vsGetShader(self: *IDeviceContext) noreturn {
        return (self.vtable.vs_get_shader)(self);
    }
    pub fn psGetConstantBuffers(self: *IDeviceContext) noreturn {
        return (self.vtable.ps_get_constant_buffers)(self);
    }
    pub fn iaGetInputLayout(self: *IDeviceContext) noreturn {
        return (self.vtable.ia_get_input_layout)(self);
    }
    pub fn iaGetVertexBuffers(self: *IDeviceContext) noreturn {
        return (self.vtable.ia_get_vertex_buffers)(self);
    }
    pub fn iaGetIndexBuffer(self: *IDeviceContext) noreturn {
        return (self.vtable.ia_get_index_buffer)(self);
    }
    pub fn gsGetConstantBuffers(self: *IDeviceContext) noreturn {
        return (self.vtable.gs_get_constant_buffers)(self);
    }
    pub fn gsGetShader(self: *IDeviceContext) noreturn {
        return (self.vtable.gs_get_shader)(self);
    }
    pub fn iaGetPrimitiveTopology(self: *IDeviceContext) noreturn {
        return (self.vtable.ia_get_primitive_topology)(self);
    }
    pub fn vsGetShaderResources(self: *IDeviceContext) noreturn {
        return (self.vtable.vs_get_shader_resources)(self);
    }
    pub fn vsGetSamplers(self: *IDeviceContext) noreturn {
        return (self.vtable.vs_get_samplers)(self);
    }
    pub fn getPredication(self: *IDeviceContext) noreturn {
        return (self.vtable.get_predication)(self);
    }
    pub fn gsGetShaderResources(self: *IDeviceContext) noreturn {
        return (self.vtable.gs_get_shader_resources)(self);
    }
    pub fn gsGetSamplers(self: *IDeviceContext) noreturn {
        return (self.vtable.gs_get_samplers)(self);
    }
    pub fn omGetRenderTargets(self: *IDeviceContext) noreturn {
        return (self.vtable.om_get_render_targets)(self);
    }
    pub fn omGetRenderTargetsAndUnorderedAccessViews(self: *IDeviceContext) noreturn {
        return (self.vtable.om_get_render_targets_and_unordered_access_views)(self);
    }
    pub fn omGetBlendState(self: *IDeviceContext) noreturn {
        return (self.vtable.om_get_blend_state)(self);
    }
    pub fn omGetDepthStencilState(self: *IDeviceContext) noreturn {
        return (self.vtable.om_get_depth_stencil_state)(self);
    }
    pub fn soGetTargets(self: *IDeviceContext) noreturn {
        return (self.vtable.so_get_targets)(self);
    }
    pub fn rsGetState(self: *IDeviceContext) noreturn {
        return (self.vtable.rs_get_state)(self);
    }
    pub fn rsGetViewports(self: *IDeviceContext) noreturn {
        return (self.vtable.rs_get_viewports)(self);
    }
    pub fn rsGetScissorRects(self: *IDeviceContext) noreturn {
        return (self.vtable.rs_get_scissor_rects)(self);
    }
    pub fn hsGetShaderResources(self: *IDeviceContext) noreturn {
        return (self.vtable.hs_get_shader_resources)(self);
    }
    pub fn hsGetShader(self: *IDeviceContext) noreturn {
        return (self.vtable.hs_get_shader)(self);
    }
    pub fn hsGetSamplers(self: *IDeviceContext) noreturn {
        return (self.vtable.hs_get_samplers)(self);
    }
    pub fn hsGetConstantBuffers(self: *IDeviceContext) noreturn {
        return (self.vtable.hs_get_constant_buffers)(self);
    }
    pub fn dsGetShaderResources(self: *IDeviceContext) noreturn {
        return (self.vtable.ds_get_shader_resources)(self);
    }
    pub fn dsGetShader(self: *IDeviceContext) noreturn {
        return (self.vtable.ds_get_shader)(self);
    }
    pub fn dsGetSamplers(self: *IDeviceContext) noreturn {
        return (self.vtable.ds_get_samplers)(self);
    }
    pub fn dsGetConstantBuffers(self: *IDeviceContext) noreturn {
        return (self.vtable.ds_get_constant_buffers)(self);
    }
    pub fn csGetShaderResources(self: *IDeviceContext) noreturn {
        return (self.vtable.cs_get_shader_resources)(self);
    }
    pub fn csGetUnorderedAccessViews(self: *IDeviceContext) noreturn {
        return (self.vtable.cs_get_unordered_access_views)(self);
    }
    pub fn csGetShader(self: *IDeviceContext) noreturn {
        return (self.vtable.cs_get_shader)(self);
    }
    pub fn csGetSamplers(self: *IDeviceContext) noreturn {
        return (self.vtable.cs_get_samplers)(self);
    }
    pub fn csGetConstantBuffers(self: *IDeviceContext) noreturn {
        return (self.vtable.cs_get_constant_buffers)(self);
    }
    pub fn clearState(self: *IDeviceContext) noreturn {
        return (self.vtable.clear_state)(self);
    }
    pub fn flush(self: *IDeviceContext) noreturn {
        return (self.vtable.flush)(self);
    }
    pub fn getType(self: *IDeviceContext) noreturn {
        return (self.vtable.get_type)(self);
    }
    pub fn getContextFlags(self: *IDeviceContext) noreturn {
        return (self.vtable.get_context_flags)(self);
    }
    pub fn finishCommandList(self: *IDeviceContext, restore: BOOL, command_list: *?*ICommandList) HRESULT {
        return (self.vtable.finish_command_list)(self, restore, command_list);
    }
    // IDeviceChild methods
    pub fn getDevice(self: *IDeviceContext, device: *?*IDevice) void {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), device);
    }
    pub fn getPrivateData(self: *IDeviceContext) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IDeviceContext) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IDeviceContext) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IDeviceContext, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IDeviceContext) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IDeviceContext) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const ICommandList = extern struct {
    pub const IID = GUID.parse("{A24BC4D1-769E-43F7-8013-98FF566C18E2}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IDeviceChild.VTable,
        get_context_flags: *const fn (*ICommandList) callconv(.winapi) u32,
    };

    pub fn getContextFlags(self: *ICommandList) u32 {
        return (self.vtable.get_context_flags)(self);
    }
    // IDeviceChild methods
    pub fn getDevice(self: *ICommandList, device: *?*IDevice) void {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), device);
    }
    pub fn getPrivateData(self: *ICommandList) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *ICommandList) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *ICommandList) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *ICommandList, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *ICommandList) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *ICommandList) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IResource = extern struct {
    pub const IID = GUID.parse("{696442BE-A72E-4059-BC79-5B5C98040FAD}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IDeviceChild.VTable,
        get_type: *const fn (*IResource) callconv(.winapi) noreturn,
        set_eviction_priority: *const fn (*IResource) callconv(.winapi) noreturn,
        get_eviction_priority: *const fn (*IResource) callconv(.winapi) noreturn,
    };

    pub fn getType(self: *IResource) noreturn {
        return (self.vtable.get_type)(self);
    }
    pub fn setEvictionPriority(self: *IResource) noreturn {
        return (self.vtable.set_eviction_priority)(self);
    }
    pub fn getEvictionPriority(self: *IResource) noreturn {
        return (self.vtable.get_eviction_priority)(self);
    }
    // IDeviceChild methods
    pub fn getDevice(self: *IResource, device: *?*IDevice) void {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), device);
    }
    pub fn getPrivateData(self: *IResource) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IResource) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IResource) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IResource, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IResource) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IResource) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const ITexture2D = extern struct {
    pub const IID = GUID.parse("{6F15AAF2-D208-4E89-9AB4-489535D34F9C}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IResource.VTable,
        get_desc: *const fn (*ITexture2D) callconv(.winapi) noreturn,
    };

    pub fn getDesc(self: *ITexture2D) noreturn {
        return (self.vtable.get_desc)(self);
    }
    // IResource methods
    pub fn getType(self: *ITexture2D) noreturn {
        return (@as(*const IResource.VTable, @ptrCast(self.vtable)).get_type)(@ptrCast(self));
    }
    pub fn setEvictionPriority(self: *ITexture2D) noreturn {
        return (@as(*const IResource.VTable, @ptrCast(self.vtable)).set_eviction_priority)(@ptrCast(self));
    }
    pub fn getEvictionPriority(self: *ITexture2D) noreturn {
        return (@as(*const IResource.VTable, @ptrCast(self.vtable)).get_eviction_priority)(@ptrCast(self));
    }
    // IDeviceChild methods
    pub fn getDevice(self: *ITexture2D, device: *?*IDevice) void {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), device);
    }
    pub fn getPrivateData(self: *ITexture2D) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *ITexture2D) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *ITexture2D) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *ITexture2D, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *ITexture2D) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *ITexture2D) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IView = extern struct {
    pub const IID = GUID.parse("{839D1216-BB2E-412B-B7F4-A9DBEBE08ED1}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IDeviceChild.VTable,
        get_resource: *const fn (*IView) callconv(.winapi) noreturn,
    };

    pub fn getResource(self: *IView) noreturn {
        return (self.vtable.get_resource)(self);
    }
    // IDeviceChild methods
    pub fn getDevice(self: *IView, device: *?*IDevice) void {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), device);
    }
    pub fn getPrivateData(self: *IView) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IView) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IView) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IView, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IView) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IView) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IRenderTargetView = extern struct {
    pub const IID = GUID.parse("{DFDBA067-0B8D-4865-875B-D7B4516CC164}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IView.VTable,
        get_desc: *const fn (*IRenderTargetView) callconv(.winapi) noreturn,
    };

    pub fn getDesc(self: *IRenderTargetView) noreturn {
        return (self.vtable.get_desc)(self);
    }
    // IView methods
    pub fn getResource(self: *IRenderTargetView) noreturn {
        return (@as(*const IView.VTable, @ptrCast(self.vtable)).get_resource)(@ptrCast(self));
    }
    // IDeviceChild methods
    pub fn getDevice(self: *IRenderTargetView, device: *?*IDevice) void {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), device);
    }
    pub fn getPrivateData(self: *IRenderTargetView) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IRenderTargetView) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IRenderTargetView) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IRenderTargetView, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IRenderTargetView) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IRenderTargetView) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IDepthStencilView = extern struct {
    pub const IID = GUID.parse("{9FDAC92A-1876-48C3-AFAD-25B94F84A9B6}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IView.VTable,
        get_desc: *const fn (*IDepthStencilView) callconv(.winapi) noreturn,
    };

    pub fn getDesc(self: *IDepthStencilView) noreturn {
        return (self.vtable.get_desc)(self);
    }
    // IView methods
    pub fn getResource(self: *IDepthStencilView) noreturn {
        return (@as(*const IView.VTable, @ptrCast(self.vtable)).get_resource)(@ptrCast(self));
    }
    // IDeviceChild methods
    pub fn getDevice(self: *IDepthStencilView, device: *?*IDevice) void {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), device);
    }
    pub fn getPrivateData(self: *IDepthStencilView) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IDepthStencilView) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IDepthStencilView) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IDepthStencilView, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IDepthStencilView) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IDepthStencilView) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IDebug = extern struct {
    pub const IID = GUID.parse("{79CF2233-7536-4948-9D36-1E4692DC5760}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IUnknown.VTable,
        set_feature_mask: *const fn (*IDebug, mask: DEBUG_FEATURES) callconv(.winapi) HRESULT,
        get_feature_mask: *const fn (*IDebug) callconv(.winapi) DEBUG_FEATURES,
        set_present_per_render_op_delay: *const fn (*IDebug, milliseconds: u32) callconv(.winapi) HRESULT,
        get_present_per_render_op_delay: *const fn (*IDebug) callconv(.winapi) u32,
        set_swap_chain: *const fn (*IDebug, swapchain: *dxgi.ISwapChain) callconv(.winapi) HRESULT,
        get_swap_chain: *const fn (*IDebug, swapchain: *?*dxgi.ISwapChain) callconv(.winapi) HRESULT,
        validate_context: *const fn (*IDebug, context: *IDeviceContext) callconv(.winapi) HRESULT,
        report_live_device_objects: *const fn (*IDebug, flags: RLDO_FLAGS) callconv(.winapi) HRESULT,
        validate_context_for_dispatch: *const fn (*IDebug, context: *IDeviceContext) callconv(.winapi) HRESULT,
    };

    pub fn setFeatureMask(self: *IDebug, mask: DEBUG_FEATURES) HRESULT {
        return (self.vtable.set_feature_mask)(self, mask);
    }
    pub fn getFeatureMask(self: *IDebug) DEBUG_FEATURES {
        return (self.vtable.get_feature_mask)(self);
    }
    pub fn setPresentPerRenderOpDelay(self: *IDebug, milliseconds: u32) HRESULT {
        return (self.vtable.set_present_per_render_op_delay)(self, milliseconds);
    }
    pub fn getPresentPerRenderOpDelay(self: *IDebug) u32 {
        return (self.vtable.get_present_per_render_op_delay)(self);
    }
    pub fn setSwapChain(self: *IDebug, swapchain: *dxgi.ISwapChain) HRESULT {
        return (self.vtable.set_swap_chain)(self, swapchain);
    }
    pub fn getSwapChain(self: *IDebug, swapchain: *?*dxgi.ISwapChain) HRESULT {
        return (self.vtable.get_swap_chain)(self, swapchain);
    }
    pub fn validateContext(self: *IDebug, context: *IDeviceContext) HRESULT {
        return (self.vtable.validate_context)(self, context);
    }
    pub fn reportLiveDeviceObjects(self: *IDebug, flags: RLDO_FLAGS) HRESULT {
        return (self.vtable.report_live_device_objects)(self, flags);
    }
    pub fn validateContextForDispatch(self: *IDebug, context: *IDeviceContext) HRESULT {
        return (self.vtable.validate_context_for_dispatch)(self, context);
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

pub const IInfoQueue = extern struct {
    pub const IID = GUID.parse("{6543DBB6-1B48-42F5-AB82-E97EC74326F6}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IUnknown.VTable,
        set_message_count_limit: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        clear_stored_messages: *const fn (*IInfoQueue) callconv(.winapi) void,
        get_message: *const fn (*IInfoQueue, index: u64, message: ?*MESSAGE, length: *SIZE_T) callconv(.winapi) HRESULT,
        get_num_messages_allowed_by_storage_filter: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        get_num_messages_denied_by_storage_filter: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        get_num_stored_messages: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        get_num_stored_messages_allowed_by_retrieval_filter: *const fn (*IInfoQueue) callconv(.winapi) u64,
        get_num_messages_discarded_by_message_count_limit: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        get_message_count_limit: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        add_storage_filter_entries: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        get_storage_filter: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        clear_storage_filter: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        push_empty_storage_filter: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        push_copy_of_storage_filter: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        push_storage_filter: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        pop_storage_filter: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        get_storage_filter_stack_size: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        add_retrieval_filter_entries: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        get_retrieval_filter: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        clear_retrieval_filter: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        push_empty_retrieval_filter: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        push_copy_of_retrieval_filter: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        push_retrieval_filter: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        pop_retrieval_filter: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        get_retrieval_filter_stack_size: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        add_message: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        add_application_message: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        set_break_on_category: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        set_break_on_severity: *const fn (*IInfoQueue, severity: MESSAGE_SEVERITY, enable: BOOL) callconv(.winapi) HRESULT,
        set_break_on_i_d: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        get_break_on_category: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        get_break_on_severity: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        get_break_on_i_d: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        set_mute_debug_output: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
        get_mute_debug_output: *const fn (*IInfoQueue) callconv(.winapi) noreturn,
    };

    pub fn setMessageCountLimit(self: *IInfoQueue) noreturn {
        return (self.vtable.set_message_count_limit)(self);
    }
    pub fn clearStoredMessages(self: *IInfoQueue) void {
        return (self.vtable.clear_stored_messages)(self);
    }
    pub fn getMessage(self: *IInfoQueue, index: u64, message: ?*MESSAGE, length: *SIZE_T) HRESULT {
        return (self.vtable.get_message)(self, index, message, length);
    }
    pub fn getNumMessagesAllowedByStorageFilter(self: *IInfoQueue) noreturn {
        return (self.vtable.get_num_messages_allowed_by_storage_filter)(self);
    }
    pub fn getNumMessagesDeniedByStorageFilter(self: *IInfoQueue) noreturn {
        return (self.vtable.get_num_messages_denied_by_storage_filter)(self);
    }
    pub fn getNumStoredMessages(self: *IInfoQueue) noreturn {
        return (self.vtable.get_num_stored_messages)(self);
    }
    pub fn getNumStoredMessagesAllowedByRetrievalFilter(self: *IInfoQueue) u64 {
        return (self.vtable.get_num_stored_messages_allowed_by_retrieval_filter)(self);
    }
    pub fn getNumMessagesDiscardedByMessageCountLimit(self: *IInfoQueue) noreturn {
        return (self.vtable.get_num_messages_discarded_by_message_count_limit)(self);
    }
    pub fn getMessageCountLimit(self: *IInfoQueue) noreturn {
        return (self.vtable.get_message_count_limit)(self);
    }
    pub fn addStorageFilterEntries(self: *IInfoQueue) noreturn {
        return (self.vtable.add_storage_filter_entries)(self);
    }
    pub fn getStorageFilter(self: *IInfoQueue) noreturn {
        return (self.vtable.get_storage_filter)(self);
    }
    pub fn clearStorageFilter(self: *IInfoQueue) noreturn {
        return (self.vtable.clear_storage_filter)(self);
    }
    pub fn pushEmptyStorageFilter(self: *IInfoQueue) noreturn {
        return (self.vtable.push_empty_storage_filter)(self);
    }
    pub fn pushCopyOfStorageFilter(self: *IInfoQueue) noreturn {
        return (self.vtable.push_copy_of_storage_filter)(self);
    }
    pub fn pushStorageFilter(self: *IInfoQueue) noreturn {
        return (self.vtable.push_storage_filter)(self);
    }
    pub fn popStorageFilter(self: *IInfoQueue) noreturn {
        return (self.vtable.pop_storage_filter)(self);
    }
    pub fn getStorageFilterStackSize(self: *IInfoQueue) noreturn {
        return (self.vtable.get_storage_filter_stack_size)(self);
    }
    pub fn addRetrievalFilterEntries(self: *IInfoQueue) noreturn {
        return (self.vtable.add_retrieval_filter_entries)(self);
    }
    pub fn getRetrievalFilter(self: *IInfoQueue) noreturn {
        return (self.vtable.get_retrieval_filter)(self);
    }
    pub fn clearRetrievalFilter(self: *IInfoQueue) noreturn {
        return (self.vtable.clear_retrieval_filter)(self);
    }
    pub fn pushEmptyRetrievalFilter(self: *IInfoQueue) noreturn {
        return (self.vtable.push_empty_retrieval_filter)(self);
    }
    pub fn pushCopyOfRetrievalFilter(self: *IInfoQueue) noreturn {
        return (self.vtable.push_copy_of_retrieval_filter)(self);
    }
    pub fn pushRetrievalFilter(self: *IInfoQueue) noreturn {
        return (self.vtable.push_retrieval_filter)(self);
    }
    pub fn popRetrievalFilter(self: *IInfoQueue) noreturn {
        return (self.vtable.pop_retrieval_filter)(self);
    }
    pub fn getRetrievalFilterStackSize(self: *IInfoQueue) noreturn {
        return (self.vtable.get_retrieval_filter_stack_size)(self);
    }
    pub fn addMessage(self: *IInfoQueue) noreturn {
        return (self.vtable.add_message)(self);
    }
    pub fn addApplicationMessage(self: *IInfoQueue) noreturn {
        return (self.vtable.add_application_message)(self);
    }
    pub fn setBreakOnCategory(self: *IInfoQueue) noreturn {
        return (self.vtable.set_break_on_category)(self);
    }
    pub fn setBreakOnSeverity(self: *IInfoQueue, severity: MESSAGE_SEVERITY, enable: BOOL) HRESULT {
        return (self.vtable.set_break_on_severity)(self, severity, enable);
    }
    pub fn setBreakOnID(self: *IInfoQueue) noreturn {
        return (self.vtable.set_break_on_i_d)(self);
    }
    pub fn getBreakOnCategory(self: *IInfoQueue) noreturn {
        return (self.vtable.get_break_on_category)(self);
    }
    pub fn getBreakOnSeverity(self: *IInfoQueue) noreturn {
        return (self.vtable.get_break_on_severity)(self);
    }
    pub fn getBreakOnID(self: *IInfoQueue) noreturn {
        return (self.vtable.get_break_on_i_d)(self);
    }
    pub fn setMuteDebugOutput(self: *IInfoQueue) noreturn {
        return (self.vtable.set_mute_debug_output)(self);
    }
    pub fn getMuteDebugOutput(self: *IInfoQueue) noreturn {
        return (self.vtable.get_mute_debug_output)(self);
    }
    // IUnknown methods
    pub fn queryInterface(self: *IInfoQueue, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IInfoQueue) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IInfoQueue) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IPixelShader = extern struct {
    pub const IID = GUID.parse("{EA82E40D-51DC-4F33-93D4-DB7C9125AE8C}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IDeviceChild.VTable,
        get_desc: *const fn (*IPixelShader) callconv(.winapi) noreturn,
    };

    pub fn getDesc(self: *IPixelShader) noreturn {
        return (self.vtable.get_desc)(self);
    }
    // IDeviceChild methods
    pub fn getDevice(self: *IPixelShader, device: *?*IDevice) void {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), device);
    }
    pub fn getPrivateData(self: *IPixelShader) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IPixelShader) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IPixelShader) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IPixelShader, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IPixelShader) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IPixelShader) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IVertexShader = extern struct {
    pub const IID = GUID.parse("{3B301D64-D678-4289-8897-22F8928B72F3}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IDeviceChild.VTable,
        get_desc: *const fn (*IVertexShader) callconv(.winapi) noreturn,
    };

    pub fn getDesc(self: *IVertexShader) noreturn {
        return (self.vtable.get_desc)(self);
    }
    // IDeviceChild methods
    pub fn getDevice(self: *IVertexShader, device: *?*IDevice) void {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), device);
    }
    pub fn getPrivateData(self: *IVertexShader) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IVertexShader) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IVertexShader) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IVertexShader, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IVertexShader) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IVertexShader) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IClassInstance = extern struct {
    pub const IID = GUID.parse("{A6CD7FAA-B0B7-4A2F-9436-8662A65797CB}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IDeviceChild.VTable,
        get_class_linkange: *const fn (*IClassInstance) callconv(.winapi) noreturn,
        get_desc: *const fn (*IClassInstance) callconv(.winapi) noreturn,
        get_instance_name: *const fn (*IClassInstance) callconv(.winapi) noreturn,
        get_type_name: *const fn (*IClassInstance) callconv(.winapi) noreturn,
    };

    pub fn getClassLinkange(self: *IClassInstance) noreturn {
        return (self.vtable.get_class_linkange)(self);
    }
    pub fn getDesc(self: *IClassInstance) noreturn {
        return (self.vtable.get_desc)(self);
    }
    pub fn getInstanceName(self: *IClassInstance) noreturn {
        return (self.vtable.get_instance_name)(self);
    }
    pub fn getTypeName(self: *IClassInstance) noreturn {
        return (self.vtable.get_type_name)(self);
    }
    // IDeviceChild methods
    pub fn getDevice(self: *IClassInstance, device: *?*IDevice) void {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), device);
    }
    pub fn getPrivateData(self: *IClassInstance) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IClassInstance) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IClassInstance) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IClassInstance, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IClassInstance) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IClassInstance) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IBlendState = extern struct {
    pub const IID = GUID.parse("{75B68FAA-347D-4159-8F45-A0640F01CD9A}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IDeviceChild.VTable,
        get_desc: *const fn (*IBlendState) callconv(.winapi) noreturn,
    };

    pub fn getDesc(self: *IBlendState) noreturn {
        return (self.vtable.get_desc)(self);
    }
    // IDeviceChild methods
    pub fn getDevice(self: *IBlendState, device: *?*IDevice) void {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), device);
    }
    pub fn getPrivateData(self: *IBlendState) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IBlendState) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IBlendState) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IBlendState, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IBlendState) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IBlendState) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IDepthStencilState = extern struct {
    pub const IID = GUID.parse("{03823EFB-8D8F-4E1C-9AA2-F64BB2CBFDF1}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IDeviceChild.VTable,
        get_desc: *const fn (*IDepthStencilState) callconv(.winapi) noreturn,
    };

    pub fn getDesc(self: *IDepthStencilState) noreturn {
        return (self.vtable.get_desc)(self);
    }
    // IDeviceChild methods
    pub fn getDevice(self: *IDepthStencilState, device: *?*IDevice) void {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), device);
    }
    pub fn getPrivateData(self: *IDepthStencilState) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IDepthStencilState) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IDepthStencilState) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IDepthStencilState, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IDepthStencilState) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IDepthStencilState) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IRasterizerState = extern struct {
    pub const IID = GUID.parse("{9bb4ab81-ab1a-4d8f-b506-fc04200b6ee7}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IDeviceChild.VTable,
        get_desc: *const fn (*IRasterizerState) callconv(.winapi) noreturn,
    };

    pub fn getDesc(self: *IRasterizerState) noreturn {
        return (self.vtable.get_desc)(self);
    }
    // IDeviceChild methods
    pub fn getDevice(self: *IRasterizerState, device: *?*IDevice) void {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), device);
    }
    pub fn getPrivateData(self: *IRasterizerState) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IRasterizerState) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IRasterizerState) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IRasterizerState, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IRasterizerState) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IRasterizerState) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IClassLinkage = extern struct {
    pub const IID = GUID.parse("{DDF57CBA-9543-46E4-A12B-F207A0FE7FED}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IDeviceChild.VTable,
        get_class_instance: *const fn (*IClassLinkage) callconv(.winapi) noreturn,
        create_class_instance: *const fn (*IClassLinkage) callconv(.winapi) noreturn,
    };

    pub fn getClassInstance(self: *IClassLinkage) noreturn {
        return (self.vtable.get_class_instance)(self);
    }
    pub fn createClassInstance(self: *IClassLinkage) noreturn {
        return (self.vtable.create_class_instance)(self);
    }
    // IDeviceChild methods
    pub fn getDevice(self: *IClassLinkage, device: *?*IDevice) void {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), device);
    }
    pub fn getPrivateData(self: *IClassLinkage) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IClassLinkage) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IClassLinkage) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IClassLinkage, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IClassLinkage) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IClassLinkage) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IInputLayout = extern struct {
    pub const IID = GUID.parse("{E4819DDC-4CF0-4025-BD26-5DE82A3E07B7}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IDeviceChild.VTable,
        get_desc: *const fn (*IInputLayout) callconv(.winapi) noreturn,
    };

    pub fn getDesc(self: *IInputLayout) noreturn {
        return (self.vtable.get_desc)(self);
    }
    // IDeviceChild methods
    pub fn getDevice(self: *IInputLayout, device: *?*IDevice) void {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), device);
    }
    pub fn getPrivateData(self: *IInputLayout) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IInputLayout) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IInputLayout) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IInputLayout, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IInputLayout) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IInputLayout) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IBuffer = extern struct {
    pub const IID = GUID.parse("{}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IResource.VTable,
    };
    // IResource methods
    pub fn getType(self: *IBuffer) noreturn {
        return (@as(*const IResource.VTable, @ptrCast(self.vtable)).get_type)(@ptrCast(self));
    }
    pub fn setEvictionPriority(self: *IBuffer) noreturn {
        return (@as(*const IResource.VTable, @ptrCast(self.vtable)).set_eviction_priority)(@ptrCast(self));
    }
    pub fn getEvictionPriority(self: *IBuffer) noreturn {
        return (@as(*const IResource.VTable, @ptrCast(self.vtable)).get_eviction_priority)(@ptrCast(self));
    }
    // IDeviceChild methods
    pub fn getDevice(self: *IBuffer, device: *?*IDevice) void {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), device);
    }
    pub fn getPrivateData(self: *IBuffer) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IBuffer) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IBuffer) noreturn {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IBuffer, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IBuffer) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IBuffer) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};
