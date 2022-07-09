struct Attributes
{
    float4 posOS : POSITION;
    float4 normal : NORMAL;
    float2 uv : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv : TEXCOORD0;
    float4 posCS : SV_POSITION;
    float4 posWS : TEXCOORD1;
    float3 normal : NORMAL;
    float3 normalWS : TEXCOORD2;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

UNITY_INSTANCING_BUFFER_START(PerInstance)
UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
UNITY_DEFINE_INSTANCED_PROP(float, _SpecIntensity)
UNITY_INSTANCING_BUFFER_END(PerInstance)