//MOVE THIS TO CAMERA:
CBUFFER_START(CustomCamera)
float3 _WorldSpaceCameraPos;
CBUFFER_END

/******************************************************************************************************/
/*****************************************LIGHT COUNTS***********************************************/
/******************************************************************************************************/

#define MAX_DIR_LIGHTS 4
#define MAX_SPOT_LIGHTS 4
#define MAX_POINT_LIGHTS 4
#define MAX_CAPSULE_LIGHTS 4

/******************************************************************************************************/
/*****************************************LIGHT BUFFERS***********************************************/
/******************************************************************************************************/

CBUFFER_START(CustomLighting)
//for point light:
float3 _PointLightPos[MAX_POINT_LIGHTS];
float _PointLightRange[MAX_POINT_LIGHTS];
float3 _PointLightColor[MAX_POINT_LIGHTS];

//for directional light:
float3 _DirectionalLightDirs[MAX_DIR_LIGHTS];
float3 _DirectionalLightColors[MAX_DIR_LIGHTS];

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

/******************************************************************************************************/
/*****************************************LIGHT STRUCTS***********************************************/
/******************************************************************************************************/

struct GameLight
{
    float3 color;
    float3 direction;
    float3 range;
};

/******************************************************************************************************/
/*****************************************GET LIGHT FUNCTIONS***********************************************/
/******************************************************************************************************/

GameLight GetDirectionalLight(int id)
{
    GameLight light;
    light.color = _DirectionalLightColors[id];
    light.direction = _DirectionalLightDirs[id];
    return light;
}

GameLight GetPointLight(int id)
{
    GameLight light;
    light.color = _PointLightColor[id];
    light.direction = _PointLightPos[id];
    light.range = _PointLightRange[id];
    return light;
}

/******************************************************************************************************/
/*****************************************LIGHTING FUNCTIONS***********************************************/
/******************************************************************************************************/

float CalculateBlinnSpecular(float4 posWS, float3 normal, float3 lightDir)
{
    //Blinn Specular:
    float3 ToEye = normalize(_WorldSpaceCameraPos.xyz - posWS.xyz);
    float3 halfWay = normalize(ToEye + lightDir);
    float NDotH = saturate(dot(halfWay, normal));
    float spec = NDotH * pow(NDotH, UNITY_ACCESS_INSTANCED_PROP(PerInstance, _SpecExp)) * UNITY_ACCESS_INSTANCED_PROP(PerInstance, _SpecIntensity);
    return spec;
}

float3 CalculatePointLighting(Varyings input, float4 clr)
{
    float3 outColor = 0;
    for (int i = 0; i < MAX_POINT_LIGHTS; i++)
    {
        GameLight pointLight = GetPointLight(i);
        //pointLight.direction has position of the light

        float3 normalizedNormals = normalize(input.normalWS);
        float3 ToLight = pointLight.direction - input.posWS.xyz;
        float3 ToEye = _WorldSpaceCameraPos.xyz - input.posWS.xyz;
        float DistToLight = length(ToLight);
        ToLight /= DistToLight;
        float NDotL = saturate(dot(ToLight, normalizedNormals));
        float3 finalColor = pointLight.color.rgb * NDotL;

#ifdef ENABLE_SPECULAR
        ToEye = normalize(ToEye);
        float3 halfway = normalize(ToEye + ToLight);
        float NdotH = saturate(dot(halfway, normalizedNormals));
        float spec = CalculateBlinnSpecular(input.posWS, normalizedNormals, ToLight);
        finalColor += pointLight.color.rgb * spec;
#endif

#ifdef ENABLE_ATTENUATION
        float DistToLightNorm = 1.0 - saturate(DistToLight * pointLight.range);
        float Attn = DistToLightNorm * DistToLightNorm; //squared attenuation
        finalColor *= pointLight.color.rgb * Attn;
#endif
        outColor += finalColor;
    }
    return clr * outColor;
}

float3 CalculateAllDirLights(float3 normalizedNormals, float4 posWS)
{
    
}

float3 CalculateDirectionalLighting(Varyings input, float4 clr)
{
    float3 normalizedNormals = normalize(input.normalWS);

    float3 outColor = 0;
    for (int i = 0; i < 4; i++)
    {
        GameLight light = GetDirectionalLight(i);
        //Phong Diffuse:
        float NDotL = saturate(dot(light.direction, normalizedNormals));
        float3 finalColor = light.color.rgb * saturate(NDotL);

#ifdef ENABLE_SPECULAR
        float spec = CalculateBlinnSpecular(input.posWS, normalizedNormals, light.direction);
        finalColor += light.color.rgb * spec;
#endif
        outColor += finalColor;
    }

    return clr * outColor;
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