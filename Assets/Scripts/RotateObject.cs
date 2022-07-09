using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateObject : MonoBehaviour
{
    public Transform rotationPoint;
    public float speed = 1f;
    public float radius = 1f;
    float angle = 0f;
    // Start is called before the first frame update
    void Start()
    {
        if (!rotationPoint)
            enabled = false;
    }

    // Update is called once per frame
    void Update()
    {
        angle = Time.deltaTime * speed;
        transform.RotateAround(rotationPoint.position * radius, Vector3.up, angle);
    }
}
