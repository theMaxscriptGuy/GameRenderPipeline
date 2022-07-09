using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class GameLight : MonoBehaviour
{
    public float Range = 1f;
    public Color LightColor = Color.yellow;
    public Camera cam;
    // Update is called once per frame
    void Update()
    {
        UpdateLight();
    }

    private void OnEnable()
    {
        
    }

    private void OnDisable()
    {
        
    }

    private void UpdateLight()
    {
        Shader.SetGlobalVector("_PointLightPos", transform.position);
        Shader.SetGlobalVector("_WorldSpaceCameraPos", cam.transform.position);
        Shader.SetGlobalColor("_PointLightColor", LightColor);
        Shader.SetGlobalFloat("_PointLightRange",1.0f/Range);
    }
}

