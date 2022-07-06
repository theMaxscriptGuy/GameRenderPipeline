Shader "GameRP/BasicShader"
{
    Properties
    {
        _TextureA("TextureA", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        [Toggle(ENABLE_SPECULAR)] _EnableSpecular("Enable Specular", float) = 1
        _SpecIntensity("Specularity", float) = 1
        _SpecExp("Specular Exponent", float) = 1
        [Toggle(ENABLE_ATTENUATION)] _EnableAttenuation("Enable Attenuation", float) = 1
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" "LightMode" = "GameForward"}
        Pass
        {
            HLSLPROGRAM

            #pragma target 3.5
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/common.hlsl"

            CBUFFER_START(UnityPerDraw)
                float4x4 unity_ObjectToWorld;
            CBUFFER_END

            #define UNITY_MATRIX_M unity_ObjectToWorld

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature ENABLE_SPECULAR
            #pragma shader_feature ENABLE_ATTENUATION
                    
            
            float4x4 unity_MatrixVP;
            //float4x4 unity_ObjectToWorld; //if not using the unity cbuffer

            struct Attributes
            {
                float4 posOS : POSITION;
                float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 posCS : SV_POSITION;
                float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 posWS : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            CBUFFER_START(UnityPerFrame)
                float3 _PointLightPos;
                float _PointLightRange;
                float3 _WorldSpaceCameraPos;
                float3 _PointLightColor;
                float _SpecExp;

                //for directional light:
            CBUFFER_END

            CBUFFER_START(UnityPerMaterial)
                float4 _TextureA_ST;
            CBUFFER_END

            TEXTURE2D(_TextureA);
            SAMPLER(sampler_TextureA);

            UNITY_INSTANCING_BUFFER_START(PerInstance)
            UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
            UNITY_DEFINE_INSTANCED_PROP(float, _SpecIntensity)
            UNITY_INSTANCING_BUFFER_END(PerInstance)

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                UNITY_SETUP_INSTANCE_ID(IN);
	            UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
                float4 wPos = mul(UNITY_MATRIX_M, IN.posOS);
                OUT.posWS = wPos;

                OUT.posCS = mul(unity_MatrixVP, wPos);
                OUT.normal = IN.normal;
                OUT.uv = (IN.uv.xy * _TextureA_ST.xy) + _TextureA_ST.zw;
                return OUT;
            }

            float3 CalculatePointLighting(Varyings input, float4 clr)
            {
                float3 ToLight = _PointLightPos - input.posWS.xyz;
                float3 ToEye = _WorldSpaceCameraPos.xyz - input.posWS.xyz;
                float DistToLight = length(ToLight);
                ToLight /= DistToLight;
                float NDotL = saturate(dot(ToLight, input.normal.xyz));
                float3 finalColor = clr.rgb * _PointLightColor.rgb * NDotL;

#ifdef ENABLE_SPECULAR
                ToEye = normalize(ToEye);
                float3 halfway = normalize(ToEye + ToLight);
                float NdotH = saturate(dot(halfway, input.normal.xyz));
                finalColor += _PointLightColor.rgb * pow(NdotH, _SpecExp) * UNITY_ACCESS_INSTANCED_PROP(PerInstance, _SpecIntensity);
#endif

#ifdef ENABLE_ATTENUATION
                float DistToLightNorm = 1.0 - saturate(DistToLight * _PointLightRange);
                float Attn = DistToLightNorm * DistToLightNorm; //squared attenuation
                finalColor *= Attn;
#endif
                return finalColor;
            }

            float4 frag(Varyings IN) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                half4 color = UNITY_ACCESS_INSTANCED_PROP(PerInstance, _Color);
                color.rgb = CalculatePointLighting(IN, color);
                color.rgb *= SAMPLE_TEXTURE2D(_TextureA, sampler_TextureA, IN.uv);
                return color;
            }
            ENDHLSL
        }
    }
}
