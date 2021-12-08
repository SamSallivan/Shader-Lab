Shader "Custom/starry blur"
{
    Properties {
        _tex0 ("tex", 2D) = "white" {}
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

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };

            #define numTap 15.0

            sampler2D _tex0;

            float noised(float2 co){
                return frac(sin(dot(co, float2(12.9898, 78.233))) * 43758.5453);
            }
            
            float2 getField(float2 p)
            {
                float3 nzd = noised(p*2.);
                nzd += noised(p*8.)*0.3;    
                return normalize(float2(nzd.z,-nzd.y));
            }


            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.uv = v.uv;
                return o;
            }


            float4 frag (Interpolators i) : SV_Target
            {
                float2 q = _ScreenParams.xy / _ScreenParams.w;
                float2 p = q * float2(i.screenPos.x / i.screenPos.y, 1.0);
                //p = p*2 - 1;
                //float aspect = _ScreenParams.x / _ScreenParams.y;
                //p.x *= aspect;
                

                float2 dsp = getField(p);
                float3 col = 0;
                
                for(float i = 0.; i < numTap; i++)
                {
                    float2 nxtTap = p + dsp*i*0.005*(sin(_Time.y)*0.25+0.6);
                    col += tex2Dlod(_tex0, float4(nxtTap,0,0)).bgr;
                    dsp = lerp(dsp, getField(nxtTap), 0.5);
                }
                
                col = col*smoothstep(-0.25,.9,q.y)*1.35/numTap;
                col *= pow(16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.15)*0.4 + 0.6;
                return float4(col, 1.0);
            }
            ENDCG
        }
    }
}
