const std = @import("std");
const d3dcommon = @import("d3dcommon.zig");
const d3d11 = @import("d3d11.zig");

const IUnknown = d3dcommon.IUnknown;

const GUID = std.os.windows.GUID;
const HRESULT = std.os.windows.HRESULT;
const LPCSTR = std.os.windows.LPCSTR;
const UINT = std.os.windows.UINT;
const SIZE_T = std.os.windows.SIZE_T;
const ULONG = std.os.windows.ULONG;

pub const COMPILE_FLAG = UINT;
pub const COMPILE_DEBUG: COMPILE_FLAG = (1 << 0);
pub const COMPILE_SKIP_VALIDATION: COMPILE_FLAG = (1 << 1);
pub const COMPILE_SKIP_OPTIMIZATION: COMPILE_FLAG = (1 << 2);
pub const COMPILE_PACK_MATRIX_ROW_MAJOR: COMPILE_FLAG = (1 << 3);
pub const COMPILE_PACK_MATRIX_COLUMN_MAJOR: COMPILE_FLAG = (1 << 4);
pub const COMPILE_PARTIAL_PRECISION: COMPILE_FLAG = (1 << 5);
pub const COMPILE_FORCE_VS_SOFTWARE_NO_OPT: COMPILE_FLAG = (1 << 6);
pub const COMPILE_FORCE_PS_SOFTWARE_NO_OPT: COMPILE_FLAG = (1 << 7);
pub const COMPILE_NO_PRESHADER: COMPILE_FLAG = (1 << 8);
pub const COMPILE_AVOID_FLOW_CONTROL: COMPILE_FLAG = (1 << 9);
pub const COMPILE_PREFER_FLOW_CONTROL: COMPILE_FLAG = (1 << 10);
pub const COMPILE_ENABLE_STRICTNESS: COMPILE_FLAG = (1 << 11);
pub const COMPILE_ENABLE_BACKWARDS_COMPATIBILITY: COMPILE_FLAG = (1 << 12);
pub const COMPILE_IEEE_STRICTNESS: COMPILE_FLAG = (1 << 13);
pub const COMPILE_OPTIMIZATION_LEVEL0: COMPILE_FLAG = (1 << 14);
pub const COMPILE_OPTIMIZATION_LEVEL1: COMPILE_FLAG = 0;
pub const COMPILE_OPTIMIZATION_LEVEL2: COMPILE_FLAG = ((1 << 14) | (1 << 15));
pub const COMPILE_OPTIMIZATION_LEVEL3: COMPILE_FLAG = (1 << 15);
pub const COMPILE_RESERVED16: COMPILE_FLAG = (1 << 16);
pub const COMPILE_RESERVED17: COMPILE_FLAG = (1 << 17);
pub const COMPILE_WARNINGS_ARE_ERRORS: COMPILE_FLAG = (1 << 18);
pub const COMPILE_RESOURCES_MAY_ALIAS: COMPILE_FLAG = (1 << 19);
pub const COMPILE_ENABLE_UNBOUNDED_DESCRIPTOR_TABLES: COMPILE_FLAG = (1 << 20);
pub const COMPILE_ALL_RESOURCES_BOUND: COMPILE_FLAG = (1 << 21);
pub const COMPILE_DEBUG_NAME_FOR_SOURCE: COMPILE_FLAG = (1 << 22);
pub const COMPILE_DEBUG_NAME_FOR_BINARY: COMPILE_FLAG = (1 << 23);

// functions
// ---------

pub extern "D3DCompiler_47" fn D3DCompile(
    pSrcData: *const anyopaque,
    SrcDataSize: SIZE_T,
    pSourceName: ?LPCSTR,
    pDefines: ?*const SHADER_MACRO,
    pInclude: ?*const IInclude,
    pEntrypoint: LPCSTR,
    pTarget: LPCSTR,
    Flags1: UINT,
    Flags2: UINT,
    ppCode: **d3dcommon.IBlob,
    ppErrorMsgs: ?**d3dcommon.IBlob,
) callconv(.winapi) HRESULT;

pub extern "D3DCompiler_47" fn D3DReflect(
    pSrcData: *const anyopaque,
    SrcDataSize: SIZE_T,
    pInterface: *const std.os.windows.GUID,
    ppReflector: *?*IShaderReflection,
) callconv(.winapi) HRESULT;

// types
// -----

pub const PRIMITIVE_TOPOLOGY = d3dcommon.PRIMITIVE_TOPOLOGY;

pub const SHADER_MACRO = extern struct {
    Name: LPCSTR,
    Definition: LPCSTR,
};

pub const PRIMITIVE = enum(u32) {};

pub const TESSELLATOR_OUTPUT_PRIMITIVE = enum(UINT) {};

pub const TESSELLATOR_PARTITIONING = enum(UINT) {};

pub const TESSELLATOR_DOMAIN = enum(UINT) {
    UNDEFINED = 0,
    ISOLINE = 1,
    TRI = 2,
    QUAD = 3,
};

pub const SRV_DIMENSION = enum(UINT) {
    UNKNOWN = 0,
    BUFFER = 1,
    TEXTURE1D = 2,
    TEXTURE1DARRAY = 3,
    TEXTURE2D = 4,
    TEXTURE2DARRAY = 5,
    TEXTURE2DMS = 6,
    TEXTURE2DMSARRAY = 7,
    TEXTURE3D = 8,
    TEXTURECUBE = 9,
    TEXTURECUBEARRAY = 10,
    BUFFEREX = 11,
};

pub const SHADER_INPUT_BIND_DESC = extern struct {
    Name: LPCSTR,
    Type: SHADER_INPUT_TYPE,
    BindPoint: UINT,
    BindCount: UINT,

    uFlags: UINT,
    ReturnType: RESOURCE_RETURN_TYPE,
    Dimension: SRV_DIMENSION,
    NumSamples: UINT,
};

pub const SHADER_INPUT_TYPE = enum(UINT) {
    CBUFFER = 0,
    TBUFFER = 1,
    TEXTURE = 2,
    SAMPLER = 3,
    UAV_RWTYPED = 4,
    STRUCTURED = 5,
    UAV_RWSTRUCTURED = 6,
    BYTEADDRESS = 7,
    UAV_RWBYTEADDRESS = 8,
    UAV_APPEND_STRUCTURED = 9,
    UAV_CONSUME_STRUCTURED = 10,
    UAV_RWSTRUCTURED_WITH_COUNTER = 11,
    RTACCELERATIONSTRUCTURE = 12,
    UAV_FEEDBACKTEXTURE = 13,
};

pub const RESOURCE_RETURN_TYPE = enum(UINT) {
    UNORM = 1,
    SNORM = 2,
    SINT = 3,
    UINT = 4,
    FLOAT = 5,
    MIXED = 6,
    DOUBLE = 7,
    CONTINUED = 8,
};

pub const CBUFFER_TYPE = enum(UINT) {
    CBUFFER = 0,
    TBUFFER = 1,
    INTERFACE_POINTERS = 2,
    RESOURCE_BIND_INFO = 3,
};

pub const SHADER_VARIABLE_CLASS = enum(UINT) {
    SCALAR = 0,
    VECTOR = 1,
    MATRIX_ROWS = 2,
    MATRIX_COLUMNS = 3,
    OBJECT = 4,
    STRUCT = 5,
    INTERFACE_CLASS = 6,
    INTERFACE_POINTER = 7,
};

pub const SHADER_VARIABLE_TYPE = enum(UINT) {
    VOID = 0,
    BOOL = 1,
    INT = 2,
    FLOAT = 3,
    STRING = 4,
    TEXTURE = 5,
    TEXTURE1D = 6,
    TEXTURE2D = 7,
    TEXTURE3D = 8,
    TEXTURECUBE = 9,
    SAMPLER = 10,
    SAMPLER1D = 11,
    SAMPLER2D = 12,
    SAMPLER3D = 13,
    SAMPLERCUBE = 14,
    PIXELSHADER = 15,
    VERTEXSHADER = 16,
    PIXELFRAGMENT = 17,
    VERTEXFRAGMENT = 18,
    UINT = 19,
    UINT8 = 20,
    GEOMETRYSHADER = 21,
    RASTERIZER = 22,
    DEPTHSTENCIL = 23,
    BLEND = 24,
    BUFFER = 25,
    CBUFFER = 26,
    TBUFFER = 27,
    TEXTURE1DARRAY = 28,
    TEXTURE2DARRAY = 29,
    RENDERTARGETVIEW = 30,
    DEPTHSTENCILVIEW = 31,
    TEXTURE2DMS = 32,
    TEXTURE2DMSARRAY = 33,
    TEXTURECUBEARRAY = 34,
    HULLSHADER = 35,
    DOMAINSHADER = 36,
    INTERFACE_POINTER = 37,
    COMPUTESHADER = 38,
    DOUBLE = 39,
    RWTEXTURE1D = 40,
    RWTEXTURE1DARRAY = 41,
    RWTEXTURE2D = 42,
    RWTEXTURE2DARRAY = 43,
    RWTEXTURE3D = 44,
    RWBUFFER = 45,
    BYTEADDRESS_BUFFER = 46,
    RWBYTEADDRESS_BUFFER = 47,
    STRUCTURED_BUFFER = 48,
    RWSTRUCTURED_BUFFER = 49,
    APPEND_STRUCTURED_BUFFER = 50,
    CONSUME_STRUCTURED_BUFFER = 51,
    MIN8FLOAT = 52,
    MIN10FLOAT = 53,
    MIN16FLOAT = 54,
    MIN12INT = 55,
    MIN16INT = 56,
    MIN16UINT = 57,
    INT16 = 58,
    UINT16 = 59,
    FLOAT16 = 60,
    INT64 = 61,
    UINT64 = 62,
};

pub const SHADER_DESC = extern struct {
    Version: UINT,
    Creator: LPCSTR,
    Flags: UINT,
    ConstantBuffers: UINT,
    BoundResources: UINT,
    InputParameters: UINT,
    OutputParameters: UINT,
    InstructionCount: UINT,
    TempRegisterCount: UINT,
    TempArrayCount: UINT,
    DefCount: UINT,
    DclCount: UINT,
    TextureNormalInstructions: UINT,
    TextureLoadInstructions: UINT,
    TextureCompInstructions: UINT,
    TextureBiasInstructions: UINT,
    TextureGradientInstructions: UINT,
    FloatInstructionCount: UINT,
    IntInstructionCount: UINT,
    UintInstructionCount: UINT,
    StaticFlowControlCount: UINT,
    DynamicFlowControlCount: UINT,
    MacroInstructionCount: UINT,
    ArrayInstructionCount: UINT,
    CutInstructionCount: UINT,
    EmitInstructionCount: UINT,
    GSOutputTopology: PRIMITIVE_TOPOLOGY,
    GSMaxOutputVertexCount: UINT,
    InputPrimitive: PRIMITIVE,
    PatchConstantParameters: UINT,
    cGSInstanceCount: UINT,
    cControlPoints: UINT,
    HSOutputPrimitive: TESSELLATOR_OUTPUT_PRIMITIVE,
    HSPartitioning: TESSELLATOR_PARTITIONING,
    TessellatorDomain: TESSELLATOR_DOMAIN,
    cBarrierInstructions: UINT,
    cInterlockedInstructions: UINT,
    cTextureStoreInstructions: UINT,
};

pub const SHADER_BUFFER_DESC = extern struct {
    Name: LPCSTR,
    Type: CBUFFER_TYPE,
    Variables: UINT,
    Size: UINT,
    uFlags: UINT,
};

pub const SHADER_VARIABLE_DESC = extern struct {
    Name: LPCSTR,
    StartOffset: UINT,
    Size: UINT,
    uFlags: UINT,
    DefaultValue: *anyopaque,
    StartTexture: UINT,
    TextureSize: UINT,
    StartSampler: UINT,
    SamplerSize: UINT,
};

pub const SHADER_TYPE_DESC = extern struct {
    Class: SHADER_VARIABLE_CLASS,
    Type: SHADER_VARIABLE_TYPE,
    Rows: UINT,
    Columns: UINT,
    Elements: UINT,
    Members: UINT,
    Offset: UINT,
    Name: LPCSTR,
};

// THIS FILE IS AUTOGENERATED BEYOND THIS POINT! DO NOT EDIT!
// ----------------------------------------------------------

pub const IInclude = extern struct {
    pub const IID = GUID.parse("{}");

    vtable: *const VTable,

    const VTable = extern struct {
    };
};

pub const IShaderReflection = extern struct {
    pub const IID = GUID.parse("{8d536ca1-0cca-4956-a837-786963755584}");

    vtable: *const VTable,

    const VTable = extern struct {
        base: IUnknown.VTable,
        get_desc: *const fn (*IShaderReflection, desc: *SHADER_DESC) callconv(.winapi) HRESULT,
        get_constant_buffer_by_index: *const fn (*IShaderReflection, index: UINT) callconv(.winapi) *IShaderReflectionConstantBuffer,
        get_constant_buffer_by_name: *const fn (*IShaderReflection) callconv(.winapi) noreturn,
        get_resource_binding_desc: *const fn (*IShaderReflection, index: UINT, desc: *SHADER_INPUT_BIND_DESC) callconv(.winapi) HRESULT,
        get_bitwise_instruction_count: *const fn (*IShaderReflection) callconv(.winapi) noreturn,
        get_conversion_instruction_count: *const fn (*IShaderReflection) callconv(.winapi) noreturn,
        get_g_s_input_primitive: *const fn (*IShaderReflection) callconv(.winapi) noreturn,
        get_input_parameter_desc: *const fn (*IShaderReflection) callconv(.winapi) noreturn,
        get_min_feature_level: *const fn (*IShaderReflection) callconv(.winapi) noreturn,
        get_movc_instruction_count: *const fn (*IShaderReflection) callconv(.winapi) noreturn,
        get_mov_instruction_count: *const fn (*IShaderReflection) callconv(.winapi) noreturn,
        get_num_interface_slots: *const fn (*IShaderReflection) callconv(.winapi) noreturn,
        get_output_parameter_desc: *const fn (*IShaderReflection) callconv(.winapi) noreturn,
        get_patch_constant_parameter_desc: *const fn (*IShaderReflection) callconv(.winapi) noreturn,
        get_requires_flags: *const fn (*IShaderReflection) callconv(.winapi) noreturn,
        get_resource_binding_desc_by_name: *const fn (*IShaderReflection) callconv(.winapi) noreturn,
        get_thread_group_size: *const fn (*IShaderReflection) callconv(.winapi) noreturn,
        get_variable_by_name: *const fn (*IShaderReflection) callconv(.winapi) noreturn,
        is_sample_frequency_shader: *const fn (*IShaderReflection) callconv(.winapi) noreturn,
    };

    pub fn getDesc(self: *IShaderReflection, desc: *SHADER_DESC) HRESULT {
        return (self.vtable.get_desc)(self, desc);
    }
    pub fn getConstantBufferByIndex(self: *IShaderReflection, index: UINT) *IShaderReflectionConstantBuffer {
        return (self.vtable.get_constant_buffer_by_index)(self, index);
    }
    pub fn getConstantBufferByName(self: *IShaderReflection) noreturn {
        return (self.vtable.get_constant_buffer_by_name)(self);
    }
    pub fn getResourceBindingDesc(self: *IShaderReflection, index: UINT, desc: *SHADER_INPUT_BIND_DESC) HRESULT {
        return (self.vtable.get_resource_binding_desc)(self, index, desc);
    }
    pub fn getBitwiseInstructionCount(self: *IShaderReflection) noreturn {
        return (self.vtable.get_bitwise_instruction_count)(self);
    }
    pub fn getConversionInstructionCount(self: *IShaderReflection) noreturn {
        return (self.vtable.get_conversion_instruction_count)(self);
    }
    pub fn getGSInputPrimitive(self: *IShaderReflection) noreturn {
        return (self.vtable.get_g_s_input_primitive)(self);
    }
    pub fn getInputParameterDesc(self: *IShaderReflection) noreturn {
        return (self.vtable.get_input_parameter_desc)(self);
    }
    pub fn getMinFeatureLevel(self: *IShaderReflection) noreturn {
        return (self.vtable.get_min_feature_level)(self);
    }
    pub fn getMovcInstructionCount(self: *IShaderReflection) noreturn {
        return (self.vtable.get_movc_instruction_count)(self);
    }
    pub fn getMovInstructionCount(self: *IShaderReflection) noreturn {
        return (self.vtable.get_mov_instruction_count)(self);
    }
    pub fn getNumInterfaceSlots(self: *IShaderReflection) noreturn {
        return (self.vtable.get_num_interface_slots)(self);
    }
    pub fn getOutputParameterDesc(self: *IShaderReflection) noreturn {
        return (self.vtable.get_output_parameter_desc)(self);
    }
    pub fn getPatchConstantParameterDesc(self: *IShaderReflection) noreturn {
        return (self.vtable.get_patch_constant_parameter_desc)(self);
    }
    pub fn getRequiresFlags(self: *IShaderReflection) noreturn {
        return (self.vtable.get_requires_flags)(self);
    }
    pub fn getResourceBindingDescByName(self: *IShaderReflection) noreturn {
        return (self.vtable.get_resource_binding_desc_by_name)(self);
    }
    pub fn getThreadGroupSize(self: *IShaderReflection) noreturn {
        return (self.vtable.get_thread_group_size)(self);
    }
    pub fn getVariableByName(self: *IShaderReflection) noreturn {
        return (self.vtable.get_variable_by_name)(self);
    }
    pub fn isSampleFrequencyShader(self: *IShaderReflection) noreturn {
        return (self.vtable.is_sample_frequency_shader)(self);
    }
    // IUnknown methods
    pub fn queryInterface(self: *IShaderReflection, riid: *const GUID, out: *?*anyopaque) HRESULT {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).query_interface)(@ptrCast(self), riid, out);
    }
    pub fn addRef(self: *IShaderReflection) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).add_ref)(@ptrCast(self));
    }
    pub fn release(self: *IShaderReflection) ULONG {
        return (@as(*const IUnknown.VTable, @ptrCast(self.vtable)).release)(@ptrCast(self));
    }
};

pub const IShaderReflectionConstantBuffer = extern struct {
    pub const IID = GUID.parse("{}");

    vtable: *const VTable,

    const VTable = extern struct {
        get_desc: *const fn (*IShaderReflectionConstantBuffer, desc: *SHADER_BUFFER_DESC) callconv(.winapi) void,
        get_variable_by_index: *const fn (*IShaderReflectionConstantBuffer, index: u32) callconv(.winapi) *IShaderReflectionVariable,
        get_variable_by_name: *const fn (*IShaderReflectionConstantBuffer, name: LPCSTR) callconv(.winapi) *IShaderReflectionVariable,
    };

    pub fn getDesc(self: *IShaderReflectionConstantBuffer, desc: *SHADER_BUFFER_DESC) void {
        return (self.vtable.get_desc)(self, desc);
    }
    pub fn getVariableByIndex(self: *IShaderReflectionConstantBuffer, index: u32) *IShaderReflectionVariable {
        return (self.vtable.get_variable_by_index)(self, index);
    }
    pub fn getVariableByName(self: *IShaderReflectionConstantBuffer, name: LPCSTR) *IShaderReflectionVariable {
        return (self.vtable.get_variable_by_name)(self, name);
    }
};

pub const IShaderReflectionVariable = extern struct {
    pub const IID = GUID.parse("{}");

    vtable: *const VTable,

    const VTable = extern struct {
        get_desc: *const fn (*IShaderReflectionVariable, desc: *SHADER_VARIABLE_DESC) callconv(.winapi) void,
        get_type: *const fn (*IShaderReflectionVariable) callconv(.winapi) *IShaderReflectionType,
        get_buffer: *const fn (*IShaderReflectionVariable) callconv(.winapi) noreturn,
        get_interface_slot: *const fn (*IShaderReflectionVariable) callconv(.winapi) noreturn,
    };

    pub fn getDesc(self: *IShaderReflectionVariable, desc: *SHADER_VARIABLE_DESC) void {
        return (self.vtable.get_desc)(self, desc);
    }
    pub fn getType(self: *IShaderReflectionVariable) *IShaderReflectionType {
        return (self.vtable.get_type)(self);
    }
    pub fn getBuffer(self: *IShaderReflectionVariable) noreturn {
        return (self.vtable.get_buffer)(self);
    }
    pub fn getInterfaceSlot(self: *IShaderReflectionVariable) noreturn {
        return (self.vtable.get_interface_slot)(self);
    }
};

pub const IShaderReflectionType = extern struct {
    pub const IID = GUID.parse("{}");

    vtable: *const VTable,

    const VTable = extern struct {
        get_desc: *const fn (*IShaderReflectionType, desc: *SHADER_TYPE_DESC) callconv(.winapi) HRESULT,
        get_member_type_by_index: *const fn (*IShaderReflectionType) callconv(.winapi) noreturn,
        get_member_type_by_name: *const fn (*IShaderReflectionType) callconv(.winapi) noreturn,
        get_member_type_name: *const fn (*IShaderReflectionType) callconv(.winapi) noreturn,
        is_equal: *const fn (*IShaderReflectionType) callconv(.winapi) noreturn,
        get_sub_type: *const fn (*IShaderReflectionType) callconv(.winapi) noreturn,
        get_base_class: *const fn (*IShaderReflectionType) callconv(.winapi) noreturn,
        get_num_interfaces: *const fn (*IShaderReflectionType) callconv(.winapi) noreturn,
        get_interface_by_index: *const fn (*IShaderReflectionType) callconv(.winapi) noreturn,
        is_of_type: *const fn (*IShaderReflectionType) callconv(.winapi) noreturn,
        implements_interface: *const fn (*IShaderReflectionType) callconv(.winapi) noreturn,
    };

    pub fn getDesc(self: *IShaderReflectionType, desc: *SHADER_TYPE_DESC) HRESULT {
        return (self.vtable.get_desc)(self, desc);
    }
    pub fn getMemberTypeByIndex(self: *IShaderReflectionType) noreturn {
        return (self.vtable.get_member_type_by_index)(self);
    }
    pub fn getMemberTypeByName(self: *IShaderReflectionType) noreturn {
        return (self.vtable.get_member_type_by_name)(self);
    }
    pub fn getMemberTypeName(self: *IShaderReflectionType) noreturn {
        return (self.vtable.get_member_type_name)(self);
    }
    pub fn isEqual(self: *IShaderReflectionType) noreturn {
        return (self.vtable.is_equal)(self);
    }
    pub fn getSubType(self: *IShaderReflectionType) noreturn {
        return (self.vtable.get_sub_type)(self);
    }
    pub fn getBaseClass(self: *IShaderReflectionType) noreturn {
        return (self.vtable.get_base_class)(self);
    }
    pub fn getNumInterfaces(self: *IShaderReflectionType) noreturn {
        return (self.vtable.get_num_interfaces)(self);
    }
    pub fn getInterfaceByIndex(self: *IShaderReflectionType) noreturn {
        return (self.vtable.get_interface_by_index)(self);
    }
    pub fn isOfType(self: *IShaderReflectionType) noreturn {
        return (self.vtable.is_of_type)(self);
    }
    pub fn implementsInterface(self: *IShaderReflectionType) noreturn {
        return (self.vtable.implements_interface)(self);
    }
};
