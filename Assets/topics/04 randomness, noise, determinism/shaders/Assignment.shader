Shader "examples/week 4/Assignment"
{
    Properties
    {
        _scale ("noise scale", Range(2, 800)) = 5
        _speed ("speed", Range(0, 10)) = 1
        _intensity("noise intensity", Range(0.001, 0.05)) = 0.006
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
            float _speed;
            float _intensity;

            float rand (float2 uv) {
                return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float noise (float2 uv) {
                float2 ipos = floor(uv);
                float2 fpos = frac(uv); 
                
                float o  = rand(ipos);
                float x  = rand(ipos + float2(1, 0));
                float y  = rand(ipos + float2(0, 1));
                float xy = rand(ipos + float2(1, 1));

                float2 smooth = smoothstep(0, 1, fpos);
                return lerp( lerp(o,  x, smooth.x), lerp(y, xy, smooth.x), smooth.y);
            }

            float fractal_noise (float2 uv) {
                float n = 0;

                n  = (1 / 2.0)  * noise( uv * 1 + _Time.y * _speed);
                n += (1 / 4.0)  * noise( uv * 2 ); 
                n += (1 / 8.0)  * noise( uv * 4 ); 
                n += (1 / 16.0) * noise( uv * 8 );
                
                return n;
            }

            //  Function from Iñigo Quiles
            //  https://www.shadertoy.com/view/MsS3Wc
            float3 hsb2rgb(in float3 c) {
                float3 rgb = saturate(abs((c.x * 6.0 + float3(0.0, 4.0, 2.0) %
                    6.0) - 3.0) - 1.0);
                rgb = rgb * rgb * (3.0 - 2.0 * rgb);
                return c.z * lerp(float3(1, 1, 1), rgb, c.y);
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
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }

            #define PI  3.14159265
            #define TAU 6.28318531

            float4 frag (Interpolators i) : SV_Target
            {   
                float2 uv = i.uv;
                uv *= _scale;

                float3 color = float3(0, 0, 0);

                for (int i = 0; i < 10; i++) {

                    float2 newUV = uv;

                    float offset = _Time.y + i * 0.025;

                    float2 translate = float2(0, 0);
                    translate.x += sin(offset);
                    translate.y += cos(offset);
                    translate *= 0.33;

                    float colorOffset = sin(offset * TAU) * 0.1;

                    float3 col = hsb2rgb(float3(colorOffset, 0.8, 0.15));

                    newUV.x = fractal_noise(newUV);
                    newUV.y = fractal_noise(newUV + translate);

                    uv += 5 * newUV;

                    color = saturate(color + col);
                }


                color = fractal_noise(uv);

                return float4(color.rrr, 1.0);
            }
            ENDCG
        }
    }
}
