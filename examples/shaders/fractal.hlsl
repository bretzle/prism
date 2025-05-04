cbuffer constants : register(b0)
{
    float4x4 u_matrix;
};

struct vs_in
{
    float4 pos : ATTR0;
    float4 col : ATTR1;
    float2 uv : ATTR2;
};

struct vs_out
{
    float4 pos : SV_POSITION;
    float4 frag_pos : ATTR0;
    float2 frag_uv : ATTR1;
};

Texture2D u_texture : register(t0);
SamplerState u_texture_sampler : register(s0);

vs_out vertex_main(vs_in input)
{
    vs_out output;
    output.pos = mul(input.pos, u_matrix);
    output.frag_pos = 0.5 * (input.pos + float4(1, 1, 1, 1));
    output.frag_uv = input.uv;
    return output;
}

float4 frag_main(vs_out input) : SV_TARGET
{
    float4 color = u_texture.Sample(u_texture_sampler, input.frag_uv * 0.8 + float2(0.1, 0.1));
    float f = length(color.rgb - float3(0.5, 0.5, 0.5)) < 0.01;
    return (1.0 - f) * color + f * input.frag_pos;
}