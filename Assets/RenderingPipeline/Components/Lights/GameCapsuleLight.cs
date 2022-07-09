using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class GameCapsuleLight : MonoBehaviour
{
    public float Intensity = 1f;
    public Color LightColor = Color.yellow;
    public float Range = 1f;
    // Update is called once per frame
    void Update()
    {
        Shader.SetGlobalVector("_CapsuleLightPos", transform.position);
        Shader.SetGlobalFloat("_CapsuleLightRange", Range);
        Shader.SetGlobalVector("_CapsuleLightDir", transform.up);
        Shader.SetGlobalFloat("_CapsuleLightLen", Range);
        Shader.SetGlobalColor("_CapsuleLightColor", LightColor * Intensity);
    }
}