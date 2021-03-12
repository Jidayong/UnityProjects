using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthTextureCamera : MonoBehaviour
{

    public Camera _camera;
    RenderTexture _rt;

    private void Start()
    {
        /*
        _camera.depth = 2;
        _camera.clearFlags = CameraClearFlags.SolidColor;
        _camera.backgroundColor = new Color(1, 1, 1, 0);
        _camera.aspect = 1;

        _camera.orthographic = true;
        _camera.orthographicSize = 15;
        */

        _rt = new RenderTexture(512, 512, 24, RenderTextureFormat.Default);
        _rt.hideFlags = HideFlags.DontSave;

        _camera.backgroundColor = Color.white;
        _camera.clearFlags = CameraClearFlags.SolidColor;
        _camera.cullingMask = 1 << LayerMask.NameToLayer("Player");
        _camera.orthographic = true;
        _camera.orthographicSize = 2;
        _camera.targetTexture = _rt;
        _camera.SetReplacementShader(Shader.Find("Unlit/DepthTextureShadow"), "RenderType");
    }

    private void Update()
    {
        _camera.Render();
        Matrix4x4 tm = GL.GetGPUProjectionMatrix(_camera.projectionMatrix, false) * _camera.worldToCameraMatrix;

        Shader.SetGlobalTexture("_DepthTexture", _rt);
        Shader.SetGlobalMatrix("_ProjectionMatrix", tm);
    }
}
