Shader "examples/week 5/vertex animation jitter"
{
    Properties
    {
        _displacement ("displacement", Range(0, 0.1)) = 0.05
        _timeScale ("time scale", Float) = 1
        _seed ("seed", Float) = 82193283
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

            float _displacement;
            float _timeScale;
            float _seed;

            float rand (float2 uv) {
                return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }
            
            // create a function to return a random normalized vector
            float3 rand_vec (float3 pos) {
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

                // use our ran_vec function. seed the function with the vertex position in object space
                // add _Time within the round() function to get this value to change in discrete steps
                float3 rVec = rand_vec(v.vertex.xyz + round(_Time.y * _timeScale));

                // add our random normalized vector to our vertex position, scaled by _displacement
                v.vertex.xyz += rVec * _displacement;
               
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
