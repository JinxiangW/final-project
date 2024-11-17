Shader "Custom/Clouds"
{
    Properties
    {
        [MainTexture] _BaseMap("Albedo", 2D) = "white" {}
        _Ramp("Color Ramp", 2D) = "white" {}
        [HideInInspector][MainColor] _BaseColor("Color", Color) = (1,1,1,1)
    }

    SubShader
    {
		PackageRequirements {
			"org.happy-turtle.order-independent-transparency"
			"com.unity.render-pipelines.universal"
		}

        // Universal Pipeline tag is required. If Universal render pipeline is not set in the graphics settings
        // this Subshader will fail. One can add a subshader below or fallback to Standard built-in to make this
        // material work with both Universal Render Pipeline and Builtin Unity Pipeline
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
            "IgnoreProjector" = "True"
            "Queue" = "Geometry+1"
        }
        LOD 300

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
        #include "Assets/Shaders/Common.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
        #include "Packages/org.happy-turtle.order-independent-transparency/URP/Shaders/OitLitForwardPassURP.hlsl"
        CBUFFER_START(UnityPerMaterial)


        CBUFFER_END

        TEXTURE2D(_Ramp);
        SAMPLER(sampler_Ramp);

        [earlydepthstencil]
        // Used in Standard (Physically Based) shader
        void frag(
            Varyings input
            , out half4 outColor : SV_Target0
        #ifdef _WRITE_RENDERING_LAYERS
            , out float4 outRenderingLayers : SV_Target1
        #endif
            , uint uSampleIdx : SV_SampleIndex
        )
        {
            UNITY_SETUP_INSTANCE_ID(input);
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

        #if defined(_PARALLAXMAP)
        #if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
            half3 viewDirTS = input.viewDirTS;
        #else
            half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
            half3 viewDirTS = GetViewDirectionTangentSpace(input.tangentWS, input.normalWS, viewDirWS);
        #endif
            ApplyPerPixelDisplacement(viewDirTS, input.uv);
        #endif

            SurfaceData surfaceData;
            InitializeStandardLitSurfaceData(input.uv, surfaceData);

        #ifdef LOD_FADE_CROSSFADE
            LODFadeCrossFade(input.positionCS);
        #endif

            InputData inputData;
            InitializeInputData(input, surfaceData.normalTS, inputData);
            SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);

        #ifdef _DBUFFER
            ApplyDecalToSurfaceData(input.positionCS, surfaceData, inputData);
        #endif

            // screen uv
            float2 UV = input.positionCS.xy / _ScaledScreenParams.xy;
            float4 cloudSample = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);

            // cloud color
            float2 colorUV = float2(cloudSample.x, 0.0);
            float4 color = SAMPLE_TEXTURE2D(_Ramp, sampler_Ramp, colorUV);
            color.a = cloudSample.a;
            createFragmentEntry(color, input.positionCS.xyz, uSampleIdx);
            outColor = color.a;
            

        #ifdef _WRITE_RENDERING_LAYERS
            uint renderingLayers = GetMeshRenderingLayer();
            outRenderingLayers = float4(EncodeMeshRenderingLayer(renderingLayers), 0, 0, 0);
        #endif
        }


 

        

        ENDHLSL


        // ------------------------------------------------------------------
        //  Forward pass. Shades all light in a single pass. GI + emission + Fog
        Pass
        {
            // Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Universal Render Pipeline
            Name "ForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

			ZTest LEqual
			ZWrite Off
			Cull Off

            HLSLPROGRAM
			#pragma target 4.5

            #pragma vertex LitPassVertex
            #pragma fragment frag

            
            ENDHLSL
        }

    }

    FallBack "OrderIndependentTransparency/Unlit"
}
