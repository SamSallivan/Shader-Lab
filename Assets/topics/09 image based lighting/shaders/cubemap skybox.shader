Shader "examples/week 9/textured skybox"
{
    Properties{
        [NoScaleOffset] _texCube("Cube map", Cube) = "black"{}
    }

        SubShader
    {
        Tags { "Queue" = "Background" "RenderType" = "Background" "PreviewType" = "Skybox" }
        Cull Off
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            samplerCUBE _texCube;

            struct MeshData
            {
                float4 vertex : POSITION;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 objPos : TEXCOORD0;
            };

            Interpolators vert(MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.objPos = v.vertex.xyz;

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float3 color = 0;
                float3 sampleVec = normalize(i.objPos);
                color = sampleVec;

                color = texCUBElod(_texCube, float4(sampleVec, 0));
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}