// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/shader12"{
	Properties{
		_Color("Main Tint", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white" {}
		_AlphaScale("Alpha Scale", Range(0,1)) = 1
	}

	SubShader{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }

		//新增的Pass的目的仅仅是为了把模型的深度信息写入到深度缓冲中，
		//从而剔除模型中被自身遮挡的片元。因此先开启深度写入
		//然后我们使用了一个新的渲染名利——ColorMask。在ShaderLab 中，ColorMask
		//用于设置颜色通道的写掩码，为0时表示不写入任何颜色。
		//在下一个pass才进行颜色写入，是因为当前pass不能准确的知道当前模型像素点的渲染顺序，并且，深度缓存中储存的是上一个模型的缓存，
		//如果当前的像素点不是当前模型最近摄像机的，而它和上一个模型的深度缓存作对比，则会通过了深度测试，进行了颜色融合，到最后会导致颜色错乱
		//所以本pass的作用是把深度缓存更新为当前模型最近摄像机的像素点深度，从而使下一个pass进行深度测试的时候剔除掉距离摄像机较远的像素，只融合与摄像机距离最近的像素颜色
		Pass{
			ZWrite On
			ColorMask 0
		}

		Pass{
			Tags{ "LightMode" = "ForwardBase" }
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "Lighting.cginc"

				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				//用于在透明纹理的基础上控制整体的透明度
				fixed _AlphaScale;

				struct a2v {
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float4 texcoord : TEXCOORD0;
				};

				struct v2f {
					float4 pos : SV_POSITION;
					float3 worldNormal : TEXCOORD0;
					float3 worldPos : TEXCOORD1;
					float2 uv : TEXCOORD2;
				};

				v2f vert(a2v v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldNormal = UnityObjectToWorldNormal(v.normal);
					o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
					o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target{
					fixed3 worldNormal = normalize(i.worldNormal);
					fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
					fixed4 texColor = tex2D(_MainTex,i.uv);
					fixed3 albedo = texColor.rgb * _Color.rgb;
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
					fixed3 diffuse = _LightColor0.rgb*albedo*max(0,dot(worldNormal,worldLightDir));

					return fixed4(ambient + diffuse,texColor.a * _AlphaScale);
				}
			ENDCG
		}
	}
	Fallback "Diffuse"


}