using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class DemoPipeline3 : RenderPipeline
{
    CommandBuffer _cb;
    Vector3 _lightDir;

    protected override void Render(ScriptableRenderContext context, Camera[] cameras)
    {
        if (_cb == null)
            _cb = new CommandBuffer();

        var _lightDir = Shader.PropertyToID("_LightDir");
        var _lightColor = Shader.PropertyToID("_LightColor");
        var _cameraPos = Shader.PropertyToID("_CameraPos");

        foreach(var camera in cameras)
        {
            context.SetupCameraProperties(camera);

            _cb.name = "Setup";
            _cb.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);
            _cb.ClearRenderTarget(true, true, camera.backgroundColor);

            Vector4 cameraPosition = new Vector4(camera.transform.localPosition.x, camera.transform.localPosition.y, camera.transform.localPosition.z, 1.0f);
            _cb.SetGlobalVector(_cameraPos, camera.transform.localToWorldMatrix * cameraPosition);
            context.ExecuteCommandBuffer(_cb);
            _cb.Clear();

            context.DrawSkybox(camera);

            ScriptableCullingParameters cullingParam = new ScriptableCullingParameters();
            camera.TryGetCullingParameters(out cullingParam);
            cullingParam.isOrthographic = false;
            CullingResults cullingResult = context.Cull(ref cullingParam);

            var lights = cullingResult.visibleLights;
            _cb.name = "RenderLights";
            foreach(var light in lights)
            {
                if (light.lightType != LightType.Directional)
                    continue;

                Vector4 pos = light.localToWorldMatrix.GetColumn(2);
                Vector4 lightDirection = new Vector4(-pos.x, -pos.y, -pos.z, 0);

                Color lightColor = light.finalColor;

                _cb.SetGlobalVector(_lightDir, lightDirection);
                _cb.SetGlobalVector(_lightColor, lightColor);
                context.ExecuteCommandBuffer(_cb);
                _cb.Clear();

                FilteringSettings filterSetting = new FilteringSettings(RenderQueueRange.opaque);
                DrawingSettings drawingSettings = new DrawingSettings(new ShaderTagId("forwardbase"), new SortingSettings(camera) { criteria = SortingCriteria.CommonOpaque });

                context.DrawRenderers(cullingResult, ref drawingSettings, ref filterSetting);
                break;
            }

            context.Submit();
        }
    }
}
