using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class GameSpotLight : GameLight
{
    [SerializeField]
    private float SpotLightAngle = 50f;
    [SerializeField]
    private float SpotLightRange = 1f;
    [SerializeField]
    private float SpotOuterCone = 100f;
    [SerializeField]
    private float SpotInnerCone = 50f;

    internal float spotLightAngle { get => Mathf.Cos(SpotLightAngle); }
    internal float spotLightRange { get => 1.0f / SpotLightRange; }
    internal float spotOuterCone { get => Mathf.Cos(SpotOuterCone); }
    internal float spotInnerCone { get => Mathf.Cos(1.0f / SpotInnerCone); }

    private void Awake()
    {
        lightType = LIGHT_TYPE.Spot;
    }
}

