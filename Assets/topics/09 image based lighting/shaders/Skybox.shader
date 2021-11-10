Shader "examples/week 9/Skybox"
{
    Properties
    {
		_OffsetHorizon("Horizon Offset",  Range(-1, 1)) = 0
		_HorizonIntensity("Horizon Intensity",  Range(0, 10)) = 3.3
		_SunSet("Sunset/Rise Color", Color) = (1,0.8,1,1)
		_HorizonColorDay("Day Horizon Color", Color) = (0,0.8,1,1)
		_HorizonColorNight("Night Horizon Color", Color) = (0,0.8,1,1)

		 _SunColor("Sun Color", Color) = (1,1,1,1)
		_SunRadius("Sun Radius",  Range(0, 2)) = 0.1
		_MoonColor("Moon Color", Color) = (1,1,1,1)
		_MoonRadius("Moon Radius",  Range(0, 2)) = 0.15
		_MoonOffset("Moon Crescent",  Range(-1, 1)) = -0.1

		_DayTopColor("Day Sky Color Top", Color) = (0.4,1,1,1)
		_DayBottomColor("Day Sky Color Bottom", Color) = (0,0.8,1,1)
        
		_BaseNoise("Base Noise", 2D) = "black" {}
		_Distort("Distort", 2D) = "black" {}
		_SecNoise("Secondary Noise", 2D) = "black" {}
		_BaseNoiseScale("Base Noise Scale",  Range(0, 1)) = 0.2
		_DistortScale("Distort Noise Scale",  Range(0, 1)) = 0.06
		_SecNoiseScale("Secondary Noise Scale",  Range(0, 1)) = 0.05
		_Distortion("Extra Distortion",  Range(0, 1)) = 0.1
		_Speed("Movement Speed",  Range(0, 10)) = 1.4
		_CloudCutoff("Cloud Cutoff",  Range(0, 1)) = 0.3
		_Fuzziness("Cloud Fuzziness",  Range(0, 1)) = 0.04
		_FuzzinessUnder("Cloud Fuzziness Under",  Range(0, 1)) = 0.01

		_CloudColorDayEdge("Clouds Edge Day", Color) = (1,1,1,1)
		_CloudColorDayMain("Clouds Main Day", Color) = (0.8,0.9,0.8,1)
		_CloudColorDayUnder("Clouds Under Day", Color) = (0.6,0.7,0.6,1)
		_CloudColorNightEdge("Clouds Edge Night", Color) = (0,1,1,1)
		_CloudColorNightMain("Clouds Main Night", Color) = (0,0.2,0.8,1)
		_CloudColorNightUnder("Clouds Under Night", Color) = (0,0.2,0.6,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag				
			#include "UnityCG.cginc"
			
			sampler2D _BaseNoise, _Distort, _SecNoise;
			float4 _CloudColorDayEdge, _CloudColorDayMain, _CloudColorDayUnder, _CloudColorNightEdge, _CloudColorNightMain, _CloudColorNightUnder;
			float _SunRadius, _MoonRadius, _MoonOffset, _OffsetHorizon, _HorizonIntensity;
			float4 _SunColor,_MoonColor, _DayTopColor, _DayBottomColor, _NightBottomColor, _NightTopColor;
			float4 _HorizonColorDay, _HorizonColorNight, _SunSet;
			float _BaseNoiseScale, _DistortScale, _SecNoiseScale, _Distortion;
			float _Speed, _CloudCutoff, _Fuzziness, _FuzzinessUnder, _Brightness;

        
			struct MeshData
			{
				float4 vertex : POSITION;
				float3 uv : TEXCOORD0;
			};
        
			struct Interpolators
			{
				float3 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD1;
			};
        
			Interpolators vert (MeshData v)
			{
				Interpolators o;
				o.uv = v.uv;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);

				return o;

			}

			float4 frag (Interpolators i) : SV_Target
			{
				float horizon = abs((i.uv.y * _HorizonIntensity) - _OffsetHorizon);

				float2 skyUV = i.worldPos.xz / i.worldPos.y;

				float baseNoise = tex2D(_BaseNoise, (skyUV - _Time.x) * _BaseNoiseScale).x;

				float noise1 = tex2D(_Distort, ((skyUV + baseNoise) - (_Time.x * _Speed)) * _DistortScale);

				float noise2 = tex2D(_SecNoise, ((skyUV + (noise1 * _Distortion)) - (_Time.x * (_Speed * 0.5))) * _SecNoiseScale);

				float finalNoise = saturate(noise1 * noise2) * 3 * saturate(i.worldPos.y);
				
				float clouds = saturate(smoothstep(_CloudCutoff, _CloudCutoff + _Fuzziness, finalNoise));
				float cloudsunder = saturate(smoothstep(_CloudCutoff, _CloudCutoff + _Fuzziness + _FuzzinessUnder , noise2) * clouds);
				
				
				float3 cloudsColored = lerp(_CloudColorDayEdge, lerp(_CloudColorDayUnder, _CloudColorDayMain, cloudsunder), clouds) * clouds;
				float3 cloudsColoredNight = lerp(_CloudColorNightEdge, lerp(_CloudColorNightUnder,_CloudColorNightMain , cloudsunder), clouds) * clouds;
				cloudsColoredNight *= horizon;
				
				cloudsColored = lerp(cloudsColoredNight, cloudsColored, saturate(_WorldSpaceLightPos0.y));
				cloudsColored += (2 * cloudsColored * horizon);
				
				float cloudsNegative = (1 - clouds) * horizon;

				float sun = distance(i.uv.xyz, _WorldSpaceLightPos0);
				float sunDisc = 1 - (sun / _SunRadius);
				sunDisc = saturate(sunDisc * 50);

				float moon = distance(i.uv.xyz, -_WorldSpaceLightPos0);
				float crescentMoon = distance(float3(i.uv.x + _MoonOffset, i.uv.yz), -_WorldSpaceLightPos0);
				float crescentMoonDisc = 1 - (crescentMoon / _MoonRadius);
				crescentMoonDisc = saturate(crescentMoonDisc * 50);
				float moonDisc = 1 - (moon / _MoonRadius);
				moonDisc = saturate(moonDisc * 50);
				moonDisc = saturate(moonDisc - crescentMoonDisc);

				float3 sunAndMoon = (sunDisc * _SunColor) + (moonDisc * _MoonColor);
				sunAndMoon *= cloudsNegative;

				float3 gradientDay = lerp(_DayBottomColor, _DayTopColor, saturate(horizon));

				float3 gradientNight = lerp(_NightBottomColor, _NightTopColor, saturate(horizon));

				float3 skyGradients = lerp(gradientNight, gradientDay, saturate(_WorldSpaceLightPos0.y)) * cloudsNegative;

				float sunset = saturate((1 - horizon) * saturate(_WorldSpaceLightPos0.y * 5));


				float3 sunsetColoured = sunset * _SunSet;

				float3 horizonGlow = saturate((1 - horizon * 5) * saturate(_WorldSpaceLightPos0.y * 10)) * _HorizonColorDay;// 
				
				float3 color = skyGradients + sunAndMoon + sunsetColoured + cloudsColored + horizonGlow;
				return float4(color,1);
			
			}
			ENDCG
		}
	}
}