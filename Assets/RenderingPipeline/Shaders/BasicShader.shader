Shader "GameRP/BasicShader"
{
    Properties
    {
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
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 posCS : SV_POSITION;
                float4 normal : NORMAL;
                float4 posWS : TEXCOORD0;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                UNITY_SETUP_INSTANCE_ID(IN);
                float4 wPos = mul(UNITY_MATRIX_M, IN.posOS);
                OUT.posCS = mul(unity_MatrixVP, wPos);
                OUT.normal = IN.normal;
                OUT.posWS = wPos;
                return OUT;
            }

            CBUFFER_START(UnityPerMaterial)
                half4 _Color;
            CBUFFER_END

            CBUFFER_START(UnityPerFrame)
                float3 _PointLightPos;
                float _PointLightRange;
                float3 _WorldSpaceCameraPos;
                float _SpecIntensity;
                float3 _PointLightColor;
                float _SpecExp;
            CBUFFER_END

            /*cbuffer GamePipelineMaterial : register(b0)
            {
                half4 _Color : packoffset(c0);
                float3 _PointLightPos : packoffset(c1);
                float _PointLightRange : packoffset(c1.w);
                float3 _WorldSpaceCameraPos : packoffset(c2);
                float _SpecIntensity : packoffset(c2.w);
                float3 _PointLightColor : packoffset(c3);
                float _SpecExp : packoffset(c3.w);
            }*/

            float3 CalculatePointLighting(Varyings input)
            {
                float3 ToLight = _PointLightPos - input.posWS.xyz;
                float3 ToEye = _WorldSpaceCameraPos.xyz - input.posWS.xyz;
                float DistToLight = length(ToLight);
                ToLight /= DistToLight;
                float NDotL = saturate(dot(ToLight, input.normal.xyz));
                float3 finalColor = _Color.rgb * _PointLightColor.rgb * NDotL;

#ifdef ENABLE_SPECULAR
                ToEye = normalize(ToEye);
                float3 halfway = normalize(ToEye + ToLight);
                float NdotH = saturate(dot(halfway, input.normal.xyz));
                finalColor += _PointLightColor.rgb * pow(NdotH, _SpecExp) * _SpecIntensity;
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
                half4 color = _Color;
                color.rgb = CalculatePointLighting(IN);
                return color;
            }
            ENDHLSL
        }
    }
}
