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
using UnityEngine;
using UnityEditor;

namespace FronkonGames.Artistic.Tonemapper
{
  /// <summary> Inspector base. </summary>
  public abstract partial class Inspector
  {
    /// <summary> Separator. </summary>
    public static void Separator(float space = 0.0f)
    {
      if (space <= 0.0f)
        EditorGUILayout.Separator();
      else
        GUILayout.Space(space);
    }

    /// <summary> Label. </summary>
    public static void Label(string label, string tooltip = default) => EditorGUILayout.LabelField(new GUIContent(label, tooltip));

    /// <summary> Toggle. </summary>
    public static bool Toggle(string label, string tooltip, bool value) => EditorGUILayout.Toggle(new GUIContent(label, tooltip), value);

    /// <summary> Toggle. </summary>
    public static bool Toggle(string label, string tooltip, bool value, bool resetValue)
    {
      EditorGUILayout.BeginHorizontal();
      {
        value = EditorGUILayout.Toggle(new GUIContent(label, tooltip), value);

        if (ResetButton(resetValue) == true)
          value = resetValue;
      }
      EditorGUILayout.EndHorizontal();

      return value;
    }

    /// <summary> Enum popup with reset. </summary>
    public static Enum EnumPopup(string label, string tooltip, Enum selected, Enum resetValue)
    {
      EditorGUILayout.BeginHorizontal();
      {
        selected = EditorGUILayout.EnumPopup(new GUIContent(label, tooltip), selected);

        if (ResetButton(resetValue) == true)
          selected = resetValue;
      }
      EditorGUILayout.EndHorizontal();

      return selected;
    }

    /// <summary> Int field with reset. </summary>
    public static int IntField(string label, string tooltip, int value, int resetValue)
    {
      EditorGUILayout.BeginHorizontal();
      {
        value = EditorGUILayout.IntField(new GUIContent(label, tooltip), value);

        if (ResetButton(resetValue) == true)
          value = resetValue;
      }
      EditorGUILayout.EndHorizontal();

      return value;
    }

    /// <summary> Int field with reset. </summary>
    public static int Slider(string label, string tooltip, int value, int minValue, int maxValue, int resetValue)
    {
      EditorGUILayout.BeginHorizontal();
      {
        value = EditorGUILayout.IntSlider(new GUIContent(label, tooltip), value, minValue, maxValue);

        if (ResetButton(resetValue) == true)
          value = resetValue;
      }
      EditorGUILayout.EndHorizontal();

      return value;
    }

    /// <summary> Int popup field with reset. </summary>
    public static int IntPopup(string label, int value, string[] names, int[] values, int resetValue)
    {
      EditorGUILayout.BeginHorizontal();
      {
        value = EditorGUILayout.IntPopup(label, value, names, values);

        if (ResetButton(resetValue) == true)
          value = resetValue;
      }
      EditorGUILayout.EndHorizontal();

      return value;
    }

    /// <summary> Float field with reset. </summary>
    public static float FloatField(string label, string tooltip, float value, float resetValue)
    {
      EditorGUILayout.BeginHorizontal();
      {
        value = EditorGUILayout.FloatField(new GUIContent(label, tooltip), value);

        if (ResetButton(resetValue) == true)
          value = resetValue;
      }
      EditorGUILayout.EndHorizontal();

      return value;
    }

    /// <summary> Float field with reset. </summary>
    public static float Slider(string label, string tooltip, float value, float minValue, float maxValue, float resetValue)
    {
      EditorGUILayout.BeginHorizontal();
      {
        value = EditorGUILayout.Slider(new GUIContent(label, tooltip), value, minValue, maxValue);

        if (ResetButton(resetValue) == true)
          value = resetValue;
      }
      EditorGUILayout.EndHorizontal();

      return value;
    }

    /// <summary> Min-max slider with reset. </summary>
    public static void MinMaxSlider(string label, string tooltip, ref float minValue, ref float maxValue, float minLimit, float maxLimit, float defaultMinLimit, float defaultMaxLimit)
    {
      EditorGUILayout.BeginHorizontal();
      {
        EditorGUILayout.MinMaxSlider(new GUIContent(label, tooltip + $" [{minValue:0.0}..{maxValue:0.0}]"), ref minValue, ref maxValue, minLimit, maxLimit);

        if (ResetButton() == true)
        {
          minValue = defaultMinLimit;
          maxValue = defaultMaxLimit;
        }
      }
      EditorGUILayout.EndHorizontal();
    }

    /// <summary> Vector2 field with reset. </summary>
    public static Vector2 Vector2Field(string label, string tooltip, Vector2 value, Vector2 resetValue)
    {
      EditorGUILayout.BeginHorizontal();
      {
        value = EditorGUILayout.Vector2Field(new GUIContent(label, tooltip), value);

        if (ResetButton(resetValue) == true)
          value = resetValue;
      }
      EditorGUILayout.EndHorizontal();

      return value;
    }

    /// <summary> Vector3 field with reset. </summary>
    public static Vector3 Vector3Field(string label, string tooltip, Vector3 value, Vector3 resetValue)
    {
      EditorGUILayout.BeginHorizontal();
      {
        value = EditorGUILayout.Vector3Field(new GUIContent(label, tooltip), value);

        if (ResetButton(resetValue) == true)
          value = resetValue;
      }
      EditorGUILayout.EndHorizontal();

      return value;
    }

    /// <summary> Vector4 field with reset. </summary>
    public static Vector4 Vector4Field(string label, string tooltip, Vector4 value, Vector4 resetValue)
    {
      EditorGUILayout.BeginHorizontal();
      {
        value = EditorGUILayout.Vector4Field(new GUIContent(label, tooltip), value);

        if (ResetButton(resetValue) == true)
          value = resetValue;
      }
      EditorGUILayout.EndHorizontal();

      return value;
    }

    /// <summary> Color field with reset. </summary>
    public static Color ColorField(string label, string tooltip, Color value, Color resetValue)
    {
      EditorGUILayout.BeginHorizontal();
      {
        value = EditorGUILayout.ColorField(new GUIContent(label, tooltip), value);

        if (ResetButton(resetValue) == true)
          value = resetValue;
      }
      EditorGUILayout.EndHorizontal();

      return value;
    }

    /// <summary> Gradient field with reset. </summary>
    public static Gradient GradientField(string label, string tooltip, Gradient value)
    {
      EditorGUILayout.BeginHorizontal();
      {
        value = EditorGUILayout.GradientField(new GUIContent(label, tooltip), value);
      }
      EditorGUILayout.EndHorizontal();

      return value;
    }

    /// <summary> AnimationCurve field with reset. </summary>
    public static AnimationCurve CurveField(string label, string tooltip, AnimationCurve value, AnimationCurve resetValue = null)
    {
      EditorGUILayout.BeginHorizontal();
      {
        value = EditorGUILayout.CurveField(new GUIContent(label, tooltip), value);

        if (resetValue != null && ResetButton(resetValue) == true)
          value.keys = resetValue.keys;
      }
      EditorGUILayout.EndHorizontal();

      return value;
    }

    /// <summary> Object field with reset. </summary>
    public static T ObjectField<T>(string label, string tooltip, T value, bool allowSceneObjects = true) where T : UnityEngine.Object =>
      EditorGUILayout.ObjectField(new GUIContent(label, tooltip), value, typeof(T), allowSceneObjects) as T;

    /// <summary> Layermask field with reset. </summary>
    public static LayerMask LayerMask(string label, LayerMask layerMask, int resetValue)
    {
      List<string> layers = new();
      List<int> layerNumbers = new();

      for (int i = 0; i < 32; ++i)
      {
        string layerName = UnityEngine.LayerMask.LayerToName(i);
        if (string.IsNullOrEmpty(layerName) == false)
        {
          layers.Add(layerName);
          layerNumbers.Add(i);
        }
      }

      int maskWithoutEmpty = 0;
      for (int i = 0; i < layerNumbers.Count; ++i)
      {
        if (((1 << layerNumbers[i]) & layerMask.value) > 0)
          maskWithoutEmpty |= (1 << i);
      }

      EditorGUILayout.BeginHorizontal();
      {
        maskWithoutEmpty = EditorGUILayout.MaskField(label, maskWithoutEmpty, layers.ToArray());
        int mask = 0;
        for (int i = 0; i < layerNumbers.Count; ++i)
        {
          if ((maskWithoutEmpty & (1 << i)) > 0)
            mask |= (1 << layerNumbers[i]);
        }

        layerMask.value = mask;

        if (ResetButton(resetValue) == true)
          layerMask.value = resetValue;
      }
      EditorGUILayout.EndHorizontal();

      return layerMask;
    }

    /// <summary> Button. </summary>
    public static bool Button(string label, string tooltip = default, GUIStyle style = null) => GUILayout.Button(new GUIContent(label, tooltip), style ?? GUI.skin.button);

    /// <summary> Mini button. </summary>
    public static bool MiniButton(string label, string tooltip = default) => GUILayout.Button(new GUIContent(label, tooltip), Styles.miniLabelButton);

    /// <summary> Reset button. </summary>
    public static bool ResetButton<T>(T resetValue) => GUILayout.Button(EditorGUIUtility.IconContent("Refresh"), EditorStyles.miniLabel, GUILayout.Width(19.0f));

    /// <summary> Reset button. </summary>
    public static bool ResetButton() => GUILayout.Button(EditorGUIUtility.IconContent("Refresh"), EditorStyles.miniLabel, GUILayout.Width(19.0f));

    /// <summary> Nice header. </summary>
    public static void Header(string title)
    {
      Separator();

      Rect rect = GUILayoutUtility.GetRect(16.0f, 22.0f, Styles.HeaderStyle);
      GUI.Box(rect, title, Styles.HeaderStyle);
    }

    /// <summary> Nice foldout. </summary>
    public static bool Foldout(string title)
    {
      bool display = GetFoldoutDisplay(title);

      Rect rect = GUILayoutUtility.GetRect(16.0f, 22.0f, Styles.HeaderStyle);
      GUI.Box(rect, title, Styles.HeaderStyle);

      Rect toggleRect = new(rect.x + 4.0f, rect.y + 2.0f, 13.0f, 13.0f);
      if (Event.current.type == EventType.Repaint)
        EditorStyles.foldout.Draw(toggleRect, false, false, display, false);

      Event e = Event.current;
      if (e.type == EventType.MouseDown && rect.Contains(e.mousePosition) == true)
      {
        display = !display;
        e.Use();
      }

      SetFoldoutDisplay(title, display);

      return display;
    }

    private static bool GetFoldoutDisplay(string foldoutName)
    {
      string key = $"{Constants.Asset.AssemblyName}.display{foldoutName}";
      bool value = true;

      if (foldoutDisplay.ContainsKey(key) == false)
      {
        value = PlayerPrefs.GetInt(key, 0) == 1;
        foldoutDisplay.Add(key, value);
      }
      else
        value = foldoutDisplay[key];

      return value;
    }

    private static void SetFoldoutDisplay(string foldoutName, bool value)
    {
      string key = $"{Constants.Asset.AssemblyName}.display{foldoutName}";

      if (foldoutDisplay.ContainsKey(key) == false)
        foldoutDisplay.Add(key, value);
      else
        foldoutDisplay[key] = value;

      PlayerPrefs.SetInt(key, value == true ? 1 : 0);
    }
  }
}
