using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

[ExecuteInEditMode]
public class ProceduralTextureGeneration : MonoBehaviour
{
    public Material _material = null;

    #region Material properties
    [SerializeField, SetProperty("textureWidth")]
    private int _textureWidth = 512;
    public int textureWidth
    {
        get { return _textureWidth; }
        set
        {
            _textureWidth = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("backgroundColor")]
    private Color _backgroundColor;

    public Color backgrroundColor
    {
        get { return _backgroundColor; }
        set 
        {
            _backgroundColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("circleColor")]
    private Color _circleColor;

    public Color circleColor
    {
        get { return _circleColor; }
        set
        {
            _circleColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("blurFactor")]
    private float _blurFactor = 2.0f;
    public float blurFactor
    {
        get { return _blurFactor; }
        set
        {
            _blurFactor = value;
            _UpdateMaterial();
        }
    }
    #endregion

    private Texture2D _generatedTexture = null;

    void Start()
    {
        if(_material == null)
        {
            Renderer renderer = gameObject.GetComponent<Renderer>();
            if(renderer == null)
            {
                Debug.LogWarning("Can not find a renderer");
                return;
            }
            _material = renderer.sharedMaterial;
        }

        _UpdateMaterial();
    }

    private void _UpdateMaterial()
    {
        if(_material != null)
        {
            _generatedTexture = _GenerateProceduralTexture();
            _material.SetTexture("_MainTex", _generatedTexture);
        }
    }

    private Color _MixColor(Color color0, Color color1, float mixFactor)
    {
        Color mixColor = Color.white;
        mixColor.r = Mathf.Lerp(color0.r, color1.r, mixFactor);
        mixColor.g = Mathf.Lerp(color0.g, color1.g, mixFactor);
        mixColor.b = Mathf.Lerp(color0.b, color1.b, mixFactor);
        return mixColor;
    }

    private Texture2D _GenerateProceduralTexture()
    {
        Texture2D proceduralTexture = new Texture2D(textureWidth, textureWidth);

        float circleInterval = textureWidth / 4.0f;
        float radius = textureWidth / 10.0f;
        float edgeBlur = 1.0f / blurFactor;

        for (int w = 0; w < textureWidth; w++)
        {
            for(int h = 0; h < textureWidth;  h++)
            {
                Color pixel = backgrroundColor;
                for (int i = 0; i < 3; i++)
                {
                    for (int j = 0; j < 3; j++)
                    {
                        Vector2 circleCenter = new Vector2(circleInterval * (i + 1), circleInterval * (j + 1));
                        float dist = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;

                        Color color = _MixColor(circleColor, new Color(pixel.r, pixel.g, pixel.b, 1.0f), Mathf.SmoothStep(0f, 1.0f, dist * edgeBlur));
                        pixel = _MixColor(pixel, color, color.a);
                    }
                }
                proceduralTexture.SetPixel(w, h, pixel);
            }
        }
        proceduralTexture.Apply();
        return proceduralTexture;
    }
}
