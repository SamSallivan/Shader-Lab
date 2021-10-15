Shader "examples/week 5/CheemsHat"
{
    Properties
    {
        _tex ("texture", 2D) = "white" {}
        _rotationSpeed("Self rotation speed", Float) = 0.0
        _displacement ("displacement", Range(0, 0.1)) = 0.0
        _timeScale ("time scale", Float) = 1
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
            
            #define TAU 6.28318530718
            
            sampler2D _tex;
            float _rotationSpeed;
            float _displacement;
            float _timeScale;

            float rand (float2 uv) {
                return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }
            
            float3 rand_vec (float3 pos) {
                return normalize(float3(rand(pos.xz) * 2 - 1, rand(pos.yx) * 2 - 1, rand(pos.zy) * 2 - 1));
            }

            float4x4 rotation_matrix (float3 axis, float angle) {
                axis = normalize(axis);
                float s = sin(angle);
                float c = cos(angle);
                float oc = 1.0 - c;
                
                return float4x4(
                    oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                    oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                    oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                    0.0,                                0.0,                                0.0,                                1.0);
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
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;

                float3 rVec = rand_vec(v.vertex.xyz + round(_Time.y * _timeScale));
                v.vertex.xyz += rVec * _displacement;

                float4x4 rotation = rotation_matrix(float3(0, 1, 0), _Time.x * _rotationSpeed * TAU);
                v.vertex = mul(rotation, v.vertex);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                float3 color = tex2D(_tex, uv).rgb;

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
