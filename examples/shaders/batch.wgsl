struct Uniforms {
    mvp: mat4x4<f32>,
}

struct VertexInput {
    @location(0) position: vec2<f32>,
    @location(1) texcoord: vec2<f32>,
    @location(2) color: vec4<f32>,
    @location(3) mask: vec4<f32>,
}

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(1) texcoord: vec2<f32>,
    @location(2) color: vec4<f32>,
    @location(3) mask: vec4<f32>,
}

@group(0) @binding(0) var<uniform> ubo: Uniforms;
@group(0) @binding(1) var tex: texture_2d<f32>;
@group(0) @binding(2) var smp: sampler;

@vertex fn vertex_main(input: VertexInput) -> VertexOutput {
    var output: VertexOutput;
    
    output.position = vec4<f32>(input.position.xy, 0.0, 1.0) * ubo.mvp;
    output.texcoord = input.texcoord;
    output.color = input.color;
    output.mask = input.mask;

    return output;
}

@fragment fn fragment_main(input: VertexOutput) -> @location(0) vec4<f32> {
    let color = textureSample(tex, smp, input.texcoord);
    return
        input.mask.x * color * input.color +
        input.mask.y * color.a * input.color +
        input.mask.z * input.color;
}