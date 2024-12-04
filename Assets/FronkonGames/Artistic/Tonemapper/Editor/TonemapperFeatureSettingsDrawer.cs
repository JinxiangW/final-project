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
using UnityEngine;
using UnityEditor;
using static FronkonGames.Artistic.Tonemapper.Inspector;

namespace FronkonGames.Artistic.Tonemapper.Editor
{
  /// <summary> Artistic Tonemapper inspector. </summary>
  [CustomPropertyDrawer(typeof(Tonemapper.Settings))]
  public class TonemapperFeatureSettingsDrawer : Drawer
  {
    private Tonemapper.Settings settings;

    protected override void ResetValues() => settings?.ResetDefaultValues();

    protected override void InspectorGUI()
    {
      settings ??= GetSettings<Tonemapper.Settings>();

      /////////////////////////////////////////////////
      // Common.
      /////////////////////////////////////////////////
      settings.intensity = Slider("Intensity", "Controls the intensity of the effect [0, 1]. Default 0.", settings.intensity, 0.0f, 1.0f, 1.0f);

      /////////////////////////////////////////////////
      // Tonemapper.
      /////////////////////////////////////////////////
      Separator();

      settings.tonemapperOperator = (Tonemapper.Operators)EnumPopup("Operator", "Tonemapper operator", settings.tonemapperOperator, Tonemapper.Operators.Linear);
      IndentLevel++;
      switch (settings.tonemapperOperator)
      {
        case Tonemapper.Operators.Linear: break;
        case Tonemapper.Operators.Logarithmic:
        case Tonemapper.Operators.WhiteLumaReinhard:
        case Tonemapper.Operators.Hejl2015:
        case Tonemapper.Operators.Clamping:
          settings.whiteLevel = Slider("White level", "White level exposure [0 - 5]. Default 1.", settings.whiteLevel, 0.0f, 5.0f, 1.0f);
          break;
        case Tonemapper.Operators.FilmicAldridge:
          settings.cutOff = Slider("Cutoff", "Cutoff to black [0 - 0.5]. Default 0.025.", settings.cutOff, 0.0f, 0.5f, 0.025f);
          break;
        case Tonemapper.Operators.WatchDogs:
          settings.linearWhite = Slider("Linear white", "Linear white. Used in WatchDogs [0.5 - 2]. Default 1.5.", settings.linearWhite, 0.5f, 2.0f, 1.5f);
          settings.linearColor = Slider("Linear color", "Linear color. Used in WatchDogs [0.5 - 2]. Default 1.5.", settings.linearColor, 0.5f, 2.0f, 1.5f);
          break;
      }
      IndentLevel--;

      settings.colorFilter = ColorField("Color filter", "Color tint. Default White.", settings.colorFilter, Color.white);
      IndentLevel++;
      settings.exposure = Slider("Exposure", "Exposure, affects the overal brightness [0, 10]. Default 0.", settings.exposure, 0.0f, 10.0f, 0.0f);
      settings.vibrance = Slider("Vibrance", "Color vibrance [-1, 1]. Default 0.", settings.vibrance, -1.0f, 1.0f, 0.0f);
      IndentLevel++;
      settings.vibranceBalance = Vector3Field("Balance", "Color vibrance balance. Default (1, 1, 1).", settings.vibranceBalance, Vector3.one);
      IndentLevel--;
      settings.contrast = Slider("Contrast", "Contrast [0.0, 10.0]. Default 1.", settings.contrast, 0.0f, 10.0f, 1.0f);
      IndentLevel++;
      settings.contrastMidpoint = Slider("Midpoint", "Log of linear constrast midpoint. Default 0.18.", settings.contrastMidpoint, -5.0f, 5.0f, 0.18f);
      IndentLevel--;
      IndentLevel--;

      settings.lift = ColorField("Lift", "Adjust shadows for RGB. Default White.", settings.lift, Color.white);
      IndentLevel++;
      settings.liftBright = Slider("Bright", "Lift bright [0, 2]. Default 1.", settings.liftBright, 0.0f, 2.0f, 1.0f);
      IndentLevel--;

      settings.midtones = ColorField("Midtones", "Adjust midtones for RGB. Default White.", settings.midtones, Color.white);
      IndentLevel++;
      settings.midtonesBright = Slider("Bright", "Midtones bright [0, 2]. Default 1.", settings.midtonesBright, 0.0f, 2.0f, 1.0f);
      IndentLevel--;

      settings.gain = ColorField("Gain", "Adjust highlights for RGB. Default White.", settings.gain, Color.white);
      IndentLevel++;
      settings.gainBright = Slider("Bright", "Gain bright [0, 2]. Default 1.", settings.gainBright, 0.0f, 2.0f, 1.0f);
      IndentLevel--;

      /////////////////////////////////////////////////
      // Color.
      /////////////////////////////////////////////////
      Separator();

      if (Foldout("Color") == true)
      {
        IndentLevel++;

        settings.brightness = Slider("Brightness", "Brightness [-1.0, 1.0]. Default 0.", settings.brightness, -1.0f, 1.0f, 0.0f);
        settings.gamma = Slider("Gamma", "Gamma [0.1, 10.0]. Default 1.", settings.gamma, 0.01f, 10.0f, 1.0f);
        settings.hue = Slider("Hue", "The color wheel [0.0, 1.0]. Default 0.", settings.hue, 0.0f, 1.0f, 0.0f);
        settings.saturation = Slider("Saturation", "Intensity of a colors [0.0, 2.0]. Default 1.", settings.saturation, 0.0f, 2.0f, 1.0f);

        IndentLevel--;
      }

      /////////////////////////////////////////////////
      // Advanced.
      /////////////////////////////////////////////////
      Separator();

      if (Foldout("Advanced") == true)
      {
        IndentLevel++;

#if !UNITY_6000_0_OR_NEWER
        settings.affectSceneView = Toggle("Affect the Scene View?", "Does it affect the Scene View?", settings.affectSceneView);
        settings.filterMode = (FilterMode)EnumPopup("Filter mode", "Filter mode. Default Bilinear.", settings.filterMode, FilterMode.Bilinear);
#endif
        settings.whenToInsert = (UnityEngine.Rendering.Universal.RenderPassEvent)EnumPopup("RenderPass event",
          "Render pass injection. Default BeforeRenderingPostProcessing.",
          settings.whenToInsert,
          UnityEngine.Rendering.Universal.RenderPassEvent.BeforeRenderingPostProcessing);
#if !UNITY_6000_0_OR_NEWER
        settings.enableProfiling = Toggle("Enable profiling", "Enable render pass profiling", settings.enableProfiling);
#endif

        IndentLevel--;
      }
    }
  }
}
