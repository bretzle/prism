const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;
const types = gpu.types;
const shader = gpu.shader;

const Adapter = @import("adapter.zig").Adapter;
const Queue = @import("queue.zig").Queue;
const BindGroup = @import("bind_group.zig").BindGroup;
const BindGroupLayout = @import("bind_group.zig").BindGroupLayout;
const Buffer = @import("buffer.zig").Buffer;
const CommandEncoder = @import("command.zig").CommandEncoder;
const ComputePipeline = @import("pipeline.zig").ComputePipeline;
const ExternalTexture = @import("texture.zig").ExternalTexture;
const PipelineLayout = @import("pipeline.zig").PipelineLayout;
const QuerySet = @import("query_set.zig").QuerySet;
const RenderBundleEncoder = @import("pass.zig").RenderBundleEncoder;
const RenderPipeline = @import("pipeline.zig").RenderPipeline;
const Sampler = @import("sampler.zig").Sampler;
const ShaderModule = @import("shader_module.zig").ShaderModule;
const Surface = @import("surface.zig").Surface;
const SwapChain = @import("swap_chain.zig").SwapChain;
const Texture = @import("texture.zig").Texture;

const FeatureName = types.FeatureName;
const RequiredLimits = types.RequiredLimits;
const SupportedLimits = types.SupportedLimits;
const ErrorType = types.ErrorType;
const ErrorFilter = types.ErrorFilter;
const LoggingType = types.LoggingType;
const CreatePipelineAsyncStatus = types.CreatePipelineAsyncStatus;
const LoggingCallback = types.LoggingCallback;
const ErrorCallback = types.ErrorCallback;
const CreateComputePipelineAsyncCallback = types.CreateComputePipelineAsyncCallback;
const CreateRenderPipelineAsyncCallback = types.CreateRenderPipelineAsyncCallback;

const allocator = @import("../../prism.zig").allocator;

pub const Device = opaque {
    pub const LostCallback = *const fn (reason: LostReason, message: [:0]const u8, userdata: ?*anyopaque) void;

    pub const LostReason = enum { undefined, destroyed };

    pub const Descriptor = struct {
        label: ?[:0]const u8 = null,
        required_features: ?[]const FeatureName = null,
        required_limits: ?*const RequiredLimits = null,
        default_queue: Queue.Descriptor = Queue.Descriptor{},
        // device_lost_callback: LostCallback,
        // device_lost_userdata: ?*anyopaque,
    };

    pub inline fn createBindGroup(self: *Device, desc: BindGroup.Descriptor) *BindGroup {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = desc; // autofix
        unreachable;
    }

    pub inline fn createBindGroupLayout(self: *Device, desc: BindGroupLayout.Descriptor) *BindGroupLayout {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = desc; // autofix
        unreachable;
    }

    pub inline fn createBuffer(self: *Device, desc: Buffer.Descriptor) *Buffer {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = desc; // autofix
        unreachable;
    }

    pub inline fn createCommandEncoder(self: *Device, desc: CommandEncoder.Descriptor) !*CommandEncoder {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        const command_encoder = try impl.CommandEncoder.create(device, desc);
        return @ptrCast(command_encoder);
    }

    pub inline fn createComputePipeline(self: *Device, desc: ComputePipeline.Descriptor) *ComputePipeline {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = desc; // autofix
        unreachable;
    }

    pub inline fn createComputePipelineAsync(
        self: *Device,
        desc: ComputePipeline.Descriptor,
        context: anytype,
        comptime callback: fn (status: CreatePipelineAsyncStatus, compute_pipeline: *ComputePipeline, message: [:0]const u8, ctx: @TypeOf(context)) callconv(.Inline) void,
    ) void {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = desc; // autofix
        _ = callback; // autofix
        unreachable;
    }

    pub inline fn createErrorBuffer(self: *Device, desc: Buffer.Descriptor) *Buffer {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = desc; // autofix
        unreachable;
    }

    pub inline fn createErrorExternalTexture(self: *Device) *ExternalTexture {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        unreachable;
    }

    pub inline fn createErrorTexture(self: *Device, desc: Texture.Descriptor) *Texture {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = desc; // autofix
        unreachable;
    }

    pub inline fn createExternalTexture(self: *Device, desc: ExternalTexture.Descriptor) *ExternalTexture {
        _ = desc; // autofix
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        unreachable;
    }

    pub inline fn createPipelineLayout(self: *Device, desc: PipelineLayout.Descriptor) *PipelineLayout {
        _ = desc; // autofix
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        unreachable;
    }

    pub inline fn createQuerySet(self: *Device, desc: QuerySet.Descriptor) *QuerySet {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = desc; // autofix
        unreachable;
    }

    pub inline fn createRenderBundleEncoder(self: *Device, desc: RenderBundleEncoder.Descriptor) *RenderBundleEncoder {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = desc; // autofix
        unreachable;
    }

    pub inline fn createRenderPipeline(self: *Device, desc: RenderPipeline.Descriptor) !*RenderPipeline {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        const render_pipeline = try impl.RenderPipeline.create(device, desc);
        return @ptrCast(render_pipeline);
    }

    pub inline fn createRenderPipelineAsync(
        self: *Device,
        desc: RenderPipeline.Descriptor,
        context: anytype,
        comptime callback: fn (ctx: @TypeOf(context), status: CreatePipelineAsyncStatus, pipeline: *RenderPipeline, message: [:0]const u8) callconv(.Inline) void,
    ) void {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = desc; // autofix
        _ = callback; // autofix
        unreachable;
    }

    pub inline fn createSampler(self: *Device, desc: ?Sampler.Descriptor) *Sampler {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = desc; // autofix
        unreachable;
    }

    // pub inline fn createShaderModule(self: *Device, desc: ShaderModule.Descriptor) !*ShaderModule {
    //     const device: *impl.Device = @alignCast(@ptrCast(self));
    //     _ = desc; // autofix
    //     unreachable;
    // }

    /// Helper to make createShaderModule invocations slightly nicer.
    pub inline fn createShaderModuleWGSL(self: *Device, label: ?[:0]const u8, code: [:0]const u8) !*ShaderModule {
        const device: *impl.Device = @alignCast(@ptrCast(self));

        var errors = try shader.ErrorList.init(allocator);
        var ast = try shader.Ast.parse(allocator, &errors, code);
        defer ast.deinit(allocator);

        const air = try allocator.create(shader.Air);
        air.* = shader.Air.generate(allocator, &ast, &errors, null) catch |err| switch (err) {
            error.AnalysisFail => {
                errors.print(code, null) catch @panic("api error");
                std.process.exit(1);
            },
            else => @panic("api error"),
        };

        const shader_module = try impl.ShaderModule.create(device, air, label);
        return @ptrCast(shader_module);
    }

    pub inline fn createSwapChain(self: *Device, surface_: *Surface, desc: SwapChain.Descriptor) !*SwapChain {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        const surface: *impl.Surface = @alignCast(@ptrCast(surface_));
        const swapchain = try impl.SwapChain.create(device, surface, desc);
        return @ptrCast(swapchain);
    }

    pub inline fn createTexture(self: *Device, desc: Texture.Descriptor) *Texture {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = desc; // autofix
        unreachable;
    }

    pub inline fn destroy(self: *Device) void {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        unreachable;
    }

    /// Enumerates the adapter features, storing the result in an allocated slice which is owned by
    /// the caller.
    pub inline fn enumerateFeatures(self: *Device) ![]FeatureName {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = allocator; // autofix
        unreachable;
    }

    pub inline fn forceLoss(self: *Device, reason: LostReason, message: [:0]const u8) void {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = reason; // autofix
        _ = message; // autofix
        unreachable;
    }

    pub inline fn getAdapter(self: *Device) *Adapter {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        unreachable;
    }

    pub inline fn getLimits(self: *Device, limits: *SupportedLimits) bool {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = limits; // autofix
        unreachable;
    }

    pub inline fn getQueue(self: *Device) !*Queue {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        const queue = try device.getQueue();
        queue.manager.reference();
        return @ptrCast(queue);
    }

    pub inline fn hasFeature(self: *Device, feature: FeatureName) bool {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = feature; // autofix
        unreachable;
    }

    pub inline fn injectError(self: *Device, typ: ErrorType, message: [:0]const u8) void {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = typ; // autofix
        _ = message; // autofix
        unreachable;
    }

    pub inline fn popErrorScope(
        self: *Device,
        context: anytype,
        comptime callback: fn (ctx: @TypeOf(context), typ: ErrorType, message: [:0]const u8) callconv(.Inline) void,
    ) void {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = callback; // autofix
        unreachable;
    }

    pub inline fn pushErrorScope(self: *Device, filter: ErrorFilter) void {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = filter; // autofix
        unreachable;
    }

    pub inline fn setDeviceLostCallback(
        self: *Device,
        context: anytype,
        comptime callback: ?fn (ctx: @TypeOf(context), reason: LostReason, message: [:0]const u8) callconv(.Inline) void,
    ) void {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = callback; // autofix
        unreachable;
    }

    pub inline fn setLoggingCallback(
        self: *Device,
        context: anytype,
        comptime callback: ?fn (ctx: @TypeOf(context), typ: LoggingType, message: [:0]const u8) callconv(.Inline) void,
    ) void {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = callback; // autofix
        unreachable;
    }

    pub inline fn setUncapturedErrorCallback(
        self: *Device,
        context: anytype,
        comptime callback: ?fn (ctx: @TypeOf(context), typ: ErrorType, message: [:0]const u8) callconv(.Inline) void,
    ) void {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = callback; // autofix
        unreachable;
    }

    pub inline fn tick(self: *Device) !void {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        try device.tick();
    }

    // When making Metal interop with other APIs, we need to be careful that QueueSubmit doesn't
    // mean that the operations will be visible to other APIs/Metal devices right away. macOS
    // does have a global queue of graphics operations, but the command buffers are inserted there
    // when they are "scheduled". Submitting other operations before the command buffer is
    // scheduled could lead to races in who gets scheduled first and incorrect rendering.
    pub inline fn machWaitForCommandsToBeScheduled(self: *Device) void {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        unreachable;
    }

    pub inline fn validateTextureDescriptor(self: *Device, desc: Texture.Descriptor) void {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = desc; // autofix
        unreachable;
    }

    pub inline fn setLabel(self: *Device, label: [:0]const u8) void {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        _ = device; // autofix
        _ = label; // autofix
        unreachable;
    }

    pub inline fn reference(self: *Device) void {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        device.manager.reference();
    }

    pub inline fn release(self: *Device) void {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        device.manager.release();
    }
};
