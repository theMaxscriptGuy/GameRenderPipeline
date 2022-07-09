using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class GameSpotLight : MonoBehaviour
{
    public float Intensity = 1f;
    public float SpotLightRange = 1f;
    public float SpotLightAngle=50f;
    public Color SpotLightColor = Color.yellow;
    public float SpotOuterCone = 100f;
    public float SpotInnerCone = 50f;

    // Update is called once per frame
    void Update()
    {
        //range has to be reciprocal:
        Shader.SetGlobalFloat("_SpotLightRange", 1.0f/SpotLightRange);
        Shader.SetGlobalFloat("_SpotLightAngle", Mathf.Cos(SpotLightAngle));
        Shader.SetGlobalColor("_SpotLightColor", SpotLightColor * Intensity);
        
        //Outer and Inner angles will be passed with cos of the actual values:
        Shader.SetGlobalFloat("_SpotOuterCone", Mathf.Cos(SpotOuterCone));
        Shader.SetGlobalFloat("_SpotInnerCone", Mathf.Cos(1.0f/SpotInnerCone));
        Shader.SetGlobalVector("_SpotLightPos", transform.position);
        Shader.SetGlobalVector("_SpotLightDir", -transform.forward);
    }
}

