using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
public class GamePipeline : RenderPipeline
{
	private GamePipelineAsset renderPipelineAsset;
	private GameLightManager lightManager;
	private GameShadowManager shadowManager;
	public GamePipeline(GamePipelineAsset rpAsset)
	{
		renderPipelineAsset = rpAsset;
		lightManager = new GameLightManager();
		lightManager.Initialize();
		shadowManager = new GameShadowManager(renderPipelineAsset.shadowSettings);
	}

#if UNITY_EDITOR
	void DrawGizmos(ScriptableRenderContext context, Camera camera)
	{
		if (Handles.ShouldRenderGizmos())
		{
			context.DrawGizmos(camera, GizmoSubset.PreImageEffects);
			context.DrawGizmos(camera, GizmoSubset.PostImageEffects);
		}
	}
#endif

	protected override void Render(ScriptableRenderContext context, Camera[] cameras)
	{
		Debug.Log(renderPipelineAsset.rendererName);
		
		CommandBuffer cmd = CommandBufferPool.Get("MainLoop");
		cmd.ClearRenderTarget(true, true, renderPipelineAsset.clearColor);
		context.ExecuteCommandBuffer(cmd);
		CommandBufferPool.Release(cmd);

		foreach (Camera camera in cameras)
		{
			Debug.Log($"Rending camera : {camera.name}");

			Shader.SetGlobalVector("_WorldSpaceCameraPos", camera.transform.position);
			camera.TryGetCullingParameters(out var cullingParams);
			cullingParams.shadowDistance = shadowManager.settings.ShadowDistance;
			var cullingResults = context.Cull(ref cullingParams);


			//setup light data:
			lightManager.SetupLightData();

			//setup shadows:
			shadowManager.Initialize(context, cullingResults);
			shadowManager.RenderShadows();
			shadowManager.CleanUp();


			context.SetupCameraProperties(camera);

			ShaderTagId shaderTagId = new ShaderTagId("GameForward");

			var sortingSettings = new SortingSettings(camera);

			DrawingSettings drawingSettings = new DrawingSettings(shaderTagId, sortingSettings);
			drawingSettings.enableDynamicBatching = true;
			drawingSettings.enableInstancing = true;
			FilteringSettings filteringSettings = FilteringSettings.defaultValue;

			context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);

			if(camera.clearFlags == CameraClearFlags.Skybox && RenderSettings.skybox != null)
			{
				context.DrawSkybox(camera);
			}

#if UNITY_EDITOR
			DrawGizmos(context, camera);
#endif
		}

		context.Submit();

	}
}
