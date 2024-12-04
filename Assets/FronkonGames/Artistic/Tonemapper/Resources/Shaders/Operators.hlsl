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
#ifndef OPERATORS_INCLUDE
#define OPERATORS_INCLUDE

inline half3 PreOperator(half3 pixel)
{
#if UNITY_COLORSPACE_GAMMA
  pixel = SRGBToLinear(pixel);
#endif
  pixel = ExposureAndColorFilter(pixel);
  pixel = SaturationAndVibrance(pixel);
  return LogContrast(pixel);
}

inline half3 PostOperator(half3 pixel)
{
  pixel = LiftGammaGain(pixel);
  pixel = ColorAdjust(pixel, 1.0, _Brightness, _Hue, _Gamma, 1.0);
#if UNITY_COLORSPACE_GAMMA
  pixel = LinearToSRGB(pixel);
#endif
  return pixel;
}

inline half3 LinearOperator(half3 pixel)
{
  return pixel;
}

inline half3 LogarithmicOperator(half3 pixel)
{
  const float luma = CalcLuminance(pixel);
  const float toneMappedLuma = (log10(1.0 + luma) / log10(1.0 + _WhiteLevel));

  pixel = toneMappedLuma * SafePositivePow(pixel / luma, (half3)_Saturation);

  return pixel;
}

inline half3 ExponentialOperator(half3 pixel)
{
  return exp(-1.0 / (2.72 * pixel + 0.15));
}

inline half3 SimpleReinhardOperator(half3 pixel)
{
  return pixel / (1.0 + pixel);
}

inline half3 LumaReinhardOperator(half3 pixel)
{
  return pixel / (1.0 + CalcLuminance(pixel));
}

inline half3 LumaInvertedReinhardOperator(half3 pixel)
{
  return pixel / (1.0 - CalcLuminance(pixel));
}

inline half3 WhiteLumaReinhardOperator(half3 pixel)
{
  const float luminance = CalcLuminance(pixel);
  pixel = pixel * (1.0 + luminance / (_WhiteLevel * _WhiteLevel)) / (1.0 + luminance);  

  return pixel;
}

inline half3 Hejl2015Operator(half3 pixel)
{
  float3 va = (1.425 * pixel) + 0.05;
  float3 vf = ((pixel * va + 0.004) / ((pixel * (va + 0.55) + 0.0491))) - 0.0821;
  pixel = vf / _WhiteLevel;

  return pixel;
}

inline half3 FilmicOperator(half3 pixel)
{
  float3 X = max((float3)0.0, pixel - 0.004);
  pixel = SafePositivePow((X * (6.2 * X + 0.5)) / (X * (6.2 * X + 1.7) + 0.06), (float3)2.2);

  return pixel;
}

inline half3 FilmicAldridgeOperator(half3 pixel)
{
  float3 tmp  = (float3)(2.0 * _Cutoff);
  float3 x = pixel + (tmp - pixel) * clamp(tmp - pixel, 0.0, 1.0) * (0.25 / _Cutoff) - _Cutoff;

  return (x * (6.2 * x + 0.5)) / (x * (6.2 * x + 1.7) + 0.06);
}

inline half3 ACESOperator(half3 pixel)
{
  const float a = 2.51;
  const float b = 0.03;
  const float c = 2.43;
  const float d = 0.59;
  const float e = 0.14;

  pixel = clamp((pixel * (a * pixel + b)) / (pixel * (c * pixel + d) + e), 0.0, 1.0);

  return pixel;
}

inline half3 ACESOscarsOperator(half3 pixel)
{
  const float3x3 m1 = float3x3(0.59719, 0.07600, 0.02840,
                               0.35458, 0.90834, 0.13383,
                               0.04823, 0.01566, 0.83777);

  // ODT_SAT => XYZ => D60_2_D65 => sRGB.
  const float3x3 m2 = float3x3(1.60475, -0.10208, -0.00327,
                              -0.53108,  1.10813, -0.07276,
                              -0.07367, -0.00605,  1.07602);

  float3 v = mul(pixel, m1);
  float3 a = (v + 0.0245786) * v - 0.000090537;
  float3 b = (v * 0.983729 + 0.4329510) * v + 0.238081;

  pixel = SafePositivePow(clamp(mul((a / b), m2), 0.0, 1.0), (float3)(1.0 / 2.2));	

  return pixel;
}

inline half3 MulInput(half3 color)
{
  float a = 0.59719 * color.r + 0.35458 * color.g + 0.04823 * color.b,
        b = 0.07600 * color.r + 0.90834 * color.g + 0.01566 * color.b,
        c = 0.02840 * color.r + 0.13383 * color.g + 0.83777 * color.b;
  
  return half3(a, b, c);
}

inline half3 MulOutput(half3 color)
{
  float a =  1.60475 * color.r - 0.53108 * color.g - 0.07367 * color.b,
        b = -0.10208 * color.r + 1.10813 * color.g - 0.00605 * color.b,
        c = -0.00327 * color.r - 0.07276 * color.g + 1.07602 * color.b;

  return half3(a, b, c);
}

inline half3 ACESHillOperator(half3 pixel)
{
  pixel = MulInput(pixel);
  float3 a = pixel * (pixel + 0.0245786) - 0.000090537,
         b = pixel * (0.983729 * pixel + 0.4329510) + 0.238081,
         c = a / b;
  pixel = MulOutput(c);

  return pixel;
}

inline half3 ACESNarkowiczOperator(half3 pixel)
{
  const float a = 2.51;
  const float b = 0.03;
  const float c = 2.43;
  const float d = 0.59;
  const float e = 0.14;

  pixel *= 0.6;
  pixel = (pixel * (a * pixel + b)) / (pixel * (c * pixel + d) + e);

  return pixel;
}

inline half3 LottesOperator(half3 pixel)
{
  const float3 a = (float3)1.6;
  const float3 d = (float3)0.977;
  const float3 hdrMax = (float3)8.0;
  const float3 midIn = (float3)0.18;
  const float3 midOut = (float3)0.267;

  const float3 b = (-SafePositivePow(midIn, a) + SafePositivePow(hdrMax, a) * midOut) /
                   ((SafePositivePow(hdrMax, a * d) - SafePositivePow(midIn, a * d)) * midOut);
  const float3 c = (SafePositivePow(hdrMax, a * d) * SafePositivePow(midIn, a) - SafePositivePow(hdrMax, a) * SafePositivePow(midIn, a * d) * midOut) /
                   ((SafePositivePow(hdrMax, a * d) - SafePositivePow(midIn, a * d)) * midOut);

  pixel = SafePositivePow(pixel, a) / (SafePositivePow(pixel, a * d) * b + c);

  return pixel;
}

inline half3 UchimuraOperator(half3 pixel)
{
  const float P = 1.0;  // max display brightness
  const float a = 1.0;  // contrast
  const float m = 0.22; // linear section start
  const float l = 0.4;  // linear section length
  const float c = 1.33; // black
  const float b = 0.0;  // pedestal
  
  float l0 = ((P - m) * l) / a;
  float L0 = m - m / a;
  float L1 = m + (1.0 - m) / a;
  float S0 = m + l0;
  float S1 = m + a * l0;
  float C2 = (a * P) / (P - S1);
  float CP = -C2 / P;
  
  float3 w0 = float3(1.0 - smoothstep(0.0, m, pixel));
  float3 w2 = float3(step(m + l0, pixel));
  float3 w1 = float3(1.0 - w0 - w2);
  
  float3 T = float3(m * SafePositivePow(pixel / m, (float3)c) + b);
  float3 S = float3(P - (P - S1) * exp(CP * (pixel - S0)));
  float3 L = float3(m + a * (pixel - m));
  
  return T * w0 + L * w1 + S * w2;
}

inline half3 Unreal3Operator(half3 pixel)
{
  pixel = SafePositivePow(pixel / (pixel + (float3)0.155) * 1.019, 2.2);

  return pixel;
}

inline half3 Uncharted2(half3 pixel)
{
  float A = 0.15;	// Shoulder strength.
  float B = 0.50;	// Linear strength.
  float C = 0.10;	// Linear angle.
  float D = 0.20;	// Toe strength.
  float E = 0.02;	// Toe Numerator.
  float F = 0.30;	// Toe Denominator.
  float W = 11.2;	// Linear White Point Value.

  return ((pixel * (A * pixel + C * B) + D * E) / (pixel * (A * pixel + B) + D * F)) - E / F;
}

inline half3 Uncharted2Operator(half3 pixel)
{
  const float W = 11.2;
  float exposureBias = 2.0;

  float3 curr = Uncharted2(exposureBias * pixel);
  float3 whiteScale = Uncharted2((float3)W);

  pixel = curr / whiteScale;

  return pixel;
}

inline half3 WatchDogsOperator(half3 pixel)
{
  const float3 A = float3(0.55, 0.50, 0.45);	// Shoulder strength.
  const float3 B = float3(0.30, 0.27, 0.22);	// Linear strength.
  const float3 C = float3(0.10, 0.10, 0.10);	// Linear angle.
  const float3 D = float3(0.10, 0.07, 0.03);	// Toe strength.
  const float3 E = float3(0.01, 0.01, 0.01);	// Toe Numerator.
  const float3 F = float3(0.30, 0.30, 0.30);	// Toe Denominator.
  const float3 W = float3(2.80, 2.90, 3.10);	// Linear White Point Value.

  const float3 linearWhite = ((W * (A * W + C * B) + D * E) / (W * (A * W + B) + D * F)) - (E / F);
  const float3 linearColor = ((pixel * (A * pixel + C * B) + D * E) / (pixel * (A * pixel + B) + D * F)) - (E / F);

  pixel = SafePositivePow(saturate(linearColor * _LinearColor / linearWhite), _LinearWhite);

  return pixel;
}

inline float PWC(float x)
{
  const float n = 0.0;
  const float m = 0.05;
  const float p = 0.05;
  const float f = 0.25;
  const float q = 0.35;

  if (x < n)
    return 0.0;
  else if (x < m)
    return p * SafePositivePow_float((x - n) / (m - n), (q - p) * (m - n) / (p * (f - m)));
  else if (x < f)
    return (q - p) / (f - m) * x - m * (q - p) / (f - m) + p;

  return q + (1.0 - q) * (q - p) * (x - f) / ((q - p) * (x - f) + (f - m) * (1.0 - q));
}

inline half3 PieceWiseOperator(half3 pixel)
{
  pixel = half3(PWC(pixel.r), PWC(pixel.g), PWC(pixel.b));

  return pixel;
}

inline half3 RomBinDaHouseOperator(half3 pixel)
{
  pixel = exp(-1.0 / (2.72 * pixel + 0.15));
  pixel = SafePositivePow(pixel, (float3)(1.0 / _Gamma));

  return pixel;
}

inline half3 RGB2OKLab(half3 c) 
{
  float l = 0.4121656120 * c.r + 0.5362752080 * c.g + 0.0514575653 * c.b;
  float m = 0.2118591070 * c.r + 0.6807189584 * c.g + 0.1074065790 * c.b;
  float s = 0.0883097947 * c.r + 0.2818474174 * c.g + 0.6302613616 * c.b;

  l = SafePositivePow_float(l, 1.0 / 3.0);
  m = SafePositivePow_float(m, 1.0 / 3.0);
  s = SafePositivePow_float(s, 1.0 / 3.0);

  half3 labResult;
  labResult.x = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s;
  labResult.y = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s;
  labResult.z = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s;

  return labResult;
}

inline half3 OKLabToRGB(half3 c) 
{
  float l = c.x + 0.3963377774 * c.y + 0.2158037573 * c.z;
  float m = c.x - 0.1055613458 * c.y - 0.0638541728 * c.z;
  float s = c.x - 0.0894841775 * c.y - 1.2914855480 * c.z;

  l = l * l * l;
  m = m * m * m;
  s = s * s * s;

  half3 rgbResult;
  rgbResult.r = + 4.0767245293 * l - 3.3072168827 * m + 0.2307590544 * s;
  rgbResult.g = - 1.2681437731 * l + 2.6093323231 * m - 0.3411344290 * s;
  rgbResult.b = - 0.0041119885 * l - 0.7034763098 * m + 1.7068625689 * s;

  return rgbResult;
}

inline half3 OklabOperator(half3 pixel)
{
  const float limitHardness = 1.5;

  float3 okl = RGB2OKLab(pixel);
  okl.x = okl.x / SafePositivePow_float(SafePositivePow_float(okl.x, limitHardness) + 1.0, 1.0 / limitHardness);

  float mag = length(okl.yz);
  float magAfter = mag;

  magAfter *= 4.0;
  magAfter = magAfter / SafePositivePow_float(SafePositivePow_float(magAfter, limitHardness) + 1.0, 1.0 / limitHardness);
  magAfter /= 4.0;
  okl.yz *= magAfter / mag;

  pixel = OKLabToRGB(okl);

  return pixel;
}

inline half3 ClampingOperator(half3 pixel)
{
  const float luma = CalcLuminance(pixel);

  float lout = clamp(luma / _WhiteLevel, 0.0, 1.0);

  return (pixel / max(luma, 0.001)) * lout;
}

inline half3 Max3Operator(half3 pixel)
{
	float maxValue = max(max(pixel.x, pixel.y), pixel.z);

	return pixel / (1.0 + maxValue);
}

inline half3 Max3InvertedOperator(half3 pixel)
{
	float maxValue = max(max(pixel.x, pixel.y), pixel.z);

	return pixel / (1.0 - maxValue);
}

#endif // OPERATORS_INCLUDE