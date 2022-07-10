/******************************************************************************************************/
/*****************************************SHADOWS***********************************************/
/******************************************************************************************************/

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Shadow/ShadowSamplingTent.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"


TEXTURE2D_SHADOW(_DirectionalShadowsMap);
#define SHADOW_SAMPLER sampler_linear_clamp_compare
SAMPLER_CMP(SHADOW_SAMPLER);
CBUFFER_START(_CustomShadows)
float4x4 _DirectionalShadowMatrix;
CBUFFER_END

float SampleDirectionalShadowAtlas(float3 positionSTS) {
	return SAMPLE_TEXTURE2D_SHADOW(
		_DirectionalShadowsMap, SHADOW_SAMPLER, positionSTS
	);
}