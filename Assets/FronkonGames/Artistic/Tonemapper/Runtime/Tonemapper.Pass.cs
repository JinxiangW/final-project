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
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
#if UNITY_6000_0_OR_NEWER
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
#endif

namespace FronkonGames.Artistic.Tonemapper
{
  ///------------------------------------------------------------------------------------------------------------------
  /// <summary> Render Pass. </summary>
  /// <remarks> Only available for Universal Render Pipeline. </remarks>
  ///------------------------------------------------------------------------------------------------------------------
  public sealed partial class Tonemapper
  {
    private sealed class RenderPass : ScriptableRenderPass, IDisposable
    {
      private readonly Settings settings;

#if UNITY_6000_0_OR_NEWER
#elif UNITY_2022_3_OR_NEWER
      private RenderTargetIdentifier colorBuffer;
      private RenderTextureDescriptor renderTextureDescriptor;

      private RTHandle renderTextureHandle0;
      
      private const string CommandBufferName = Constants.Asset.AssemblyName;

      private ProfilingScope profilingScope;
      private readonly ProfilingSampler profilingSamples = new(Constants.Asset.AssemblyName);
#endif
      private readonly Material material;

      private static class ShaderIDs
      {
        internal static readonly int Intensity = Shader.PropertyToID("_Intensity");

        internal static readonly int Exposure = Shader.PropertyToID("_Exposure");
        internal static readonly int ColorFilter = Shader.PropertyToID("_ColorFilter");
        internal static readonly int Vibrance = Shader.PropertyToID("_Vibrance");
        internal static readonly int VibranceBalance = Shader.PropertyToID("_VibranceBalance");
        internal static readonly int ContrastMidpoint = Shader.PropertyToID("_ContrastMidpoint");
        internal static readonly int WhiteLevel = Shader.PropertyToID("_WhiteLevel");
        internal static readonly int LinearWhite = Shader.PropertyToID("_LinearWhite");
        internal static readonly int LinearColor = Shader.PropertyToID("_LinearColor");
        internal static readonly int Lift = Shader.PropertyToID("_Lift");
        internal static readonly int LiftBright = Shader.PropertyToID("_LiftBright");
        internal static readonly int Midtones = Shader.PropertyToID("_Midtones");
        internal static readonly int MidtonesBright = Shader.PropertyToID("_MidtonesBright");
        internal static readonly int Gain = Shader.PropertyToID("_Gain");
        internal static readonly int GainBright = Shader.PropertyToID("_GainBright");
        internal static readonly int CutOff = Shader.PropertyToID("_Cutoff");

        internal static readonly int Brightness = Shader.PropertyToID("_Brightness");
        internal static readonly int Contrast = Shader.PropertyToID("_Contrast");
        internal static readonly int Gamma = Shader.PropertyToID("_Gamma");
        internal static readonly int Hue = Shader.PropertyToID("_Hue");
        internal static readonly int Saturation = Shader.PropertyToID("_Saturation");
      }

      /// <summary> Render pass constructor. </summary>
      public RenderPass(Settings settings)
      {
        this.settings = settings;

        string shaderPath = $"Shaders/{Constants.Asset.ShaderName}_URP";
        Shader shader = Resources.Load<Shader>(shaderPath);
        if (shader != null)
        {
          if (shader.isSupported == true)
          {
            material = new Material(shader);
#if UNITY_6000_0_OR_NEWER
            this.requiresIntermediateTexture = true;
#endif
          }
          else
            Log.Warning($"'{shaderPath}.shader' not supported");
        }
      }

      private void UpdateMaterial()
      {
        material.shaderKeywords = null;
        material.SetFloat(ShaderIDs.Intensity, settings.intensity);

        material.SetFloat(ShaderIDs.Exposure, settings.exposure);
        material.SetColor(ShaderIDs.ColorFilter, settings.colorFilter);
        material.SetFloat(ShaderIDs.Vibrance, settings.vibrance);
        material.SetVector(ShaderIDs.VibranceBalance, settings.vibranceBalance);
        material.SetFloat(ShaderIDs.ContrastMidpoint, settings.contrastMidpoint);

        switch (settings.tonemapperOperator)
        {
          case Operators.Linear: break;
          case Operators.Logarithmic:
          case Operators.WhiteLumaReinhard:
          case Operators.Hejl2015:
          case Operators.Clamping:
            material.SetFloat(ShaderIDs.WhiteLevel, Mathf.Max(settings.whiteLevel, 0.0001f));
            break;
          case Operators.FilmicAldridge:
            material.SetFloat(ShaderIDs.CutOff, Mathf.Max(settings.cutOff, 0.0001f));
            break;
          case Operators.WatchDogs:
            material.SetFloat(ShaderIDs.LinearWhite, settings.linearWhite);
            material.SetFloat(ShaderIDs.LinearColor, settings.linearColor);
            break;
        }

        material.SetColor(ShaderIDs.Lift, settings.lift);
        material.SetFloat(ShaderIDs.LiftBright, settings.liftBright);
        material.SetColor(ShaderIDs.Midtones, settings.midtones);
        material.SetFloat(ShaderIDs.MidtonesBright, settings.midtonesBright);
        material.SetColor(ShaderIDs.Gain, settings.gain);
        material.SetFloat(ShaderIDs.GainBright, settings.gainBright);

        material.SetFloat(ShaderIDs.Brightness, settings.brightness);
        material.SetFloat(ShaderIDs.Contrast, settings.contrast);
        material.SetFloat(ShaderIDs.Gamma, 1.0f / settings.gamma);
        material.SetFloat(ShaderIDs.Hue, settings.hue);
        material.SetFloat(ShaderIDs.Saturation, settings.saturation);
      }

#if UNITY_6000_0_OR_NEWER
      /// <inheritdoc/>
      public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
      {
        if (material == null || settings.intensity == 0.0f)
          return;

        UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();
        if (resourceData.isActiveTargetBackBuffer == false)
        {
          TextureHandle source = resourceData.activeColorTexture;
          TextureDesc destinationDesc = renderGraph.GetTextureDesc(source);
          destinationDesc.name = $"CameraColor-{Constants.Asset.AssemblyName}";
          destinationDesc.clearBuffer = false;

          TextureHandle destination = renderGraph.CreateTexture(destinationDesc);

          UpdateMaterial();

          if (source.IsValid() == true && destination.IsValid() == true)
          {
            RenderGraphUtils.BlitMaterialParameters parameters = new(source, destination, material, (int)settings.tonemapperOperator);
            renderGraph.AddBlitPass(parameters, passName: Constants.Asset.AssemblyName);

            resourceData.cameraColor = destination;
          }
        }
      }
#elif UNITY_2022_3_OR_NEWER
      /// <inheritdoc/>
      public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
      {
        renderTextureDescriptor = renderingData.cameraData.cameraTargetDescriptor;
        renderTextureDescriptor.depthBufferBits = 0;

        colorBuffer = renderingData.cameraData.renderer.cameraColorTargetHandle;

        renderTextureDescriptor.colorFormat = RenderTextureFormat.ARGB32;
        RenderingUtils.ReAllocateIfNeeded(ref renderTextureHandle0, renderTextureDescriptor, settings.filterMode, TextureWrapMode.Clamp, false, 1, 0, $"_RTHandle0_{Constants.Asset.Name}");
      }

      /// <inheritdoc/>
      public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
      {
        if (material == null ||
            renderingData.postProcessingEnabled == false ||
            settings.intensity == 0.0f ||
            settings.affectSceneView == false && renderingData.cameraData.isSceneViewCamera == true)
          return;

        CommandBuffer cmd = CommandBufferPool.Get(CommandBufferName);

        if (settings.enableProfiling == true)
          profilingScope = new ProfilingScope(cmd, profilingSamples);

        UpdateMaterial();

        cmd.Blit(colorBuffer, renderTextureHandle0, material, (int)settings.tonemapperOperator);
        cmd.Blit(renderTextureHandle0, colorBuffer);

        if (settings.enableProfiling == true)
          profilingScope.Dispose();

        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
      }
#else
      #warning("Unity version not supported.");
#endif

      public void Dispose()
      {
#if UNITY_EDITOR
        if (UnityEditor.EditorApplication.isPlaying)
          UnityEngine.Object.Destroy(material);
        else
          UnityEngine.Object.DestroyImmediate(material);
#else
        UnityEngine.Object.Destroy(material);
#endif        
      }
    }
  }
}
