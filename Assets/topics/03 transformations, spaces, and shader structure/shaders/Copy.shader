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

            #define TAU 6.28318530718

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

            float opSmoothUnion( float d1, float d2, float k ) {
                float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
                return lerp( d2, d1, h ) - k*h*(1.0-h); 
            }

            float sdRoundedBox( float2 p, float b, float r ) {
                float2 q = abs(p)-b+r;
                return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r;
            }

            float LED( float2 POS, float2 UV, float size ){
    
    
                //TIME
                float blend = sin(fmod(  _second,         1.0 )*1.57075);
    
                float secs1 = _second;
                float secs2 = _second + 1;
    
	            float mins1 = _minute;
	            float mins2 = _minute;
    
	            float hors1 = _hour;
	            float hors2 = _hour;
    
                // draw LED
                float d = 0.;
                if        (POS.x == 2.){
                    d =      float( (int(secs2) >> int(POS.y)) &1 );
                    d = lerp( float( (int(secs1) >> int(POS.y)) &1 ), d, blend );
        
                } else if (POS.x == 1.){
                    d =      float( (int(mins2) >> int(POS.y)) &1 );
                    d = lerp( float( (int(mins1) >> int(POS.y)) &1 ), d, blend );
        
                } else if (POS.x == 0.){
                    d =      float( (int(hors2) >> int(POS.y)) &1 );
                    d = lerp( float( (int(hors1) >> int(POS.y)) &1 ), d, blend );
                }

                // Output to screen
                //d = (length(UV-0.5)) + (1.-d);// for round dots
                //d = (length(UV-0.5)) + (1.-d);// for square dots
                d = sdRoundedBox(UV-0.5, size, size-0.2) + (1.-d);

                return d;
            }

            float LED_tiled( in float2 UV ){
                float2 char_pos = float2( floor(UV.x*5.), floor(UV.y*5.) );
                float2 char_uv  = float2( fmod(UV.x*5., 1.), fmod(UV.y*5., 1.) );
    
                float fgr = 1.;
                float bgr = 1.;
    
                for( int x=-1; x < 2; x++ ){
                    for( int y=-1; y < 2; y++ ){
                        float2 offset = float2(x,y);
                        fgr = opSmoothUnion( fgr, LED( char_pos+offset, char_uv-(offset), 0.1 ), 0.35 );
                        bgr = opSmoothUnion( bgr, LED( char_pos+offset, char_uv-(offset), 0.3 ), 0.35 );
                    }
                }
    
                return 1.-max(1.-fgr, bgr);
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv; // * 2 - 1;

                float fg = LED_tiled( uv );
                fg = smoothstep( 0.5, 0.55, fg );
    
                float bg = LED_tiled( uv + float2(0.,0.05) );
                bg = smoothstep( 0.2, 0.85, bg )*0.5;
    
    
    
                float3 col_bg = lerp( float3(1.,1.,1.), float3(0.5,0.,0.), bg);
    
                float3 col_fg = lerp( col_bg, float3(1.,0.,0.), fg);

                return float4( lerp( col_bg, col_fg, 0.5), 1.0);
            }
            ENDCG
        }
    }
}
/*
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

            #define TAU 6.28318530718

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

            float opSmoothUnion( float d1, float d2, float k ) {
                float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
                return lerp( d2, d1, h ) - k*h*(1.0-h); 
            }

            float sdRoundedBox( float2 p, float b, float r ) {
                float2 q = abs(p)-b+r;
                return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r;
            }
            float LED( float2 newGrid, float2 newUV){
    
                float secs1 = _second-1;
                float secs2 = _second;
    
	            float mins1 = floor(_minute) - (_second+1)/60;
	            float mins2 = _minute;
    
	            float hors1 = _hour;
	            float hors2 = _hour ;
                // draw LED
                float shape = 0.;
                if        (newGrid.x == 2.){
                    shape =      float( (int(secs2) >> int(newGrid.y)) &1 );
                    shape = lerp( float( (int(secs1) >> int(newGrid.y)) &1 ), shape, sin(frac(_second)*1.57075)  );
        
                } else if (newGrid.x == 1.){
                    shape =      float( (int(mins2) >> int(newGrid.y)) &1 );
                    shape = lerp( float( (int(mins1) >> int(newGrid.y)) &1 ), shape, sin(frac(_second)*1.57075)  );
        
                } else if (newGrid.x == 0.){
                    shape =      float( (int(hors2) >> int(newGrid.y)) &1 );
                    shape = lerp( float( (int(hors1) >> int(newGrid.y)) &1 ), shape, sin(frac(_second)*1.57075)  );
                }

                shape = sdRoundedBox(newUV-0.5, 0.3, 0.1) + (1.-shape);
                //d = (length(UV-0.5)) + (1.-d);// for round dots
                //d = (length(UV-0.5)) + (1.-d);// for square dots
                return shape;

            }
            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv; // * 2 - 1;

                float2 grid = float2( floor(uv.x*5), floor(uv.y*5) );
                float2 gridUV  = float2( frac(uv.x*5), frac(uv.y*5) );
    
                float bgr = 1;
    
                for( int x=-1; x < 2; x++ ){
                    for( int y=-1; y < 2; y++ ){
                        float2 offset = float2(x,y); 

                        float2 shape;
                        float2 newGrid = grid+offset;
                        float2 newUV = gridUV-offset;

                        
                        if        (newGrid.x == 2.){
                            shape =      float( (int(secs2) >> int(newGrid.y)) &1 );
                            shape = lerp( float( (int(secs1) >> int(newGrid.y)) &1 ), shape, sin(frac(_second)*1.5)  );
        
                        } else if (newGrid.x == 1.){
                            shape =      float( (int(mins2) >> int(newGrid.y)) &1 );
                            shape = lerp( float( (int(mins1) >> int(newGrid.y)) &1 ), shape, sin(frac(_second)*1.5)  );
        
                        } else if (newGrid.x == 0.){
                            shape =      float( (int(hors2) >> int(newGrid.y)) &1 );
                            shape = lerp( float( (int(hors1) >> int(newGrid.y)) &1 ), shape, sin(frac(_second)*1.5)  );
                        }

                        shape = sdRoundedBox(newUV-0.5, 0.3, 0.1) + (1.-shape);
                        

                        shape = LED( newGrid, newUV);
                        bgr = opSmoothUnion( bgr, shape, 0.35 );
                    }
                }
    
                float fg = 1-bgr;

                fg = smoothstep( 0.5, 0.55, fg );

                float3 col_fg = lerp( float3(0.,0.,0.), float3(1.,0.,0.), fg);
                
                return float4( fg,fg,fg, 1.0);
            }
            ENDCG
        }
    }
}

*/