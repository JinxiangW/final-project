////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) Martin Bustos @FronkonGames <fronkongames@gmail.com>. All rights reserved.
//
// THIS FILE CAN NOT BE HOSTED IN PUBLIC REPOSITORIES.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef ARTISTIC_INCLUDE
#define ARTISTIC_INCLUDE

#if UNITY_VERSION >= 600000
  #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
  #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

  #define SAMPLE_MAIN(uv) SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv)
  #define SAMPLE_MAIN_LOD(uv) SAMPLE_TEXTURE2D_LOD(_BlitTexture, sampler_LinearClamp, uv, 0)
  #define TEXEL_SIZE _BlitTexture_TexelSize
#else
  #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
  #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"

  TEXTURE2D_X(_MainTex);

  CBUFFER_START(UnityPerMaterial)
  float4 _MainTex_TexelSize;
  CBUFFER_END

  #define SAMPLE_MAIN(uv) SAMPLE_TEXTURE2D_X(_MainTex, sampler_LinearClamp, uv)
  #define SAMPLE_MAIN_LOD(uv) SAMPLE_TEXTURE2D_X_LOD(_MainTex, sampler_LinearClamp, uv, 0)
  #define TEXEL_SIZE _MainTex_TexelSize
#endif

TEXTURE2D(_CameraDepthTexture);
SAMPLER(sampler_CameraDepthTexture);

inline float SampleDepth(float2 uv)
{
  return SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, uv);
}

inline float SampleLinear01Depth(float2 uv)
{
  return Linear01Depth(SampleDepth(uv), _ZBufferParams);
}

inline float SampleEyeLinearDepth(float2 uv)
{
  return LinearEyeDepth(SampleDepth(uv), _ZBufferParams);
}

#if SHADER_API_PS4
inline float2 lerp(float2 a, float2 b, float t) { return lerp(a, b, (float2)t); }
inline float3 lerp(float3 a, float3 b, float t) { return lerp(a, b, (float3)t); }
inline float4 lerp(float4 a, float4 b, float t) { return lerp(a, b, (float4)t); }
#endif

inline float mod(float x, float y)    { return x - y * floor(x / y); }
inline float2 mod(float2 a, float2 b) { return a - floor(a / b) * b; }
inline float3 mod(float3 a, float3 b) { return a - floor(a / b) * b; }
inline float4 mod(float4 a, float4 b) { return a - floor(a / b) * b; }

inline float Rand(const float c)
{
  return frac(sin(dot(float2(c, 1.0 - c), float2(12.9898, 78.233))) * 43758.5453);
}

inline float Rand(const float2 c)
{
  return frac(sin(dot(c, float2(12.9898, 78.233))) * 43758.5453);
}

inline float2 Rand2(const float2 c)
{
  const float2x2 m = float2x2(12.9898, 0.16180, 78.233, 0.31415);

  return frac(sin(mul(c, m)) * float2(43758.5453, 14142.1));
}

inline float Rand21(const float2 c)
{
  return frac(sin(dot(c.xy, float2(12.9898, 78.233))) * 43758.5453);
}

inline float Rand(const float2 c, const int seed)
{
  return frac(sin(dot(c.xy, float2(12.9898, 78.233)) + seed) * 43758.5453);
}

inline float Trunc(float x, float num_levels)
{
  return floor(x * num_levels) / num_levels;
}

inline float2 Trunc(float2 x, float2 num_levels)
{
  return floor(x * num_levels) / num_levels;
}

inline float Sat(float t)
{
  return clamp(t, 0.0, 1.0);
}

inline float Linterp(float t)
{
  return Sat(1.0 - abs(2.0 * t - 1.0));
}

inline float RemapValue(float t, float a, float b)
{
  return Sat((t - a) / (b - a));
}

inline float RemapValue(float target, float oldMin, float oldMax, float newMin, float newMax)
{
  return(target - oldMin) / (oldMax - oldMin) * (newMax - newMin) + newMin;
}

inline float2 RemapValue(float2 target, float oldMin, float oldMax, float newMin, float newMax)
{
  target.x = RemapValue(target.x, oldMin, oldMax, newMin, newMax);
  target.y = RemapValue(target.y, oldMin, oldMax, newMin, newMax);
  
  return target;
}

/// Noise by Ian McEwan, Ashima Arts.
inline float3 mod289(const float3 x)  { return x - floor(x * (1.0 / 289.0)) * 289.0; }
inline float2 mod289(const float2 x)  { return x - floor(x * (1.0 / 289.0)) * 289.0; }
inline float3 permute(const float3 x) { return mod289(((x * 34.0) + 1.0) * x); }
inline float snoise(const float2 v)
{
  const float4 C = float4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439);
  
  float2 i  = floor(v + dot(v, C.yy) );
  float2 x0 = v -   i + dot(i, C.xx);

  float2 i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
  
  float4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
  
  i = mod289(i);
  const float3 p = permute(permute(i.y + float3(0.0, i1.y, 1.0)) + i.x + float3(0.0, i1.x, 1.0));
  
  float3 m = max(0.5 - float3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m;
  m = m*m;

  const float3 x = 2.0 * frac(p * C.www) - 1.0;
  float3 h = abs(x) - 0.5;
  const float3 ox = floor(x + 0.5);
  float3 a0 = x - ox;
  
  m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
  
  float3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;

  return 130.0 * dot(m, g);
}

float _Intensity;
float _DeltaTime;

float _Brightness;
float _Gamma;
float _Hue;

inline float3 ColorAdjust(float3 pixel, float contrast, float brightness, float hue, float gamma, float saturation)
{
  pixel = max(0.0, (pixel - (float3)0.5) * contrast + (float3)0.5 + brightness);

  float3 hsv = RgbToHsv(pixel);
  hsv.x += hue;
  pixel = HsvToRgb(hsv);

  pixel = pow(abs(pixel), gamma);

  float luma = Luminance(pixel);
  pixel = luma.xxx + saturation * (pixel - luma.xxx);

  return max(0.0, pixel);
}

#if UNITY_VERSION >= 600000
struct VertexInput
{
  uint vertexID : SV_VertexID;
  UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct VertexOutput
{
  float4 positionCS : SV_POSITION;
  float2 texcoord   : TEXCOORD0;
  UNITY_VERTEX_OUTPUT_STEREO
};

VertexOutput ArtisticVert(VertexInput input)
{
  Varyings output;
  UNITY_SETUP_INSTANCE_ID(input);
  UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

  float4 pos = GetFullScreenTriangleVertexPosition(input.vertexID);
  float2 uv  = GetFullScreenTriangleTexCoord(input.vertexID);

  output.positionCS = pos;
  output.texcoord   = DYNAMIC_SCALING_APPLY_SCALEBIAS(uv);

  return output;
}
#else
struct VertexInput
{
  float4 positionOS : POSITION;
  float2 texcoord   : TEXCOORD0;
  UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct VertexOutput
{
  half4  positionCS   : SV_POSITION;
  half4  texcoord     : TEXCOORD0;
  UNITY_VERTEX_OUTPUT_STEREO
};

VertexOutput ArtisticVert(VertexInput input)
{
  VertexOutput output;
  UNITY_SETUP_INSTANCE_ID(input);
  UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

  output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

  float4 projPos = output.positionCS * 0.5;
  projPos.xy = projPos.xy + projPos.w;

  output.texcoord.xy = UnityStereoTransformScreenSpaceTex(input.texcoord);
  output.texcoord.zw = projPos.xy;

  return output;
}
#endif

#if ARTISTIC_DEMO
float _DemoSeparator;

// Do not use ;)
inline half3 PixelDemo(half3 pixel, half3 final, float2 uv)
{
  const half separatorWidth = 6.0 * _MainTex_TexelSize.x;

  _DemoSeparator += separatorWidth;
  if (uv.x >= _DemoSeparator)
    final = pixel;
  else if (abs(uv.x - _DemoSeparator) < separatorWidth)
    final.r += 0.4;

  return final;
}
#endif // ARTISTIC_DEMO

#endif // ARTISTIC_INCLUDE