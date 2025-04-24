const std = @import("std");
const builtin = @import("builtin");

pub const impl = switch (builtin.os.tag) {
    .windows => @import("d3d12/d3d12.zig"),
    else => unreachable,
};

pub const types = @import("types.zig");
pub const shader = @import("shader");

pub const Adapter = @import("sys/adapter.zig").Adapter;
pub const BindGroupLayout = @import("sys/bind_group_layout.zig").BindGroupLayout;
pub const BindGroup = @import("sys/bind_group.zig").BindGroup;
pub const Buffer = @import("sys/buffer.zig").Buffer;
pub const CommandBuffer = @import("sys/command_buffer.zig").CommandBuffer;
pub const CommandEncoder = @import("sys/command_encoder.zig").CommandEncoder;
pub const ComputePassEncoder = @import("sys/compute_pass_encoder.zig").ComputePassEncoder;
pub const ComputePipeline = @import("sys/compute_pipeline.zig").ComputePipeline;
pub const Device = @import("sys/device.zig").Device;
pub const ExternalTexture = @import("sys/external_texture.zig").ExternalTexture;
pub const Instance = @import("sys/instance.zig").Instance;
pub const PipelineLayout = @import("sys/pipeline_layout.zig").PipelineLayout;
pub const QuerySet = @import("sys/query_set.zig").QuerySet;
pub const Queue = @import("sys/queue.zig").Queue;
pub const RenderBundleEncoder = @import("sys/render_bundle_encoder.zig").RenderBundleEncoder;
pub const RenderBundle = @import("sys/render_bundle.zig").RenderBundle;
pub const RenderPassEncoder = @import("sys/render_pass_encoder.zig").RenderPassEncoder;
pub const RenderPipeline = @import("sys/render_pipeline.zig").RenderPipeline;
pub const Sampler = @import("sys/sampler.zig").Sampler;
pub const ShaderModule = @import("sys/shader_module.zig").ShaderModule;
pub const SharedFence = @import("sys/shared_fence.zig").SharedFence;
pub const SharedTextureMemory = @import("sys/shared_texture_memory.zig").SharedTextureMemory;
pub const Surface = @import("sys/surface.zig").Surface;
pub const SwapChain = @import("sys/swap_chain.zig").SwapChain;
pub const TextureView = @import("sys/texture_view.zig").TextureView;
pub const Texture = @import("sys/texture.zig").Texture;

test {
    std.testing.refAllDeclsRecursive(@This());
}
