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
using System.Reflection;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace FronkonGames.Artistic.Tonemapper
{
  ///------------------------------------------------------------------------------------------------------------------
  /// <summary> Manager tools. </summary>
  /// <remarks> Only available for Universal Render Pipeline. </remarks>
  ///------------------------------------------------------------------------------------------------------------------
  public sealed partial class Tonemapper
  {
    private static Tonemapper renderFeature;

    private const string RenderListFieldName = "m_RendererDataList";

    private const BindingFlags bindingFlags = BindingFlags.Instance | BindingFlags.NonPublic;

    /// <summary> Is it in the render features? </summary>
    /// <returns>True / false</returns>
    public static bool IsInRenderFeatures() => RenderFeature != null;

    /// <summary> Is active? </summary>
    /// <returns>True / false</returns>
    public static bool IsEnable() => RenderFeature?.isActive == true;

    /// <summary> On / Off </summary>
    /// <param name="enable">Enable or disable</param>
    public static void SetEnable(bool enable)
    {
      if (RenderFeature != null)
        RenderFeature.SetActive(enable);
      else
        Log.Error($"'{Constants.Asset.Name}' is not added to the render features. Add it in the Editor or use the AddRenderFeature function.");
    }

    /// <summary> Get settings </summary>
    /// <returns>Settings or null</returns>
    public static Settings GetSettings()
    {
      if (RenderFeature != null)
        return RenderFeature.settings;

      return null;
    }

    private static Tonemapper RenderFeature
    {
      get
      {
        if (renderFeature == null)
        {
          UniversalRenderPipelineAsset pipelineAsset = (UniversalRenderPipelineAsset)GraphicsSettings.defaultRenderPipeline;
          if (pipelineAsset != null)
          {
            FieldInfo propertyInfo = pipelineAsset.GetType().GetField(RenderListFieldName, bindingFlags);
            ScriptableRendererData scriptableRendererData = ((ScriptableRendererData[])propertyInfo?.GetValue(pipelineAsset))?[0];
            for (int i = 0; i < scriptableRendererData.rendererFeatures.Count && renderFeature == null; ++i)
            {
              if (scriptableRendererData.rendererFeatures[i] is Tonemapper)
                renderFeature = scriptableRendererData.rendererFeatures[i] as Tonemapper;
            }
          }
        }

        return renderFeature;
      }
    }
  }
}
