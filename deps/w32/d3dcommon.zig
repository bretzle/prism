const windows = @import("std").os.windows;

const GUID = windows.GUID;
const HRESULT = windows.HRESULT;
const ULONG = windows.ULONG;
const SIZE_T = windows.SIZE_T;

pub const IUnknown = extern struct {
    pub const IID = GUID.parse("{00000000-0000-0000-C000-000000000046}");

    vtable: *const VTable,

    pub const VTable = extern struct {
        query_interface: *const fn (*IUnknown, *const GUID, ?*?*anyopaque) callconv(.winapi) HRESULT,
        add_ref: *const fn (*IUnknown) callconv(.winapi) ULONG,
        release: *const fn (*IUnknown) callconv(.winapi) ULONG,
    };
};

pub const IObject = extern struct {
    pub const IID = GUID.parse("{AEC22FB8-76F3-4639-9BE0-28EB43A67A2E}");
    pub const DebugObjectName = GUID.parse("{4CCA5FD8-921F-42C8-8566-70CAF2A9B741}");

    vtable: *const VTable,

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        get_private_data: *anyopaque,
        set_private_data: *const fn (*IObject, guid: *const GUID, DataSize: u32, pData: ?*const anyopaque) callconv(.winapi) HRESULT,
        set_private_data_interface: *anyopaque,
        set_name: *anyopaque,
    };

    pub fn setPrivateData(self: *IObject, guid: *const GUID, data_size: u32, data: ?*const anyopaque) HRESULT {
        return (self.vtable.set_private_data)(self, guid, data_size, data);
    }
};

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

pub const DRIVER_TYPE = enum(u32) {
    UNKNOWN = 0,
    HARDWARE = 1,
    REFERENCE = 2,
    NULL = 3,
    SOFTWARE = 4,
    WARP = 5,
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

pub const PRIMITIVE_TOPOLOGY = enum(u32) {
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
