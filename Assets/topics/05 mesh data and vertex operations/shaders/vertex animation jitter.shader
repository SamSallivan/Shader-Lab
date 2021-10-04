﻿Shader "examples/week 5/vertex animation jitter"
{
    Properties
    {
        _displacement ("displacement", Range(0, 0.1)) = 0.05
        _timeScale ("time scale", Float) = 1
        _seed ("seed", Range(0, 99999999)) = 15863157
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float _scale;
            float _displacement;
            float _timeScale;
            float _seed;

            float rand (float2 uv) {
                return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float3 rand_vec (float3 pos, float seed) {
                pos.x += seed / 4;
                pos.y += seed / rand(seed);
                pos.z += rand(seed) * pos.x;
                return normalize(float3(rand(pos.xz) * 2 - 1, rand(pos.yx) * 2 - 1, rand(pos.zy) * 2 - 1));
            }

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float disp : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;

                v.vertex.xyz += rand_vec(v.vertex.xyz + round(_Time.y * _timeScale), _seed) * _displacement;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                return float4(i.uv.x, 0, i.uv.y, 1.0);
            }
            ENDCG
        }
    }
}
