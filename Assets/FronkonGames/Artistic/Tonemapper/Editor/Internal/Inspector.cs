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
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Reflection;

using UnityEngine;
using UnityEditor;

namespace FronkonGames.Artistic.Tonemapper
{
  /// <summary> Inspector base. </summary>
  public abstract partial class Inspector : UnityEditor.Editor
  {
    /// <summary> Indent level. </summary>
    public static int IndentLevel
    {
      get => EditorGUI.indentLevel;
      set => EditorGUI.indentLevel = value;
    }

    /// <summary> Begin vertical. </summary>
    public static void BeginVertical() => EditorGUILayout.BeginVertical();

    /// <summary> End vertical. </summary>
    public static void EndVertical() => EditorGUILayout.EndVertical();

    /// <summary> Begin horizontal. </summary>
    public static void BeginHorizontal() => EditorGUILayout.BeginHorizontal();

    /// <summary> End horizontal. </summary>
    public static void EndHorizontal() => EditorGUILayout.EndHorizontal();

    /// <summary> Flexible space. </summary>
    public static void FlexibleSpace() => GUILayout.FlexibleSpace();

    /// <summary> Label width. </summary>
    public static float LabelWidth
    {
      get => EditorGUIUtility.labelWidth;
      set => EditorGUIUtility.labelWidth = value;
    }

    /// <summary> Field width. </summary>
    public static float FieldWidth
    {
      get => EditorGUIUtility.fieldWidth;
      set => EditorGUIUtility.fieldWidth = value;
    }

    /// <summary> GUI enabled? </summary>
    public static bool EnableGUI
    {
      get => GUI.enabled;
      set => GUI.enabled = value;
    }

    /// <summary> GUI changed? </summary>
    public static bool Changed
    {
      get => GUI.changed;
      set => GUI.changed = value;
    }

    private static readonly Dictionary<string, bool> foldoutDisplay = new();

    private PropertyInfo[] properties;

    public override void OnInspectorGUI()
    {
      ResetGUI();

      serializedObject.Update();

      InspectorGUI();

      serializedObject.ApplyModifiedProperties();

      if (Changed == true)
        SetTargetDirty();
    }

    protected abstract void InspectorGUI();

    /// <summary> Human-readable strings. </summary>
    public static string HumanizeName(string text)
    {
      if (string.IsNullOrEmpty(text) == false)
      {
        text = text.Replace("_", " ").Trim();
        text = Regex.Replace(text, "^_", "").Trim();
        text = Regex.Replace(text, "([a-z])([A-Z])", "$1 $2").Trim();
        text = Regex.Replace(text, "([A-Z])([A-Z][a-z])", "$1 $2").Trim();
        text = char.ToUpper(text[0]) + text.Substring(1);
      }

      return text;
    }

    /// <summary> Reset some GUI variables. </summary>
    public static void ResetGUI(int indentLevel = 0, float labelWidth = 0.0f, float fieldWidth = 0.0f, bool guiEnabled = true)
    {
      EditorGUI.indentLevel = 0;
      EditorGUIUtility.labelWidth = 0.0f;
      EditorGUIUtility.fieldWidth = 0.0f;
      GUI.enabled = true;
    }

    /// <summary> Marks as dirty. </summary>
    public void SetTargetDirty() => EditorUtility.SetDirty(target);

    /// <summary> Marks object target as dirty. </summary>
    public void SetDirty(UnityEngine.Object obj) => EditorUtility.SetDirty(obj);

    private T GetCustomAttribute<T>(string attributeName) where T : Attribute
    {
      T attribute = null;

      FieldInfo[] fieldInfos = target.GetType().GetFields(BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
      for (int i = 0; i < fieldInfos.Length && attribute == null; ++i)
      {
        if (fieldInfos[i].Name.Equals(attributeName) == true)
          attribute = Attribute.GetCustomAttribute(fieldInfos[i], typeof(T)) as T;
      }

      return attribute;
    }

    private bool GetCustomProperty<T>(string propertyName, out T attribute, out PropertyInfo propertyInfo) where T : PropertyAttribute
    {
      attribute = null;
      propertyInfo = null;

      properties ??= target.GetType().GetProperties();

      for (int i = 0; i < properties.Length && attribute == null; ++i)
      {
        if (properties[i].Name.Equals(propertyName) == true)
        {
          object[] attributes = properties[i].GetCustomAttributes(true);
          for (int j = 0; j < attributes.Length; ++j)
          {
            attribute = attributes[j] as T;
            propertyInfo = properties[i];
          }
        }
      }

      return attribute != null && propertyInfo != null;
    }

    private T GetProperty<T>(string propertyName)
    {
      properties ??= target.GetType().GetProperties();

      for (int i = 0; i < properties.Length; ++i)
      {
        if (properties[i].Name.Equals(propertyName) == true)
          return (T)properties[i].GetValue(target, null);
      }

      return default;
    }

    public static GUIContent NewGUIContent(string label, string name, string tooltip) => new(string.IsNullOrEmpty(label) == false ? label : HumanizeName(name), tooltip);
  }
}
