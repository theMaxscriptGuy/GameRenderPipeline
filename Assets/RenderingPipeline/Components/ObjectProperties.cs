using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectProperties : MonoBehaviour
{
    public Color color = Color.blue;
    // Start is called before the first frame update
    void Start()
    {
        GetComponent<Renderer>().sharedMaterial.color = color;
        //GetComponent<Renderer>().sharedMaterial.SetFloat("_SpecExp", Random.Range(1f,100f));
        //GetComponent<Renderer>().material.SetFloat("_SpecExp", Random.Range(1f,100f));
        //GetComponent<Renderer>().material.color = color;
    }
}
