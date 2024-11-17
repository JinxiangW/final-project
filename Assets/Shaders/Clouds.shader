// This Unity shader reconstructs the world space positions for pixels using a depth
// texture and screen space UV coordinates. The shader draws a checkerboard pattern
// on a mesh to visualize the positions.
Shader "Custom/Clouds"
{
    Properties
    { 
        _CloudTex("Cloud Texture", 2D) = "white" {}
        _Ramp("Ramp", 2D) = "white" {}
    }

    // The SubShader block containing the Shader code.
    SubShader
    {
        // SubShader Tags define when and under which conditions a SubShader block or
        // a pass is executed.
        Tags { "RenderType" = "Trasparent" "RenderPipeline" = "UniversalPipeline" "Queue"="Transparent+1"}
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
        #include "Assets/Shaders/Common.hlsl"

        CBUFFER_START(UnityPerMaterial)


        CBUFFER_END

        TEXTURE2D(_CloudTex);
        SAMPLER(sampler_CloudTex);
        TEXTURE2D(_Ramp);
        SAMPLER(sampler_Ramp);

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
            // screen uv
            float2 UV = IN.positionHCS.xy / _ScaledScreenParams.xy;
            float4 cloudSample = SAMPLE_TEXTURE2D(_CloudTex, sampler_CloudTex, IN.uv);

            // cloud color
            float2 colorUV = float2(cloudSample.x, 0.0);
            float4 color = SAMPLE_TEXTURE2D(_Ramp, sampler_Ramp, colorUV);
            return half4(color.rgb, cloudSample.a);
            return 0;
        }

        ENDHLSL

        Pass
        {
            Name "cloud"
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDHLSL
        }
    }
}