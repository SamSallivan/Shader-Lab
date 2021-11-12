Shader "examples/week 10/ObraDinn"
{
    Properties
    {
        _MainTex ("render texture", 2D) = "white" {}
        _Dither ("dither pattern", 2D) = "gray" {}
        _threshold ("threshold", float ) = 0

    }

    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex; float4 _MainTex_TexelSize;
            sampler2D _Dither; float4 _Dither_TexelSize;
            float _threshold;

            struct MeshData 
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 posWorld : TEXCOORD1;
                //float3 viewDir : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                //o.viewDir = WorldSpaceCameraView;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float color = 0;
                float2 uv = i.uv;

                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
                float2 ditherUV = (uv * _Dither_TexelSize.xy) * _MainTex_TexelSize.zw;
                //float noise = tex2D(_ditherPattern, ditherUV).r;
                
                ditherUV.x +=  _ScreenParams.x *  viewDirection.y;

                float3 graysclaeLuminence = float3(0.299, 0.587, 0.144);
                color = dot(tex2D(_MainTex, uv), graysclaeLuminence);
                
                float threshold = dot(tex2D(_Dither, ditherUV), graysclaeLuminence);

                color = step(threshold, color + _threshold);

                return float4(color.rrr, 1.0);
            }
            ENDCG
        }
    }
}
