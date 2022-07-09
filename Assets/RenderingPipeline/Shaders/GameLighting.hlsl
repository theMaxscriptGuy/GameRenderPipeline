CBUFFER_START(UnityPerFrame)
//for point light:
float3 _PointLightPos;
float _PointLightRange;
float3 _WorldSpaceCameraPos;
float3 _PointLightColor;
float _SpecExp;

//for directional light:
float3 _DirectionalLightDir;
float3 _DirectionalLightColor;

//for spot light:
float3 _SpotLightPos;
float _SpotLightRange;
float _SpotLightAngle;
float3 _SpotLightDir;
float4 _SpotLightColor;
float _SpotOuterCone;
float _SpotInnerCone;

//for capsule light:
float3 _CapsuleLightPos;
float _CapsuleLightRange;
float3 _CapsuleLightDir;
float3 _CapsuleLightColor;
float _CapsuleLightLen;
CBUFFER_END

float CalculateBlinnSpecular(float4 posWS, float3 normal, float3 lightDir)
{
    //Blinn Specular:
    float3 ToEye = normalize(_WorldSpaceCameraPos.xyz - posWS.xyz);
    float3 halfWay = normalize(ToEye + lightDir);
    float NDotH = saturate(dot(halfWay, normal));
    float spec = NDotH * pow(NDotH, _SpecExp) * UNITY_ACCESS_INSTANCED_PROP(PerInstance, _SpecIntensity);
    return spec;
}

float3 CalculatePointLighting(Varyings input, float4 clr)
{
    float3 normalizedNormals = normalize(input.normalWS);
    float3 ToLight = _PointLightPos - input.posWS.xyz;
    float3 ToEye = _WorldSpaceCameraPos.xyz - input.posWS.xyz;
    float DistToLight = length(ToLight);
    ToLight /= DistToLight;
    float NDotL = saturate(dot(ToLight, normalizedNormals));
    float3 finalColor = _PointLightColor.rgb * NDotL;

#ifdef ENABLE_SPECULAR
    ToEye = normalize(ToEye);
    float3 halfway = normalize(ToEye + ToLight);
    float NdotH = saturate(dot(halfway, normalizedNormals));
    float spec = CalculateBlinnSpecular(input.posWS, normalizedNormals, ToLight);
    finalColor += _PointLightColor.rgb * spec;
#endif

#ifdef ENABLE_ATTENUATION
    float DistToLightNorm = 1.0 - saturate(DistToLight * _PointLightRange);
    float Attn = DistToLightNorm * DistToLightNorm; //squared attenuation
    finalColor *= clr * Attn;
#endif
    return finalColor;
}

float3 CalculateDirectionalLighting(Varyings input, float4 clr)
{
    float3 normalizedNormals = normalize(input.normalWS);
    //Phong Diffuse:
    float NDotL = saturate(dot(_DirectionalLightDir, normalizedNormals));
    float3 finalColor = _DirectionalLightColor * saturate(NDotL);

#ifdef ENABLE_SPECULAR
    float spec = CalculateBlinnSpecular(input.posWS, normalizedNormals, _DirectionalLightDir);
    finalColor += _DirectionalLightColor.rgb * spec;
#endif
    return clr * finalColor;
}

float3 CalculateSpotLighting(Varyings input, float4 clr)
{
    float3 normalizedNormals = normalize(input.normalWS);
    float3 toLight = _SpotLightPos - input.posWS;
    float3 toEye = _WorldSpaceCameraPos.xyz - input.posWS;
    float distToLight = length(toLight);

    //phong diffuse:
    toLight /= distToLight;
    float NDotL = saturate(dot(toLight, normalizedNormals));
    float3 finalColor = _SpotLightColor * NDotL;

#ifdef ENABLE_SPECULAR
    //Blinn Specular:
    float spec = CalculateBlinnSpecular(input.posWS, normalizedNormals, toLight);
    finalColor += _SpotLightColor.rgb * spec;
#endif

    //cone attenuation:
    float cosAng = dot(_SpotLightDir, toLight);
    float conAttn = saturate((cosAng - _SpotOuterCone) * _SpotInnerCone);
    conAttn *= conAttn;
    
    float distToLightNorm = 1.0 - saturate(distToLight * _SpotLightRange);
    float Attn = distToLightNorm * distToLightNorm;

    finalColor *= clr.rgb * Attn * conAttn;

    return finalColor;
}

float3 CalculateCapsuleLighting(Varyings input, float4 clr)
{
    float3 normalizedNormals = normalize(input.normalWS);
    float3 toEye = _WorldSpaceCameraPos.xyz - input.posWS;
    float3 toCapsuleStart = input.posWS - _CapsuleLightPos;
    float distOnLine = dot(toCapsuleStart, _CapsuleLightDir) / _CapsuleLightLen;
    distOnLine = saturate(distOnLine) * _CapsuleLightRange;
    float3 pointOnLine = _CapsuleLightPos + _CapsuleLightDir * distOnLine;

    float3 toLight = pointOnLine - input.posWS;
    float distToLight = length(toLight);

    //phong diffuse:
    toLight /= distToLight;
    float NDotL = saturate(dot(toLight, normalizedNormals));
    float3 finalColor = clr * NDotL;

    //Attenuation:
    float distToLightNorm = 1.0 - saturate(distToLight * _CapsuleLightRange);
    float Attn = distToLightNorm * distToLightNorm;
    return finalColor * _CapsuleLightColor * Attn;
}