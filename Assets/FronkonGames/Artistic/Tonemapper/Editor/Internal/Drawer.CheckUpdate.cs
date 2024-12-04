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
using System.Net;
using UnityEngine;
using UnityEditor;

namespace FronkonGames.Artistic.Tonemapper
{
  /// <summary> Drawer base. </summary>
  public abstract partial class Drawer : PropertyDrawer
  {
    private bool updateAvailable;

    [Serializable]
    private class Root
    {
      public string version;
      public string name;
      public string category;
      public string id;
      public string publisher;
    }

    private void CheckForUpdate()
    {
      string id = Constants.Support.Store[(Constants.Support.Store.LastIndexOf('/') + 1)..];
      string url = $"https://api.assetstore.unity3d.com/package/latest-version/{id}";

      RequestData(url, (data) =>
      {
        updateAvailable = false;
        if (string.IsNullOrEmpty(data) == false && string.IsNullOrEmpty(id) == false)
        {
          Root deserialized = JsonUtility.FromJson<Root>(data);
          if (string.IsNullOrEmpty(deserialized.version) == false)
          {
            Version current = new(Constants.Asset.Version);
            Version online = new(deserialized.version);

            updateAvailable = online > current;
          }
        }
      });
    }

    private async void RequestData(string url, Action<string> action)
    {
      string data = string.Empty;
      try
      {
        using WebClient client = new();

        data = await client.DownloadStringTaskAsync(url);
      }
      catch
      {
        updateAvailable = false;
      }
      finally
      {
        action?.Invoke(data);
      }
    }
  }
}