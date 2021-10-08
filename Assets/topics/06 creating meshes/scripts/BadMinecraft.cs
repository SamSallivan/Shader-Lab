using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof (MeshFilter))]
[RequireComponent(typeof (MeshRenderer))]
public class BadMinecraft : MonoBehaviour
{
    Mesh mesh;

    void Start()
    {
        MakeCube();
    }

    void MakeCube()
    {
        Vector3[] c = new Vector3[8];

        c[0] = new Vector3(0, 0, 0);
        c[1] = new Vector3(1, 0, 0);
        c[2] = new Vector3(1, 1, 0);
        c[3] = new Vector3(0, 1, 0);
        c[4] = new Vector3(0, 1, 1);
        c[5] = new Vector3(1, 1, 1);
        c[6] = new Vector3(1, 0, 1);
        c[7] = new Vector3(0, 0, 1);

        Vector3[] vertices = new Vector3[]
        {

            c[0], c[1], c[2], c[3],//south

            c[3], c[2], c[5], c[4],//top

            c[1], c[6], c[5], c[2],//east

            c[0], c[3], c[4], c[7],//west

            c[7], c[4], c[5], c[6],//north

            c[0], c[1], c[6], c[7] //bottom

        };

        Vector3 south = Vector3.back;
        Vector3 top = Vector3.up;
        Vector3 east = Vector3.right;
        Vector3 west = Vector3.left;
        Vector3 north = Vector3.forward;
        Vector3 bottom = Vector3.down;

        Vector3[] normals = new Vector3[]
        {
            south, south, south, south,
            top, top, top, top,
            east, east, east, east,
            west, west, west, west,
            north, north, north, north,
            bottom, bottom, bottom, bottom
        };

        Vector2[] uvs = new Vector2[]
        {
            new Vector2(0f, 0f), new Vector2(0.5f, 0f), new Vector2(0.5f, 0.5f), new Vector2(0f, 0.5f),

            new Vector2(0f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(0.5f, 1f), new Vector2(0f, 1f),

            new Vector2(0f, 0f), new Vector2(0.5f, 0f), new Vector2(0.5f, 0.5f), new Vector2(0f, 0.5f),

            new Vector2(0.5f, 0f), new Vector2(0.5f, 0.5f), new Vector2(0f, 0.5f), new Vector2(0f, 0f),

            new Vector2(0.5f, 0f), new Vector2(0.5f, 0.5f), new Vector2(0f, 0.5f), new Vector2(0f, 0f),

            new Vector2(0.5f, 0f), new Vector2(1f, 0f), new Vector2(1f, 0.5f), new Vector2(0.5f, 0.5f),

        };

        int[] triangles = new int[] {
            0, 3, 2, 0, 2, 1,
            4, 7, 6, 4, 6, 5,
            8, 11, 10, 8, 10, 9,
            12, 15, 14, 12, 14, 13,
            16, 19, 18, 16, 18, 17,
            20, 21, 22, 20, 22, 23
        };

        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.normals = normals;
        mesh.uv = uvs;

        GetComponent<MeshFilter>().mesh = mesh;
    }
}
