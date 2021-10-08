Shader "examples/week 5/Assignment"
{
    Properties
    {
        _color1 ("color 1", Color) = (0.1, 0.3, 0.0, 1)
        _color2 ("color 2", Color) = (0.8, 0.1, 0.0, 1)
        _color3 ("color 3", Color) = (0.6 ,0.3, 0.1, 1)
        _color4 ("color 4", Color) = (0.1, 0.1, 0.4, 1)
        _scale ("noise scale", Range(1, 10)) = 3
        _speed ("speed", Range(0, 10)) = 1
        _displacement ("displacement", Range(0, 10)) = 0.05 
        _colorIntensity ("color intensity", Range(0, 10)) = 3
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

            float3 _color1;
            float3 _color2;
            float3 _color3;
            float3 _color4;
            float _scale;
            float _speed;
            float _displacement;
            float _colorIntensity;

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
                n += (1 / 4.0)  * noise( uv * 2 + _Time.y * _speed); 
                n += (1 / 8.0)  * noise( uv * 4 + _Time.y * _speed); 
                n += (1 / 16.0) * noise( uv * 8 + _Time.y * _speed);
                
                return n;
            }

            float4 warp (float2 uv) {
                
                float fn0 = fractal_noise(uv + float2(0, 0));
                float fn1 = fractal_noise(uv + float2(1, 1));
                float fn2 = fractal_noise(uv + float2(1, 0) + float2(fn0, fn1) * 2);
                float fn3 = fractal_noise(uv + float2(0, 1) + float2(fn0, fn1) * 2);
                //float fn2 = fractal_noise(uv + float2(1, 0) + fn1 * 2);
                //float fn3 = fractal_noise(uv + float2(0, 1) + fn2 * 2);
                float wave = fractal_noise(uv + float2(fn2, fn3) * 2);

                float3 color = _color1;
                //float3 color = float3(0.1, 0.3, 0.0, 1);
                color = lerp(color, _color2, fn1 * 3);
                //color = lerp(color, float3(0.8,0.1,0.0),fn1 * 3);
                color = lerp(color, _color3, fn2 * 2);
                //color = lerp(color, float3(0.6,0.3,0.1),fn2 * 2);
                color = lerp(color, _color4, fn3 * 1);
                //color = lerp(color, float3(0.1,0.1,0.4),fn3 * 1);

                return float4(wave, color);
            }

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float3 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 color : COLOR;
                float2 uv : TEXCOORD0;
                float wave : TEXCOORD1;
                float2 worldUV : TEXCOORD2;
            };


            Interpolators vert (MeshData v)
            {
                Interpolators o;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float2 worldUV = worldPos.xz * 0.02 * _scale;

                o.wave = warp(worldUV* _scale).x * _displacement * v.color;
                v.vertex.y += o.wave;
                o.color = warp(v.uv* _scale).yzw;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                o.uv = v.uv;

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = i.color * _colorIntensity; 

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
