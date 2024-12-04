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
using UnityEngine;
using UnityEditor;
using static FronkonGames.Artistic.Tonemapper.Inspector;
using System;

namespace FronkonGames.Artistic.Tonemapper
{
  /// <summary> Drawer base. </summary>
  public abstract partial class Drawer : PropertyDrawer
  {
    protected SerializedProperty properties = null;

    private GUIStyle styleLogo;

    protected abstract void InspectorGUI();

    protected abstract void ResetValues();

    protected virtual void InspectorChanged() { }

    protected virtual void OnCopy() { }

    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
      properties = property;

      ResetGUI();

      Event evt = Event.current;
      if (evt?.isKey == true && evt.type == EventType.KeyDown && evt.keyCode == KeyCode.C && evt.control == true)
      {
        OnCopy();

        evt.Use();
      }

      if (styleLogo == null)
      {
        Font font = null;
        string[] ids = AssetDatabase.FindAssets("FronkonGames-Black");
        for (int i = 0; i < ids.Length; ++i)
        {
          string fontPath = AssetDatabase.GUIDToAssetPath(ids[i]);
          if (fontPath.Contains(".otf") == true)
          {
            font = AssetDatabase.LoadAssetAtPath<Font>(fontPath);
            break;
          }
        }

        if (font != null)
        {
          styleLogo = new GUIStyle(EditorStyles.boldLabel)
          {
            font = font,
            alignment = TextAnchor.LowerLeft,
            fontSize = 24
          };
        }
      }

      EditorGUI.BeginChangeCheck();

      BeginVertical();
      {
        /////////////////////////////////////////////////
        // Description.
        /////////////////////////////////////////////////
        if (styleLogo != null)
        {
          EditorGUILayout.BeginHorizontal();
          {
            FlexibleSpace();

            GUILayout.Label(Constants.Asset.Name, styleLogo);
          }
          EditorGUILayout.EndHorizontal();

          EditorGUILayout.BeginHorizontal();
          {
            FlexibleSpace();

            GUILayout.Label(Constants.Asset.Description, EditorStyles.miniLabel);
          }
          EditorGUILayout.EndHorizontal();

          Separator();
        }

        InspectorGUI();

        /////////////////////////////////////////////////
        // Misc.
        /////////////////////////////////////////////////
        Separator();

        BeginHorizontal();
        {
          if (MiniButton("documentation", "Online documentation") == true)
            Application.OpenURL(Constants.Support.Documentation);

          if (MiniButton("support", "Do you have any problem or suggestion?") == true)
            SupportWindow.ShowWindow();

          try
          {
            string lastCheck = EditorPrefs.GetString($"{Constants.Asset.AssemblyName}.LastCheck");
            if (string.IsNullOrEmpty(lastCheck) == false)
            {
              DateTime lastCheckTime = DateTime.Parse(lastCheck);
              if (lastCheckTime < DateTime.Now.AddHours(-24))
              {
                CheckForUpdate();

                GUI.changed = true;

                EditorPrefs.SetString($"{Constants.Asset.AssemblyName}.LastCheck", DateTime.Now.ToString("yyyy-MM-dd"));
              }
            }
            else
              EditorPrefs.SetString($"{Constants.Asset.AssemblyName}.LastCheck", DateTime.Now.ToString("yyyy-MM-dd"));
          }
          catch
          {
            EditorPrefs.SetString($"{Constants.Asset.AssemblyName}.LastCheck", DateTime.Now.ToString("yyyy-MM-dd"));
            updateAvailable = false;
          }

          Separator();

          if (updateAvailable == true)
          {
            if (MiniButton("<color=#FFD700>update available</color>", "A new update is available in the store!") == true)
            {
              Application.OpenURL(Constants.Support.Store);

              updateAvailable = false;
            }
          }
          else if (EditorPrefs.GetBool($"{Constants.Asset.AssemblyName}.Review") == false)
          {
            if (MiniButton("write a review <color=#800000>❤️</color>", "Write a review, thanks!") == true)
            {
              Application.OpenURL(Constants.Support.Store);

              EditorPrefs.SetBool($"{Constants.Asset.AssemblyName}.Review", true);
            }
          }

          FlexibleSpace();

          if (Button("Reset") == true)
            ResetValues();
        }
        EndHorizontal();
      }
      EndVertical();

      if (EditorGUI.EndChangeCheck() == true)
        InspectorChanged();
    }

    protected T GetSettings<T>()
    {
      object target = GetValue(properties.serializedObject.targetObject, "settings");

      return (T)target;
    }

    protected string ToString(float value) { return $"{value}f".Replace(",", "."); }

    protected string ToString(Color value) { return $"new Color({ToString(value.r)}, {ToString(value.g)}, {ToString(value.b)})"; }

    private static object GetValue(object source, string name)
    {
      if (source == null)
        return null;

      var type = source.GetType();
      var f = type.GetField(name, BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.Instance);
      if (f == null)
      {
        var p = type.GetProperty(name, BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.Instance | BindingFlags.IgnoreCase);
        return p?.GetValue(source, null);
      }

      return f.GetValue(source);
    }
  }
}