Shader "Custom/postprocess_effect" {
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader 
	{
		Stencil 
		{
			Ref 2
			Comp Equal
		}
		
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) 
		{
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb * half4(1,0,0,1);
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
