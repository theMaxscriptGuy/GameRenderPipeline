/******************************************************************************************************/
/*****************************************SHADOWS***********************************************/
/******************************************************************************************************/

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Shadow/ShadowSamplingTent.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"


//TEXTURE2D_SHADOW(_DirectionalShadowsID);
//#define SHADOW_SAMPLER sampler_ShadowMap
//SAMPLER_CMP(sampler_DirectionalShadowsID);
//CBUFFER_START(_CustomShadows)
//float4x4 _DirectionalShadowMatrices[1];
//CBUFFER_END
//
//float SampleDirectionalShadowAtlas(float3 positionSTS) {
//	return SAMPLE_TEXTURE2D_SHADOW(
//		_DirectionalShadowsID, SHADOW_SAMPLER, positionSTS
//	);
//}