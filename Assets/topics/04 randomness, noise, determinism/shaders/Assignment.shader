Shader "examples/week 4/Assignment"
{
    Properties
    {
        _tex ("texture", 2D) = "white" {}
        _scale ("noise scale", Range(2, 800)) = 50
        _speed ("speed", Range(0, 10)) = 1
        _contrast ("contrast", Range(1, 30)) = 25
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

            sampler2D _tex;
            float _scale;
            float _speed;
            float _contrast;

            float rand (float2 uv) {
                return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float noise (float2 uv) {
                float2 ipos = floor(uv);
                float2 fpos = frac(uv); 

                //fpos = fpos*fpos*(1 - fpos);
                
                float o  = rand(ipos);
                float x  = rand(ipos + float2(1, 0));
                float y  = rand(ipos + float2(0, 1));
                float xy = rand(ipos + float2(1, 1));

                float2 smooth = smoothstep(0, 1, fpos);
                //float l = lerp( lerp(o,  x, smooth.x), lerp(y, xy, smooth.x), smooth.y);
                return lerp( lerp(o,  x, smooth.x), lerp(y, xy, smooth.x), smooth.y);

            }

            float fractal_noise (float2 uv) {
                float n = 0;
                float time = 0;
                time = _Time.y;

                n  = (1 / 2.0)  * noise( uv * 1 + time); //uv = mul(uv, float2x2( 0.80,  0.60, -0.60,  0.80 )*2.02);
                n += (1 / 4.0)  * noise( uv * 2 ); //uv = mul(uv, float2x2( 0.80,  0.60, -0.60,  0.80 )*2.03);
                n += (1 / 8.0)  * noise( uv * 4 ); //uv = mul(uv, float2x2( 0.80,  0.60, -0.60,  0.80 )*2.01);
                n += (1 / 16.0) * noise( uv * 8 );
                
                return n;
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

            float4 frag (Interpolators i) : SV_Target
            {   
                float2 uv = i.uv;
                uv*=20;

                //float fn = fractal_noise(uv);

                float3 color = fractal_noise(uv);
                //float3 color = fractal_noise(uv + fractal_noise(uv + fractal_noise(uv)));

                return float4(color.rrr, 1.0);
            }
            ENDCG
        }
    }
}
