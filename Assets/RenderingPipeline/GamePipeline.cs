using UnityEngine;
using UnityEngine.Rendering;
public class GamePipeline : RenderPipeline
{
	private GamePipelineAsset renderPipelineAsset;
	public GamePipeline(GamePipelineAsset rpAsset)
	{
		renderPipelineAsset = rpAsset;
	}

	protected override void Render(ScriptableRenderContext context, Camera[] cameras)
	{
		Debug.Log(renderPipelineAsset.rendererName);

		CommandBuffer cmd = CommandBufferPool.Get("MainLoop");
		cmd.ClearRenderTarget(true, true, renderPipelineAsset.clearColor);
		context.ExecuteCommandBuffer(cmd);
		CommandBufferPool.Release(cmd);
		
		
		foreach(Camera camera in cameras)
		{
			camera.TryGetCullingParameters(out var cullingParams);

			var cullingResults = context.Cull(ref cullingParams);
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
		}
		
		context.Submit();

	}
}