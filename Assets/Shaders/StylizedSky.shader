// This Unity shader reconstructs the world space positions for pixels using a depth
// texture and screen space UV coordinates. The shader draws a checkerboard pattern
// on a mesh to visualize the positions.
Shader "Custom/Caustics"
{
    Properties
    { 
        _MainTex("Skybox", CUBE) = "" {}
        _StarTex("Starfield", CUBE) = "" {}
        
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


            TEXTURECUBE(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURECUBE(_StarTex);
            SAMPLER(sampler_StarTex);
            
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
                // 定义采样方向。通常是从某个世界空间方向来采样cubemap
                float3 sampleDirection = normalize(IN.positionWS); // 使用世界空间位置作为采样方向

                // 采样天空盒纹理
                half4 skyboxColor = SAMPLE_TEXTURECUBE(_MainTex, sampler_MainTex, sampleDirection);
                half4 starfieldColor = SAMPLE_TEXTURECUBE(_StarTex, sampler_StarTex, sampleDirection);

                // 组合结果，简单相加
                return skyboxColor + starfieldColor;
            }
            ENDHLSL
        }
    }
}