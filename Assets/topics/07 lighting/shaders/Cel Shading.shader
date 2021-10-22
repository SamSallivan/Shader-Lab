// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Cel Shading"
{
	Properties
	{
		_PaletteScale("Palette Scale", Float) = 0.75
		_PaletteOffset("Palette Offset", Float) = 0.75
		_RimTint("Rim Tint", Color) = (1,1,1,0)
		_Normal("Normal", 2D) = "white" {}
		_Float1("Float 1", Float) = 0
		_RimOffset("Rim Offset", Float) = 0
		_RimPower("Rim Power", Range( 0 , 1)) = 0
		_OutlineMin("Outline Min", Float) = 0
		_OutlineMax("Outline Max", Float) = 0
		_ToonRamp("Toon Ramp", 2D) = "white" {}
		_Gloss("Gloss", Float) = 0
		_SpecMin("Spec Min", Float) = 0
		_SpecMax("Spec Max", Float) = 0
		_SpecIntensity("Spec Intensity", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityStandardBRDF.cginc"
			#include "Lighting.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _RimOffset;
			uniform float _RimPower;
			uniform float4 _RimTint;
			uniform sampler2D _ToonRamp;
			uniform sampler2D _Normal;
			uniform float4 _Normal_ST;
			uniform float _PaletteScale;
			uniform float _PaletteOffset;
			uniform float _SpecMin;
			uniform float _SpecMax;
			uniform float _Gloss;
			uniform float _SpecIntensity;
			uniform float _OutlineMin;
			uniform float _OutlineMax;
			uniform float _Float1;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				float dotResult138 = dot( ase_worldNormal , ase_worldViewDir );
				float ViewDir80 = dotResult138;
				#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
				float4 ase_lightColor = 0;
				#else //aselc
				float4 ase_lightColor = _LightColor0;
				#endif //aselc
				float4 RimLight100 = saturate( ( pow( ( 1.0 - saturate( ( ViewDir80 + _RimOffset ) ) ) , _RimPower ) * ( ase_lightColor * _RimTint ) ) );
				float2 uv_Normal = i.ase_texcoord2.xy * _Normal_ST.xy + _Normal_ST.zw;
				float4 Normal129 = tex2D( _Normal, uv_Normal );
				float3 ase_worldTangent = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal1 = Normal129.rgb;
				float3 worldNormal1 = float3(dot(tanToWorld0,tanNormal1), dot(tanToWorld1,tanNormal1), dot(tanToWorld2,tanNormal1));
				float dotResult2 = dot( worldNormal1 , _WorldSpaceLightPos0.xyz );
				float Diffuse54 = max( (float)0 , dotResult2 );
				float2 temp_cast_2 = ((Diffuse54*_PaletteScale + _PaletteOffset)).xx;
				float4 PaletteDiffuse46 = tex2D( _ToonRamp, temp_cast_2 );
				float3 normalizeResult34 = normalize( ( ase_worldViewDir + _WorldSpaceLightPos0.xyz ) );
				float dotResult147 = dot( ase_worldNormal , normalizeResult34 );
				float HalfDir81 = dotResult147;
				float Specular150 = pow( max( (float)0 , HalfDir81 ) , _Gloss );
				float smoothstepResult141 = smoothstep( _SpecMin , _SpecMax , Specular150);
				float SmoothSpecular53 = ( smoothstepResult141 * _SpecIntensity );
				float smoothstepResult167 = smoothstep( _OutlineMin , _OutlineMax , ( 1.0 - saturate( ( ViewDir80 + _Float1 ) ) ));
				float4 Outline165 = ( 1.0 - saturate( ( smoothstepResult167 * ase_lightColor ) ) );
				
				
				finalColor = ( ( RimLight100 + ( ( PaletteDiffuse46 * ase_lightColor ) + ( ase_lightColor * SmoothSpecular53 ) ) ) * Outline165 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18912
132;489;1116;623;419.1944;-1598.181;1.684885;True;False
Node;AmplifyShaderEditor.CommentaryNode;35;-2589.523,572.6935;Inherit;False;1396.484;627.5106;;12;81;147;146;79;24;22;23;29;34;19;30;21;HalfDir;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;21;-2088.124,834.3657;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightPos;30;-2146.507,1041.447;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;149;-2586.596,1288.423;Inherit;False;652.1084;307.1056;;2;129;130;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-1869.459,869.8395;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;130;-2539.606,1362.508;Inherit;True;Property;_Normal;Normal;9;0;Create;True;0;0;0;False;0;False;-1;d0b88ab803e3f3d4e94f1afd2cb65fe9;14f2e7000dd8eb4498b650dac463d0e1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;146;-1743.716,660.6121;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;34;-1715.447,869.8156;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;129;-2174.75,1418.969;Inherit;False;Normal;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;37;-2590,19.50594;Inherit;False;1087.929;475.4003;;8;8;80;138;17;13;12;14;137;ViewDir;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;36;-1088.02,18.80064;Inherit;False;1138.429;474.9573;;7;54;10;11;2;9;1;135;Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;8;-2065.473,330.2945;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;135;-1029.183,158.1232;Inherit;False;129;Normal;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldNormalVector;137;-2073.263,71.09984;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;147;-1515.54,760.3641;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;81;-1385.769,768.2964;Inherit;False;HalfDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;138;-1845.087,165.6904;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;1;-807.6832,129.3247;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightPos;9;-826.7669,355.5083;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;42;-1086.98,572.2411;Inherit;False;1272.886;464.8422;;12;53;144;145;141;143;142;150;139;41;140;136;38;Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;136;-1054.522,771.4617;Inherit;False;81;HalfDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;2;-531.9571,239.0862;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;38;-1030.776,634.1614;Inherit;False;Constant;_Int1;Int 1;0;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.CommentaryNode;153;-1077.695,1670.891;Inherit;False;1327.399;688.4039;;13;165;177;164;163;167;158;157;159;168;166;156;154;155;Outline;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;-1706.443,170.2506;Inherit;False;ViewDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;11;-547.0718,120.9313;Inherit;False;Constant;_Int0;Int 0;0;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.CommentaryNode;101;-2582.302,1673.114;Inherit;False;1328.637;686.2552;;13;100;127;108;107;98;99;97;105;106;96;95;94;93;Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;155;-1029.536,1708.009;Inherit;False;80;ViewDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;10;-365.4008,181.8337;Inherit;False;2;0;INT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;154;-1013.425,1802.408;Inherit;False;Property;_Float1;Float 1;10;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-2532.302,1723.114;Inherit;False;80;ViewDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-2516.193,1817.514;Inherit;False;Property;_RimOffset;Rim Offset;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;140;-860.9905,813.7639;Inherit;False;Property;_Gloss;Gloss;16;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;41;-859.8519,689.6907;Inherit;False;2;0;INT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;139;-706.7842,714.6038;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-213.6479,184.2596;Inherit;False;Diffuse;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;156;-850.6144,1747.462;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;95;-2353.382,1762.567;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;52;331.8828,28.54894;Inherit;False;1180.952;473.8137;;8;50;83;48;133;51;90;89;46;Palette Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;96;-2218.11,1775.445;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;142;-506.8912,826.7638;Inherit;False;Property;_SpecMin;Spec Min;17;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;166;-715.3424,1760.34;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;375.8259,210.0877;Inherit;False;Property;_PaletteScale;Palette Scale;0;0;Create;True;0;0;0;False;0;False;0.75;0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;373.1947,300.6289;Inherit;False;Property;_PaletteOffset;Palette Offset;1;0;Create;True;0;0;0;False;0;False;0.75;0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-510.8912,918.7638;Inherit;False;Property;_SpecMax;Spec Max;18;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;150;-550.8384,719.2403;Inherit;False;Specular;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;83;372.6439,113.9665;Inherit;False;54;Diffuse;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;159;-571.3423,1760.34;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;168;-574.0811,1933.277;Inherit;False;Property;_OutlineMax;Outline Max;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;105;-2147.509,2115.704;Inherit;False;Property;_RimTint;Rim Tint;5;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;48;596.3082,176.1328;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;106;-2091.12,1974.081;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.OneMinusNode;97;-2074.11,1775.445;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;99;-2206.829,1880.427;Inherit;False;Property;_RimPower;Rim Power;12;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;158;-571.5646,1843.238;Inherit;False;Property;_OutlineMin;Outline Min;13;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;141;-345.6911,805.3639;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-357.2911,956.5638;Inherit;False;Property;_SpecIntensity;Spec Intensity;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;98;-1921.248,1820.919;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;133;809.7663,139.1672;Inherit;True;Property;_ToonRamp;Toon Ramp;15;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;144;-171.6907,822.9637;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;167;-398.8321,1805.457;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;157;-575.4714,2028.904;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;179;350.3443,1124.208;Inherit;False;1444.615;1237.43;;12;169;185;188;187;186;126;174;128;102;74;72;73;Master;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;-1914.304,1961.527;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;186;371.9742,1996.005;Inherit;False;288.7698;250.3164;;2;71;152;Spec;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;187;372.3899,1223.631;Inherit;False;291;261.3894;;2;70;47;Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;188;371.9196,1483.251;Inherit;False;283;511.0715;;3;68;178;148;Colors;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;-23.87081,831.9319;Inherit;False;SmoothSpecular;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;-1751.892,1887.359;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;163;-213.0833,1934.534;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;1308.427,213.628;Inherit;False;PaletteDiffuse;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;152;457.7552,2121.27;Inherit;False;53;SmoothSpecular;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;127;-1610.978,1900.422;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;47;456.8497,1290.517;Inherit;False;46;PaletteDiffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;164;-83.94722,1937.065;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;148;486.6169,1829.357;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.OneMinusNode;177;-100.3762,1842.925;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;729.3975,1601.932;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;725.7604,1959.642;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;100;-1461.283,1896.486;Inherit;False;RimLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;74;942.2158,1809.576;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;942.6748,1701.5;Inherit;False;100;RimLight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;165;51.98564,1933.875;Inherit;False;Outline;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;67;339.542,576.2635;Inherit;False;1171.546;452.2067;;12;64;66;56;60;59;63;65;62;61;57;55;58;Posterize;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;169;1093.975,1863.191;Inherit;False;165;Outline;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;128;1128.014,1742.359;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;182;-1856.368,1297.205;Inherit;False;654.4421;306.0975;;4;184;183;181;180;Ambient Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;88;-1082.965,1118.834;Inherit;False;833.0174;472.238;;4;87;86;85;84;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;180;-1839.376,1338.75;Inherit;False;Property;_AmbientColor;Ambient Color;6;0;Create;True;0;0;0;False;0;False;0.8964038,1,0.4009434,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;982.7559,680.7544;Inherit;False;DiffusePosterized;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;389.5419,802.899;Inherit;False;150;Specular;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;59;420.1653,889.0461;Inherit;False;Property;_fSteps;fSteps;3;0;Create;True;0;0;0;False;0;False;6;0;False;0;1;INT;0
Node;AmplifyShaderEditor.ObjSpaceLightDirHlpNode;79;-2383.413,1023.742;Inherit;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;62;858.8281,674.3907;Inherit;False;2;0;FLOAT;0;False;1;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;958.4232,372.7554;Inherit;False;87;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldPosInputsNode;29;-2516.712,813.1712;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;185;689.3304,2121.317;Inherit;False;184;AmbientLight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.FloorOpNode;61;732.2944,655.8737;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;14;-2500.784,310.7;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;590.4863,828.779;Inherit;False;2;2;0;FLOAT;0;False;1;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;13;-2250.583,233.2985;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;181;-1780.812,1518.187;Inherit;False;Constant;_Float0;Float 0;8;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;85;-1032.966,1369.831;Inherit;True;Property;_Albedo;Albedo;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-707.4394,1303.121;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;84;-954.7521,1168.834;Inherit;False;Property;_Tint;Tint;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;58;422.6222,706.5893;Inherit;False;Property;_dSteps;dSteps;2;0;Create;True;0;0;0;False;0;False;6;0;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;174;1280.197,1801.572;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;64;855.7421,856.4759;Inherit;False;2;0;FLOAT;0;False;1;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;984.6132,863.506;Inherit;False;SpecularPosterized;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;71;439.6921,2039.728;Inherit;False;66;SpecularPosterized;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;24;-2553.513,627.5703;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;183;-1609.006,1448.653;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;12;-2537.583,125.0986;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;17;-2078.242,239.4954;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;392.1713,626.2635;Inherit;False;54;Diffuse;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;-555.704,1310.486;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;184;-1458.082,1458.916;Inherit;False;AmbientLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;178;472.9424,1737.389;Inherit;False;87;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;23;-2266.508,735.7696;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;68;436.6691,1553.138;Inherit;False;Property;_SurfaceColor;Surface Color;4;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;590.1243,643.4413;Inherit;False;2;2;0;FLOAT;0;False;1;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;22;-2075.164,734.9666;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;435.8987,1370.709;Inherit;False;65;DiffusePosterized;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;1146.786,275.7154;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FloorOpNode;63;729.2083,837.9587;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;126;1434.537,1797.181;Float;False;True;-1;2;ASEMaterialInspector;100;1;Cel Shading;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;19;0;21;0
WireConnection;19;1;30;1
WireConnection;34;0;19;0
WireConnection;129;0;130;0
WireConnection;147;0;146;0
WireConnection;147;1;34;0
WireConnection;81;0;147;0
WireConnection;138;0;137;0
WireConnection;138;1;8;0
WireConnection;1;0;135;0
WireConnection;2;0;1;0
WireConnection;2;1;9;1
WireConnection;80;0;138;0
WireConnection;10;0;11;0
WireConnection;10;1;2;0
WireConnection;41;0;38;0
WireConnection;41;1;136;0
WireConnection;139;0;41;0
WireConnection;139;1;140;0
WireConnection;54;0;10;0
WireConnection;156;0;155;0
WireConnection;156;1;154;0
WireConnection;95;0;93;0
WireConnection;95;1;94;0
WireConnection;96;0;95;0
WireConnection;166;0;156;0
WireConnection;150;0;139;0
WireConnection;159;0;166;0
WireConnection;48;0;83;0
WireConnection;48;1;50;0
WireConnection;48;2;51;0
WireConnection;97;0;96;0
WireConnection;141;0;150;0
WireConnection;141;1;142;0
WireConnection;141;2;143;0
WireConnection;98;0;97;0
WireConnection;98;1;99;0
WireConnection;133;1;48;0
WireConnection;144;0;141;0
WireConnection;144;1;145;0
WireConnection;167;0;159;0
WireConnection;167;1;158;0
WireConnection;167;2;168;0
WireConnection;107;0;106;0
WireConnection;107;1;105;0
WireConnection;53;0;144;0
WireConnection;108;0;98;0
WireConnection;108;1;107;0
WireConnection;163;0;167;0
WireConnection;163;1;157;0
WireConnection;46;0;133;0
WireConnection;127;0;108;0
WireConnection;164;0;163;0
WireConnection;177;0;164;0
WireConnection;72;0;47;0
WireConnection;72;1;148;0
WireConnection;73;0;148;0
WireConnection;73;1;152;0
WireConnection;100;0;127;0
WireConnection;74;0;72;0
WireConnection;74;1;73;0
WireConnection;165;0;177;0
WireConnection;128;0;102;0
WireConnection;128;1;74;0
WireConnection;65;0;62;0
WireConnection;62;0;61;0
WireConnection;62;1;58;0
WireConnection;61;0;57;0
WireConnection;60;0;56;0
WireConnection;60;1;59;0
WireConnection;13;0;12;0
WireConnection;13;1;14;0
WireConnection;86;0;84;0
WireConnection;86;1;85;0
WireConnection;174;0;128;0
WireConnection;174;1;169;0
WireConnection;64;0;63;0
WireConnection;64;1;59;0
WireConnection;66;0;64;0
WireConnection;183;0;180;0
WireConnection;183;1;181;0
WireConnection;17;0;13;0
WireConnection;87;0;86;0
WireConnection;184;0;183;0
WireConnection;23;0;24;0
WireConnection;23;1;29;0
WireConnection;57;0;55;0
WireConnection;57;1;58;0
WireConnection;22;0;23;0
WireConnection;90;1;89;0
WireConnection;63;0;60;0
WireConnection;126;0;174;0
ASEEND*/
//CHKSM=5C2DC90D993C42BDDA0A2C2FA32AAE60591BBD7F