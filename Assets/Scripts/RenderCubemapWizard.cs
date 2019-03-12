using UnityEngine;
using UnityEditor;
using System.Collections;

public class RenderCubemapWizard : ScriptableWizard
{

    public Transform renderFromPosition;
    public Cubemap cubemap;

    void OnWizardUpdate()
    {
        helpString = "Select transform to render from and cubemap to render into";
        isValid = (renderFromPosition != null) && (cubemap != null);
    }

    void OnWizardCreate()
    {

        GameObject go = new GameObject("CubemapCamera");
        go.AddComponent<Camera>();
        //在renderFromPosition(用户指定位置）创建一个摄像头
        go.transform.position = renderFromPosition.position;
        //把当前位置观察到的图像渲染到用户指定的立方体纹理中
        go.GetComponent<Camera>().RenderToCubemap(cubemap);
        DestroyImmediate(go);
    }

    [MenuItem("GameObject/Render into Cubemap")]
    static void RenderCubemap()
    {
        ScriptableWizard.DisplayWizard<RenderCubemapWizard>(
            "Render cubemap", "Render!");
    }
}