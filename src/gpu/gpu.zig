const std = @import("std");
const builtin = @import("builtin");

pub const impl = switch (builtin.os.tag) {
    .windows => @import("d3d12/d3d12.zig"),
    else => unreachable,
};

pub const types = @import("types.zig");
pub const shader = @import("shader");

pub const Adapter = @import("sys/adapter.zig").Adapter;
pub const BindGroupLayout = @import("sys/bind_group.zig").BindGroupLayout;
pub const BindGroup = @import("sys/bind_group.zig").BindGroup;
pub const Buffer = @import("sys/buffer.zig").Buffer;
pub const CommandBuffer = @import("sys/command.zig").CommandBuffer;
pub const CommandEncoder = @import("sys/command.zig").CommandEncoder;
pub const ComputePassEncoder = @import("sys/pass.zig").ComputePassEncoder;
pub const ComputePipeline = @import("sys/pipeline.zig").ComputePipeline;
pub const Device = @import("sys/device.zig").Device;
pub const ExternalTexture = @import("sys/texture.zig").ExternalTexture;
pub const Instance = @import("sys/instance.zig").Instance;
pub const PipelineLayout = @import("sys/pipeline.zig").PipelineLayout;
pub const QuerySet = @import("sys/query_set.zig").QuerySet;
pub const Queue = @import("sys/queue.zig").Queue;
pub const RenderBundleEncoder = @import("sys/pass.zig").RenderBundleEncoder;
pub const RenderBundle = @import("sys/pass.zig").RenderBundle;
pub const RenderPassEncoder = @import("sys/pass.zig").RenderPassEncoder;
pub const RenderPipeline = @import("sys/pipeline.zig").RenderPipeline;
pub const Sampler = @import("sys/sampler.zig").Sampler;
pub const ShaderModule = @import("sys/shader_module.zig").ShaderModule;
pub const SharedFence = @import("sys/shared_fence.zig").SharedFence;
pub const SharedTextureMemory = @import("sys/shared_texture_memory.zig").SharedTextureMemory;
pub const Surface = @import("sys/surface.zig").Surface;
pub const SwapChain = @import("sys/swap_chain.zig").SwapChain;
pub const TextureView = @import("sys/texture.zig").TextureView;
pub const Texture = @import("sys/texture.zig").Texture;

test {
    _ = impl;
    _ = types;
    _ = Adapter;
    _ = BindGroupLayout;
    _ = BindGroup;
    _ = Buffer;
    _ = CommandBuffer;
    _ = CommandEncoder;
    _ = ComputePassEncoder;
    _ = ComputePipeline;
    _ = Device;
    _ = ExternalTexture;
    _ = Instance;
    _ = PipelineLayout;
    _ = QuerySet;
    _ = Queue;
    _ = RenderBundleEncoder;
    _ = RenderBundle;
    _ = RenderPassEncoder;
    _ = RenderPipeline;
    _ = Sampler;
    _ = ShaderModule;
    _ = SharedFence;
    _ = SharedTextureMemory;
    _ = Surface;
    _ = SwapChain;
    _ = TextureView;
    _ = Texture;
}
