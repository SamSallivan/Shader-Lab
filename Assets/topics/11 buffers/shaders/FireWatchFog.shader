Shader "Custom/FireWatchFog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorRamp("Color ramp", 2D) = "white" {}
        _FogIntensity("Fog intensity", Range(0, 1)) = 1
        _FogStart("Fog start distance", float) = 1
        _FogEnd("Fog end distance", float) = 1
        
        _stencilRef ("Stencil Ref", int) = 0
    }
    SubShader
    {
        
		Stencil{
			Ref 1
			ReadMask 1
			Comp NotEqual
			Pass Keep
		}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            sampler2D _ColorRamp;
            float _FogIntensity;
            float _FogStart;
            float _FogEnd;

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 color : COLOR;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;  
                float3 normal : NORMAL;
                float2 worldUV : TEXCOORD1;
                float4 screenPos : TEXCOORD2;
                float surfZ : TEXCOORD3;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;

                o.uv = v.uv;
                o.normal = v.normal;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.surfZ = (-UnityObjectToViewPos(v.vertex) * _ProjectionParams.w).z;

                return o;
            }


            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = tex2D(_MainTex, i.uv);
                
                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                float depth = tex2D(_CameraDepthTexture, screenUV);
                //float depth = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos));

                //float depth01 = Linear01Depth(depth);
                float depthEye = LinearEyeDepth(depth);

                float fogDepth = (depthEye - _FogStart) / _FogEnd;
                float3 fogCol = tex2D(_ColorRamp, (float2(fogDepth, 0)));

                color = lerp(color, fogCol, _FogIntensity);
                //color = (depth > 0) ? lerp(color, fogCol, _FogIntensity) : color;
                
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
