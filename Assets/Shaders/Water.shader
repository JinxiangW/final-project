Shader "Custom/StylizedWater"
{
    Properties 
    {
        _DepthRamp ("Depth Ramp", 2D) = "white" {}
        _Clarity ("Clarity", Range(0, 1)) = 1.0
        _MaxDepth ("Max Depth", Range(0, 100)) = 0.2
        _FoamWidth ("Foam Width", Range(0, 0.05)) =  0.012
        _FoamFreq ("Foam Freq", Range(50, 300)) = 100
        _FoamColor ("FoamColor", Color) = (1,1,1,1)
        _WaveSpeed("Wave Speed", Range(0, 3.0)) = 1.0
        
        _NormalMap("Normal", 2D) = "white" {}
        _NormalScale("Normal Scale", Range(0, 2)) = 1.0
        _SpecIntensity("Specular Intensity", Range(0, 1)) = 0.1
        _SpecColor("Specular Color", Color) = (1, 1, 1, 1)

        _Burn("Burn", Range(0, 1)) = 1.0
    }
    
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "Queue"="Transparent-1"
        }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Pass
        {
            Name "Unlit"
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // Pragmas
            #pragma target 2.0
            
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Assets/Shaders/Common.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float _MaxDepth;
            half4 _FoamColor;
            float _FoamWidth;
            float _FoamFreq;
            float _WaveSpeed;
            float _ParallaxScale;
            float _NormalScale;
            float _SpecIntensity;
            half4 _SpecColor;
            float _Burn;
            float _Clarity;
            CBUFFER_END

            
            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
				float4 tangent:TANGENT;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
                float3 positionWS : TEXCOORD2;

                // TBN
                float3 worldNormal : TEXCOORD3;
				float3 worldTangent :TEXCOORD4;
				float3 worldBitangent : TEXCOORD5;
            };


            TEXTURE2D(_DepthRamp);
            TEXTURE2D(_Displacement);
            float4 _Displacement_ST;
            TEXTURE2D(_NormalMap);
            float4 _NormalMap_ST;
            TEXTURE2D(_CameraOpaqueTexture); 
            #define sampler_CameraOpaqueTexture _Bilinear_Clamp
            SAMPLER(sampler_CameraOpaqueTexture);
            #define dsampler _Bilinear_Repeat
            SAMPLER(dsampler);


            

            Varyings vert(Attributes v)
            {
                Varyings o;
                o.uv = v.uv;
                o.positionWS = TransformObjectToWorld(v.positionOS);
                o.positionCS = TransformObjectToHClip(v.positionOS);
                o.screenPos = ComputeScreenPos(o.positionCS);

                VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal, v.tangent);
				o.worldNormal = normalInput.normalWS;
				o.worldTangent = normalInput.tangentWS;
				o.worldBitangent = normalInput.bitangentWS;
                return o;
            }

            

            // Perlin noise
            float2 randomVec(float2 uv)
            {
	            float vec = dot(uv, float2(127.1, 311.7));
	            return -1.0 + 2.0 * frac(sin(vec) * 43758.5453123);
            }

            float perlinNoise(float2 uv) 
            {				
	            float2 pi = floor(uv);
	            float2 pf = uv - pi;
	            float2 w = pf * pf * (3.0 - 2.0 *  pf);

	            float2 lerp1 = lerp(
		            dot(randomVec(pi + float2(0.0, 0.0)), pf - float2(0.0, 0.0)),
		            dot(randomVec(pi + float2(1.0, 0.0)), pf - float2(1.0, 0.0)), w.x);
                
 	            float2 lerp2 = lerp(
		            dot(randomVec(pi + float2(0.0, 1.0)), pf - float2(0.0, 1.0)),
		            dot(randomVec(pi + float2(1.0, 1.0)), pf - float2(1.0, 1.0)), w.x);
		
	            return lerp(lerp1, lerp2, w.y).x;
            }

            float getBlinnPhongKs(float3 h, float3 n)
            {
                // return dot(h, n);
                return pow(max(dot(h, n),0), 16);
            }

            half4 frag(Varyings i) : SV_TARGET
            {
                half4 col = _FoamColor;
                // Screen uv
                float2 UV = i.positionCS.xy / _ScaledScreenParams.xy;
                // Get depth value from depth buffer 
                #if UNITY_REVERSED_Z
                    real depth = SampleSceneDepth(UV);
                #else
                    // Adjust z to match NDC for OpenGL
                    real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(UV));
                #endif

                // Reconstruct world position based on depth 
                float3 worldPos = ComputeWorldSpacePosition(UV, depth, UNITY_MATRIX_I_VP);

                // Compute water depth
                float hoffset = i.positionWS.y - worldPos.y;

                // Sample from depth color ramp 
                col.xyz = SAMPLE_TEXTURE2D(_DepthRamp, dsampler,float2(saturate(hoffset / _MaxDepth), 0.5)).xyz;
                col.w = lerp(0.6, 0.8, saturate(hoffset / _MaxDepth));

                float3 viewDir = normalize(_WorldSpaceCameraPos - worldPos);
                // Calculate offset from height map 
                float noffset = perlinNoise(i.uv * 50 + _Time.x * 0.5);
                float2 puv = (i.uv + _Time.y * _WaveSpeed * 0.005 + noffset * 0.01) * _NormalMap_ST.xy + _NormalMap_ST.zw;
                

                // Sample from normal map
                half3 n = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, dsampler, puv), _NormalScale);
                n = TransformTangentToWorld(n, half3x3(i.worldTangent.xyz, i.worldBitangent, i.worldNormal)).xyz;

                // Sample from color buffer
                half4 sceneCol =  SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, UV + n.xz);
                // Alpha blend
                sceneCol.w = 1 - col.w;
                col = col + sceneCol;

                Light light = GetMainLight();
                // return half4(viewDir, 1.);
                // Calculate highlight 
                // return half4(n, 1);

                float intensity = getBlinnPhongKs(normalize(viewDir + light.direction), normalize(n*half3(20, 1, 20)));
                half4 specCol = _SpecColor * max(intensity * _SpecIntensity, 0);
                col = col * (1 - specCol.w) + specCol;

                // Compute foam
                float foamThres = _FoamWidth + (perlinNoise(i.uv *  _FoamFreq + _WaveSpeed * _Time.y)) * 0.02;
                half4 foamCol = _FoamColor;
                if (hoffset < foamThres) col = foamCol;

                col.xyz *= _Burn;
                col.w *= _Clarity;
                return col;
               
            }
            ENDHLSL
        }
    }
    FallBack "Hidden/Shader Graph/FallbackError"
}
