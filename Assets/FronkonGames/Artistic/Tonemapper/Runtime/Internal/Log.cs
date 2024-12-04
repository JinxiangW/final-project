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

namespace FronkonGames.Artistic.Tonemapper
{
  /// <summary> Log utils. </summary>
  internal static class Log
  {
    /// <summary> Info message. </summary>
    /// <param name="message">Message.</param>
    public static void Info(string message) => Debug.Log($"[{Constants.Asset.AssemblyName}] {message}.");

    /// <summary> Warning message. </summary>
    /// <param name="message">Message.</param>
    public static void Warning(string message) => Debug.LogWarning($"[{Constants.Asset.AssemblyName}] {message}.");

    /// <summary> Error message. </summary>
    /// <param name="message">Message.</param>
    public static void Error(string message) => Debug.LogError($"[{Constants.Asset.AssemblyName}] {message} Please contact with '{Constants.Support.Email}' and send the log file.");
  }
}