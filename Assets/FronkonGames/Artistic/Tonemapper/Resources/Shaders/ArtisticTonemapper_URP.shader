// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Shader "Hidden/Fronkon Games/Artistic/Tonemapper URP"
{
  Properties
  {
    _MainTex("Main Texture", 2D) = "white" {}
  }

  HLSLINCLUDE
  float _Exposure;
  float3 _ColorFilter;
  float _Vibrance;
  float3 _VibranceBalance;
  float _ContrastMidpoint;
  float4 _Lift;
  float4 _Midtones;
  float4 _Gain;
  float _LiftBright;
  float _MidtonesBright;
  float _GainBright;

  float _WhiteLevel;
  float _LinearWhite;
  float _LinearColor;

  float _Cutoff;

  float _Saturation;
  float _Contrast;

  float _LuminanceMean;

  static const float FloatEpsilon = 1.0e-10;
 
  inline float SafePositivePowFloat(float base, float power)
  {
    return pow(max(abs(base), FloatEpsilon), power);
  }
 
  inline float CalcLuminance(half3 pixel)
  {
    const float3 LumCeoff = float3(0.299, 0.587, 0.114);

    return (log(1.0 + dot(pixel, LumCeoff))).r;
  }

  inline half3 ExposureAndColorFilter(half3 pixel)
  {
    return exp2(_Exposure) * pixel * _ColorFilter;
  }

  inline half3 SaturationAndVibrance(half3 pixel)
  {
    float luma = CalcLuminance(pixel);
    
    pixel = lerp(luma.xxx, pixel, _Saturation);

    float maxColor = max(pixel.r, max(pixel.g, pixel.b));
    float minColor = min(pixel.r, min(pixel.g, pixel.b));

    float saturationColor = maxColor - minColor;
	  float3 coeffVibrance = float3(_VibranceBalance * _Vibrance);

    return lerp(luma.xxx, pixel, 1.0 + (coeffVibrance * (1.0 - (sign(coeffVibrance) * saturationColor))));
  }

  inline half3 LiftGammaGain(half3 pixel)
  {
    _Lift *= _LiftBright;
    _Midtones *= _MidtonesBright;
    _Gain *= _GainBright;
    
    pixel.r = SafePositivePowFloat(_Gain.r * (pixel.r + (_Lift.r - 1.0) * (1.0 - pixel.r)), 1.0 / _Midtones.r);
    pixel.g = SafePositivePowFloat(_Gain.g * (pixel.g + (_Lift.g - 1.0) * (1.0 - pixel.g)), 1.0 / _Midtones.g);
    pixel.b = SafePositivePowFloat(_Gain.b * (pixel.b + (_Lift.b - 1.0) * (1.0 - pixel.b)), 1.0 / _Midtones.b);
    
    return pixel;    
  }
  
  inline half3 LogContrast(half3 pixel)
  {
    const float eps = 0.00001;

    float3 adjX = _ContrastMidpoint + (log2(pixel + eps) - _ContrastMidpoint) * _Contrast;
    
    return max((half3)0.0, exp2(adjX) - eps);
  }
  ENDHLSL

  SubShader
  {
    Tags
    {
      "RenderType" = "Opaque"
      "RenderPipeline" = "UniversalPipeline"
    }
    LOD 100
    ZTest Always ZWrite Off Cull Off

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper Linear Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(LinearOperator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper Logarithmic Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(LogarithmicOperator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper Exponential Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(ExponentialOperator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper Simple Reinhard Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(SimpleReinhardOperator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper Luma Reinhard Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(LumaReinhardOperator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper Luma Inverted Reinhard Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(LumaInvertedReinhardOperator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper White Luma Reinhard Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(WhiteLumaReinhardOperator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper Hejl 2015 Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(Hejl2015Operator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper Filmic Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(FilmicOperator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper Filmic Aldridge Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(FilmicAldridgeOperator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper ACES Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(ACESOperator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper ACES Oscars Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(ACESOscarsOperator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper ACES Hill Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(ACESHillOperator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper ACES Narkowicz Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(ACESNarkowiczOperator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper Lottes Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(LottesOperator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper Uchimura Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(UchimuraOperator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper Unreal 3 Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(Unreal3Operator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper Uncharted 2 Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(Uncharted2Operator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper WatchDogs Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(WatchDogsOperator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper Piece-Wise Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(PieceWiseOperator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper RomBinDaHouse Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(RomBinDaHouseOperator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper Oklab Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(OklabOperator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper Clamping Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(ClampingOperator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper Max3 Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(Max3Operator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }

    Pass
    {
      Name "Fronkon Games Artistic Tonemapper Ma3 Inverted Pass"

      HLSLPROGRAM
      #pragma vertex ArtisticVert
      #pragma fragment ArtisticFrag
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma exclude_renderers d3d9 d3d11_9x ps3 flash
      #pragma multi_compile ___ ARTISTIC_DEMO

      #include "Artistic.hlsl"
      #include "Operators.hlsl"

      half4 ArtisticFrag(VertexOutput input) : SV_Target
      {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        const float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord).xy;
        const half4 color = SAMPLE_MAIN(uv);
        half4 pixel = color;

        pixel.rgb = PreOperator(pixel.rgb);
        pixel.rgb = saturate(Max3InvertedOperator(pixel.rgb));
        pixel.rgb = PostOperator(pixel.rgb);
#if ARTISTIC_DEMO
        pixel.rgb = PixelDemo(color.rgb, pixel.rgb, uv);
#endif
        return lerp(color, pixel, _Intensity);
      }
      ENDHLSL
    }    
  }
  
  FallBack "Diffuse"
}
