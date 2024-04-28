Shader "examples/week 12/Ray Marching With Color"
{
    Properties {
        _smoothness ("shape blend smoothness", Range(0.001,1)) = 0.2
        _speed ("shape move speed", Range(0,1)) = 0.2
        //_shapePos1 ("shape Pos 1", Vector) = (0, 0, 0)
        //_shapePos2 ("shape Pos 2", Vector) = (0, 0, 0)
        //_shapePos3 ("shape Pos 3", Vector) = (0, 0, 0)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            #define MAX_STEPS 100
            #define MAX_DIST 100
            #define MIN_DIST 0.001

            float _smoothness;
            float _speed;
            //float3 _shapePos1;
            //float3 _shapePos2;
            //float3 _shapePos3;

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 hitPos : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.hitPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = v.uv;
                return o;
            }

            float PlaneDistance(float3 eye, float3 centre) {
                return eye.y - centre.y;
            }

            float SphereDistance(float3 eye, float3 centre, float radius) {
                return distance(eye, centre) - radius;
            }
            
            float CubeDistance(float3 eye, float3 centre, float3 size) {
                float3 o = abs(eye-centre) -size;
                float ud = length(max(o,0));
                float n = max(max(min(o.x,0),min(o.y,0)), min(o.z,0));
                return ud+n;
            }

            // Following distance functions from http://iquilezles.org/www/articles/distfunctions/distfunctions.htm
            float TorusDistance(float3 eye, float3 centre, float r1, float r2)
            {   
                float2 q = float2(length((eye-centre).xz)-r1,eye.y-centre.y);
                return length(q)-r2;
            }

            // a substitute for our min function that smoothly blends primitives together
            float smin ( float a, float b) {
                // k is smoothness factor
                float k = _smoothness;
                float h = max( k-abs(a-b), 0.0 )/k;
                return min( a, b ) - h*h*h*k*(1.0/6.0);
            }

            float4 sminColor( float a, float3 colA, float b, float3 colB)
            {
                float k = _smoothness;
                float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
                float blendDst = lerp( b, a, h ) - k*h*(1.0-h);
                float3 blendCol = lerp(colB,colA,h);
                return float4(blendDst, blendCol);
            }

            float4 get_dist (float3 pos) {
                // this defines the scene
                float t1 = _Time.y * _speed;
                float t2 = t1 * 1.5;

                const int count = 4;
                float4 shapeInfos[count];
                
                shapeInfos[0] = float4(SphereDistance(pos, 1.5 * float3(sin(t2), cos(t2), 0), 1.25), float3(1, 0.1, 0.1));
                shapeInfos[1] = float4(CubeDistance(pos, 1.5 * float3(0, sin(t1), cos(t1)), float3(1, 1, 1)), float3(0.1, 1, 0.1));
                shapeInfos[2] = float4(TorusDistance(pos, 1.5 * float3(sin(t1), 0, cos(t1)), 1.25, 0.5), float3(0.1, 0.1, 1));
                shapeInfos[3] = float4(PlaneDistance(pos, float3(0, -5, 0)), float3(1, 1, 1));
                /*
                shapeInfos[0] = float4(SphereDistance(pos, _shapePos1, 1), float3(1, 0.1, 0.1));
                shapeInfos[1] = float4(CubeDistance(pos, _shapePos2, float3(1, 1, 1)), float3(0.1, 1, 0.1));
                shapeInfos[2] = float4(TorusDistance(pos, _shapePos3, 1.5, 0.5), float3(0.1, 0.1, 1));
                shapeInfos[3] = float4(PlaneDistance(pos, float3(0, -5, 0)), float3(1, 1, 1));
                */

                float4 currentShapeInfo = float4(MAX_DIST, 1, 1, 1);
                for(int i = 0; i < count; i++) {
                    currentShapeInfo = sminColor(currentShapeInfo.x, currentShapeInfo.yzw, shapeInfos[i].x, shapeInfos[i].yzw);
                }
                
                return float4(currentShapeInfo);
            }

            float4 ray_march (float3 rayOrigin, float3 rayDir) {
                // keep track of the total distance we've traveled
                float marchDist = 0;
                float3 color = 0;

                for(int i = 0; i < MAX_STEPS; i++) {
                    // our current position
                    float3 pos = rayOrigin + rayDir * marchDist;

                    // our current distance to the closest point in the scene
                    float distToSurf = get_dist(pos).x;
                    color = get_dist(rayOrigin + rayDir * marchDist).yzw;

                    // add this distance to our accumulated march distance
                    marchDist += distToSurf;
                    //color = get_dist(pos).yzw;

                    // break out of loop if we are at the surface or go too far
                    if (distToSurf < MIN_DIST || marchDist > MAX_DIST) 
                    break;
                }

                return float4(marchDist, color);
            }

            float3 get_normal(float3 pos){
                float disAtPos = get_dist(pos).x;
                float sampleDelta = 0.01;
                float3 sampleVec = float3(
                   get_dist(pos + float3(sampleDelta,0,0)).x,
                   get_dist(pos + float3(0,sampleDelta,0)).x,
                   get_dist(pos + float3(0,0,sampleDelta)).x
                );
                float3 normal = normalize(sampleVec - disAtPos);
                return normal;

            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = 0;
                float2 uv = i.uv * 2 - 1;
                float3 normal = float3(0,1,0);

                float3 camPos = _WorldSpaceCameraPos;
                float3 rayDir = normalize(i.hitPos - camPos);
                //float3 camPos = float3(0, 0, -5);
                //float3 rayDir = normalize(float3(uv.x, uv.y, 1));

                float d = ray_march(camPos, rayDir);
                float3 surfaceColor = ray_march(camPos, rayDir).yzw;
                float3 p = camPos + rayDir * d;

                normal = get_normal(p);

                // half lambert lighting
                float3 lightPos = float3(0, 50, 20);
                //lightPos.xz += float2(sin(_Time.y), cos(_Time.y))*200;
                //float3 lightDirection = _WorldSpaceLightPos0;
                //float3 lightColor = _LightColor0;
                float3 lightDirection = normalize(lightPos - p);;
                float3 lightColor = float3(1, 1, 1);

                float diffuseFalloff = max(0, dot(normal, lightDirection));

                float shadow = ray_march(camPos + rayDir * d + normal*0.001*2, lightDirection);
                if(shadow < 10) diffuseFalloff *= 0.1;

                float halfLambert = pow(diffuseFalloff * 0.75 + 0.25, 2);
                float3 diffuse = halfLambert * lightColor * surfaceColor;

                // constrain lighting values to distances that are less than max (only where we hit something)
                //diffuse *= 1-step(MAX_DIST, d);

                color = diffuse;// + float3(0, 0.05, 0.05);
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
