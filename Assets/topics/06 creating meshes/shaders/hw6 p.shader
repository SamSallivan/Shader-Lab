Shader "hw6 p"
{
    Properties
    {
        _displacement ("displacement", Range(0, 0.6)) = 0.05
        _timeScale ("time scale", Float) = 1
        _scale ("noise scale", Range(2, 50)) = 15.5
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

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv * 2 - 1;
                float time = _Time.y;
                float3 color = 0;

                color += float3(abs(sin(time)) - .45f, 0, sin(time) + .2);




                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
