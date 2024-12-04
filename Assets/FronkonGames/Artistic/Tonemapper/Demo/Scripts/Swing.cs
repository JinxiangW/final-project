using UnityEngine;

namespace FronkonGames.Artistic.Tonemapper
{
  /// <summary> Object swing. </summary>
  /// <remarks> This code is designed for a simple demo, not for production environments. </remarks>
  public sealed class Swing : MonoBehaviour
  {
    [SerializeField]
    private Transform lookAt;

    [SerializeField]
    private Vector3 lookAtOffset = new(0.0f, 0.5f, 0.0f);

    [SerializeField]
    private Vector3 swingStrength = new(0.5f, 0.5f, 0.5f);

    [SerializeField]
    private Vector3 swingVelocity = new(1.0f, 0.5f, 0.25f);

    [SerializeField]
    private float smoothStart = 10.0f;

    private Vector3 originalPosition;
    private float progress = 0.0f;

    public void Reset()
    {
      originalPosition = this.transform.position;
      progress = 0.0f;
    }

    private void OnEnable() => Reset();

    private void Update()
    {
      Vector3 position = new(Mathf.Sin(Time.time * swingVelocity.x) * swingStrength.x,
                             Mathf.Cos(Time.time * swingVelocity.y) * swingStrength.y,
                             Mathf.Sin(Time.time * swingVelocity.z) * swingStrength.z);

      this.transform.position = originalPosition + (position * progress);

      if (lookAt != null && lookAtOffset.sqrMagnitude > 0.0f)
        this.transform.LookAt(lookAt.position + lookAtOffset);

      if (progress < 1.0f)
        progress = Mathf.Clamp01(progress + (Time.deltaTime * smoothStart));
    }
  }
}
