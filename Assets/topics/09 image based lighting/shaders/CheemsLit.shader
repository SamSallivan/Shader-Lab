Shader "examples/week 9/CheemsLit"
{
    Properties
    {
        _albedo ("texture", 2D) = "white" {}
        [NoScaleOffset] _normalMap ("normal map", 2D) = "bump" {}
        [NoScaleOffset] _displacementMap ("displacement map", 2D) = "gray" {}
        [NoScaleOffset] _IBL ("IBL cube map", Cube) = "black" {}
        
        _gloss ("gloss", Range(0,1)) = 1
        _reflectivity ("reflectivity", Range(0,1)) = 0.5

        _fresnelPower ("fresnel power", Range(0, 10)) = 5
        _normalIntensity ("normal intensity", Range(0, 1)) = 1
        _displacementIntensity ("displacement intensity", Range(0, 0.5)) = 0

        _rotationSpeed("Self rotation speed", Float) = 0.0
        _displacement ("displacement", Range(0, 10)) = 0.0
        _timeScale ("time scale", Float) = 1
    }

    SubShader
    {
        Tags { "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            #define TAU 6.28318530718
            #define DIFFUSE_MIP_LEVEL 5
            #define SPECULAR_MIP_STEPS 4
            #define MAX_SPECULAR_POWER 256
            
            sampler2D _albedo; float4 _albedo_ST;
            sampler2D _normalMap;
            sampler2D _displacementMap;
            samplerCUBE _IBL;
            
            float _gloss;
            float _reflectivity;
            float _fresnelPower;
            float _normalIntensity;
            float _displacementIntensity;

            float _timeScale;
            float _rotationSpeed; 
            float _displacement;

            float rand (float2 uv) {
                return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }
            
            float3 rand_vec (float3 pos) {
                return normalize(float3(rand(pos.xz) * 2 - 1, rand(pos.yx) * 2 - 1, rand(pos.zy) * 2 - 1));
            }

            float4x4 rotation_matrix (float3 axis, float angle) {
                axis = normalize(axis);
                float s = sin(angle);
                float c = cos(angle);
                float oc = 1.0 - c;
                
                return float4x4(
                    oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                    oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                    oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                    0.0,                                0.0,                                0.0,                                1.0);
            }

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 tangent : TEXCOORD2;
                float3 bitangent : TEXCOORD3;
                float3 posWorld : TEXCOORD4;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                //o.uv = v.uv;
                o.uv = TRANSFORM_TEX(v.uv, _albedo);

                float3 rVec = rand_vec(v.vertex.xyz + round(_Time.y * _timeScale));
                v.vertex.xyz += rVec * _displacement;
                
                float height = tex2Dlod(_displacementMap, float4(o.uv, 0, 0)).r * 2 - 1;
                v.vertex.xyz += v.normal * height * _displacementIntensity;

                float4x4 rotation = rotation_matrix(float3(0, 0, 1), _Time.x * _rotationSpeed * TAU);
                v.vertex = mul(rotation, v.vertex);
                
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldNormal(v.tangent);
                o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);

                return o;

            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = 0;
                float2 uv = i.uv;
                
                float3 tangentSpaceNormal = UnpackNormal(tex2D(_normalMap, uv));
                tangentSpaceNormal = normalize(lerp(float3(0, 0, 1), tangentSpaceNormal, _normalIntensity));
                
                float3x3 tangentToWorld = float3x3 
                (
                    i.tangent.x, i.bitangent.x, i.normal.x,
                    i.tangent.y, i.bitangent.y, i.normal.y,
                    i.tangent.z, i.bitangent.z, i.normal.z
                );

                float3 normal = mul(tangentToWorld, tangentSpaceNormal);
                //float3 normal = normalize(i.normal);
                
                float3 lightDirection = _WorldSpaceLightPos0;
                float3 lightColor = _LightColor0; 

                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
                float3 halfDirection = normalize(viewDirection + lightDirection);
                float3 viewReflection = reflect(-viewDirection, normal);
                float fresnel = 1 - saturate(dot(viewDirection, normal));
                fresnel = pow(fresnel, _fresnelPower);
                float reflectivity = _reflectivity * fresnel;

                float3 surfaceColor = tex2D(_albedo, uv).rgb;
                //float3 surfaceColor = lerp(0, tex2D(_albedo, uv).rgb, 1 - reflectivity);

                float directDiffuse = max(0, dot(normal, lightDirection));
                directDiffuse = floor(directDiffuse * 3) / 3;
                //float3 indirectDiffuse = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, normal, 20) * _reflectivity;
                float3 indirectDiffuse = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, normal, 20);
                //float3 indirectDiffuse = texCUBElod(_IBL, float4(normal, 20));//DIFFUSE_MIP_LEVEL

                //float3 diffuse = surfaceColor * (directDiffuse * lightColor + indirectDiffuse);
                //float3 diffuse = surfaceColor * (directDiffuse * lightColor + indirectDiffuse * fresnel);
                float3 diffuse = surfaceColor * (directDiffuse * lightColor + indirectDiffuse * _reflectivity);

                float mip = (1-_gloss) * SPECULAR_MIP_STEPS;
                float3 indirectSpecular = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, viewReflection, mip) * _reflectivity;

                float specularFalloff = max(0, dot(normal, halfDirection));
                float3 directSpecular = pow(specularFalloff, _gloss * MAX_SPECULAR_POWER + 0.0001) * lightColor * _gloss;
                float3 specular = directSpecular + indirectSpecular * reflectivity;


                
                color = diffuse + specular;

                return float4(color, 1.0);
            }
            ENDCG
        }
    
    // Pass to render object as a shadow caster
		Pass 
		{
			Name "CastShadow"
			Tags { "LightMode" = "ShadowCaster" }
	
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"
	
			struct v2f 
			{ 
				V2F_SHADOW_CASTER;
			};
	
			v2f vert( appdata_base v )
			{
				v2f o;
				TRANSFER_SHADOW_CASTER(o)
				return o;
			}
	
			float4 frag( v2f i ) : COLOR
			{
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}
	}
}

