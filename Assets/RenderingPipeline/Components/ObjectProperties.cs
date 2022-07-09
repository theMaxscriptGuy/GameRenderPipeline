using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectProperties : MonoBehaviour
{
	public Color color = Color.blue;
	public float specularity = 1f;
	public float specularityExponent = 1f;
	public Texture2D TextureA;

	static MaterialPropertyBlock propertyBlock;
	static int colorID = Shader.PropertyToID("_Color");
	static int Specularity = Shader.PropertyToID("_SpecIntensity");
	static int specularityExp = Shader.PropertyToID("_SpecExp");

	private void Awake()
	{
		OnValidate();
	}

	private void OnValidate()
	{
		if (propertyBlock == null)
		{
			propertyBlock = new MaterialPropertyBlock();
		}
		propertyBlock.SetColor(colorID, color);
		propertyBlock.SetFloat(Specularity, specularity);
		propertyBlock.SetFloat(specularityExp, specularityExponent);
		GetComponent<MeshRenderer>().SetPropertyBlock(propertyBlock);
	}
}
