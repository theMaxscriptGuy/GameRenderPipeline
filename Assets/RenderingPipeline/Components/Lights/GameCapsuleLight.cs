using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class GameCapsuleLight : GameLight
{
    [SerializeField]
    private float Range = 1f;
    [SerializeField]
    internal float Length = 1f;

    internal float range { get => 1.0f / Range; }

    private void Awake()
    {
        lightType = LIGHT_TYPE.Capsule;
    }
}