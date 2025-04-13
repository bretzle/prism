const std = @import("std");

pub fn vcast(comptime f: anytype) VtableFn(@TypeOf(f)) {
    return @ptrCast(&f);
}

fn VtableFn(comptime T: type) type {
    const info = @typeInfo(T).@"fn";

    var params: [info.params.len]std.builtin.Type.Fn.Param = undefined;
    @memcpy(&params, info.params);
    params[0] = .{ .is_generic = false, .is_noalias = false, .type = *anyopaque };

    const U = @Type(.{ .@"fn" = .{
        .calling_convention = info.calling_convention,
        .is_generic = info.is_generic,
        .is_var_args = info.is_var_args,
        .params = &params,
        .return_type = info.return_type,
    } });

    return @Type(.{ .pointer = .{
        .size = .one,
        .is_const = true,
        .is_volatile = false,
        .alignment = 1,
        .address_space = .generic,
        .child = U,
        .is_allowzero = false,
        .sentinel_ptr = null,
    } });
}
