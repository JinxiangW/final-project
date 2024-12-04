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
using System.Text.RegularExpressions;
using UnityEngine;
using UnityEditor;

namespace FronkonGames.Artistic.Tonemapper
{
  /// <summary> Support window. </summary>
  public sealed class SupportWindow : EditorWindow
  {
    private const float width = 500.0f;
    private const float height = 400.0f;

    private string UserEmail
    {
      get => EditorPrefs.GetString(SupportWindowEmailKey, string.Empty);
      set => EditorPrefs.SetString(SupportWindowEmailKey, value);
    }

    private string UserName
    {
      get => EditorPrefs.GetString(SupportWindowUserNameKey, string.Empty);
      set => EditorPrefs.SetString(SupportWindowUserNameKey, value);
    }

    private const string SupportWindowPositionXKey = "FronkonGames.SupportWindow.Position.X";
    private const string SupportWindowPositionYKey = "FronkonGames.SupportWindow.Position.Y";
    private const string SupportWindowEmailKey = "FronkonGames.SupportWindow.Email";
    private const string SupportWindowUserNameKey = "FronkonGames.SupportWindow.UserName";

    private Regex validEmailRegex;

    private string subject;
    private string issue;

    [MenuItem("Help/Fronkon Games/Artistic/Tonemapper/Online documentation")]
    public static void OnlineDocumentation() => Application.OpenURL(Constants.Support.Documentation);

    [MenuItem("Help/Fronkon Games/Artistic/Tonemapper/Leave a review ❤️")]
    public static void LeaveAReview() => Application.OpenURL(Constants.Support.Store);

    [MenuItem("Help/Fronkon Games/Artistic/Tonemapper/Support && suggestions")]
    public static void ShowWindow()
    {
      EditorWindow window = GetWindow(typeof(SupportWindow), false, "Support & suggestions");
      window.minSize = new Vector2(width, height);
      window.position = new Rect(EditorPrefs.GetInt(SupportWindowPositionXKey, ((int)Screen.width / 2) - ((int)width / 2)),
                                 EditorPrefs.GetInt(SupportWindowPositionYKey, ((int)Screen.height / 2) - ((int)height / 2)), width, height);
    }

    private string CollectAnonymousData()
    {
      const string nl = "%0A";
      string assetVersion = $"{Constants.Asset.Name} v{Constants.Asset.Version}";
      string unityVersion = $"Unity v{Application.unityVersion} {Application.platform}";
      string deviceInfo = $"OS: {SystemInfo.deviceType} - {SystemInfo.deviceModel} - {SystemInfo.operatingSystem} - {Application.systemLanguage}";
      string cpuInfo = $"CPU: {SystemInfo.processorType} - {SystemInfo.processorCount} threads - {SystemInfo.systemMemorySize / 1024}MB";
      string gpuInfo = $"GPU: {SystemInfo.graphicsDeviceName} - {SystemInfo.graphicsDeviceVendor} - {SystemInfo.graphicsDeviceVersion} - {SystemInfo.graphicsMemorySize / 1024}MB - {SystemInfo.maxTextureSize}";

      return $"{nl}{nl}{nl}{assetVersion}{nl}{unityVersion}{nl}{deviceInfo}{nl}{cpuInfo}{nl}{gpuInfo}";
    }

    private bool ValidEmail(string email)
    {
      if (validEmailRegex == null)
        validEmailRegex = new Regex(@"^(?!\.)(""([^""\r\\]|\\[""\r\\])*""|([-a-z0-9!#$%&'*+/=?^_`{|}~]|(?<!\.)\.)*)(?<!\.)@[a-z0-9][\w\.-]*[a-z0-9]\.[a-z][a-z\.]*[a-z]$", RegexOptions.IgnoreCase);

      return validEmailRegex.IsMatch(email);
    }

    private void OnGUI()
    {
      GUILayout.BeginVertical("box");
      {
        GUILayout.Label("Do you have any problem or suggestion? Send me an email(*) telling me the problem or your suggestion and will help you with it.", EditorStyles.wordWrappedLabel);

        GUILayout.Space(10.0f);

        GUILayout.Label($"Remember that maybe you can solve your problem if:\n* Read the online documentation.\n* Make sure you have the latest version available (current {Constants.Asset.Version}).", EditorStyles.wordWrappedLabel);

        GUILayout.Space(20.0f);

        GUILayout.BeginHorizontal();
        {
          GUILayout.Label("Your name", GUILayout.Width(75));
          UserName = GUILayout.TextField(UserName);
        }
        GUILayout.EndHorizontal();

        GUILayout.BeginHorizontal();
        {
          GUILayout.Label("Your email", GUILayout.Width(75));
          UserEmail = GUILayout.TextField(UserEmail);
        }
        GUILayout.EndHorizontal();

        GUILayout.BeginHorizontal();
        {
          GUILayout.Label("Subject", GUILayout.Width(75));
          subject = GUILayout.TextField(subject);
        }
        GUILayout.EndHorizontal();

        GUILayout.Space(5.0f);

        GUILayout.Label("Problem / suggestion");

        issue = GUILayout.TextArea(issue, GUILayout.ExpandWidth(true), GUILayout.ExpandHeight(true));

        GUILayout.BeginHorizontal();
        {
          GUILayout.Label("* anonimal information will be sent of your system", EditorStyles.miniLabel);

          GUI.enabled = ValidEmail(UserEmail) == true && string.IsNullOrEmpty(issue) == false && issue.Length >= 30 && issue.Length < 2048;

          if (GUILayout.Button("Send", GUILayout.Height(40)) == true)
            Application.OpenURL($"mailto:{Constants.Support.Email}?subject={subject.Trim()}&body={issue.Trim()}{CollectAnonymousData()}");

          GUI.enabled = true;
        }
        GUILayout.EndHorizontal();
      }
      GUILayout.EndVertical();
    }

    private void OnDisable()
    {
      EditorPrefs.SetInt(SupportWindowPositionXKey, (int)this.position.x);
      EditorPrefs.SetInt(SupportWindowPositionYKey, (int)this.position.y);
    }
  }
}