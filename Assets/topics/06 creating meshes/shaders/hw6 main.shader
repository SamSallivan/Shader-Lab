Shader "hw6 main"
{
    Properties
    {
        _displacement ("displacement", Range(0, 0.6)) = 0.05
        _timeScale ("time scale", Float) = 1
        _scale ("noise scale", Range(2, 50)) = 15.5
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
            float _scale;

            float rand (float2 uv) {
                return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }
            
            // create a function to return a random normalized vector
            float3 rand_vec (float3 pos) {
                return normalize(float3(rand(pos.xz) * 2 - 1, rand(pos.yx) * 2 - 1, rand(pos.zy) * 2 - 1));
            }

            float value_noise (float2 uv) {
                float2 ipos = floor(uv);
                float2 fpos = frac(uv); 
                
                float o  = rand(ipos);
                float x  = rand(ipos + float2(1, 0));
                float y  = rand(ipos + float2(0, 1));
                float xy = rand(ipos + float2(1, 1));

                float2 smooth = smoothstep(0, 1, fpos);
                return lerp( lerp(o,  x, smooth.x), 
                             lerp(y, xy, smooth.x), smooth.y);
            }

            float fractal_noise (float2 uv) {
                float n = 0;

                n  = (1 / 2.0)  * value_noise( uv * 1);
                n += (1 / 4.0)  * value_noise( uv * 2); 
                n += (1 / 8.0)  * value_noise( uv * 4); 
                n += (1 / 16.0) * value_noise( uv * 8);
                
                return n;
            }

            float2x2 rotate2D (float angle) {
                return float2x2 (
                    cos(angle), -sin(angle),
                    sin(angle),  cos(angle)
                );
            }

            float rectangle (float2 uv, float2 scale) {
                float2 s = scale * 0.5;
                float2 shaper = float2(step(-s.x, uv.x), step(-s.y, uv.y));
                shaper *= float2(1-step(s.x, uv.x), 1-step(s.y, uv.y));
                return shaper.x * shaper.y;
            }

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
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
                o.uv = v.uv;


                float height = fractal_noise((o.uv + _Time.z / 120) * _scale) * _displacement * (sin(_Time.z * .2) + 1);
                v.vertex.xyz += v.normal * height;

                float3 rVec = rand_vec(v.vertex.xyz + round(_Time.z));

                o.vertex = UnityObjectToClipPos(v.vertex);

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv * 2 - 1.15;
                float time = _Time.y;
                float3 color = 0;

                for(int n = 1; n < 100; n++) {
                    float minus = .05;

                    for(int i = 1; i < 188; i++) {
                        float2 newHourUV = uv + 2 - minus * n;
                        float offset = i  * .075 + sin(time * .4);
                        float2 hourTrans = float2(offset, 0);
                        newHourUV -= hourTrans;
                        float newHourRect = rectangle(newHourUV, float2(0.005, 0.05));
                        color.r += newHourRect / i;
                        color.g += newHourRect / 13 * i;
                        color.b += newHourRect * .5 * i;
                    }
                }

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
