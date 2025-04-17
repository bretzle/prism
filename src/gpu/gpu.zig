const std = @import("std");
const prism = @import("../prism.zig");
const platform = @import("../platform/platform.zig");
const internal = @import("internal.zig");

const d3d12 = @import("d3d12.zig");

const allocator = prism.allocator;

pub const Implementation = enum { d3d12 };

pub const Context = struct {
    ptr: *anyopaque,
    vtable: struct {
        destroy: *const fn (*anyopaque) void,
        create_device: *const fn (*anyopaque, window: *platform.Window) anyerror!*Device,
    },

    pub fn create(comptime impl: Implementation) !Context {
        switch (impl) {
            .d3d12 => return try d3d12.Context.create(),
        }
    }

    pub fn destroy(self: *Context) void {
        (self.vtable.destroy)(self.ptr);
    }

    pub fn createDevice(self: *Context, window: *platform.Window) !*Device {
        return try (self.vtable.create_device)(self.ptr, window);
    }
};

pub const Device = struct {
    ptr: *anyopaque,
    vtable: struct {
        // Device
        destroy: *const fn (*anyopaque) void,
        get_command_buffer_header: *const fn (*CommandBuffer) *internal.CommandBufferHeader,

        // State Creation
        // ComputePipeline *(*CreateComputePipeline)( Renderer *driverData, const ComputePipelineCreateInfo *createinfo);
        // GraphicsPipeline *(*CreateGraphicsPipeline)( Renderer *driverData, const GraphicsPipelineCreateInfo *createinfo);
        // Sampler *(*CreateSampler)( Renderer *driverData, const SamplerCreateInfo *createinfo);
        // Shader *(*CreateShader)( Renderer *driverData, const ShaderCreateInfo *createinfo);
        // Texture *(*CreateTexture)( Renderer *driverData, const TextureCreateInfo *createinfo);
        // Buffer *(*CreateBuffer)( Renderer *driverData, BufferUsageFlags usageFlags, Uint32 size, const char *debugName);
        // TransferBuffer *(*CreateTransferBuffer)( Renderer *driverData, TransferBufferUsage usage, Uint32 size, const char *debugName);

        // Debug Naming
        // void (*SetBufferName)( Renderer *driverData, Buffer *buffer, const char *text);
        // void (*SetTextureName)( Renderer *driverData, Texture *texture, const char *text);
        // void (*InsertDebugLabel)( CommandBuffer *commandBuffer, const char *text);
        // void (*PushDebugGroup)( CommandBuffer *commandBuffer, const char *name);
        // void (*PopDebugGroup)( CommandBuffer *commandBuffer);

        // Disposal
        // void (*ReleaseTexture)( Renderer *driverData, Texture *texture);
        // void (*ReleaseSampler)( Renderer *driverData, Sampler *sampler);
        // void (*ReleaseBuffer)( Renderer *driverData, Buffer *buffer);
        // void (*ReleaseTransferBuffer)( Renderer *driverData, TransferBuffer *transferBuffer);
        // void (*ReleaseShader)( Renderer *driverData, Shader *shader);
        // void (*ReleaseComputePipeline)( Renderer *driverData, ComputePipeline *computePipeline);
        // void (*ReleaseGraphicsPipeline)( Renderer *driverData, GraphicsPipeline *graphicsPipeline);

        // Render Pass
        // void (*BeginRenderPass)( CommandBuffer *commandBuffer, const ColorTargetInfo *colorTargetInfos, Uint32 numColorTargets, const DepthStencilTargetInfo *depthStencilTargetInfo);
        // void (*BindGraphicsPipeline)( CommandBuffer *commandBuffer, GraphicsPipeline *graphicsPipeline);
        // void (*SetViewport)( CommandBuffer *commandBuffer, const Viewport *viewport);
        // void (*SetScissor)( CommandBuffer *commandBuffer, const SDL_Rect *scissor);
        // void (*SetBlendConstants)( CommandBuffer *commandBuffer, SDL_FColor blendConstants);
        // void (*SetStencilReference)( CommandBuffer *commandBuffer, Uint8 reference);
        // void (*BindVertexBuffers)( CommandBuffer *commandBuffer, Uint32 firstSlot, const BufferBinding *bindings, Uint32 numBindings);
        // void (*BindIndexBuffer)( CommandBuffer *commandBuffer, const BufferBinding *binding, IndexElementSize indexElementSize);
        // void (*BindVertexSamplers)( CommandBuffer *commandBuffer, Uint32 firstSlot, const TextureSamplerBinding *textureSamplerBindings, Uint32 numBindings);
        // void (*BindVertexStorageTextures)( CommandBuffer *commandBuffer, Uint32 firstSlot, Texture *const *storageTextures, Uint32 numBindings);
        // void (*BindVertexStorageBuffers)( CommandBuffer *commandBuffer, Uint32 firstSlot, Buffer *const *storageBuffers, Uint32 numBindings);
        // void (*BindFragmentSamplers)( CommandBuffer *commandBuffer, Uint32 firstSlot, const TextureSamplerBinding *textureSamplerBindings, Uint32 numBindings);
        // void (*BindFragmentStorageTextures)( CommandBuffer *commandBuffer, Uint32 firstSlot, Texture *const *storageTextures, Uint32 numBindings);
        // void (*BindFragmentStorageBuffers)( CommandBuffer *commandBuffer, Uint32 firstSlot, Buffer *const *storageBuffers, Uint32 numBindings);
        // void (*PushVertexUniformData)( CommandBuffer *commandBuffer, Uint32 slotIndex, const void *data, Uint32 length);
        // void (*PushFragmentUniformData)( CommandBuffer *commandBuffer, Uint32 slotIndex, const void *data, Uint32 length);
        // void (*DrawIndexedPrimitives)( CommandBuffer *commandBuffer, Uint32 numIndices, Uint32 numInstances, Uint32 firstIndex, Sint32 vertexOffset, Uint32 firstInstance);
        // void (*DrawPrimitives)( CommandBuffer *commandBuffer, Uint32 numVertices, Uint32 numInstances, Uint32 firstVertex, Uint32 firstInstance);
        // void (*DrawPrimitivesIndirect)( CommandBuffer *commandBuffer, Buffer *buffer, Uint32 offset, Uint32 drawCount);
        // void (*DrawIndexedPrimitivesIndirect)( CommandBuffer *commandBuffer, Buffer *buffer, Uint32 offset, Uint32 drawCount);
        // void (*EndRenderPass)( CommandBuffer *commandBuffer);

        // Compute Pass
        // void (*BeginComputePass)( CommandBuffer *commandBuffer, const StorageTextureReadWriteBinding *storageTextureBindings, Uint32 numStorageTextureBindings, const StorageBufferReadWriteBinding *storageBufferBindings, Uint32 numStorageBufferBindings);
        // void (*BindComputePipeline)( CommandBuffer *commandBuffer, ComputePipeline *computePipeline);
        // void (*BindComputeSamplers)( CommandBuffer *commandBuffer, Uint32 firstSlot, const TextureSamplerBinding *textureSamplerBindings, Uint32 numBindings);
        // void (*BindComputeStorageTextures)( CommandBuffer *commandBuffer, Uint32 firstSlot, Texture *const *storageTextures, Uint32 numBindings);
        // void (*BindComputeStorageBuffers)( CommandBuffer *commandBuffer, Uint32 firstSlot, Buffer *const *storageBuffers, Uint32 numBindings);
        // void (*PushComputeUniformData)( CommandBuffer *commandBuffer, Uint32 slotIndex, const void *data, Uint32 length);
        // void (*DispatchCompute)( CommandBuffer *commandBuffer, Uint32 groupcountX, Uint32 groupcountY, Uint32 groupcountZ);
        // void (*DispatchComputeIndirect)( CommandBuffer *commandBuffer, Buffer *buffer, Uint32 offset);
        // void (*EndComputePass)( CommandBuffer *commandBuffer);

        // TransferBuffer Data
        // void *(*MapTransferBuffer)( Renderer *device, TransferBuffer *transferBuffer, bool cycle);
        // void (*UnmapTransferBuffer)( Renderer *device, TransferBuffer *transferBuffer);

        // Copy Pass
        // void (*BeginCopyPass)( CommandBuffer *commandBuffer);
        // void (*UploadToTexture)( CommandBuffer *commandBuffer, const TextureTransferInfo *source, const TextureRegion *destination, bool cycle);
        // void (*UploadToBuffer)( CommandBuffer *commandBuffer, const TransferBufferLocation *source, const BufferRegion *destination, bool cycle);
        // void (*CopyTextureToTexture)( CommandBuffer *commandBuffer, const TextureLocation *source, const TextureLocation *destination, Uint32 w, Uint32 h, Uint32 d, bool cycle);
        // void (*CopyBufferToBuffer)( CommandBuffer *commandBuffer, const BufferLocation *source, const BufferLocation *destination, Uint32 size, bool cycle);
        // void (*GenerateMipmaps)( CommandBuffer *commandBuffer, Texture *texture);
        // void (*DownloadFromTexture)( CommandBuffer *commandBuffer, const TextureRegion *source, const TextureTransferInfo *destination);
        // void (*DownloadFromBuffer)( CommandBuffer *commandBuffer, const BufferRegion *source, const TransferBufferLocation *destination);
        // void (*EndCopyPass)( CommandBuffer *commandBuffer);
        // void (*Blit)( CommandBuffer *commandBuffer, const BlitInfo *info);

        // Submission/Presentation
        // bool (*SupportsSwapchainComposition)( Renderer *driverData, SDL_Window *window, SwapchainComposition swapchainComposition);
        // bool (*SupportsPresentMode)( Renderer *driverData, SDL_Window *window, PresentMode presentMode);
        // bool (*ClaimWindow)( Renderer *driverData, SDL_Window *window);
        // void (*ReleaseWindow)( Renderer *driverData, SDL_Window *window);
        // bool (*SetSwapchainParameters)( Renderer *driverData, SDL_Window *window, SwapchainComposition swapchainComposition, PresentMode presentMode);
        // bool (*SetAllowedFramesInFlight)( Renderer *driverData, Uint32 allowedFramesInFlight);
        // TextureFormat (*GetSwapchainTextureFormat)( Renderer *driverData, SDL_Window *window);
        acquire_command_buffer: *const fn (*anyopaque) anyerror!*CommandBuffer,
        // bool (*AcquireSwapchainTexture)( CommandBuffer *commandBuffer, SDL_Window *window, Texture **swapchainTexture, Uint32 *swapchainTextureWidth, Uint32 *swapchainTextureHeight);
        // bool (*WaitForSwapchain)( Renderer *driverData, SDL_Window *window);
        // bool (*WaitAndAcquireSwapchainTexture)( CommandBuffer *commandBuffer, SDL_Window *window, Texture **swapchainTexture, Uint32 *swapchainTextureWidth, Uint32 *swapchainTextureHeight);
        // bool (*Submit)( CommandBuffer *commandBuffer);
        // Fence *(*SubmitAndAcquireFence)( CommandBuffer *commandBuffer);
        // bool (*Cancel)( CommandBuffer *commandBuffer);
        // bool (*Wait)( Renderer *driverData);
        // bool (*WaitForFences)( Renderer *driverData, bool waitAll, Fence *const *fences, Uint32 numFences);
        // bool (*QueryFence)( Renderer *driverData, Fence *fence);
        // void (*ReleaseFence)( Renderer *driverData, Fence *fence);

        // Feature Queries
        // bool (*SupportsTextureFormat)( Renderer *driverData, TextureFormat format, TextureType type, TextureUsageFlags usage);
        // bool (*SupportsSampleCount)( Renderer *driverData, TextureFormat format, SampleCount desiredSampleCount);
    },

    pub fn destroy(self: *Device) void {
        (self.vtable.destroy)(self.ptr);
    }

    pub fn acquireCommandBuffer(self: *Device) !*CommandBuffer {
        const buffer = try (self.vtable.acquire_command_buffer)(self.ptr);

        const header = (self.vtable.get_command_buffer_header)(buffer);
        header.* = .{};

        return buffer;
    }
};

pub const CommandBuffer = opaque {};
