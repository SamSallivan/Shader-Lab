Shader "examples/week 1/masks"
{
    Properties
    {
        [NoScaleOffset] _tex1 ("texture one", 2D) = "white" {}
        [NoScaleOffset] _tex2 ("texture two", 2D) = "white" {}
        [NoScaleOffset] _tex3 ("texture three", 2D) = "white" {}
        _textureOneIntensity ("texture one intensity", range(0,2)) = 1.50
        _textureTwoIntensity ("texture two intensity", range(0,2)) = 2.00
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

            uniform sampler2D _tex1;
            uniform sampler2D _tex2;
            uniform sampler2D _tex3;
            
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

            float _textureOneIntensity;
            float _textureTwoIntensity;

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;

                // sample the color data from each of the three textures and store them in float3 variables

                float3 t1 = tex2D(_tex1, uv).rgb;
                float3 t2 = tex2D(_tex2, uv).rgb;
                float3 mask = tex2D(_tex3, uv).rgb;

                float3 color = 0;
				

				float3 layer1 = max(t1 * 0.75, t2) * (1 - mask) * _textureOneIntensity;
				float3 layer2 = t2 * mask * _textureTwoIntensity;
                
                //float breathing1 = smoothstep(0, 1, sin(_Time.y) * 0.25 + 0.75);
                float breathing1 = sin(_Time.y) * 0.25 + 0.75;
                //float breathing2 = smoothstep(0, 1, cos(_Time.y+3.14/2) * 0.125 + 0.125);
                float breathing2 = cos(_Time.y+3.14/2) * 0.125 + 0.25;
                
				color = tan(layer1 * breathing1 + layer2 * breathing2);


                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
