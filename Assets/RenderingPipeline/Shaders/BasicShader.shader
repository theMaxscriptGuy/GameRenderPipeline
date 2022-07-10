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
                float4x4 unity_WorldToObject;
                float4x4 unity_MatrixV;
                float4x4 unity_MatrixVP;
                float4x4 glstate_matrix_projection;
                real4 unity_WorldTransformParams;
            CBUFFER_END

            #define UNITY_MATRIX_M unity_ObjectToWorld
            #define UNITY_MATRIX_I_M unity_WorldToObject
            #define UNITY_MATRIX_V unity_MatrixV
            #define UNITY_MATRIX_VP unity_MatrixVP
            #define UNITY_MATRIX_P glstate_matrix_projection

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
            #pragma shader_feature ENABLE_SPECULAR
            #pragma shader_feature ENABLE_ATTENUATION

            #include "GameInput.hlsl"
            #include "GameLighting.hlsl"
            #include "Shadows.hlsl"



            #pragma vertex vert
            #pragma fragment frag


            CBUFFER_START(UnityPerMaterial)
                float4 _TextureA_ST;
            CBUFFER_END

            TEXTURE2D(_TextureA);
            SAMPLER(sampler_TextureA);

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                UNITY_SETUP_INSTANCE_ID(IN);
	            UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
                float4 wPos = mul(UNITY_MATRIX_M, IN.posOS);
                OUT.posWS = wPos;
                OUT.posCS = mul(unity_MatrixVP, wPos); //this can later be converted to TransfrormObjcetToHClip when using SpaceTransforms.hlsl
                OUT.normal = IN.normal;
                OUT.normalWS = TransformObjectToWorldNormal(IN.normal);
                OUT.uv = (IN.uv.xy * _TextureA_ST.xy) + _TextureA_ST.zw;
                return OUT;
            }

            float4 frag(Varyings IN) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                half4 color = UNITY_ACCESS_INSTANCED_PROP(PerInstance, _Color);
                half3 dirLightClr = CalculateDirectionalLighting(IN, color);
                half3 pointLightClr = CalculatePointLighting(IN, color);
                half3 spotLightClr = CalculateSpotLighting(IN, color);
                half3 capsuleLightClr = CalculateCapsuleLighting(IN, color);
                color.rgb = saturate(dirLightClr + pointLightClr + spotLightClr+ capsuleLightClr);
                color.rgb *= SAMPLE_TEXTURE2D(_TextureA, sampler_TextureA, IN.uv);
                return color;
            }
            ENDHLSL
        }

        Pass
        {
            Tags {
                "LightMode" = "ShadowCaster"
            }
                ColorMask 0

            HLSLPROGRAM
            #pragma target 3.5
            #pragma shader_feature _CLIPPING
            #pragma multi_compile_instancing
            #pragma vertex ShadowCasterPassVertex
            #pragma fragment ShadowCasterPassFragment
            #include "./ShadowCasterPass.hlsl"
            ENDHLSL
        }
    }
}
