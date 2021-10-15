using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
[RequireComponent(typeof(MeshRenderer))]
public class CheemsHat : MonoBehaviour
{
    Mesh mesh;
    public float mul = 1.0f;
    public float addx = 0.0f;
    public float addy = 0.0f;
    public float addz = 0.0f;
    public float rotate = 0.0f;

    void Start()
    {
        MakePyrimid();
    }

    void MakePyrimid()
    {
        Vector3[] vertices = {
            new Vector3(0.0f*mul+addx,0.25f*mul+addy,0.0f*mul+addz),
            new Vector3(-0.5f*mul+addx,0.0f*mul+addy,-0.25f*mul+addz),
            new Vector3(-0.25f*mul+addx,0.0f*mul+addy,-0.5f*mul+addz),
            new Vector3(0.25f*mul+addx,0.0f*mul+addy,-0.5f*mul+addz),
            new Vector3(0.5f*mul+addx,0.0f*mul+addy,-0.25f*mul+addz),
            new Vector3(0.5f*mul+addx,0.0f*mul+addy,0.25f*mul+addz),
            new Vector3(0.25f*mul+addx,0.0f*mul+addy,0.5f*mul+addz),
            new Vector3(-0.25f*mul+addx,0.0f*mul+addy,0.5f*mul+addz),
            new Vector3(-0.5f*mul+addx,0.0f*mul+addy,0.25f*mul+addz)
        };

        int[] triangles = {
            0, 2, 1,
            0, 3, 2,
            0, 4, 3,
            0, 5, 4,
            0, 6, 5,
            0, 7, 6,
            0, 8, 7,
            0, 1, 8,
            1, 2, 3,
            1, 3, 4,
            8, 1, 4,
            8, 4, 5,
            7, 8, 5,
            7, 5, 6
        };

        mesh = GetComponent<MeshFilter>().mesh;

        mesh.Clear();

        mesh.vertices = vertices;
        mesh.triangles = triangles;
    }

    void Update()
    {
        transform.Rotate(0, rotate, 0);

        Vector3[] vertices = {
            new Vector3(0.0f*mul+addx,0.25f*mul+addy,0.0f*mul+addz),
            new Vector3(-0.5f*mul+addx,0.0f*mul+addy,-0.25f*mul+addz),
            new Vector3(-0.25f*mul+addx,0.0f*mul+addy,-0.5f*mul+addz),
            new Vector3(0.25f*mul+addx,0.0f*mul+addy,-0.5f*mul+addz),
            new Vector3(0.5f*mul+addx,0.0f*mul+addy,-0.25f*mul+addz),
            new Vector3(0.5f*mul+addx,0.0f*mul+addy,0.25f*mul+addz),
            new Vector3(0.25f*mul+addx,0.0f*mul+addy,0.5f*mul+addz),
            new Vector3(-0.25f*mul+addx,0.0f*mul+addy,0.5f*mul+addz),
            new Vector3(-0.5f*mul+addx,0.0f*mul+addy,0.25f*mul+addz)
        };

        int[] triangles = {
            0, 2, 1,
            0, 3, 2,
            0, 4, 3,
            0, 5, 4,
            0, 6, 5,
            0, 7, 6,
            0, 8, 7,
            0, 1, 8,
            1, 2, 3,
            1, 3, 4,
            8, 1, 4,
            8, 4, 5,
            7, 8, 5,
            7, 5, 6
        };

        mesh = GetComponent<MeshFilter>().mesh;

        mesh.vertices = vertices;
        mesh.triangles = triangles;
    }
}
