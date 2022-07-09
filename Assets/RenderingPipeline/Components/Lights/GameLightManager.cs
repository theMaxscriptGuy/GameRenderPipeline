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
	}
}
