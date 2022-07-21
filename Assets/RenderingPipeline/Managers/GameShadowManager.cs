using UnityEngine;
using UnityEngine.Rendering;

/// <summary>
/// This is responsible to render out the shadows from the lights
/// </summary>

public class GameShadowManager
{
	//for now we are just trying to add shadow using the first light that unity gets,
	//ideally this is done when you have to add shadows to multiple lights:
	private static int s_shadowTextureMapID = Shader.PropertyToID("_DirectionalShadowsMap");
	private static int dirShadowMatricesID = Shader.PropertyToID("_DirectionalShadowMatrix");

	private static Matrix4x4 dirShadowMatrix = Matrix4x4.identity;

	private ScriptableRenderContext context;
	private CullingResults cullingResults;
	private const string shadowBufferName = "Shadow_Buffer";
	private CommandBuffer cmd = new CommandBuffer
	{
		name = shadowBufferName
	};
	internal ShadowSettings settings;

	public GameShadowManager(ShadowSettings sSettings)
	{
		settings = sSettings;
	}

	internal void Initialize(ScriptableRenderContext sContext, CullingResults cullRes)
	{
		context = sContext;
		cullingResults = cullRes;
	}

	internal void RenderShadows()
	{
		cmd.BeginSample("SHADOW_SAMPLE");
		cmd.GetTemporaryRT(s_shadowTextureMapID, (int)settings.shadowTextureMapSize, (int)settings.shadowTextureMapSize, 32, FilterMode.Bilinear, RenderTextureFormat.Shadowmap);
		cmd.SetRenderTarget(s_shadowTextureMapID, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store);
		cmd.ClearRenderTarget(true, false, Color.clear);
		ExecuteBuffer();

		RenderDirectionalShadows(0, (int)settings.shadowTextureMapSize);

		ExecuteBuffer();

		cmd.EndSample("SHADOW_SAMPLE");
	}

	private void RenderDirectionalShadows(int id, int textureSize)
	{
		ShadowDrawingSettings shadowDrawSettings = new ShadowDrawingSettings(cullingResults, id);
		//foreach (var light in cullingResults.visibleLights)
		//{
		//	Debug.LogError(light.light.name);
		//}
		if (cullingResults.visibleLights.Length <= 0)
			return;
		cullingResults.ComputeDirectionalShadowMatricesAndCullingPrimitives(
				0, 0, 1, Vector3.zero, textureSize, 0f, 
				out Matrix4x4 viewMatrix, out Matrix4x4 projectionMatrix, out ShadowSplitData splitData
			);
		dirShadowMatrix = ConvertToAtlasMatrix(projectionMatrix * viewMatrix);
		cmd.SetViewProjectionMatrices(viewMatrix, projectionMatrix);

		cmd.SetGlobalMatrix(dirShadowMatricesID, dirShadowMatrix);

		ExecuteBuffer();
		cmd.SetGlobalDepthBias(settings.bias, settings.slopeBias);
		context.DrawShadows(ref shadowDrawSettings);
	}
	Matrix4x4 ConvertToAtlasMatrix(Matrix4x4 m)
	{
		if (SystemInfo.usesReversedZBuffer)
		{
			m.m20 = -m.m20;
			m.m21 = -m.m21;
			m.m22 = -m.m22;
			m.m23 = -m.m23;
		}
		m.m00 = 0.5f * (m.m00 + m.m30);
		m.m01 = 0.5f * (m.m01 + m.m31);
		m.m02 = 0.5f * (m.m02 + m.m32);
		m.m03 = 0.5f * (m.m03 + m.m33);
		m.m10 = 0.5f * (m.m10 + m.m30);
		m.m11 = 0.5f * (m.m11 + m.m31);
		m.m12 = 0.5f * (m.m12 + m.m32);
		m.m13 = 0.5f * (m.m13 + m.m33);
		m.m20 = 0.5f * (m.m20 + m.m30);
		m.m21 = 0.5f * (m.m21 + m.m31);
		m.m22 = 0.5f * (m.m22 + m.m32);
		m.m23 = 0.5f * (m.m23 + m.m33);
		return m;
	}

	internal void CleanUp()
	{
		cmd.ReleaseTemporaryRT(s_shadowTextureMapID);
		ExecuteBuffer();
	}

	internal void ExecuteBuffer()
	{
		context.ExecuteCommandBuffer(cmd);
		cmd.Clear();
	}
}
