using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class GamePointLight : GameLight
{
    [SerializeField]
    private float Range = 1f;

    internal float RangeRCP { get => Range; }

    private void Awake()
    {
        lightType = LIGHT_TYPE.Point;
    }
}

