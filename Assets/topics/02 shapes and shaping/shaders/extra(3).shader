Shader "examples/week 2/shapes"
{

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

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
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float circle (float cutoff, float2 uv) {
                return step(cutoff, 1-length(uv));
            }

            float fill(float x, float size) { // 09
                return 1. - smoothstep(size-0.005, size+0.005, x);
            }

            float circleSDF(float2 st) { // 08
                return length(st - 0.5) * 2.;
            }

            float trapezoid(float2 position, float halfWidth1, float halfWidth2, float halfHeight) {
                position.x = abs(position.x);
                position.x -= (halfWidth2 + halfWidth1) * 0.5;
                float2 end = float2((halfWidth2 - halfWidth1) * 0.5, halfHeight);
                float2 intersection = position - end * clamp(dot(position, end) / dot(end, end), -1.0, 1.0);
                float d = length(intersection);
                if (intersection.x > 0.0) {
                    return d;
                }
                return max(-d, abs(position.y) - halfHeight);
            }


            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                uv*=5;
                float2 gridUV = frac(uv)*2-1;
                
                float index = floor(uv.x) + floor(uv.y);
                gridUV.x += sin(_Time.y + index/3) * 0.25;
                gridUV.y += cos(_Time.y + index/3) * 0.25;

                float halfWidth1 = 0.2 + 0.15 * sin(_Time.z * 1.3);
                float halfWidth2 = 0.2 + 0.15 * sin(_Time.z * 1.4 + 1.1);
                float halfHeight = 0.5 + 0.2 * sin(1.3 * _Time.z);
                float d = trapezoid(gridUV, halfWidth1, halfWidth2, halfHeight);

                // same colorization that Inigo Quilez uses in his shaders
                float3 color = float3(1.0,1,1) - sign(d) * float3(0.1, 0.4, 0.7); // base color
                color *= 1.0 - exp(-4.0 * abs(d)); // gradient
	            color *= 0.8 + 0.2 * cos(120.0 * d); // ripples
	            color = lerp(color, float3(1.0,1,1), 1.0 - smoothstep(0.0, 0.015, abs(d)));

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
