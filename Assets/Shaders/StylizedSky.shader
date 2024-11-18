// This Unity shader reconstructs the world space positions for pixels using a depth
// texture and screen space UV coordinates. The shader draws a checkerboard pattern
// on a mesh to visualize the positions.
Shader "Custom/Caustics"
{
    Properties
    { 
        _MainTex("Skybox", CUBE) = "" {}
        _StarTex("Starfield", CUBE) = "" {}
        _SunTex("Sun", 2D) = "" {}
        _MoonTex("Moon", 2D) = "" {}
        _MoonRadius("Moon Radius", Range(0.1, 0.5)) = 0.2
    }

    // The SubShader block containing the Shader code.
    SubShader
    {
        // SubShader Tags define when and under which conditions a SubShader block or
        // a pass is executed.
        Tags { "RenderPipeline" = "UniversalPipeline" "Queue" = "Background" "RenderType" = "Opaque"}
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Assets/Shaders/Common.hlsl"

            TEXTURECUBE(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURECUBE(_StarTex);
            SAMPLER(sampler_StarTex);
            
            TEXTURE2D(_SunTex);
            SAMPLER(sampler_SunTex);
            TEXTURE2D(_MoonTex);
            SAMPLER(sampler_MoonTex);

            CBUFFER_START(UnityPerMaterial)
            float _MoonRadius;
            CBUFFER_END


            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float3 obj : TEXCOORD2;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                OUT.obj = IN.positionOS.xyz;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // screen UV
                float2 UV = IN.positionHCS.xy / _ScaledScreenParams.y;

                float3 camPos = _WorldSpaceCameraPos;
                float3 sampleDirection = normalize(IN.positionWS);

                half4 skyboxColor = SAMPLE_TEXTURECUBE(_MainTex, sampler_MainTex, sampleDirection);
                half4 starfieldColor = SAMPLE_TEXTURECUBE(_StarTex, sampler_StarTex, sampleDirection);

                // main light
                Light light = GetMainLight();
                float3 sunDir = light.direction;
                float3 moonDir = -sunDir;

                // moon color
                float4 moonClipPos = mul(UNITY_MATRIX_VP, float4(moonDir, 0));
                moonClipPos /= moonClipPos.w;
                moonClipPos.y = -moonClipPos.y;
                float2 moonUV = 0.5 * moonClipPos.xy + 0.5;
                moonUV.x *= _ScreenParams.x / _ScreenParams.y;

                half4 moonColor = max(abs(UV - moonUV).x, abs(UV - moonUV).y) < _MoonRadius ? SAMPLE_TEXTURE2D(_MoonTex, sampler_MoonTex, (moonUV - UV) / _MoonRadius + 0.5) : 0;
                moonColor.rgb *= moonColor.a;
                return skyboxColor + starfieldColor + moonColor;
            }
            ENDHLSL
        }
    }
}