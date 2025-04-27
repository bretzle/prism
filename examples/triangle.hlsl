float4 vertex_main(uint VertexIndex : SV_VertexID) : SV_Position
{
    float2 pos[3] = {
        float2(0.0, 0.5),
        float2(-0.5, -0.5),
        float2(0.5, -0.5),
    };
    return float4(pos[VertexIndex].x, pos[VertexIndex].y, 0.0, 1.0);
}

float4 frag_main() : SV_Target0
{
    return float4(1.0, 0.0, 0.0, 1.0);
}