struct Uniforms {
    mvp : mat4x4<f32>,
};

struct VertexInput {
    @location(0) pos : vec4<f32>,
    @location(1) uv : vec2<f32>,
}

struct VertexOutput {
    @builtin(position) pos : vec4<f32>,
    @location(0) frag_uv : vec2<f32>,
    @location(1) frag_pos : vec4<f32>,
}

@binding(0) @group(0) 
var<uniform> ubo : Uniforms;

@binding(1) @group(0)
var smp : sampler;

@binding(2) @group(0)
var tex : texture_2d<f32>;

@vertex
fn vertex_main(input : VertexInput) -> VertexOutput {
    var output : VertexOutput;
    output.pos = input.pos * ubo.mvp;
    output.frag_uv = input.uv;
    output.frag_pos = 0.5 * (input.pos + vec4<f32>(1.0, 1.0, 1.0, 1.0));
    return output;
}

@fragment
fn frag_main(input : VertexOutput) -> @location(0) vec4<f32> {
    let color = textureSample(tex, smp, input.frag_uv * 0.8 + vec2<f32>(0.1, 0.1));
    let f = f32(length(color.rgb - vec3<f32>(0.5, 0.5, 0.5)) < 0.01);
    return (1.0 - f) * color + f * input.frag_pos;
}
