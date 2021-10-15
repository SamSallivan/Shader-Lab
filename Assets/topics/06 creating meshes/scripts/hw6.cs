using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof (MeshFilter))]
[RequireComponent(typeof (MeshRenderer))]
public class hw6 : MonoBehaviour
{
    Mesh mesh;

    void Start()
    {
        MakePyrimid();
    }

    void MakePyrimid() {
        Vector3[] vertices = {
            new Vector3(-.5f, -.5f, -.5f),
            new Vector3(.5f, -.5f, -.5f),
            new Vector3(0, .5f, 0),
            new Vector3(.5f, -.5f, .5f),
            new Vector3(-.5f, -.5f, .5f)
        };

        int[] triangles = {
            0, 1, 2,
            1, 3, 2,
            3, 4, 2,
            4, 0, 2,
            0, 4, 1,
            4, 3, 1
        };

        mesh = GetComponent<MeshFilter>().mesh;
        
        mesh.Clear();
        
        mesh.vertices = vertices;
        mesh.triangles = triangles;
    }

    void Update() {
        transform.Rotate(0, 0f, 0);
    }
}
