Shader "examples/week 2/shapes"
{
    Properties
    {
        _spaceBlend ("space blend", Range(0,1)) = 0
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
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            #define TAU 6.28318530718

            uniform float _spaceBlend;

            float4 frag (Interpolators i) : SV_Target
            {
                float2 UV = i.uv*2-1;

                float2 polarUV = float2(atan2(UV.y, UV.x), length(UV));
                polarUV.x = polarUV.x / 6.28 + 0.5;
                float2 uv = lerp(UV, polarUV, _spaceBlend);

                uv.x*=5;
                uv.y*=3;
                float2 gridUV = frac(uv)*2-1;
                float2 gridUV1 = frac(uv-0.5)*2-1;

                float index=0;
                //index = floor(uv.x) * floor(uv.y);
                float index1=0;
                //index1 = floor(uv.x-0.5) * floor(uv.y-0.5);
                
                float shaper = (sin(_Time.y+index) ) * lerp( -15 , 10 , smoothstep( 0 , 1 , sin(_Time.y + index ) ));
                float shape = 1 - smoothstep(0.5, 0.55, pow(abs(gridUV.x), shaper) + pow(abs(gridUV.y), shaper));

                float shaper1 = (cos(_Time.y + index1 ) ) * lerp( -15 , 10 , smoothstep( 0 , 1 , cos(_Time.y + index1 ) ));
                float shape1 = smoothstep(0.5, 0.55, pow(abs(gridUV1.x), shaper1) + pow(abs(gridUV1.y), shaper1));

                float color = max(shape1,shape);
                float color1 = min(shape1,shape);

                return float4(shape, color1, shape1, 1.0);
                //return float4(sin(color), sin(_Time.x), sin(color1), 1.0); //pow(color1,shaper1)

                //return float4(color1.r,color1*shaper,color1*shaper1, 1.0);
            }
            ENDCG
        }
    }
}
