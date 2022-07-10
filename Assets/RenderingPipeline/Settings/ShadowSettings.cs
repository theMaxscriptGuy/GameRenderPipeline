using System.Collections;
using System.Collections.Generic;

[System.Serializable]
public class ShadowSettings
{
	public enum TextureSize
	{
		_256 = 256, _512 = 512, _1024 = 1024,
		_2048 = 2048, _4096 = 4096, _8192 = 8192
	}

	public float ShadowDistance = 100f;
	public TextureSize shadowTextureMapSize = TextureSize._1024;
}
