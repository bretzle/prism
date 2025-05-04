cbuffer constants : register(b0)
{
    float4x4 u_matrix;
};

struct vs_in
{
    float4 position : ATTR0;
    float2 uv : ATTR1;
};

struct vs_out
{
    float2 fragUV : ATTR0;
    float4 fragPosition : ATTR1;
    float4 position_clip : SV_Position;
};

vs_out vertex_main(vs_in input)
{
    vs_out output;

    output.position_clip = mul(input.position, u_matrix);
    output.fragUV = input.uv;
    output.fragPosition = 0.5 * (input.position + float4(1, 1, 1, 1));

    return output;
}

float4 frag_main(vs_out input) : SV_Target0
{
    return input.fragPosition;
}
