using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class DemoPipeline : RenderPipeline
{
    protected override void Render(ScriptableRenderContext context, Camera[] cameras)
    {
        foreach(var camera in cameras)
        {
            // 这边主要是设置一些相机相关的渲染参数，比如MPV等等，这些都与相机的位置、朝向、是否正交等相关
            context.SetupCameraProperties(camera);

            // 绘制一个天空盒，传入相机只不过是使用相机的clear flags来确定该天空盒是否需要绘制
            context.DrawSkybox(camera);

            // 剪裁，这边应该是相机视锥剪裁相关
            // 自定义一个剪裁参数，cullParam类里面有很多可以设置的东西。我们先简单的采用相机的默认剪裁参数
            ScriptableCullingParameters cullParam = new ScriptableCullingParameters();
            // 直接使用相机默认剪裁参数
            camera.TryGetCullingParameters(out cullParam);
            // 对相机的裁剪参数做一些修改，非正交相机
            cullParam.isOrthographic = false;
            // 获取剪裁之后的全部结果（其中不仅有渲染物体，还有相关的其他渲染要素）
            CullingResults cullResults = context.Cull(ref cullParam);

            // 此时也就获得了视锥内的所有需要渲染的内容，这里还可以获取灯光等相关渲染需要的参数。

            // 渲染设置
            // 渲染时，会牵扯到渲染排序，所以要先进行一个相机的排序设置，这里Unity内置了一些默认的排序可以调用
            SortingSettings sortSet = new SortingSettings(camera) { criteria = SortingCriteria.CommonOpaque };
            // 这边进行渲染相关设置，需要指定渲染shader的光照模式(就是这里，如果shader中没有标注LightMode的话，使用该shader的物体就没法进行渲染了)和上面的排序设置两个参数
            // 下面的意思是使用Shader中LightMode为Always的Pass来绘制
            DrawingSettings drawSetting = new DrawingSettings(new ShaderTagId("Always"), sortSet);

            // 过滤
            // 这边是指定渲染的种类（对应Shader中的RenderType）和相关Layer的设置（-1表示全部Layer）
            // 下面这句话的意思是渲染Geometry通道里面的所有物体，物体所处的渲染通道，是shader中Queue指定的。至于为啥RenderQueueRange.opaque对应Geometry，这个不太清楚
            // Layer是Unity面板中指定的
            FilteringSettings filterSet = new FilteringSettings(RenderQueueRange.opaque, -1);

            context.DrawRenderers(cullResults, ref drawSetting, ref filterSet);
            context.Submit();
        }
    }
}
