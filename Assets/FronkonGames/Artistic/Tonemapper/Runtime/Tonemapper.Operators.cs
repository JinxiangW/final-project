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

namespace FronkonGames.Artistic.Tonemapper
{
  ///------------------------------------------------------------------------------------------------------------------
  /// <summary> Manager tools. </summary>
  /// <remarks> Only available for Universal Render Pipeline. </remarks>
  ///------------------------------------------------------------------------------------------------------------------
  public sealed partial class Tonemapper
  {
    /// <summary> Tonemapping operators. </summary>    
    public enum Operators
    {
      /// <summary> Good old linear. </summary>
      Linear,

      /// <summary> Logarithmic mapping. </summary>
      Logarithmic,

      /// <summary> Exponential mapping. </summary>
      Exponential,

      /// <summary> Simple and fast Reinhard. </summary>
      SimpleReinhard,

      /// <summary>
      /// "Photographic Tone Reproduction for Digital Images", Reinhard 2002.
      /// Reinhard based on luminance.
      /// </summary>
      LumaReinhard,

      /// <summary> Reinhard based on inverted luminance, by Brian Karis. </summary>
      LumaInvertedReinhard,

      /// <summary> Reinhard based on luminance, but white preserving. </summary>
      WhiteLumaReinhard,

      /// <summary> ACES-liked, by Jim Hejl. </summary>
      Hejl2015,

      /// <summary> Filmic tonemapping. </summary>
      Filmic,

      /// <summary>
      /// Variation of the Hejl and Burgess-Dawson filmic curve by Graham Aldridge.
      /// http://iwasbeingirony.blogspot.com/2010/04/approximating-film-with-tonemapping.html
      /// </summary>
      FilmicAldridge,

      /// <summary> "ACES Filmic Tone Mapping Curve", Narkowicz 2015. </summary>
      ACES,

      /// <summary>
      /// ACES Oscars, based on http://www.oscars.org/science-technology/sci-tech-projects/aces.
      /// Pastel hue function, designed to provide a pleasing albedo.
      /// </summary>
      ACESOscars,

      /// <summary> ACES curve fit by Stephen Hill (@self_shadow). </summary>
      ACESHill,

      /// <summary>
      /// ACES curve fit by Krzysztof Narkowicz.
      /// https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/
      /// </summary>
      ACESNarkowicz,

      /// <summary> "Advanced Techniques and Optimization of HDR Color Pipelines", Lottes 2016. </summary>
      Lottes,

      /// <summary>
      /// Used in Gran Turismo. From "HDR theory and practice", Uchimura 2017.
      /// https://www.slideshare.net/nikuque/hdr-theory-and-practicce-jp
      /// </summary>
      Uchimura,

      /// <summary>
      /// Used in Unreal Engine 3 up to 4.14.
      /// Adapted to be close to ACES curve by Romain Guy. </summary>
      Unreal,

      /// <summary>
      /// Created by John Hable for 'Uncharted 2' (based on Haarm-Pieter Duiker's works in 2006 for EA).
      /// https://en.slideshare.net/ozlael/hable-john-uncharted2-hdr-lighting.
      /// </summary>
      Uncharted2,

      /// <summary> Used in 'Watch Dogs' by Ubisoft. </summary>
      WatchDogs,

      /// <summary> 'Piece-Wise Power Curve' by John Hable at Epic Games. </summary>
      PieceWise,

      /// <summary> By tech art Roman Galashov, @RomanGalashov. </summary>
      RomBinDaHouse,

      /// <summary> Oklab-based. </summary>
      Oklab,

      /// <summary> Clamps everything above a given luminance threshold to 1, by Schlick. </summary>
      Clamping,

      /// <summary> 'Optimized Reversible Tonemapper for Resolve', by Timothy Lottes. </summary>
      Max3,

      /// <summary> 'Optimized Reversible Tonemapper for Resolve', by Timothy Lottes. Inverted luminance. </summary>
      Max3Inverted,
    }
  }
}
