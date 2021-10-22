Shader "examples/week 7/posterized"
{
    Properties 
    {
        _surfaceColor ("surface color", Color) = (0.4, 0.1, 0.9)
        _ambientColor ("ambient color", Color) = (0, 0, 0, 0)
        _gloss ("gloss", Range(0,1)) = 1
        _diffuseSteps ("diffuse steps", Int) = 4
        _specularSteps ("specular steps", Int) = 4

    }
    SubShader
    {
        // this tag is required to use _LightColor0
        Tags { "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // might be UnityLightingCommon.cginc for later versions of unity
            #include "Lighting.cginc"

            #define MAX_SPECULAR_POWER 256
            
            float3 _surfaceColor;
            float3 _ambientColor;
            float _gloss;
            int _diffuseSteps;
            int _specularSteps;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float3 posWorld : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = 0;

                float3 normal = normalize(i.normal);
                
                float3 lightDirection = _WorldSpaceLightPos0;
                float3 lightColor = _LightColor0; // includes intensity

                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
                float3 halfDirection = normalize(viewDirection + lightDirection);

                float diffuseFalloff = max(0, dot(normal, lightDirection));
                
                float specularFalloff = max(0, dot(normal, halfDirection));
                specularFalloff = pow(specularFalloff, _gloss * MAX_SPECULAR_POWER + 0.0001) * _gloss;

                // posterization
                float dSteps = max(2, _diffuseSteps);
                float sSteps = max(2, _specularSteps);
                diffuseFalloff = floor(diffuseFalloff * dSteps) / dSteps;
                specularFalloff = floor(specularFalloff * sSteps) / sSteps;

                float3 diffuse = diffuseFalloff * _surfaceColor * lightColor;
                float3 specular = specularFalloff * lightColor;
                
                float3 ambient = _ambientColor * 0.1;
                color = diffuse + specular + ambient;

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
