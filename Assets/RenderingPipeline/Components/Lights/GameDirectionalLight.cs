using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class GameDirectionalLight : GameLight
{
	private void Awake()
	{
		lightType = LIGHT_TYPE.Directional;
	}
}