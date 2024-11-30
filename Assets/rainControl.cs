using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class rainControl : MonoBehaviour
{
    // Start is called before the first frame update
    public AudioSource thunderRainAudio;

    public Material NoRainWindow;
    public Material RainWindow;

    private bool isVisible = true;

    private GameObject rainPlane;
    private Renderer quadRenderer;

    void Start()
    {
        InitializeScene();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            ToggleRainElements();
        }
    }

    void InitializeScene()
    {   
        Camera.main.gameObject.SetActive(true);


        rainPlane = GameObject.Find("rainPlane");
        if (rainPlane != null)
        {
            rainPlane.SetActive(false);
        }


        // 获取 rainWindow -> window -> Quad 的 Renderer
        GameObject rainWindow = GameObject.Find("rainWindow");
        if (rainWindow != null)
        {
            Transform window = rainWindow.transform.Find("window");
            if (window != null)
            {
                Transform quad = window.transform.Find("Quad");
                if (quad != null)
                {
                    quadRenderer = quad.GetComponent<Renderer>();
                    if (quadRenderer != null)
                    {
                        // 设置初始材质为 NoRainWindow
                        quadRenderer.material = NoRainWindow;
                    }
                }
            }
        }

        // 停止播放音乐
        if (thunderRainAudio != null)
        {
            thunderRainAudio.Stop();
        }
    }

    void ToggleRainElements()
    {
        // 切换状态
        isVisible = !isVisible;

        // 找到同目录下的 rainPlane
        if (rainPlane != null)
        {
            rainPlane.SetActive(isVisible);
        }

        if (quadRenderer != null)
        {
            quadRenderer.material = isVisible ? RainWindow : NoRainWindow;
        }

        // 播放或停止音乐
        if (thunderRainAudio != null)
        {
            if (isVisible)
            {
                thunderRainAudio.Play();
            }
            else
            {
                thunderRainAudio.Stop();
            }
        }
    }

}
