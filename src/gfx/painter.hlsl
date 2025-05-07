cbuffer constants : register(b0)
{
    float4x4 u_matrix;
}

struct vs_in
{
    float2 position : POS;
    float2 texcoord : TEX;
    float4 color : COL;
    float4 mask : MASK;
};

struct vs_out
{
    float4 position : SV_POSITION;
    float2 texcoord : TEX;
    float4 color : COL;
    float4 mask : MASK;
};

Texture2D u_texture : register(t0);
SamplerState u_sampler : register(s0);

vs_out vs_main(vs_in input)
{
    vs_out output;

    output.position = mul(float4(input.position, 0.0f, 1.0f), u_matrix);
    output.texcoord = input.texcoord;
    output.color = input.color;
    output.mask = input.mask;

    return output;
}

float4 ps_main(vs_out input) : SV_TARGET
{
    float4 color = u_texture.Sample(u_sampler, input.texcoord);
    return
        input.mask.x * color * input.color +
        input.mask.y * color.a * input.color +
        input.mask.z * input.color;
}
