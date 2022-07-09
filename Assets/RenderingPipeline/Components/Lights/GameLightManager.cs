using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

/// <summary>
/// This class is initialized by the scriptable rendering pipeline to
///     1. Fetch all the lights in the scene,
///     2. Filter the lights as per the visibility,
///     3. Send the data to the gpu so that shaders can use it for shading
/// </summary>

public class GameLightManager : MonoBehaviour
{
	#region Init
	private List<GameLight> gameLights = new List<GameLight>();
	public void Initialize()
	{
		gameLights = FindObjectsOfType<GameLight>().ToList();
	}
	#endregion

	#region DirectionalLight
	public static int MaxDirectionalLights = 4;
	//we need to get the directional light buffers from the gpu, so its a global shader property:
	static int DirectionalLightDir = Shader.PropertyToID("_DirectionalLightDirs");
	static int DirectionalLightColor = Shader.PropertyToID("_DirectionalLightColors");

	//setup the corresponding data value stores:
	public static Vector4[] DirectionalLightDirs = new Vector4[4];
	public static Vector4[] DirectionalLightColors = new Vector4[4];
	#endregion

	#region PointLight
	public static int MaxPointLights = 4;
	//we need to get the directional light buffers from the gpu, so its a global shader property:
	static int PointLightPos = Shader.PropertyToID("_PointLightPos");
	static int PointLightColor = Shader.PropertyToID("_PointLightColor");
	static int PointLightRange = Shader.PropertyToID("_PointLightRange");

	//setup the corresponding data value stores:
	public static Vector4[] PointLightDirs = new Vector4[4];
	public static Vector4[] PointLightColors = new Vector4[4];
	public static float[] PointLightRanges = new float[4];
	#endregion

	#region SpotLight
	public static int MaxSpotLights = 4;
	//we need to get the directional light buffers from the gpu, so its a global shader property:
	static int SpotLightPos = Shader.PropertyToID("_SpotLightPosArr");
	static int SpotLightRange = Shader.PropertyToID("_SpotLightRanges");
	static int SpotLightColor = Shader.PropertyToID("_SpotLightColors");
	static int SpotLightAngle = Shader.PropertyToID("_SpotLightAngles");
	static int SpotLightDir = Shader.PropertyToID("_SpotLightDirs");
	static int SpotOuterCone = Shader.PropertyToID("_SpotOuterCones");
	static int SpotInnerCone = Shader.PropertyToID("_SpotInnerCones");

	//setup the corresponding data value stores:
	public static Vector4[] SpotLightPosArr = new Vector4[4];
	public static float[] SpotLightRanges = new float[4];
	public static Vector4[] SpotLightColors = new Vector4[4];
	public static float[] SpotLightAngles = new float[4];
	public static Vector4[] SpotLightDirs = new Vector4[4];
	public static float[] SpotOuterCones = new float[4];
	public static float[] SpotInnerCones = new float[4];
	#endregion

	#region CapsuleLight
	public static int MaxCapsuleLights = 4;
	//we need to get the directional light buffers from the gpu, so its a global shader property:
	static int CapsuleLightPos = Shader.PropertyToID("_CapsuleLightPosArr");
	static int CapsuleLightRange = Shader.PropertyToID("_CapsuleLightRanges");
	static int CapsuleLightColor = Shader.PropertyToID("_CapsuleLightColors");
	static int CapsuleLightDir = Shader.PropertyToID("_CapsuleLightDirs");
	static int CapsuleLightLength = Shader.PropertyToID("_CapsuleLightLens");

	//setup the corresponding data value stores:
	public static Vector4[] CapsuleLightPosArr = new Vector4[4];
	public static float[] CapsuleLightRanges = new float[4];
	public static Vector4[] CapsuleLightColors = new Vector4[4];
	public static Vector4[] CapsuleLightDirs = new Vector4[4];
	public static float[] CapsuleLightLengths = new float[4];
	#endregion

	internal void SetupLightData()
	{
		//setup directional lights:
		var currLights = gameLights.Where(o => o.enabled).Where(o => o.lightType == LIGHT_TYPE.Directional).ToList();
		for (int i = 0; i < currLights.Count; i++)
		{
			if (i >= MaxDirectionalLights)
				break;
			DirectionalLightColors[i] = ((GameDirectionalLight)currLights[i]).lightColor;
			DirectionalLightDirs[i] = -((GameDirectionalLight)currLights[i]).transform.forward;
		}
		Shader.SetGlobalVectorArray(DirectionalLightColor, DirectionalLightColors);
		Shader.SetGlobalVectorArray(DirectionalLightDir, DirectionalLightDirs);

		//setup point lights:
		currLights = gameLights.Where(o => o.enabled).Where(o => o.lightType == LIGHT_TYPE.Point).ToList();
		for (int i = 0; i < currLights.Count; i++)
		{
			if (i >= MaxPointLights)
				break;
			PointLightColors[i] = ((GamePointLight)currLights[i]).lightColor;
			PointLightDirs[i] = ((GamePointLight)currLights[i]).transform.position;
			PointLightRanges[i] = -((GamePointLight)currLights[i]).RangeRCP;
		}
		Shader.SetGlobalVectorArray(PointLightColor, PointLightColors);
		Shader.SetGlobalVectorArray(PointLightPos, PointLightDirs);
		Shader.SetGlobalFloatArray(PointLightRange, PointLightRanges);

		//setup spot lights:
		currLights = gameLights.Where(o => o.enabled).Where(o => o.lightType == LIGHT_TYPE.Spot).ToList();
		for (int i = 0; i < currLights.Count; i++)
		{
			if (i >= MaxSpotLights)
				break;
			SpotLightColors[i] = ((GameSpotLight)currLights[i]).lightColor;
			SpotLightPosArr[i] = ((GameSpotLight)currLights[i]).transform.position;
			SpotLightDirs[i] = -((GameSpotLight)currLights[i]).transform.forward;
			SpotLightRanges[i] = ((GameSpotLight)currLights[i]).spotLightRange;
			SpotOuterCones[i] = ((GameSpotLight)currLights[i]).spotOuterCone;
			SpotInnerCones[i] = ((GameSpotLight)currLights[i]).spotInnerCone;
		}

		Shader.SetGlobalVectorArray(SpotLightColor, SpotLightColors);
		Shader.SetGlobalVectorArray(SpotLightPos, SpotLightPosArr);
		Shader.SetGlobalVectorArray(SpotLightDir, SpotLightDirs);
		Shader.SetGlobalFloatArray(SpotLightRange, SpotLightRanges);
		Shader.SetGlobalFloatArray(SpotOuterCone, SpotOuterCones);
		Shader.SetGlobalFloatArray(SpotInnerCone, SpotInnerCones);

		//setup capsule lights:
		currLights = gameLights.Where(o => o.enabled).Where(o => o.lightType == LIGHT_TYPE.Capsule).ToList();
		for (int i = 0; i < currLights.Count; i++)
		{
			if (i >= MaxCapsuleLights)
				break;
			CapsuleLightColors[i] = ((GameCapsuleLight)currLights[i]).lightColor;
			CapsuleLightPosArr[i] = ((GameCapsuleLight)currLights[i]).transform.position;
			CapsuleLightDirs[i] = ((GameCapsuleLight)currLights[i]).transform.up;
			CapsuleLightRanges[i] = ((GameCapsuleLight)currLights[i]).range;
			CapsuleLightLengths[i] = ((GameCapsuleLight)currLights[i]).Length;
		}

		Shader.SetGlobalVectorArray(CapsuleLightColor, CapsuleLightColors);
		Shader.SetGlobalVectorArray(CapsuleLightPos, CapsuleLightPosArr);
		Shader.SetGlobalVectorArray(CapsuleLightDir, CapsuleLightDirs);
		Shader.SetGlobalFloatArray(CapsuleLightRange, CapsuleLightRanges);
		Shader.SetGlobalFloatArray(CapsuleLightLength, CapsuleLightLengths);
	}
}
