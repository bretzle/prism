const std = @import("std");
const w32 = @import("windows.zig");
const dxgi = @import("dxgi.zig");
const os = std.os.windows;

const GUID = w32.GUID;
const HRESULT = w32.HRESULT;
const SIZE_T = w32.SIZE_T;
const UINT = w32.UINT;
const FLOAT = os.FLOAT;
const BOOL = w32.BOOL;
const INT = w32.INT;
const ULONG = w32.ULONG;
const RECT = w32.RECT;
const UINT64 = u64;
const UINT16 = u16;
const UINT8 = u8;
const HANDLE = w32.HANDLE;

pub const IUnknown = w32.IUnknown;
pub const IObject = w32.IObject;

pub const GPU_VIRTUAL_ADDRESS = UINT64;

pub const CPU_DESCRIPTOR_HANDLE = extern struct {
    ptr: UINT64,
};

pub const GPU_DESCRIPTOR_HANDLE = extern struct {
    ptr: UINT64,
};

pub const FEATURE_LEVEL = enum(u32) {
    @"1_0_CORE" = 0x1000,
    @"9_1" = 0x9100,
    @"9_2" = 0x9200,
    @"9_3" = 0x9300,
    @"10_0" = 0xA000,
    @"10_1" = 0xA100,
    @"11_0" = 0xB000,
    @"11_1" = 0xB100,
    @"12_0" = 0xC000,
    @"12_1" = 0xC100,
    @"12_2" = 0xC200,
};

pub const PRIMITIVE_TOPOLOGY = enum(UINT) {
    UNDEFINED = 0,
    POINTLIST = 1,
    LINELIST = 2,
    LINESTRIP = 3,
    TRIANGLELIST = 4,
    TRIANGLESTRIP = 5,
    LINELIST_ADJ = 10,
    LINESTRIP_ADJ = 11,
    TRIANGLELIST_ADJ = 12,
    TRIANGLESTRIP_ADJ = 13,
    CONTROL_POINT_PATCHLIST = 33,
    @"2_CONTROL_POINT_PATCHLIST" = 34,
    @"3_CONTROL_POINT_PATCHLIST" = 35,
    @"4_CONTROL_POINT_PATCHLIST" = 36,
    @"5_CONTROL_POINT_PATCHLIST" = 37,
    @"6_CONTROL_POINT_PATCHLIST" = 38,
    @"7_CONTROL_POINT_PATCHLIST" = 39,
    @"8_CONTROL_POINT_PATCHLIST" = 40,
    @"9_CONTROL_POINT_PATCHLIST" = 41,
    @"10_CONTROL_POINT_PATCHLIST" = 42,
    @"11_CONTROL_POINT_PATCHLIST" = 43,
    @"12_CONTROL_POINT_PATCHLIST" = 44,
    @"13_CONTROL_POINT_PATCHLIST" = 45,
    @"14_CONTROL_POINT_PATCHLIST" = 46,
    @"15_CONTROL_POINT_PATCHLIST" = 47,
    @"16_CONTROL_POINT_PATCHLIST" = 48,
    @"17_CONTROL_POINT_PATCHLIST" = 49,
    @"18_CONTROL_POINT_PATCHLIST" = 50,
    @"19_CONTROL_POINT_PATCHLIST" = 51,
    @"20_CONTROL_POINT_PATCHLIST" = 52,
    @"21_CONTROL_POINT_PATCHLIST" = 53,
    @"22_CONTROL_POINT_PATCHLIST" = 54,
    @"23_CONTROL_POINT_PATCHLIST" = 55,
    @"24_CONTROL_POINT_PATCHLIST" = 56,
    @"25_CONTROL_POINT_PATCHLIST" = 57,
    @"26_CONTROL_POINT_PATCHLIST" = 58,
    @"27_CONTROL_POINT_PATCHLIST" = 59,
    @"28_CONTROL_POINT_PATCHLIST" = 60,
    @"29_CONTROL_POINT_PATCHLIST" = 61,
    @"30_CONTROL_POINT_PATCHLIST" = 62,
    @"31_CONTROL_POINT_PATCHLIST" = 63,
    @"32_CONTROL_POINT_PATCHLIST" = 64,
};

pub const FILTER = enum(UINT) {
    MIN_MAG_MIP_POINT = 0,
    MIN_MAG_POINT_MIP_LINEAR = 0x1,
    MIN_POINT_MAG_LINEAR_MIP_POINT = 0x4,
    MIN_POINT_MAG_MIP_LINEAR = 0x5,
    MIN_LINEAR_MAG_MIP_POINT = 0x10,
    MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x11,
    MIN_MAG_LINEAR_MIP_POINT = 0x14,
    MIN_MAG_MIP_LINEAR = 0x15,
    ANISOTROPIC = 0x55,
    COMPARISON_MIN_MAG_MIP_POINT = 0x80,
    COMPARISON_MIN_MAG_POINT_MIP_LINEAR = 0x81,
    COMPARISON_MIN_POINT_MAG_LINEAR_MIP_POINT = 0x84,
    COMPARISON_MIN_POINT_MAG_MIP_LINEAR = 0x85,
    COMPARISON_MIN_LINEAR_MAG_MIP_POINT = 0x90,
    COMPARISON_MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x91,
    COMPARISON_MIN_MAG_LINEAR_MIP_POINT = 0x94,
    COMPARISON_MIN_MAG_MIP_LINEAR = 0x95,
    COMPARISON_ANISOTROPIC = 0xd5,
    MINIMUM_MIN_MAG_MIP_POINT = 0x100,
    MINIMUM_MIN_MAG_POINT_MIP_LINEAR = 0x101,
    MINIMUM_MIN_POINT_MAG_LINEAR_MIP_POINT = 0x104,
    MINIMUM_MIN_POINT_MAG_MIP_LINEAR = 0x105,
    MINIMUM_MIN_LINEAR_MAG_MIP_POINT = 0x110,
    MINIMUM_MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x111,
    MINIMUM_MIN_MAG_LINEAR_MIP_POINT = 0x114,
    MINIMUM_MIN_MAG_MIP_LINEAR = 0x115,
    MINIMUM_ANISOTROPIC = 0x155,
    MAXIMUM_MIN_MAG_MIP_POINT = 0x180,
    MAXIMUM_MIN_MAG_POINT_MIP_LINEAR = 0x181,
    MAXIMUM_MIN_POINT_MAG_LINEAR_MIP_POINT = 0x184,
    MAXIMUM_MIN_POINT_MAG_MIP_LINEAR = 0x185,
    MAXIMUM_MIN_LINEAR_MAG_MIP_POINT = 0x190,
    MAXIMUM_MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x191,
    MAXIMUM_MIN_MAG_LINEAR_MIP_POINT = 0x194,
    MAXIMUM_MIN_MAG_MIP_LINEAR = 0x195,
    MAXIMUM_ANISOTROPIC = 0x1d5,
};

pub const STATIC_BORDER_COLOR = enum(UINT) {
    TRANSPARENT_BLACK = 0,
    OPAQUE_BLACK = 1,
    OPAQUE_WHITE = 2,
};

pub const TEXTURE_ADDRESS_MODE = enum(UINT) {
    WRAP = 1,
    MIRROR = 2,
    CLAMP = 3,
    BORDER = 4,
    MIRROR_ONCE = 5,
};

pub const COMPARISON_FUNC = enum(UINT) {
    NEVER = 1,
    LESS = 2,
    EQUAL = 3,
    LESS_EQUAL = 4,
    GREATER = 5,
    NOT_EQUAL = 6,
    GREATER_EQUAL = 7,
    ALWAYS = 8,
};

pub const STATIC_SAMPLER_DESC = extern struct {
    Filter: FILTER,
    AddressU: TEXTURE_ADDRESS_MODE,
    AddressV: TEXTURE_ADDRESS_MODE,
    AddressW: TEXTURE_ADDRESS_MODE,
    MipLODBias: FLOAT,
    MaxAnisotropy: UINT,
    ComparisonFunc: COMPARISON_FUNC,
    BorderColor: STATIC_BORDER_COLOR,
    MinLOD: FLOAT,
    MaxLOD: FLOAT,
    ShaderRegister: UINT,
    RegisterSpace: UINT,
    ShaderVisibility: SHADER_VISIBILITY,
};

pub const ROOT_SIGNATURE_FLAGS = packed struct(UINT) {
    ALLOW_INPUT_ASSEMBLER_INPUT_LAYOUT: bool = false,
    DENY_VERTEX_SHADER_ROOT_ACCESS: bool = false,
    DENY_HULL_SHADER_ROOT_ACCESS: bool = false,
    DENY_DOMAIN_SHADER_ROOT_ACCESS: bool = false,
    DENY_GEOMETRY_SHADER_ROOT_ACCESS: bool = false,
    DENY_PIXEL_SHADER_ROOT_ACCESS: bool = false,
    ALLOW_STREAM_OUTPUT: bool = false,
    LOCAL_ROOT_SIGNATURE: bool = false,
    DENY_AMPLIFICATION_SHADER_ROOT_ACCESS: bool = false,
    DENY_MESH_SHADER_ROOT_ACCESS: bool = false,
    CBV_SRV_UAV_HEAP_DIRECTLY_INDEXED: bool = false,
    SAMPLER_HEAP_DIRECTLY_INDEXED: bool = false,
    __unused: u20 = 0,
};

pub const ROOT_PARAMETER_TYPE = enum(UINT) {
    DESCRIPTOR_TABLE = 0,
    @"32BIT_CONSTANTS" = 1,
    CBV = 2,
    SRV = 3,
    UAV = 4,
};

pub const SHADER_VISIBILITY = enum(UINT) {
    ALL = 0,
    VERTEX = 1,
    HULL = 2,
    DOMAIN = 3,
    GEOMETRY = 4,
    PIXEL = 5,
    AMPLIFICATION = 6,
    MESH = 7,
};

pub const DESCRIPTOR_RANGE_TYPE = enum(UINT) {
    SRV = 0,
    UAV = 1,
    CBV = 2,
    SAMPLER = 3,
};

pub const DESCRIPTOR_RANGE = extern struct {
    RangeType: DESCRIPTOR_RANGE_TYPE,
    NumDescriptors: UINT,
    BaseShaderRegister: UINT,
    RegisterSpace: UINT,
    OffsetInDescriptorsFromStart: UINT,
};

pub const ROOT_DESCRIPTOR_TABLE = extern struct {
    NumDescriptorRanges: UINT,
    pDescriptorRanges: ?[*]const DESCRIPTOR_RANGE,
};

pub const ROOT_CONSTANTS = extern struct {
    ShaderRegister: UINT,
    RegisterSpace: UINT,
    Num32BitValues: UINT,
};

pub const ROOT_DESCRIPTOR = extern struct {
    ShaderRegister: UINT,
    RegisterSpace: UINT,
};

pub const ROOT_PARAMETER = extern struct {
    ParameterType: ROOT_PARAMETER_TYPE,
    u: extern union {
        DescriptorTable: ROOT_DESCRIPTOR_TABLE,
        Constants: ROOT_CONSTANTS,
        Descriptor: ROOT_DESCRIPTOR,
    },
    ShaderVisibility: SHADER_VISIBILITY,
};

pub const ROOT_SIGNATURE_DESC = extern struct {
    NumParameters: UINT,
    pParameters: ?[*]const ROOT_PARAMETER,
    NumStaticSamplers: UINT,
    pStaticSamplers: ?[*]const STATIC_SAMPLER_DESC,
    Flags: ROOT_SIGNATURE_FLAGS,
};

pub const ROOT_SIGNATURE_VERSION = enum(UINT) {
    VERSION_1_0 = 0x1,
    VERSION_1_1 = 0x2,
};

pub const FEATURE = enum(UINT) {
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
    NodeIndex: UINT = 0,
    TileBasedRenderer: BOOL = 0,
    UMA: BOOL = 0,
    CacheCoherentUMA: BOOL = 0,
};

pub const FEATURE_DATA_OPTIONS16 = extern struct {
    DynamicDepthBiasSupported: BOOL,
    GPUUploadHeapSupported: BOOL,
};

pub const COMMAND_LIST_TYPE = enum(UINT) {
    DIRECT = 0,
    BUNDLE = 1,
    COMPUTE = 2,
    COPY = 3,
    VIDEO_DECODE = 4,
    VIDEO_PROCESS = 5,
    VIDEO_ENCODE = 6,
};

pub const COMMAND_QUEUE_FLAGS = packed struct(UINT) {
    DISABLE_GPU_TIMEOUT: bool = false,
    __unused: u31 = 0,
};

pub const COMMAND_QUEUE_DESC = extern struct {
    Type: COMMAND_LIST_TYPE,
    Priority: INT,
    Flags: COMMAND_QUEUE_FLAGS,
    NodeMask: UINT,
};

pub const INDIRECT_ARGUMENT_TYPE = enum(UINT) {
    DRAW = 0,
    DRAW_INDEXED = 1,
    DISPATCH = 2,
    VERTEX_BUFFER_VIEW = 3,
    INDEX_BUFFER_VIEW = 4,
    CONSTANT = 5,
    CONSTANT_BUFFER_VIEW = 6,
    SHADER_RESOURCE_VIEW = 7,
    UNORDERED_ACCESS_VIEW = 8,
    DISPATCH_RAYS = 9,
    DISPATCH_MESH = 10,
};

pub const INDIRECT_ARGUMENT_DESC = extern struct {
    Type: INDIRECT_ARGUMENT_TYPE,
    u: extern union {
        VertexBuffer: extern struct {
            Slot: UINT,
        },
        Constant: extern struct {
            RootParameterIndex: UINT,
            DestOffsetIn32BitValues: UINT,
            Num32BitValuesToSet: UINT,
        },
        ConstantBufferView: extern struct {
            RootParameterIndex: UINT,
        },
        ShaderResourceView: extern struct {
            RootParameterIndex: UINT,
        },
        UnorderedAccessView: extern struct {
            RootParameterIndex: UINT,
        },
    },
};

pub const COMMAND_SIGNATURE_DESC = extern struct {
    ByteStride: UINT,
    NumArgumentDescs: UINT,
    pArgumentDescs: *const INDIRECT_ARGUMENT_DESC,
    NodeMask: UINT,
};

pub const RANGE = extern struct {
    Begin: UINT64,
    End: UINT64,
};

pub const BOX = extern struct {
    left: UINT,
    top: UINT,
    front: UINT,
    right: UINT,
    bottom: UINT,
    back: UINT,
};

pub const RESOURCE_DIMENSION = enum(UINT) {
    UNKNOWN = 0,
    BUFFER = 1,
    TEXTURE1D = 2,
    TEXTURE2D = 3,
    TEXTURE3D = 4,
};

pub const TEXTURE_LAYOUT = enum(UINT) {
    UNKNOWN = 0,
    ROW_MAJOR = 1,
    @"64KB_UNDEFINED_SWIZZLE" = 2,
    @"64KB_STANDARD_SWIZZLE" = 3,
};

pub const RESOURCE_FLAGS = packed struct(UINT) {
    ALLOW_RENDER_TARGET: bool = false,
    ALLOW_DEPTH_STENCIL: bool = false,
    ALLOW_UNORDERED_ACCESS: bool = false,
    DENY_SHADER_RESOURCE: bool = false,
    ALLOW_CROSS_ADAPTER: bool = false,
    ALLOW_SIMULTANEOUS_ACCESS: bool = false,
    VIDEO_DECODE_REFERENCE_ONLY: bool = false,
    VIDEO_ENCODE_REFERENCE_ONLY: bool = false,
    __unused: u24 = 0,
};

pub const RESOURCE_DESC = extern struct {
    Dimension: RESOURCE_DIMENSION,
    Alignment: UINT64,
    Width: UINT64,
    Height: UINT,
    DepthOrArraySize: UINT16,
    MipLevels: UINT16,
    Format: dxgi.FORMAT,
    SampleDesc: dxgi.SAMPLE_DESC,
    Layout: TEXTURE_LAYOUT,
    Flags: RESOURCE_FLAGS,
};

pub const VIEWPORT = extern struct {
    TopLeftX: FLOAT,
    TopLeftY: FLOAT,
    Width: FLOAT,
    Height: FLOAT,
    MinDepth: FLOAT,
    MaxDepth: FLOAT,
};

pub const HEAP_TYPE = enum(UINT) {
    DEFAULT = 1,
    UPLOAD = 2,
    READBACK = 3,
    CUSTOM = 4,
};

pub const CPU_PAGE_PROPERTY = enum(UINT) {
    UNKNOWN = 0,
    NOT_AVAILABLE = 1,
    WRITE_COMBINE = 2,
    WRITE_BACK = 3,
};

pub const MEMORY_POOL = enum(UINT) {
    UNKNOWN = 0,
    L0 = 1,
    L1 = 2,
};

pub const HEAP_PROPERTIES = extern struct {
    Type: HEAP_TYPE,
    CPUPageProperty: CPU_PAGE_PROPERTY,
    MemoryPoolPreference: MEMORY_POOL,
    CreationNodeMask: UINT,
    VisibleNodeMask: UINT,
};

pub const HEAP_FLAGS = packed struct(UINT) {
    SHARED: bool = false,
    __unused1: bool = false,
    DENY_BUFFERS: bool = false,
    ALLOW_DISPLAY: bool = false,
    __unused4: bool = false,
    SHARED_CROSS_ADAPTER: bool = false,
    DENY_RT_DS_TEXTURES: bool = false,
    DENY_NON_RT_DS_TEXTURES: bool = false,
    HARDWARE_PROTECTED: bool = false,
    ALLOW_WRITE_WATCH: bool = false,
    ALLOW_SHADER_ATOMICS: bool = false,
    CREATE_NOT_RESIDENT: bool = false,
    CREATE_NOT_ZEROED: bool = false,
    __unused: u19 = 0,

    pub const ALLOW_ALL_BUFFERS_AND_TEXTURES = HEAP_FLAGS{};
    pub const ALLOW_ONLY_NON_RT_DS_TEXTURES = HEAP_FLAGS{ .DENY_BUFFERS = true, .DENY_RT_DS_TEXTURES = true };
    pub const ALLOW_ONLY_BUFFERS = HEAP_FLAGS{ .DENY_RT_DS_TEXTURES = true, .DENY_NON_RT_DS_TEXTURES = true };
    pub const HEAP_FLAG_ALLOW_ONLY_RT_DS_TEXTURES = HEAP_FLAGS{
        .DENY_BUFFERS = true,
        .DENY_NON_RT_DS_TEXTURES = true,
    };
};

pub const SUBRESOURCE_FOOTPRINT = extern struct {
    Format: dxgi.FORMAT,
    Width: UINT,
    Height: UINT,
    Depth: UINT,
    RowPitch: UINT,
};

pub const PLACED_SUBRESOURCE_FOOTPRINT = extern struct {
    Offset: UINT64,
    Footprint: SUBRESOURCE_FOOTPRINT,
};

pub const TEXTURE_COPY_TYPE = enum(UINT) {
    SUBRESOURCE_INDEX = 0,
    PLACED_FOOTPRINT = 1,
};

pub const TEXTURE_COPY_LOCATION = extern struct {
    pResource: *IResource,
    Type: TEXTURE_COPY_TYPE,
    u: extern union {
        PlacedFootprint: PLACED_SUBRESOURCE_FOOTPRINT,
        SubresourceIndex: UINT,
    },
};

pub const TILED_RESOURCE_COORDINATE = extern struct {
    X: UINT,
    Y: UINT,
    Z: UINT,
    Subresource: UINT,
};

pub const TILE_REGION_SIZE = extern struct {
    NumTiles: UINT,
    UseBox: BOOL,
    Width: UINT,
    Height: UINT16,
    Depth: UINT16,
};

pub const TILE_COPY_FLAGS = packed struct(UINT) {
    NO_HAZARD: bool = false,
    LINEAR_BUFFER_TO_SWIZZLED_TILED_RESOURCE: bool = false,
    SWIZZLED_TILED_RESOURCE_TO_LINEAR_BUFFER: bool = false,
    __unused: u29 = 0,
};

pub const RESOURCE_BARRIER_TYPE = enum(UINT) {
    TRANSITION = 0,
    ALIASING = 1,
    UAV = 2,
};

pub const RESOURCE_STATES = packed struct(UINT) {
    VERTEX_AND_CONSTANT_BUFFER: bool = false, // 0x1
    INDEX_BUFFER: bool = false,
    RENDER_TARGET: bool = false,
    UNORDERED_ACCESS: bool = false,
    DEPTH_WRITE: bool = false, // 0x10
    DEPTH_READ: bool = false,
    NON_PIXEL_SHADER_RESOURCE: bool = false,
    PIXEL_SHADER_RESOURCE: bool = false,
    STREAM_OUT: bool = false, // 0x100
    INDIRECT_ARGUMENT_OR_PREDICATION: bool = false,
    COPY_DEST: bool = false,
    COPY_SOURCE: bool = false,
    RESOLVE_DEST: bool = false, // 0x1000
    RESOLVE_SOURCE: bool = false,
    __unused14: bool = false,
    __unused15: bool = false,
    VIDEO_DECODE_READ: bool = false, // 0x10000
    VIDEO_DECODE_WRITE: bool = false,
    VIDEO_PROCESS_READ: bool = false,
    VIDEO_PROCESS_WRITE: bool = false,
    __unused20: bool = false, // 0x100000
    VIDEO_ENCODE_READ: bool = false,
    RAYTRACING_ACCELERATION_STRUCTURE: bool = false,
    VIDEO_ENCODE_WRITE: bool = false,
    SHADING_RATE_SOURCE: bool = false, // 0x1000000
    __unused: u7 = 0,

    pub const COMMON = RESOURCE_STATES{};
    pub const PRESENT = RESOURCE_STATES{};
    pub const GENERIC_READ = RESOURCE_STATES{
        .VERTEX_AND_CONSTANT_BUFFER = true,
        .INDEX_BUFFER = true,
        .NON_PIXEL_SHADER_RESOURCE = true,
        .PIXEL_SHADER_RESOURCE = true,
        .INDIRECT_ARGUMENT_OR_PREDICATION = true,
        .COPY_SOURCE = true,
    };
    pub const ALL_SHADER_RESOURCE = RESOURCE_STATES{
        .NON_PIXEL_SHADER_RESOURCE = true,
        .PIXEL_SHADER_RESOURCE = true,
    };
};

pub const RESOURCE_TRANSITION_BARRIER = extern struct {
    pResource: *IResource,
    Subresource: UINT,
    StateBefore: RESOURCE_STATES,
    StateAfter: RESOURCE_STATES,
};

pub const RESOURCE_ALIASING_BARRIER = extern struct {
    pResourceBefore: ?*IResource,
    pResourceAfter: ?*IResource,
};

pub const RESOURCE_UAV_BARRIER = extern struct {
    pResource: ?*IResource,
};

pub const RESOURCE_BARRIER_FLAGS = packed struct(UINT) {
    BEGIN_ONLY: bool = false,
    END_ONLY: bool = false,
    __unused: u30 = 0,
};

pub const RESOURCE_BARRIER = extern struct {
    Type: RESOURCE_BARRIER_TYPE,
    Flags: RESOURCE_BARRIER_FLAGS,
    u: extern union {
        Transition: RESOURCE_TRANSITION_BARRIER,
        Aliasing: RESOURCE_ALIASING_BARRIER,
        UAV: RESOURCE_UAV_BARRIER,
    },
};

pub const VERTEX_BUFFER_VIEW = extern struct {
    BufferLocation: GPU_VIRTUAL_ADDRESS,
    SizeInBytes: UINT,
    StrideInBytes: UINT,
};

pub const INDEX_BUFFER_VIEW = extern struct {
    BufferLocation: GPU_VIRTUAL_ADDRESS,
    SizeInBytes: UINT,
    Format: dxgi.FORMAT,
};

pub const STREAM_OUTPUT_BUFFER_VIEW = extern struct {
    BufferLocation: GPU_VIRTUAL_ADDRESS,
    SizeInBytes: UINT64,
    BufferFilledSizeLocation: GPU_VIRTUAL_ADDRESS,
};

pub const CLEAR_FLAGS = packed struct(UINT) {
    DEPTH: bool = false,
    STENCIL: bool = false,
    __unused: u30 = 0,
};

pub const DISCARD_REGION = extern struct {
    NumRects: UINT,
    pRects: *const RECT,
    FirstSubresource: UINT,
    NumSubresources: UINT,
};

pub const PREDICATION_OP = enum(UINT) {
    EQUAL_ZERO = 0,
    NOT_EQUAL_ZERO = 1,
};

pub const QUERY_TYPE = enum(UINT) {
    OCCLUSION = 0,
    BINARY_OCCLUSION = 1,
    TIMESTAMP = 2,
    PIPELINE_STATISTICS = 3,
    SO_STATISTICS_STREAM0 = 4,
    SO_STATISTICS_STREAM1 = 5,
    SO_STATISTICS_STREAM2 = 6,
    SO_STATISTICS_STREAM3 = 7,
    VIDEO_DECODE_STATISTICS = 8,
    PIPELINE_STATISTICS1 = 10,
};

pub const DESCRIPTOR_HEAP_TYPE = enum(UINT) {
    CBV_SRV_UAV = 0,
    SAMPLER = 1,
    RTV = 2,
    DSV = 3,
};

pub const DESCRIPTOR_HEAP_FLAGS = packed struct(UINT) {
    SHADER_VISIBLE: bool = false,
    __unused: u31 = 0,
};

pub const DESCRIPTOR_HEAP_DESC = extern struct {
    Type: DESCRIPTOR_HEAP_TYPE,
    NumDescriptors: UINT,
    Flags: DESCRIPTOR_HEAP_FLAGS,
    NodeMask: UINT,
};

pub const FENCE_FLAGS = packed struct(UINT) {
    SHARED: bool = false,
    SHARED_CROSS_ADAPTER: bool = false,
    NON_MONITORED: bool = false,
    __unused: u29 = 0,
};

// functions
// ---------

pub extern "d3d12" fn D3D12GetDebugInterface(riid: *const GUID, ppvDebug: *?*anyopaque) callconv(.winapi) HRESULT;
pub extern "d3d12" fn D3D12CreateDevice(pAdapter: ?*IUnknown, MinimumFeatureLevel: FEATURE_LEVEL, riid: *const GUID, ppDevice: ?*?*anyopaque) callconv(.winapi) HRESULT;
pub extern "d3d12" fn D3D12SerializeRootSignature(pRootSignature: *const ROOT_SIGNATURE_DESC, Version: ROOT_SIGNATURE_VERSION, ppBlob: *?*IBlob, ppErrorBlob: *?*IBlob) callconv(.winapi) HRESULT;

// THIS FILE IS AUTOGENERATED BEYOND THIS POINT! DO NOT EDIT!
// ----------------------------------------------------------

pub const IBlob = extern struct {
    pub const IID = GUID.parse("{8BA5FB08-5195-40E2-AC58-0D989C3A0102}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IUnknown.VTable,
        get_buffer_pointer: *const fn (*IBlob) callconv(.winapi) *anyopaque,
        get_buffer_size: *const fn (*IBlob) callconv(.winapi) SIZE_T,
    };

    pub fn getBufferPointer(self: *IBlob) *anyopaque {
        return (self.vtable.get_buffer_pointer)(self);
    }
    pub fn getBufferSize(self: *IBlob) SIZE_T {
        return (self.vtable.get_buffer_size)(self);
    }
    // IUnknown methods
    pub fn queryInterface(self: *IBlob, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IBlob) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IBlob) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IDeviceChild = extern struct {
    pub const IID = GUID.parse("{905DB94B-A00C-4140-9DF5-2B64CA9EA357}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IObject.VTable,
        get_device: *const fn (*IDeviceChild, riid: *const GUID, device: *?*anyopaque) callconv(.winapi) HRESULT,
    };

    pub fn getDevice(self: *IDeviceChild, riid: *const GUID, device: *?*anyopaque) HRESULT {
        return (self.vtable.get_device)(self, riid, device);
    }
    // IObject methods
    pub fn getPrivateData(self: *IDeviceChild) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IDeviceChild) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IDeviceChild) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *IDeviceChild) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
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

pub const IPageable = extern struct {
    pub const IID = GUID.parse("{63EE58FB-1268-4835-86DA-F008CE62F0D6}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IDeviceChild.VTable,
    };
    // IDeviceChild methods
    pub fn getDevice(self: *IPageable, riid: *const GUID, device: *?*anyopaque) HRESULT {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), riid, device);
    }
    // IObject methods
    pub fn getPrivateData(self: *IPageable) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IPageable) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IPageable) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *IPageable) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IPageable, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IPageable) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IPageable) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IDebug = extern struct {
    pub const IID = GUID.parse("{344488B7-6846-474B-B989-F027448245E0}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IUnknown.VTable,
        enable_debug_layer: *const fn (*IDebug) callconv(.winapi) void,
    };

    pub fn enableDebugLayer(self: *IDebug) void {
        return (self.vtable.enable_debug_layer)(self);
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

pub const IDevice = extern struct {
    pub const IID = GUID.parse("{189819F1-1DB6-4B57-BE54-1821339B85F7}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IObject.VTable,
        get_node_count: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_command_queue: *const fn (*IDevice, desc: *const COMMAND_QUEUE_DESC, riid: *const GUID, command_queue: *?*anyopaque) callconv(.winapi) HRESULT,
        create_command_allocator: *const fn (*IDevice, cmdlist_type: COMMAND_LIST_TYPE, guid: *const GUID, obj: *?*anyopaque) callconv(.winapi) HRESULT,
        create_graphics_pipeline_state: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_compute_pipeline_state: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_command_list: *const fn (*IDevice, node_mask: UINT, cmdlist_type: COMMAND_LIST_TYPE, cmdalloc: *ICommandAllocator, initial_state: ?*IPipelineState, guid: *const GUID, cmdlist: *?*anyopaque) callconv(.winapi) HRESULT,
        check_feature_support: *const fn (*IDevice, feature: FEATURE, data: *anyopaque, size: UINT) callconv(.winapi) HRESULT,
        create_descriptor_heap: *const fn (*IDevice, desc: *const DESCRIPTOR_HEAP_DESC, riid: *const GUID, heap: *?*anyopaque) callconv(.winapi) HRESULT,
        get_descriptor_handle_increment_size: *const fn (*IDevice, heap_type: DESCRIPTOR_HEAP_TYPE) callconv(.winapi) UINT,
        create_root_signature: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_constant_buffer_view: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_shader_resource_view: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_unordered_access_view: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_render_target_view: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_depth_stencil_view: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_sampler: *const fn (*IDevice) callconv(.winapi) noreturn,
        copy_descriptors: *const fn (*IDevice) callconv(.winapi) noreturn,
        copy_descriptors_simple: *const fn (*IDevice) callconv(.winapi) noreturn,
        get_resource_allocation_info: *const fn (*IDevice) callconv(.winapi) noreturn,
        get_custom_heap_properties: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_committed_resource: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_heap: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_placed_resource: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_reserved_resource: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_shared_handle: *const fn (*IDevice) callconv(.winapi) noreturn,
        open_shared_handle: *const fn (*IDevice) callconv(.winapi) noreturn,
        open_shared_handle_by_name: *const fn (*IDevice) callconv(.winapi) noreturn,
        make_resident: *const fn (*IDevice) callconv(.winapi) noreturn,
        evict: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_fence: *const fn (*IDevice, initial_value: u64, flags: FENCE_FLAGS, riid: *const GUID, fence: *?*anyopaque) callconv(.winapi) HRESULT,
        get_device_removed_reason: *const fn (*IDevice) callconv(.winapi) noreturn,
        get_copyable_footprints: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_query_heap: *const fn (*IDevice) callconv(.winapi) noreturn,
        set_stable_power_state: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_command_signature: *const fn (*IDevice, desc: *const COMMAND_SIGNATURE_DESC, root_signature: ?*IRootSignature, riid: *const GUID, signature: ?*?*anyopaque) callconv(.winapi) HRESULT,
        get_resource_tiling: *const fn (*IDevice) callconv(.winapi) noreturn,
        get_adapter_luid: *const fn (*IDevice) callconv(.winapi) noreturn,
    };

    pub fn getNodeCount(self: *IDevice) noreturn {
        return (self.vtable.get_node_count)(self);
    }
    pub fn createCommandQueue(self: *IDevice, desc: *const COMMAND_QUEUE_DESC, riid: *const GUID, command_queue: *?*anyopaque) HRESULT {
        return (self.vtable.create_command_queue)(self, desc, riid, command_queue);
    }
    pub fn createCommandAllocator(self: *IDevice, cmdlist_type: COMMAND_LIST_TYPE, guid: *const GUID, obj: *?*anyopaque) HRESULT {
        return (self.vtable.create_command_allocator)(self, cmdlist_type, guid, obj);
    }
    pub fn createGraphicsPipelineState(self: *IDevice) noreturn {
        return (self.vtable.create_graphics_pipeline_state)(self);
    }
    pub fn createComputePipelineState(self: *IDevice) noreturn {
        return (self.vtable.create_compute_pipeline_state)(self);
    }
    pub fn createCommandList(self: *IDevice, node_mask: UINT, cmdlist_type: COMMAND_LIST_TYPE, cmdalloc: *ICommandAllocator, initial_state: ?*IPipelineState, guid: *const GUID, cmdlist: *?*anyopaque) HRESULT {
        return (self.vtable.create_command_list)(self, node_mask, cmdlist_type, cmdalloc, initial_state, guid, cmdlist);
    }
    pub fn checkFeatureSupport(self: *IDevice, feature: FEATURE, data: *anyopaque, size: UINT) HRESULT {
        return (self.vtable.check_feature_support)(self, feature, data, size);
    }
    pub fn createDescriptorHeap(self: *IDevice, desc: *const DESCRIPTOR_HEAP_DESC, riid: *const GUID, heap: *?*anyopaque) HRESULT {
        return (self.vtable.create_descriptor_heap)(self, desc, riid, heap);
    }
    pub fn getDescriptorHandleIncrementSize(self: *IDevice, heap_type: DESCRIPTOR_HEAP_TYPE) UINT {
        return (self.vtable.get_descriptor_handle_increment_size)(self, heap_type);
    }
    pub fn createRootSignature(self: *IDevice) noreturn {
        return (self.vtable.create_root_signature)(self);
    }
    pub fn createConstantBufferView(self: *IDevice) noreturn {
        return (self.vtable.create_constant_buffer_view)(self);
    }
    pub fn createShaderResourceView(self: *IDevice) noreturn {
        return (self.vtable.create_shader_resource_view)(self);
    }
    pub fn createUnorderedAccessView(self: *IDevice) noreturn {
        return (self.vtable.create_unordered_access_view)(self);
    }
    pub fn createRenderTargetView(self: *IDevice) noreturn {
        return (self.vtable.create_render_target_view)(self);
    }
    pub fn createDepthStencilView(self: *IDevice) noreturn {
        return (self.vtable.create_depth_stencil_view)(self);
    }
    pub fn createSampler(self: *IDevice) noreturn {
        return (self.vtable.create_sampler)(self);
    }
    pub fn copyDescriptors(self: *IDevice) noreturn {
        return (self.vtable.copy_descriptors)(self);
    }
    pub fn copyDescriptorsSimple(self: *IDevice) noreturn {
        return (self.vtable.copy_descriptors_simple)(self);
    }
    pub fn getResourceAllocationInfo(self: *IDevice) noreturn {
        return (self.vtable.get_resource_allocation_info)(self);
    }
    pub fn getCustomHeapProperties(self: *IDevice) noreturn {
        return (self.vtable.get_custom_heap_properties)(self);
    }
    pub fn createCommittedResource(self: *IDevice) noreturn {
        return (self.vtable.create_committed_resource)(self);
    }
    pub fn createHeap(self: *IDevice) noreturn {
        return (self.vtable.create_heap)(self);
    }
    pub fn createPlacedResource(self: *IDevice) noreturn {
        return (self.vtable.create_placed_resource)(self);
    }
    pub fn createReservedResource(self: *IDevice) noreturn {
        return (self.vtable.create_reserved_resource)(self);
    }
    pub fn createSharedHandle(self: *IDevice) noreturn {
        return (self.vtable.create_shared_handle)(self);
    }
    pub fn openSharedHandle(self: *IDevice) noreturn {
        return (self.vtable.open_shared_handle)(self);
    }
    pub fn openSharedHandleByName(self: *IDevice) noreturn {
        return (self.vtable.open_shared_handle_by_name)(self);
    }
    pub fn makeResident(self: *IDevice) noreturn {
        return (self.vtable.make_resident)(self);
    }
    pub fn evict(self: *IDevice) noreturn {
        return (self.vtable.evict)(self);
    }
    pub fn createFence(self: *IDevice, initial_value: u64, flags: FENCE_FLAGS, riid: *const GUID, fence: *?*anyopaque) HRESULT {
        return (self.vtable.create_fence)(self, initial_value, flags, riid, fence);
    }
    pub fn getDeviceRemovedReason(self: *IDevice) noreturn {
        return (self.vtable.get_device_removed_reason)(self);
    }
    pub fn getCopyableFootprints(self: *IDevice) noreturn {
        return (self.vtable.get_copyable_footprints)(self);
    }
    pub fn createQueryHeap(self: *IDevice) noreturn {
        return (self.vtable.create_query_heap)(self);
    }
    pub fn setStablePowerState(self: *IDevice) noreturn {
        return (self.vtable.set_stable_power_state)(self);
    }
    pub fn createCommandSignature(self: *IDevice, desc: *const COMMAND_SIGNATURE_DESC, root_signature: ?*IRootSignature, riid: *const GUID, signature: ?*?*anyopaque) HRESULT {
        return (self.vtable.create_command_signature)(self, desc, root_signature, riid, signature);
    }
    pub fn getResourceTiling(self: *IDevice) noreturn {
        return (self.vtable.get_resource_tiling)(self);
    }
    pub fn getAdapterLuid(self: *IDevice) noreturn {
        return (self.vtable.get_adapter_luid)(self);
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

pub const ICommandQueue = extern struct {
    pub const IID = GUID.parse("{0EC870A6-5D7E-4C22-8CFC-5BAAE07616ED}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IPageable.VTable,
        update_tile_mappings: *const fn (*ICommandQueue) callconv(.winapi) noreturn,
        copy_tile_mappings: *const fn (*ICommandQueue) callconv(.winapi) noreturn,
        execute_command_lists: *const fn (*ICommandQueue) callconv(.winapi) noreturn,
        set_marker: *const fn (*ICommandQueue) callconv(.winapi) noreturn,
        begin_event: *const fn (*ICommandQueue) callconv(.winapi) noreturn,
        end_event: *const fn (*ICommandQueue) callconv(.winapi) noreturn,
        signal: *const fn (*ICommandQueue, fence: *IFence, value: u64) callconv(.winapi) HRESULT,
        wait: *const fn (*ICommandQueue) callconv(.winapi) noreturn,
        get_timestamp_frequency: *const fn (*ICommandQueue) callconv(.winapi) noreturn,
        get_clock_calibration: *const fn (*ICommandQueue) callconv(.winapi) noreturn,
        get_desc: *const fn (*ICommandQueue) callconv(.winapi) noreturn,
    };

    pub fn updateTileMappings(self: *ICommandQueue) noreturn {
        return (self.vtable.update_tile_mappings)(self);
    }
    pub fn copyTileMappings(self: *ICommandQueue) noreturn {
        return (self.vtable.copy_tile_mappings)(self);
    }
    pub fn executeCommandLists(self: *ICommandQueue) noreturn {
        return (self.vtable.execute_command_lists)(self);
    }
    pub fn setMarker(self: *ICommandQueue) noreturn {
        return (self.vtable.set_marker)(self);
    }
    pub fn beginEvent(self: *ICommandQueue) noreturn {
        return (self.vtable.begin_event)(self);
    }
    pub fn endEvent(self: *ICommandQueue) noreturn {
        return (self.vtable.end_event)(self);
    }
    pub fn signal(self: *ICommandQueue, fence: *IFence, value: u64) HRESULT {
        return (self.vtable.signal)(self, fence, value);
    }
    pub fn wait(self: *ICommandQueue) noreturn {
        return (self.vtable.wait)(self);
    }
    pub fn getTimestampFrequency(self: *ICommandQueue) noreturn {
        return (self.vtable.get_timestamp_frequency)(self);
    }
    pub fn getClockCalibration(self: *ICommandQueue) noreturn {
        return (self.vtable.get_clock_calibration)(self);
    }
    pub fn getDesc(self: *ICommandQueue) noreturn {
        return (self.vtable.get_desc)(self);
    }
    // IPageable methods
    // IDeviceChild methods
    pub fn getDevice(self: *ICommandQueue, riid: *const GUID, device: *?*anyopaque) HRESULT {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), riid, device);
    }
    // IObject methods
    pub fn getPrivateData(self: *ICommandQueue) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *ICommandQueue) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *ICommandQueue) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *ICommandQueue) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *ICommandQueue, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *ICommandQueue) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *ICommandQueue) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const ICommandSignature = extern struct {
    pub const IID = GUID.parse("{C36A797C-EC80-4F0A-8985-A7B2475082D1}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IPageable.VTable,
    };
    // IPageable methods
    // IDeviceChild methods
    pub fn getDevice(self: *ICommandSignature, riid: *const GUID, device: *?*anyopaque) HRESULT {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), riid, device);
    }
    // IObject methods
    pub fn getPrivateData(self: *ICommandSignature) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *ICommandSignature) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *ICommandSignature) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *ICommandSignature) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *ICommandSignature, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *ICommandSignature) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *ICommandSignature) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IRootSignature = extern struct {
    pub const IID = GUID.parse("{C54A6B66-72DF-4EE8-8BE5-A946A1429214}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IDeviceChild.VTable,
    };
    // IDeviceChild methods
    pub fn getDevice(self: *IRootSignature, riid: *const GUID, device: *?*anyopaque) HRESULT {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), riid, device);
    }
    // IObject methods
    pub fn getPrivateData(self: *IRootSignature) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IRootSignature) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IRootSignature) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *IRootSignature) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IRootSignature, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IRootSignature) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IRootSignature) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IResource = extern struct {
    pub const IID = GUID.parse("{696442BE-A72E-4059-BC79-5B5C98040FAD}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IPageable.VTable,
        map: *const fn (*IResource, subresource: UINT, read_range: ?*const RANGE, data: *?*anyopaque) callconv(.winapi) HRESULT,
        unmap: *const fn (*IResource, subresource: UINT, read_range: ?*const RANGE) callconv(.winapi) void,
        get_desc: *const fn (*IResource, desc: *RESOURCE_DESC) callconv(.winapi) HRESULT,
        get_gpu_virtual_address: *const fn (*IResource) callconv(.winapi) GPU_VIRTUAL_ADDRESS,
        write_to_subresource: *const fn (*IResource, dst_subresource: UINT, dst_box: ?*const BOX, src_data: *const anyopaque, src_row_pitch: UINT, src_depth_pitch: UINT) callconv(.winapi) HRESULT,
        read_from_subresource: *const fn (*IResource, dst_data: *anyopaque, dst_row_pitch: UINT, dst_depth_pitch: UINT, src_subresource: UINT, src_box: ?*const BOX) callconv(.winapi) HRESULT,
        get_heap_properties: *const fn (*IResource, properties: ?*HEAP_PROPERTIES, flags: ?*HEAP_FLAGS) callconv(.winapi) HRESULT,
    };

    pub fn map(self: *IResource, subresource: UINT, read_range: ?*const RANGE, data: *?*anyopaque) HRESULT {
        return (self.vtable.map)(self, subresource, read_range, data);
    }
    pub fn unmap(self: *IResource, subresource: UINT, read_range: ?*const RANGE) void {
        return (self.vtable.unmap)(self, subresource, read_range);
    }
    pub fn getDesc(self: *IResource, desc: *RESOURCE_DESC) HRESULT {
        return (self.vtable.get_desc)(self, desc);
    }
    pub fn getGpuVirtualAddress(self: *IResource) GPU_VIRTUAL_ADDRESS {
        return (self.vtable.get_gpu_virtual_address)(self);
    }
    pub fn writeToSubresource(self: *IResource, dst_subresource: UINT, dst_box: ?*const BOX, src_data: *const anyopaque, src_row_pitch: UINT, src_depth_pitch: UINT) HRESULT {
        return (self.vtable.write_to_subresource)(self, dst_subresource, dst_box, src_data, src_row_pitch, src_depth_pitch);
    }
    pub fn readFromSubresource(self: *IResource, dst_data: *anyopaque, dst_row_pitch: UINT, dst_depth_pitch: UINT, src_subresource: UINT, src_box: ?*const BOX) HRESULT {
        return (self.vtable.read_from_subresource)(self, dst_data, dst_row_pitch, dst_depth_pitch, src_subresource, src_box);
    }
    pub fn getHeapProperties(self: *IResource, properties: ?*HEAP_PROPERTIES, flags: ?*HEAP_FLAGS) HRESULT {
        return (self.vtable.get_heap_properties)(self, properties, flags);
    }
    // IPageable methods
    // IDeviceChild methods
    pub fn getDevice(self: *IResource, riid: *const GUID, device: *?*anyopaque) HRESULT {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), riid, device);
    }
    // IObject methods
    pub fn getPrivateData(self: *IResource) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IResource) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IResource) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *IResource) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
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

pub const ICommandAllocator = extern struct {
    pub const IID = GUID.parse("{6102DEE4-AF59-4B09-B999-B44D73F09B24}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IPageable.VTable,
        reset: *const fn (*ICommandAllocator) callconv(.winapi) HRESULT,
    };

    pub fn reset(self: *ICommandAllocator) HRESULT {
        return (self.vtable.reset)(self);
    }
    // IPageable methods
    // IDeviceChild methods
    pub fn getDevice(self: *ICommandAllocator, riid: *const GUID, device: *?*anyopaque) HRESULT {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), riid, device);
    }
    // IObject methods
    pub fn getPrivateData(self: *ICommandAllocator) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *ICommandAllocator) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *ICommandAllocator) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *ICommandAllocator) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *ICommandAllocator, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *ICommandAllocator) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *ICommandAllocator) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const ICommandList = extern struct {
    pub const IID = GUID.parse("{7116D91C-E7E4-47CE-B8C6-EC8168F437E5}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IDeviceChild.VTable,
        get_type: *const fn (*ICommandList) callconv(.winapi) HRESULT,
    };

    pub fn getType(self: *ICommandList) HRESULT {
        return (self.vtable.get_type)(self);
    }
    // IDeviceChild methods
    pub fn getDevice(self: *ICommandList, riid: *const GUID, device: *?*anyopaque) HRESULT {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), riid, device);
    }
    // IObject methods
    pub fn getPrivateData(self: *ICommandList) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *ICommandList) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *ICommandList) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *ICommandList) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
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

pub const IGraphicsCommandList = extern struct {
    pub const IID = GUID.parse("{5B160D0F-AC1B-4185-8BA8-B3AE42A5A455}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: ICommandList.VTable,
        close: *const fn (*IGraphicsCommandList) callconv(.winapi) HRESULT,
        reset: *const fn (*IGraphicsCommandList, allocator: *ICommandAllocator, initial_state: ?*IPipelineState) callconv(.winapi) HRESULT,
        clear_state: *const fn (*IGraphicsCommandList, state: ?*IPipelineState) callconv(.winapi) void,
        draw_instanced: *const fn (*IGraphicsCommandList, vertex_count_per_instance: UINT, instance_count: UINT, start_vertex_location: UINT, start_index_location: UINT) callconv(.winapi) void,
        draw_indexed_instanced: *const fn (*IGraphicsCommandList, index_count_per_instance: UINT, instance_count: UINT, start_index_location: UINT, base_vertex_location: INT, start_instance_location: UINT) callconv(.winapi) void,
        dispatch: *const fn (*IGraphicsCommandList, x: UINT, y: UINT, z: UINT) callconv(.winapi) void,
        copy_buffer_region: *const fn (*IGraphicsCommandList, dst_buffer: *IResource, dst_offset: UINT64, src_buffer: *IResource, src_offset: UINT64, num_bytes: UINT64) callconv(.winapi) void,
        copy_texture_region: *const fn (*IGraphicsCommandList, dst: *const TEXTURE_COPY_LOCATION, dst_x: UINT, dst_y: UINT, dst_z: UINT, src: *const TEXTURE_COPY_LOCATION, src_box: ?*const BOX) callconv(.winapi) void,
        copy_resource: *const fn (*IGraphicsCommandList, dst: *IResource, src: *IResource) callconv(.winapi) void,
        copy_tiles: *const fn (*IGraphicsCommandList, tiled_resource: *IResource, tile_region_start_coordinate: *const TILED_RESOURCE_COORDINATE, tile_region_size: *const TILE_REGION_SIZE, buffer: *IResource, buffer_start_offset_in_bytes: UINT64, flags: TILE_COPY_FLAGS) callconv(.winapi) void,
        resolve_subresource: *const fn (*IGraphicsCommandList, dst_resource: *IResource, dst_subresource: UINT, src_resource: *IResource, src_subresource: UINT, format: dxgi.FORMAT) callconv(.winapi) void,
        ia_set_primitive_topology: *const fn (*IGraphicsCommandList, topology: PRIMITIVE_TOPOLOGY) callconv(.winapi) void,
        rs_set_viewports: *const fn (*IGraphicsCommandList, num: UINT, viewports: [*]const VIEWPORT) callconv(.winapi) void,
        rs_set_scissor_rects: *const fn (*IGraphicsCommandList, num: UINT, rects: [*]const RECT) callconv(.winapi) void,
        om_set_blend_factor: *const fn (*IGraphicsCommandList, blend_factor: *const [4]FLOAT) callconv(.winapi) void,
        om_set_stencil_ref: *const fn (*IGraphicsCommandList, stencil_ref: UINT) callconv(.winapi) void,
        set_pipeline_state: *const fn (*IGraphicsCommandList, pso: *IPipelineState) callconv(.winapi) void,
        resource_barrier: *const fn (*IGraphicsCommandList, num: UINT, barriers: [*]const RESOURCE_BARRIER) callconv(.winapi) void,
        execute_bundle: *const fn (*IGraphicsCommandList, cmdlist: *IGraphicsCommandList) callconv(.winapi) void,
        set_descriptor_heaps: *const fn (*IGraphicsCommandList, num: UINT, heaps: [*]const *IDescriptorHeap) callconv(.winapi) void,
        set_compute_root_signature: *const fn (*IGraphicsCommandList, root_signature: ?*IRootSignature) callconv(.winapi) void,
        set_graphics_root_signature: *const fn (*IGraphicsCommandList, root_signature: ?*IRootSignature) callconv(.winapi) void,
        set_compute_root_descriptor_table: *const fn (*IGraphicsCommandList, root_index: UINT, base_descriptor: GPU_DESCRIPTOR_HANDLE) callconv(.winapi) void,
        set_graphics_root_descriptor_table: *const fn (*IGraphicsCommandList, root_index: UINT, base_descriptor: GPU_DESCRIPTOR_HANDLE) callconv(.winapi) void,
        set_compute_root32_bit_constant: *const fn (*IGraphicsCommandList, index: UINT, data: UINT, offset: UINT) callconv(.winapi) void,
        set_graphics_root32_bit_constant: *const fn (*IGraphicsCommandList, index: UINT, data: UINT, offset: UINT) callconv(.winapi) void,
        set_compute_root32_bit_constants: *const fn (*IGraphicsCommandList, root_index: UINT, num: UINT, data: *const anyopaque, offset: UINT) callconv(.winapi) void,
        set_graphics_root32_bit_constants: *const fn (*IGraphicsCommandList, root_index: UINT, num: UINT, data: *const anyopaque, offset: UINT) callconv(.winapi) void,
        set_compute_root_constant_buffer_view: *const fn (*IGraphicsCommandList, index: UINT, buffer_location: GPU_VIRTUAL_ADDRESS) callconv(.winapi) void,
        set_graphics_root_constant_buffer_view: *const fn (*IGraphicsCommandList, index: UINT, buffer_location: GPU_VIRTUAL_ADDRESS) callconv(.winapi) void,
        set_compute_root_shader_resource_view: *const fn (*IGraphicsCommandList, index: UINT, buffer_location: GPU_VIRTUAL_ADDRESS) callconv(.winapi) void,
        set_graphics_root_shader_resource_view: *const fn (*IGraphicsCommandList, index: UINT, buffer_location: GPU_VIRTUAL_ADDRESS) callconv(.winapi) void,
        set_compute_root_unordered_access_view: *const fn (*IGraphicsCommandList, index: UINT, buffer_location: GPU_VIRTUAL_ADDRESS) callconv(.winapi) void,
        set_graphics_root_unordered_access_view: *const fn (*IGraphicsCommandList, index: UINT, buffer_location: GPU_VIRTUAL_ADDRESS) callconv(.winapi) void,
        ia_set_index_buffer: *const fn (*IGraphicsCommandList, view: ?*const INDEX_BUFFER_VIEW) callconv(.winapi) void,
        ia_set_vertex_buffers: *const fn (*IGraphicsCommandList, start_slot: UINT, num_views: UINT, views: ?[*]const VERTEX_BUFFER_VIEW) callconv(.winapi) void,
        so_set_targets: *const fn (*IGraphicsCommandList, start_slote: UINT, num_views: UINT, views: ?[*]const STREAM_OUTPUT_BUFFER_VIEW) callconv(.winapi) void,
        om_set_render_targets: *const fn (*IGraphicsCommandList, num_rt_descriptors: UINT, rt_descriptors: ?[*]const CPU_DESCRIPTOR_HANDLE, single_handle: BOOL, ds_descriptors: ?*const CPU_DESCRIPTOR_HANDLE) callconv(.winapi) void,
        clear_depth_stencil_view: *const fn (*IGraphicsCommandList, ds_view: CPU_DESCRIPTOR_HANDLE, clear_flags: CLEAR_FLAGS, depth: FLOAT, stencil: UINT8, num_rects: UINT, rects: ?[*]const RECT) callconv(.winapi) void,
        clear_render_target_view: *const fn (*IGraphicsCommandList, rt_view: CPU_DESCRIPTOR_HANDLE, rgba: *const [4]FLOAT, num_rects: UINT, rects: ?[*]const RECT) callconv(.winapi) void,
        clear_unordered_access_view_uint: *const fn (*IGraphicsCommandList, gpu_view: GPU_DESCRIPTOR_HANDLE, cpu_view: CPU_DESCRIPTOR_HANDLE, resource: *IResource, values: *const [4]UINT, num_rects: UINT, rects: ?[*]const RECT) callconv(.winapi) void,
        clear_unordered_access_view_float: *const fn (*IGraphicsCommandList, gpu_view: GPU_DESCRIPTOR_HANDLE, cpu_view: CPU_DESCRIPTOR_HANDLE, resource: *IResource, values: *const [4]FLOAT, num_rects: UINT, rects: ?[*]const RECT) callconv(.winapi) void,
        discard_resource: *const fn (*IGraphicsCommandList, resource: *IResource, region: ?*const DISCARD_REGION) callconv(.winapi) void,
        begin_query: *const fn (*IGraphicsCommandList, query: *IQueryHeap, query_type: QUERY_TYPE, index: UINT) callconv(.winapi) void,
        end_query: *const fn (*IGraphicsCommandList, query: *IQueryHeap, query_type: QUERY_TYPE, index: UINT) callconv(.winapi) void,
        resolve_query_data: *const fn (*IGraphicsCommandList, query: *IQueryHeap, query_type: QUERY_TYPE, start_index: UINT, num_queries: UINT, dst_resource: *IResource, buffer_offset: UINT64) callconv(.winapi) void,
        set_predication: *const fn (*IGraphicsCommandList, buffer: ?*IResource, buffer_offset: UINT64, operation: PREDICATION_OP) callconv(.winapi) void,
        set_marker: *const fn (*IGraphicsCommandList, metadata: UINT, data: ?*const anyopaque, size: UINT) callconv(.winapi) void,
        begin_event: *const fn (*IGraphicsCommandList, metadata: UINT, data: ?*const anyopaque, size: UINT) callconv(.winapi) void,
        end_event: *const fn (*IGraphicsCommandList) callconv(.winapi) void,
        execute_indirect: *const fn (*IGraphicsCommandList, command_signature: *ICommandSignature, max_commend_count: UINT, arg_buffer: *IResource, arg_buffer_offset: UINT64, count_buffer: ?*IResource, count_buffer_offset: UINT64) callconv(.winapi) void,
    };

    pub fn close(self: *IGraphicsCommandList) HRESULT {
        return (self.vtable.close)(self);
    }
    pub fn reset(self: *IGraphicsCommandList, allocator: *ICommandAllocator, initial_state: ?*IPipelineState) HRESULT {
        return (self.vtable.reset)(self, allocator, initial_state);
    }
    pub fn clearState(self: *IGraphicsCommandList, state: ?*IPipelineState) void {
        return (self.vtable.clear_state)(self, state);
    }
    pub fn drawInstanced(self: *IGraphicsCommandList, vertex_count_per_instance: UINT, instance_count: UINT, start_vertex_location: UINT, start_index_location: UINT) void {
        return (self.vtable.draw_instanced)(self, vertex_count_per_instance, instance_count, start_vertex_location, start_index_location);
    }
    pub fn drawIndexedInstanced(self: *IGraphicsCommandList, index_count_per_instance: UINT, instance_count: UINT, start_index_location: UINT, base_vertex_location: INT, start_instance_location: UINT) void {
        return (self.vtable.draw_indexed_instanced)(self, index_count_per_instance, instance_count, start_index_location, base_vertex_location, start_instance_location);
    }
    pub fn dispatch(self: *IGraphicsCommandList, x: UINT, y: UINT, z: UINT) void {
        return (self.vtable.dispatch)(self, x, y, z);
    }
    pub fn copyBufferRegion(self: *IGraphicsCommandList, dst_buffer: *IResource, dst_offset: UINT64, src_buffer: *IResource, src_offset: UINT64, num_bytes: UINT64) void {
        return (self.vtable.copy_buffer_region)(self, dst_buffer, dst_offset, src_buffer, src_offset, num_bytes);
    }
    pub fn copyTextureRegion(self: *IGraphicsCommandList, dst: *const TEXTURE_COPY_LOCATION, dst_x: UINT, dst_y: UINT, dst_z: UINT, src: *const TEXTURE_COPY_LOCATION, src_box: ?*const BOX) void {
        return (self.vtable.copy_texture_region)(self, dst, dst_x, dst_y, dst_z, src, src_box);
    }
    pub fn copyResource(self: *IGraphicsCommandList, dst: *IResource, src: *IResource) void {
        return (self.vtable.copy_resource)(self, dst, src);
    }
    pub fn copyTiles(self: *IGraphicsCommandList, tiled_resource: *IResource, tile_region_start_coordinate: *const TILED_RESOURCE_COORDINATE, tile_region_size: *const TILE_REGION_SIZE, buffer: *IResource, buffer_start_offset_in_bytes: UINT64, flags: TILE_COPY_FLAGS) void {
        return (self.vtable.copy_tiles)(self, tiled_resource, tile_region_start_coordinate, tile_region_size, buffer, buffer_start_offset_in_bytes, flags);
    }
    pub fn resolveSubresource(self: *IGraphicsCommandList, dst_resource: *IResource, dst_subresource: UINT, src_resource: *IResource, src_subresource: UINT, format: dxgi.FORMAT) void {
        return (self.vtable.resolve_subresource)(self, dst_resource, dst_subresource, src_resource, src_subresource, format);
    }
    pub fn iaSetPrimitiveTopology(self: *IGraphicsCommandList, topology: PRIMITIVE_TOPOLOGY) void {
        return (self.vtable.ia_set_primitive_topology)(self, topology);
    }
    pub fn rsSetViewports(self: *IGraphicsCommandList, num: UINT, viewports: [*]const VIEWPORT) void {
        return (self.vtable.rs_set_viewports)(self, num, viewports);
    }
    pub fn rsSetScissorRects(self: *IGraphicsCommandList, num: UINT, rects: [*]const RECT) void {
        return (self.vtable.rs_set_scissor_rects)(self, num, rects);
    }
    pub fn omSetBlendFactor(self: *IGraphicsCommandList, blend_factor: *const [4]FLOAT) void {
        return (self.vtable.om_set_blend_factor)(self, blend_factor);
    }
    pub fn omSetStencilRef(self: *IGraphicsCommandList, stencil_ref: UINT) void {
        return (self.vtable.om_set_stencil_ref)(self, stencil_ref);
    }
    pub fn setPipelineState(self: *IGraphicsCommandList, pso: *IPipelineState) void {
        return (self.vtable.set_pipeline_state)(self, pso);
    }
    pub fn resourceBarrier(self: *IGraphicsCommandList, num: UINT, barriers: [*]const RESOURCE_BARRIER) void {
        return (self.vtable.resource_barrier)(self, num, barriers);
    }
    pub fn executeBundle(self: *IGraphicsCommandList, cmdlist: *IGraphicsCommandList) void {
        return (self.vtable.execute_bundle)(self, cmdlist);
    }
    pub fn setDescriptorHeaps(self: *IGraphicsCommandList, num: UINT, heaps: [*]const *IDescriptorHeap) void {
        return (self.vtable.set_descriptor_heaps)(self, num, heaps);
    }
    pub fn setComputeRootSignature(self: *IGraphicsCommandList, root_signature: ?*IRootSignature) void {
        return (self.vtable.set_compute_root_signature)(self, root_signature);
    }
    pub fn setGraphicsRootSignature(self: *IGraphicsCommandList, root_signature: ?*IRootSignature) void {
        return (self.vtable.set_graphics_root_signature)(self, root_signature);
    }
    pub fn setComputeRootDescriptorTable(self: *IGraphicsCommandList, root_index: UINT, base_descriptor: GPU_DESCRIPTOR_HANDLE) void {
        return (self.vtable.set_compute_root_descriptor_table)(self, root_index, base_descriptor);
    }
    pub fn setGraphicsRootDescriptorTable(self: *IGraphicsCommandList, root_index: UINT, base_descriptor: GPU_DESCRIPTOR_HANDLE) void {
        return (self.vtable.set_graphics_root_descriptor_table)(self, root_index, base_descriptor);
    }
    pub fn setComputeRoot32BitConstant(self: *IGraphicsCommandList, index: UINT, data: UINT, offset: UINT) void {
        return (self.vtable.set_compute_root32_bit_constant)(self, index, data, offset);
    }
    pub fn setGraphicsRoot32BitConstant(self: *IGraphicsCommandList, index: UINT, data: UINT, offset: UINT) void {
        return (self.vtable.set_graphics_root32_bit_constant)(self, index, data, offset);
    }
    pub fn setComputeRoot32BitConstants(self: *IGraphicsCommandList, root_index: UINT, num: UINT, data: *const anyopaque, offset: UINT) void {
        return (self.vtable.set_compute_root32_bit_constants)(self, root_index, num, data, offset);
    }
    pub fn setGraphicsRoot32BitConstants(self: *IGraphicsCommandList, root_index: UINT, num: UINT, data: *const anyopaque, offset: UINT) void {
        return (self.vtable.set_graphics_root32_bit_constants)(self, root_index, num, data, offset);
    }
    pub fn setComputeRootConstantBufferView(self: *IGraphicsCommandList, index: UINT, buffer_location: GPU_VIRTUAL_ADDRESS) void {
        return (self.vtable.set_compute_root_constant_buffer_view)(self, index, buffer_location);
    }
    pub fn setGraphicsRootConstantBufferView(self: *IGraphicsCommandList, index: UINT, buffer_location: GPU_VIRTUAL_ADDRESS) void {
        return (self.vtable.set_graphics_root_constant_buffer_view)(self, index, buffer_location);
    }
    pub fn setComputeRootShaderResourceView(self: *IGraphicsCommandList, index: UINT, buffer_location: GPU_VIRTUAL_ADDRESS) void {
        return (self.vtable.set_compute_root_shader_resource_view)(self, index, buffer_location);
    }
    pub fn setGraphicsRootShaderResourceView(self: *IGraphicsCommandList, index: UINT, buffer_location: GPU_VIRTUAL_ADDRESS) void {
        return (self.vtable.set_graphics_root_shader_resource_view)(self, index, buffer_location);
    }
    pub fn setComputeRootUnorderedAccessView(self: *IGraphicsCommandList, index: UINT, buffer_location: GPU_VIRTUAL_ADDRESS) void {
        return (self.vtable.set_compute_root_unordered_access_view)(self, index, buffer_location);
    }
    pub fn setGraphicsRootUnorderedAccessView(self: *IGraphicsCommandList, index: UINT, buffer_location: GPU_VIRTUAL_ADDRESS) void {
        return (self.vtable.set_graphics_root_unordered_access_view)(self, index, buffer_location);
    }
    pub fn iaSetIndexBuffer(self: *IGraphicsCommandList, view: ?*const INDEX_BUFFER_VIEW) void {
        return (self.vtable.ia_set_index_buffer)(self, view);
    }
    pub fn iaSetVertexBuffers(self: *IGraphicsCommandList, start_slot: UINT, num_views: UINT, views: ?[*]const VERTEX_BUFFER_VIEW) void {
        return (self.vtable.ia_set_vertex_buffers)(self, start_slot, num_views, views);
    }
    pub fn soSetTargets(self: *IGraphicsCommandList, start_slote: UINT, num_views: UINT, views: ?[*]const STREAM_OUTPUT_BUFFER_VIEW) void {
        return (self.vtable.so_set_targets)(self, start_slote, num_views, views);
    }
    pub fn omSetRenderTargets(self: *IGraphicsCommandList, num_rt_descriptors: UINT, rt_descriptors: ?[*]const CPU_DESCRIPTOR_HANDLE, single_handle: BOOL, ds_descriptors: ?*const CPU_DESCRIPTOR_HANDLE) void {
        return (self.vtable.om_set_render_targets)(self, num_rt_descriptors, rt_descriptors, single_handle, ds_descriptors);
    }
    pub fn clearDepthStencilView(self: *IGraphicsCommandList, ds_view: CPU_DESCRIPTOR_HANDLE, clear_flags: CLEAR_FLAGS, depth: FLOAT, stencil: UINT8, num_rects: UINT, rects: ?[*]const RECT) void {
        return (self.vtable.clear_depth_stencil_view)(self, ds_view, clear_flags, depth, stencil, num_rects, rects);
    }
    pub fn clearRenderTargetView(self: *IGraphicsCommandList, rt_view: CPU_DESCRIPTOR_HANDLE, rgba: *const [4]FLOAT, num_rects: UINT, rects: ?[*]const RECT) void {
        return (self.vtable.clear_render_target_view)(self, rt_view, rgba, num_rects, rects);
    }
    pub fn clearUnorderedAccessViewUint(self: *IGraphicsCommandList, gpu_view: GPU_DESCRIPTOR_HANDLE, cpu_view: CPU_DESCRIPTOR_HANDLE, resource: *IResource, values: *const [4]UINT, num_rects: UINT, rects: ?[*]const RECT) void {
        return (self.vtable.clear_unordered_access_view_uint)(self, gpu_view, cpu_view, resource, values, num_rects, rects);
    }
    pub fn clearUnorderedAccessViewFloat(self: *IGraphicsCommandList, gpu_view: GPU_DESCRIPTOR_HANDLE, cpu_view: CPU_DESCRIPTOR_HANDLE, resource: *IResource, values: *const [4]FLOAT, num_rects: UINT, rects: ?[*]const RECT) void {
        return (self.vtable.clear_unordered_access_view_float)(self, gpu_view, cpu_view, resource, values, num_rects, rects);
    }
    pub fn discardResource(self: *IGraphicsCommandList, resource: *IResource, region: ?*const DISCARD_REGION) void {
        return (self.vtable.discard_resource)(self, resource, region);
    }
    pub fn beginQuery(self: *IGraphicsCommandList, query: *IQueryHeap, query_type: QUERY_TYPE, index: UINT) void {
        return (self.vtable.begin_query)(self, query, query_type, index);
    }
    pub fn endQuery(self: *IGraphicsCommandList, query: *IQueryHeap, query_type: QUERY_TYPE, index: UINT) void {
        return (self.vtable.end_query)(self, query, query_type, index);
    }
    pub fn resolveQueryData(self: *IGraphicsCommandList, query: *IQueryHeap, query_type: QUERY_TYPE, start_index: UINT, num_queries: UINT, dst_resource: *IResource, buffer_offset: UINT64) void {
        return (self.vtable.resolve_query_data)(self, query, query_type, start_index, num_queries, dst_resource, buffer_offset);
    }
    pub fn setPredication(self: *IGraphicsCommandList, buffer: ?*IResource, buffer_offset: UINT64, operation: PREDICATION_OP) void {
        return (self.vtable.set_predication)(self, buffer, buffer_offset, operation);
    }
    pub fn setMarker(self: *IGraphicsCommandList, metadata: UINT, data: ?*const anyopaque, size: UINT) void {
        return (self.vtable.set_marker)(self, metadata, data, size);
    }
    pub fn beginEvent(self: *IGraphicsCommandList, metadata: UINT, data: ?*const anyopaque, size: UINT) void {
        return (self.vtable.begin_event)(self, metadata, data, size);
    }
    pub fn endEvent(self: *IGraphicsCommandList) void {
        return (self.vtable.end_event)(self);
    }
    pub fn executeIndirect(self: *IGraphicsCommandList, command_signature: *ICommandSignature, max_commend_count: UINT, arg_buffer: *IResource, arg_buffer_offset: UINT64, count_buffer: ?*IResource, count_buffer_offset: UINT64) void {
        return (self.vtable.execute_indirect)(self, command_signature, max_commend_count, arg_buffer, arg_buffer_offset, count_buffer, count_buffer_offset);
    }
    // ICommandList methods
    pub fn getType(self: *IGraphicsCommandList) HRESULT {
        return (@as(*const ICommandList.VTable, @ptrCast(self.vtable)).get_type)(@ptrCast(self));
    }
    // IDeviceChild methods
    pub fn getDevice(self: *IGraphicsCommandList, riid: *const GUID, device: *?*anyopaque) HRESULT {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), riid, device);
    }
    // IObject methods
    pub fn getPrivateData(self: *IGraphicsCommandList) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IGraphicsCommandList) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IGraphicsCommandList) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *IGraphicsCommandList) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IGraphicsCommandList, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IGraphicsCommandList) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IGraphicsCommandList) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IPipelineState = extern struct {
    pub const IID = GUID.parse("{}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IPageable.VTable,
        get_cached_blob: *const fn (*IPipelineState, blob: **IBlob) callconv(.winapi) HRESULT,
    };

    pub fn getCachedBlob(self: *IPipelineState, blob: **IBlob) HRESULT {
        return (self.vtable.get_cached_blob)(self, blob);
    }
    // IPageable methods
    // IDeviceChild methods
    pub fn getDevice(self: *IPipelineState, riid: *const GUID, device: *?*anyopaque) HRESULT {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), riid, device);
    }
    // IObject methods
    pub fn getPrivateData(self: *IPipelineState) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IPipelineState) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IPipelineState) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *IPipelineState) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IPipelineState, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IPipelineState) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IPipelineState) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IDescriptorHeap = extern struct {
    pub const IID = GUID.parse("{8EFB471D-616C-4F49-90F7-127BB763FA51}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IPageable.VTable,
        get_desc: *const fn (*IDescriptorHeap, desc: *DESCRIPTOR_HEAP_DESC) callconv(.winapi) HRESULT,
        get_cpu_descriptor_handle_for_heap_start: *const fn (*IDescriptorHeap, handle: *CPU_DESCRIPTOR_HANDLE) callconv(.winapi) HRESULT,
        get_gpu_descriptor_handle_for_heap_start: *const fn (*IDescriptorHeap, handle: *GPU_DESCRIPTOR_HANDLE) callconv(.winapi) HRESULT,
    };

    pub fn getDesc(self: *IDescriptorHeap, desc: *DESCRIPTOR_HEAP_DESC) HRESULT {
        return (self.vtable.get_desc)(self, desc);
    }
    pub fn getCpuDescriptorHandleForHeapStart(self: *IDescriptorHeap, handle: *CPU_DESCRIPTOR_HANDLE) HRESULT {
        return (self.vtable.get_cpu_descriptor_handle_for_heap_start)(self, handle);
    }
    pub fn getGpuDescriptorHandleForHeapStart(self: *IDescriptorHeap, handle: *GPU_DESCRIPTOR_HANDLE) HRESULT {
        return (self.vtable.get_gpu_descriptor_handle_for_heap_start)(self, handle);
    }
    // IPageable methods
    // IDeviceChild methods
    pub fn getDevice(self: *IDescriptorHeap, riid: *const GUID, device: *?*anyopaque) HRESULT {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), riid, device);
    }
    // IObject methods
    pub fn getPrivateData(self: *IDescriptorHeap) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IDescriptorHeap) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IDescriptorHeap) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *IDescriptorHeap) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IDescriptorHeap, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IDescriptorHeap) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IDescriptorHeap) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IQueryHeap = extern struct {
    pub const IID = GUID.parse("{}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IPageable.VTable,
    };
    // IPageable methods
    // IDeviceChild methods
    pub fn getDevice(self: *IQueryHeap, riid: *const GUID, device: *?*anyopaque) HRESULT {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), riid, device);
    }
    // IObject methods
    pub fn getPrivateData(self: *IQueryHeap) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IQueryHeap) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IQueryHeap) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *IQueryHeap) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IQueryHeap, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IQueryHeap) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IQueryHeap) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IFence = extern struct {
    pub const IID = GUID.parse("{0a753dcf-c4d8-4b91-adf6-be5a60d95a76}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IPageable.VTable,
        get_complepted_value: *const fn (*IFence) callconv(.winapi) u64,
        set_event_on_completion: *const fn (*IFence, value: u64, event: HANDLE) callconv(.winapi) HRESULT,
        signal: *const fn (*IFence, value: u64) callconv(.winapi) HRESULT,
    };

    pub fn getCompleptedValue(self: *IFence) u64 {
        return (self.vtable.get_complepted_value)(self);
    }
    pub fn setEventOnCompletion(self: *IFence, value: u64, event: HANDLE) HRESULT {
        return (self.vtable.set_event_on_completion)(self, value, event);
    }
    pub fn signal(self: *IFence, value: u64) HRESULT {
        return (self.vtable.signal)(self, value);
    }
    // IPageable methods
    // IDeviceChild methods
    pub fn getDevice(self: *IFence, riid: *const GUID, device: *?*anyopaque) HRESULT {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), riid, device);
    }
    // IObject methods
    pub fn getPrivateData(self: *IFence) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).get_private_data)(@ptrCast(self));
    }
    pub fn setPrivateData(self: *IFence) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data)(@ptrCast(self));
    }
    pub fn setPrivateDataInterface(self: *IFence) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_private_data_interface)(@ptrCast(self));
    }
    pub fn setName(self: *IFence) noreturn {
        return (@as(*const IObject.VTable, @ptrCast(self.vtable)).set_name)(@ptrCast(self));
    }
    // IUnknown methods
    pub fn queryInterface(self: *IFence, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IFence) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IFence) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};
