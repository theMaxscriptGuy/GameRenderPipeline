using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class GameDirectionalLight : MonoBehaviour
{
    public float Intensity = 1f;
    public Color LightColor = Color.yellow;
    public Camera cam;
    // Update is called once per frame
    void Update()
    {
        Shader.SetGlobalVector("_PointLightPos", transform.position);
        Shader.SetGlobalVector("_WorldSpaceCameraPos", cam.transform.position);
        Shader.SetGlobalColor("_PointLightColor", LightColor);
    }
}

