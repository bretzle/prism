const std = @import("std");
const w32 = @import("windows.zig");
const os = std.os.windows;

const GUID = w32.GUID;
const HRESULT = w32.HRESULT;
const SIZE_T = w32.SIZE_T;
const UINT = w32.UINT;
const FLOAT = os.FLOAT;
const BOOL = w32.BOOL;
const INT = w32.INT;
const ULONG = w32.ULONG;

pub const IUnknown = w32.IUnknown;
pub const IObject = w32.IObject;

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
    NodeIndex: UINT,
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

    // IBlob methods
    pub fn getBufferPointer(self: *IBlob) *anyopaque {
        return (@as(*const IBlob.VTable, @ptrCast(self.vtable)).get_buffer_pointer)(@ptrCast(self));
    }
    pub fn getBufferSize(self: *IBlob) SIZE_T {
        return (@as(*const IBlob.VTable, @ptrCast(self.vtable)).get_buffer_size)(@ptrCast(self));
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

    // IDeviceChild methods
    pub fn getDevice(self: *IDeviceChild, riid: *const GUID, device: *?*anyopaque) HRESULT {
        return (@as(*const IDeviceChild.VTable, @ptrCast(self.vtable)).get_device)(@ptrCast(self), riid, device);
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
    pub const IID = GUID.parse("{63ee58fb-1268-4835-86da-f008ce62f0d6}");

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

    // IDebug methods
    pub fn enableDebugLayer(self: *IDebug) void {
        return (@as(*const IDebug.VTable, @ptrCast(self.vtable)).enable_debug_layer)(@ptrCast(self));
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
        create_command_allocator: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_graphics_pipeline_state: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_compute_pipeline_state: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_command_list: *const fn (*IDevice) callconv(.winapi) noreturn,
        check_feature_support: *const fn (*IDevice, feature: FEATURE, data: *anyopaque, size: UINT) callconv(.winapi) HRESULT,
        create_descriptor_heap: *const fn (*IDevice) callconv(.winapi) noreturn,
        get_descriptor_handle_increment_size: *const fn (*IDevice) callconv(.winapi) noreturn,
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
        create_fence: *const fn (*IDevice) callconv(.winapi) noreturn,
        get_device_removed_reason: *const fn (*IDevice) callconv(.winapi) noreturn,
        get_copyable_footprints: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_query_heap: *const fn (*IDevice) callconv(.winapi) noreturn,
        set_stable_power_state: *const fn (*IDevice) callconv(.winapi) noreturn,
        create_command_signature: *const fn (*IDevice, desc: *const COMMAND_SIGNATURE_DESC, root_signature: ?*IRootSignature, riid: *const GUID, signature: ?*?*anyopaque) callconv(.winapi) HRESULT,
        get_resource_tiling: *const fn (*IDevice) callconv(.winapi) noreturn,
        get_adapter_luid: *const fn (*IDevice) callconv(.winapi) noreturn,
    };

    // IDevice methods
    pub fn getNodeCount(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).get_node_count)(@ptrCast(self));
    }
    pub fn createCommandQueue(self: *IDevice, desc: *const COMMAND_QUEUE_DESC, riid: *const GUID, command_queue: *?*anyopaque) HRESULT {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).create_command_queue)(@ptrCast(self), desc, riid, command_queue);
    }
    pub fn createCommandAllocator(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).create_command_allocator)(@ptrCast(self));
    }
    pub fn createGraphicsPipelineState(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).create_graphics_pipeline_state)(@ptrCast(self));
    }
    pub fn createComputePipelineState(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).create_compute_pipeline_state)(@ptrCast(self));
    }
    pub fn createCommandList(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).create_command_list)(@ptrCast(self));
    }
    pub fn checkFeatureSupport(self: *IDevice, feature: FEATURE, data: *anyopaque, size: UINT) HRESULT {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).check_feature_support)(@ptrCast(self), feature, data, size);
    }
    pub fn createDescriptorHeap(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).create_descriptor_heap)(@ptrCast(self));
    }
    pub fn getDescriptorHandleIncrementSize(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).get_descriptor_handle_increment_size)(@ptrCast(self));
    }
    pub fn createRootSignature(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).create_root_signature)(@ptrCast(self));
    }
    pub fn createConstantBufferView(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).create_constant_buffer_view)(@ptrCast(self));
    }
    pub fn createShaderResourceView(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).create_shader_resource_view)(@ptrCast(self));
    }
    pub fn createUnorderedAccessView(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).create_unordered_access_view)(@ptrCast(self));
    }
    pub fn createRenderTargetView(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).create_render_target_view)(@ptrCast(self));
    }
    pub fn createDepthStencilView(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).create_depth_stencil_view)(@ptrCast(self));
    }
    pub fn createSampler(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).create_sampler)(@ptrCast(self));
    }
    pub fn copyDescriptors(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).copy_descriptors)(@ptrCast(self));
    }
    pub fn copyDescriptorsSimple(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).copy_descriptors_simple)(@ptrCast(self));
    }
    pub fn getResourceAllocationInfo(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).get_resource_allocation_info)(@ptrCast(self));
    }
    pub fn getCustomHeapProperties(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).get_custom_heap_properties)(@ptrCast(self));
    }
    pub fn createCommittedResource(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).create_committed_resource)(@ptrCast(self));
    }
    pub fn createHeap(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).create_heap)(@ptrCast(self));
    }
    pub fn createPlacedResource(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).create_placed_resource)(@ptrCast(self));
    }
    pub fn createReservedResource(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).create_reserved_resource)(@ptrCast(self));
    }
    pub fn createSharedHandle(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).create_shared_handle)(@ptrCast(self));
    }
    pub fn openSharedHandle(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).open_shared_handle)(@ptrCast(self));
    }
    pub fn openSharedHandleByName(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).open_shared_handle_by_name)(@ptrCast(self));
    }
    pub fn makeResident(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).make_resident)(@ptrCast(self));
    }
    pub fn evict(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).evict)(@ptrCast(self));
    }
    pub fn createFence(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).create_fence)(@ptrCast(self));
    }
    pub fn getDeviceRemovedReason(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).get_device_removed_reason)(@ptrCast(self));
    }
    pub fn getCopyableFootprints(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).get_copyable_footprints)(@ptrCast(self));
    }
    pub fn createQueryHeap(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).create_query_heap)(@ptrCast(self));
    }
    pub fn setStablePowerState(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).set_stable_power_state)(@ptrCast(self));
    }
    pub fn createCommandSignature(self: *IDevice, desc: *const COMMAND_SIGNATURE_DESC, root_signature: ?*IRootSignature, riid: *const GUID, signature: ?*?*anyopaque) HRESULT {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).create_command_signature)(@ptrCast(self), desc, root_signature, riid, signature);
    }
    pub fn getResourceTiling(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).get_resource_tiling)(@ptrCast(self));
    }
    pub fn getAdapterLuid(self: *IDevice) noreturn {
        return (@as(*const IDevice.VTable, @ptrCast(self.vtable)).get_adapter_luid)(@ptrCast(self));
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
        signal: *const fn (*ICommandQueue) callconv(.winapi) noreturn,
        wait: *const fn (*ICommandQueue) callconv(.winapi) noreturn,
        get_timestamp_frequency: *const fn (*ICommandQueue) callconv(.winapi) noreturn,
        get_clock_calibration: *const fn (*ICommandQueue) callconv(.winapi) noreturn,
        get_desc: *const fn (*ICommandQueue) callconv(.winapi) noreturn,
    };

    // ICommandQueue methods
    pub fn updateTileMappings(self: *ICommandQueue) noreturn {
        return (@as(*const ICommandQueue.VTable, @ptrCast(self.vtable)).update_tile_mappings)(@ptrCast(self));
    }
    pub fn copyTileMappings(self: *ICommandQueue) noreturn {
        return (@as(*const ICommandQueue.VTable, @ptrCast(self.vtable)).copy_tile_mappings)(@ptrCast(self));
    }
    pub fn executeCommandLists(self: *ICommandQueue) noreturn {
        return (@as(*const ICommandQueue.VTable, @ptrCast(self.vtable)).execute_command_lists)(@ptrCast(self));
    }
    pub fn setMarker(self: *ICommandQueue) noreturn {
        return (@as(*const ICommandQueue.VTable, @ptrCast(self.vtable)).set_marker)(@ptrCast(self));
    }
    pub fn beginEvent(self: *ICommandQueue) noreturn {
        return (@as(*const ICommandQueue.VTable, @ptrCast(self.vtable)).begin_event)(@ptrCast(self));
    }
    pub fn endEvent(self: *ICommandQueue) noreturn {
        return (@as(*const ICommandQueue.VTable, @ptrCast(self.vtable)).end_event)(@ptrCast(self));
    }
    pub fn signal(self: *ICommandQueue) noreturn {
        return (@as(*const ICommandQueue.VTable, @ptrCast(self.vtable)).signal)(@ptrCast(self));
    }
    pub fn wait(self: *ICommandQueue) noreturn {
        return (@as(*const ICommandQueue.VTable, @ptrCast(self.vtable)).wait)(@ptrCast(self));
    }
    pub fn getTimestampFrequency(self: *ICommandQueue) noreturn {
        return (@as(*const ICommandQueue.VTable, @ptrCast(self.vtable)).get_timestamp_frequency)(@ptrCast(self));
    }
    pub fn getClockCalibration(self: *ICommandQueue) noreturn {
        return (@as(*const ICommandQueue.VTable, @ptrCast(self.vtable)).get_clock_calibration)(@ptrCast(self));
    }
    pub fn getDesc(self: *ICommandQueue) noreturn {
        return (@as(*const ICommandQueue.VTable, @ptrCast(self.vtable)).get_desc)(@ptrCast(self));
    }
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
