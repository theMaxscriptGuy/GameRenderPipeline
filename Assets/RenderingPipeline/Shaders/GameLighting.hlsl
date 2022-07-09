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
float4 _SpotLightColors[MAX_SPOT_LIGHTS];
float3 _SpotLightDirs[MAX_SPOT_LIGHTS];
float _SpotLightRanges[MAX_SPOT_LIGHTS];
float3 _SpotLightPosArr[MAX_SPOT_LIGHTS];
float _SpotOuterCones[MAX_SPOT_LIGHTS];
float _SpotInnerCones[MAX_SPOT_LIGHTS];

//for capsule light:
float3 _CapsuleLightPosArr[MAX_CAPSULE_LIGHTS];
float _CapsuleLightRanges[MAX_CAPSULE_LIGHTS];
float3 _CapsuleLightDirs[MAX_CAPSULE_LIGHTS];
float3 _CapsuleLightColors[MAX_CAPSULE_LIGHTS];
float _CapsuleLightLens[MAX_CAPSULE_LIGHTS];
CBUFFER_END

/******************************************************************************************************/
/*****************************************LIGHT STRUCTS***********************************************/
/******************************************************************************************************/

struct GameLight
{
    float3 color;
    float3 direction;
    float range;
};

struct GameLightCapsule
{
    float3 color;
    float3 direction;
    float3 position;
    float range;
    float length;
};

struct GameLightSpot
{
    float3 color;
    float3 direction;
    float range;
    float3 pos;
    float outerCone;
    float innerCone;
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

GameLightSpot GetSpotLight(int id)
{
    GameLightSpot light;
    light.color = _SpotLightColors[id];
    light.direction = _SpotLightDirs[id];
    light.range = _SpotLightRanges[id];
    light.pos = _SpotLightPosArr[id];
    light.outerCone = _SpotOuterCones[id];
    light.innerCone = _SpotInnerCones[id];
    return light;
}

GameLightCapsule GetCapsuleLight(int id)
{
    GameLightCapsule light;
    light.position = _CapsuleLightPosArr[id];
    light.range = _CapsuleLightRanges[id];
    light.color = _CapsuleLightColors[id];
    light.direction = _CapsuleLightDirs[id];
    light.length = _CapsuleLightLens[id];
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
    float3 outColor = 0;

    for (int i = 0; i < MAX_SPOT_LIGHTS; i++)
    {
        GameLightSpot light = GetSpotLight(i);
        float3 normalizedNormals = normalize(input.normalWS);
        float3 toLight = light.pos - input.posWS;
        float3 toEye = _WorldSpaceCameraPos.xyz - input.posWS;
        float distToLight = length(toLight);

        //phong diffuse:
        toLight /= distToLight;
        float NDotL = saturate(dot(toLight, normalizedNormals));
        float3 finalColor = light.color * NDotL;

#ifdef ENABLE_SPECULAR
        //Blinn Specular:
        float spec = CalculateBlinnSpecular(input.posWS, normalizedNormals, toLight);
        finalColor += light.color.rgb * spec;
#endif

        //cone attenuation:
        float cosAng = dot(light.direction, toLight);
        float conAttn = saturate((cosAng - light.outerCone) * light.innerCone);
        conAttn *= conAttn;

        float distToLightNorm = 1.0 - saturate(distToLight * light.range);
        float Attn = distToLightNorm * distToLightNorm;

        finalColor *= clr.rgb * Attn * conAttn;

        outColor += finalColor;
    }

    return clr * outColor;
}

float3 CalculateCapsuleLighting(Varyings input, float4 clr)
{
    float3 outColor = 0;
    float3 normalizedNormals = normalize(input.normalWS);
    
    for (int i = 0; i < MAX_CAPSULE_LIGHTS; i++)
    {
        GameLightCapsule light = GetCapsuleLight(i);
        float3 toEye = _WorldSpaceCameraPos.xyz - input.posWS;
        float3 toCapsuleStart = input.posWS - light.position;
        float distOnLine = dot(toCapsuleStart, light.direction) / light.length;
        distOnLine = saturate(distOnLine) * light.length;
        float3 pointOnLine = light.position + (light.direction * distOnLine);

        float3 toLight = pointOnLine - input.posWS;
        float distToLight = length(toLight);

        //phong diffuse:
        toLight /= distToLight;
        float NDotL = saturate(dot(toLight, normalizedNormals));
        float3 finalColor = light.color * NDotL;

        //Attenuation:
        float distToLightNorm = 1.0 - saturate(distToLight * light.range);
        float Attn = distToLightNorm * distToLightNorm;
        
        outColor += finalColor * light.color * Attn;
    }
    return clr * outColor;
}