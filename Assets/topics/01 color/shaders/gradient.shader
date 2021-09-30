Shader "examples/week 1/gradient"
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

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;



                float3 color; //= float3(uv.x, 0.0, uv.y);
				//color=uv.xyx;
				//color=uv.rgr;

				float3 colorX=float3(0.2,0.4,0.6);
				float3 colorY=float3(0.6,0.4,0.2);

				float3 gradientX= lerp(colorX,colorY,uv.x);
				float3 gradientY= lerp(colorX,colorY,uv.y);
				color= gradientX+gradientY;
				//color= smoothstep(0,1,gradientX+gradientY);
				//color*=float3(1,2,2);
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
