using UnityEngine;
using UnityEngine.Rendering;

[CreateAssetMenu(menuName ="Rendering/GamePipelineAsset")]
public class GamePipelineAsset : RenderPipelineAsset
{
	public Color clearColor;
	public string rendererName;

	protected override RenderPipeline CreatePipeline()
	{
		return new GamePipeline(this);
	}
}
