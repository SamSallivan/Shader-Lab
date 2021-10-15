Shader "examples/week 6/week6_2"
{
    SubShader
    {
        Tags { "RenderType" = "Opaque" }

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
                float3 normal : NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Interpolators vert(MeshData v)
            {

                float angle = _Time.z ;
                //rotate the whole thing
                float3x3 rotationMatrix = float3x3 (
                    1,0,0,
                    0, cos(angle),-sin(angle),
                    0, sin(angle),cos(angle)
                    );
                Interpolators o;
                v.vertex.xyz = mul(v.vertex.xyz, rotationMatrix);
                v.vertex.xyz += (v.vertex.xyz) * (1-((sin(_Time.z)) / 2));
                v.vertex.xyz /= 3;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            float convertColVal(float c) {
                return (c / 255);
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float2 uv = i.uv;

                //float3 col1 = float3(convertColVal(214), convertColVal(214), convertColVal(214));
                //float3 col2 = float3(convertColVal(148), convertColVal(113), convertColVal(70));

                float3 col1 = float3(convertColVal(235), convertColVal(198), convertColVal(87));
                float3 col2 = float3(convertColVal(204), convertColVal(129), convertColVal(75));
                return float4(lerp(col1,col2,uv.x), 1.0);
            }
            ENDCG
        }
    }
}
