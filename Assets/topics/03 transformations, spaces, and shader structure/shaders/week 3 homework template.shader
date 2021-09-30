Shader "examples/week 3/homework template"
{
    Properties 
    {
        _hour ("hour", Float) = 0
        _minute ("minute", Float) = 0
        _second ("second", Float) = 0
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

            #define TAU 6.28318531
            #define PI  3.14159265

            float _hour;
            float _minute;
            float _second;

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
            
            //  Function from Iñigo Quiles
            //  https://iquilezles.org/www/articles/distfunctions/distfunctions.htm
            float opSmoothUnion( float d1, float d2, float k ) {
                float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
                return lerp( d2, d1, h ) - k*h*(1.0-h); 
            }
            
            //  Function from Iñigo Quiles
            //  https://www.iquilezles.org/www/articles/distfunctions2d/distfunctions2d.htm
            float sdRoundedBox( float2 p, float2 b, float4 r )
            {
                r.xy = (p.x>0.0)?r.xy : r.zw;
                r.x  = (p.y>0.0)?r.x  : r.y;
                float2 q = abs(p)-b+r.x;
                return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r.x;
            }

            //  Function from Iñigo Quiles
            //  https://www.shadertoy.com/view/MsS3Wc
            float3 hsb2rgb( in float3 c ){
                float3 rgb = saturate(abs((c.x*6.0+float3(0.0,4.0,2.0) %
                                        6.0)-3.0)-1.0);
                rgb = rgb*rgb*(3.0-2.0*rgb);
                return c.z * lerp(float3(1, 1, 1), rgb, c.y);
            }

            float2x2 rotate2D (float angle) {
                return float2x2 (
                    cos(angle), -sin(angle),
                    sin(angle),  cos(angle)
                );
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                
                float2 grid = float2(floor(uv.x * 7 - 0.5), floor(uv.y * 7));
                float2 gridUV  = float2(frac(uv.x * 7 - 0.5), frac(uv.y * 7));
                
                float outer = 1;
                float inner = 1;

                for (int x=-1; x < 2; x++){
                    for (int y=-1; y < 2; y++){

                        float2 offset = float2(x,y); 
                        float2 newGrid = grid+offset;
                        float2 newUV = gridUV-offset;

                        float2 shape = 0;

                        float _secondLerp = _second+1;
	                    float _minuteLerp = floor(_minute) + (_second + 1)/60;
	                    float _hourLerp = floor(_hour) + floor(_minute)/60+ (_second+1)/3600;
                        
                        int index = 5 - newGrid.x;
                        float lerpVal = sin(frac(_second) * PI/2);

                        if (newGrid.y == 1.){
                            shape = (int(_secondLerp) >> index) &1;
                            shape = lerp((int(_second) >> index) &1, shape, lerpVal);
        
                        } else if (newGrid.y == 3.){
                            shape = (int(_minuteLerp) >> index) &1;
                            shape = lerp((int(_minute) >> index) &1, shape, lerpVal);
        
                        } else if (newGrid.y == 5.){
                            shape = (int(_hourLerp) >> index) &1;
                            shape = lerp((int(_hour) >> index) &1, shape, lerpVal);
                        }

                        float shaper1 = sdRoundedBox(newUV-0.5, float2(0.2, 0.2), float4(0.1, 0.1, 0.1, 0.1)) + (1.-shape);
                        float shaper2 = sdRoundedBox(newUV-0.5, float2(0.0, 0.0), float4(0.01, 0.01, 0.01, 0.01)) + (1.-shape);
                        
                        outer = opSmoothUnion(outer, shaper1, 0.35);
                        inner = opSmoothUnion(inner, shaper2, 0.35);

                    }
                }

                float clock = max(1.-inner, outer);
                clock = smoothstep(0.475, 0.525, clock);

                uv = i.uv * 2 - 1;
				uv *= 1000;
                float3 color = 0;

				float warpStrength = 0.33;
				uv += cos(uv.yx + float2(_Time.y, 1.5)) * warpStrength;
				uv += sin(uv.yx + float2(0, _Time.y * 3)) * warpStrength;
				uv = mul(uv, rotate2D(_Time.y + uv.x));

				color += float3(uv.x, 0, uv.y);

                color += clock.rrr;

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
