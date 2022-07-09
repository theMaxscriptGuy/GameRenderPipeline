using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Core light class that defines basic parameters and virtual functions to be overridden
/// </summary>

public enum LIGHT_TYPE
{
	Directional,
	Point,
	Spot,
	Capsule
}
public abstract class GameLight : MonoBehaviour
{
	internal LIGHT_TYPE lightType;

	//Basic properties of light:
	[SerializeField]
	private Color color = Color.cyan;
	[SerializeField]
	private float intensity = 1f;

	internal Color lightColor { get => color*intensity; }
}

