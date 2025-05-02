cbuffer constants : register(b0)
{
    row_major float4x4 u_matrix;
}

struct vs_in
{
    float2 position : ATTR0;
    float2 texcoord : ATTR1;
    float4 color : ATTR2;
    float4 mask : ATTR3;
};

struct vs_out
{
    float4 position : SV_Position;
    float2 texcoord : ATTR1;
    float4 color : ATTR2;
    float4 mask : ATTR3;
};

Texture2D u_texture : register(t1);
SamplerState u_texture_sampler : register(s2);

vs_out vertex_main(vs_in input)
{
    vs_out output;

    output.position = mul(float4(input.position, 0.0f, 1.0f), u_matrix);
    output.texcoord = input.texcoord;
    output.color = input.color;
    output.mask = input.mask;

    return output;
}

float4 fragment_main(vs_out input) : SV_TARGET
{
    float4 color = u_texture.Sample(u_texture_sampler, input.texcoord);
    return
        input.mask.x * color * input.color +
        input.mask.y * color.a * input.color +
        input.mask.z * input.color;
}