using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

[RequireComponent(typeof(MeshRenderer))]
public class SendTime : MonoBehaviour
{
    Material mat;
    string hourProp = "_hour";
    string minProp = "_minute";
    string secProp = "_second";

    void Start () {
        mat = GetComponent<MeshRenderer>().material;
        if (!mat.HasProperty(hourProp) || !mat.HasProperty(minProp) || !mat.HasProperty(secProp)) {
            Debug.LogError("the shader associated with the material on this game object is missing a necessary property. _hour, _minute, and _second are required");
        }
    }
    void Update () {
        // getting the precise current time and sending values to the shader
        long ticks = DateTime.Now.TimeOfDay.Ticks;
        TimeSpan duration = new TimeSpan(ticks);
        
        float hour = (float)(duration.TotalHours % 24);
        float min  = (float)(duration.TotalMinutes % 60);
        float sec  = (float)(duration.TotalSeconds % 60);

        mat.SetFloat(hourProp, hour);
        mat.SetFloat(minProp, min);
        mat.SetFloat(secProp, sec);
    }
}
