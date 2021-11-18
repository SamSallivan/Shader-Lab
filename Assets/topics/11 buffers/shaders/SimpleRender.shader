Shader "Custom/SimpleRender" 
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
    }
        SubShader
    {
        Pass
        {
 
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"
 
            sampler2D _MainTex;
            half4 frag(v2f_img i) : COLOR
            {
                return tex2D(_MainTex, i.uv);;
            }
 
            ENDCG
        }
    }
}