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
using System;
using UnityEngine;
using UnityEngine.Rendering.Universal;

namespace FronkonGames.Artistic.Tonemapper
{
  ///------------------------------------------------------------------------------------------------------------------
  /// <summary> Settings. </summary>
  /// <remarks> Only available for Universal Render Pipeline. </remarks>
  ///------------------------------------------------------------------------------------------------------------------
  public sealed partial class Tonemapper
  {
    /// <summary> Settings. </summary>
    [Serializable]
    public sealed class Settings
    {
      public Settings() => ResetDefaultValues();

      /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      #region Common settings.

      /// <summary> Controls the intensity of the effect [0, 1]. Default 1. </summary>
      /// <remarks> An effect with Intensity equal to 0 will not be executed. </remarks>
      public float intensity = 1.0f;
      #endregion
      /////////////////////////////////////////////////////////////////////////////////////////////////////////////////

      /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      #region Tonemapping settings.

      /// <summary> Tonemapping operator. </summary>
      public Operators tonemapperOperator = Operators.Linear;

      /// <summary> Exposure, affects the overal brightness [0, 10]. Default 0. </summary>
      public float exposure = 0.0f;

      /// <summary> Color tint. Default White. </summary>
      public Color colorFilter = Color.white;

      /// <summary> Color vibrance [-1, 1]. Default 0. </summary>
      public float vibrance = 0.0f;

      /// <summary> Color vibrance color channels balance. Default (1, 1, 1). </summary>
      public Vector3 vibranceBalance = Vector3.one;

      /// <summary> Log of linear constrast midpoint. Default 0.18. </summary>
      public float contrastMidpoint = 0.18f;

      /// <summary> Adjust shadows for RGB. Default White. </summary>
      public Color lift = Color.white;

      /// <summary> Lift bright [0, 2]. Default 1. </summary>
      public float liftBright = 1.0f;

      /// <summary> Adjust midtones for RGB. Default White. </summary>
      public Color midtones = Color.white;

      /// <summary> Midtones bright [0, 2]. Default 1. </summary>
      public float midtonesBright = 1.0f;

      /// <summary> Adjust highlights for RGB. Default White. </summary>
      public Color gain = Color.white;

      /// <summary> Gain bright [0, 2]. Default 1. </summary>
      public float gainBright = 1.0f;

      /// <summary>
      /// White level exposure [0 - 5]. Default 1.
      /// Used in Linear, Logarithmic, WhiteLumaReinhard, Hejl2015 and Clamping.
      /// </summary>
      public float whiteLevel = 1.0f;

      /// <summary>
      /// Linear white [0.5 - 2]. Default 1.5.
      /// Used in WatchDogs.
      /// </summary>
      public float linearWhite = 1.5f;

      /// <summary>
      /// Linear color [0.5 - 2]. Default 1.5.
      /// Used in WatchDogs.
      /// </summary>
      public float linearColor = 1.5f;

      /// <summary>
      /// Curoff color [0 - 0.5]. Default 0.025.
      /// Used in Filmic Aldridge.
      /// </summary>
      public float cutOff = 0.025f;

      #endregion
      /////////////////////////////////////////////////////////////////////////////////////////////////////////////////

      /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      #region Color settings.

      /// <summary> Brightness [-1.0, 1.0]. Default 0. </summary>
      public float brightness = 0.0f;

      /// <summary> Contrast [0.0, 10.0]. Default 1. </summary>
      public float contrast = 1.0f;

      /// <summary> Gamma [0.1, 10.0]. Default 1. </summary>
      public float gamma = 1.0f;

      /// <summary> The color wheel [0.0, 1.0]. Default 0. </summary>
      public float hue = 0.0f;

      /// <summary> Intensity of a colors [0.0, 2.0]. Default 1. </summary>
      public float saturation = 1.0f;
      #endregion
      /////////////////////////////////////////////////////////////////////////////////////////////////////////////////

      /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      #region Advanced settings.
#if !UNITY_6000_0_OR_NEWER
      /// <summary> Does it affect the Scene View? </summary>
      public bool affectSceneView = false;

      /// <summary> Enable render pass profiling. </summary>
      public bool enableProfiling = false;

      /// <summary> Filter mode. Default Bilinear. </summary>
      public FilterMode filterMode = FilterMode.Bilinear;
#endif
      /// <summary> Render pass injection. Default BeforeRenderingPostProcessing. </summary>
      public RenderPassEvent whenToInsert = RenderPassEvent.BeforeRenderingPostProcessing;

      #endregion
      /////////////////////////////////////////////////////////////////////////////////////////////////////////////////

      /// <summary> Reset to default values. </summary>
      public void ResetDefaultValues()
      {
        intensity = 1.0f;

        tonemapperOperator = Operators.Linear;
        exposure = 0.0f;
        vibrance = 0.0f;
        vibranceBalance = Vector3.one;
        contrastMidpoint = 0.18f;
        lift = Color.white;
        liftBright = 1.0f;
        midtones = Color.white;
        midtonesBright = 1.0f;
        gain = Color.white;
        gainBright = 1.0f;
        whiteLevel = 1.0f;
        linearWhite = 1.5f;
        linearColor = 1.5f;
        cutOff = 0.025f;

        brightness = 0.0f;
        contrast = 1.0f;
        gamma = 1.0f;
        hue = 0.0f;
        saturation = 1.0f;

#if !UNITY_6000_0_OR_NEWER
        affectSceneView = false;
        enableProfiling = false;
        filterMode = FilterMode.Bilinear;
#endif
        whenToInsert = RenderPassEvent.BeforeRenderingPostProcessing;
      }
    }
  }
}
