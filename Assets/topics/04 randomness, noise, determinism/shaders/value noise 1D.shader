Shader "examples/week 4/value noise 1D"
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

            float rand (float v) {
                return frac(sin(v) * 43758.5453123);
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
                uv *= 20;
                float fpos = frac(uv.x);
                float ipos = floor(uv.x);

                float vn = 0;
                vn = rand(ipos);
                //vn = lerp(vn, rand(ipos + 1), fpos);
                vn = lerp(vn, rand(ipos + 1), smoothstep(0,1,fpos));


                return float4(vn.rrr, 1.0);
            }
            ENDCG
        }
    }
}
