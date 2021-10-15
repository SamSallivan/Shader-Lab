Shader "examples/week 6/week6"
{
    Properties
    {
        _tex("my great texture", 2D) = "white"{}
    }

        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Cull off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _tex; float4 _tex_ST;

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
                float angle = _Time.z/4;
                float ox = 0.5;
                float oy = 0.5;
                float pi = 3.14;

                float angleX = sin(_Time.x*20) * (pi/2)+pi/2;
                //float angleX = sin(_Time.x * 20) * (pi / 4) + pi / 4;
                float3x3 rotationMatrixX = float3x3 (
                    1, 0, 0,
                    0, cos(angleX), -sin(angleX),
                    0, sin(angleX), cos(angleX)
                    );

                v.vertex.xyz = v.normal.z==-1 ? mul(v.vertex.xyz, rotationMatrixX):v.vertex.xyz;
                


                //rotate the whole thing
                v.vertex.xz -= float2(0.5, 0.5);
                float3x3 rotationMatrix = float3x3 (
                    cos(angle), 0,sin(angle),
                    0,1,0,
                    -sin(angle),0,cos(angle)
                    );




                Interpolators o;
                v.vertex.xyz = mul(v.vertex.xyz, rotationMatrix);   
                o.vertex = UnityObjectToClipPos(v.vertex);


                o.uv = v.uv;
                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float2 uv = i.uv;

                float3 color = 0;
                color = tex2D(_tex, uv);

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
