// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/shader10"{
	Properties{
		_Color("Main Tint", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white" {}
		//用于决定我们调用clip进行透明度测试时使用的判断条件
		_Cutoff("Alpha Cutoff", Range(0,1)) = 0.5
	}
	SubShader{
		//第一个tag 把Queue标签设置为AlphaTest 
		//而RenderType 标签可以让Unity把这个Shader归入到提前定义的组以指明该Shader 是
		//一个使用 了透明度测试的Shader（RenderType标签通常用于着色器替换功能）
		//IgnoreProjector 设置为True，这意味着这个Shader 不会受到投影器的影响。
		//通常，使用了透明度测试的Shader 都应该在SubShader 中设置这三个标签
		Tags{ "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout" }
		Pass{
			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM
				#include "Lighting.cginc"
				#pragma vertex vert
				#pragma fragment frag

				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				fixed _Cutoff;

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
					fixed4 texColor = tex2D(_MainTex, i.uv);
					//透明度测试
					clip(texColor.a - _Cutoff);

					fixed3 albedo = texColor.rgb * _Color.rgb;
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
					fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,worldLightDir) * 0.5 + 0.5);
					return fixed4(ambient + diffuse, 1.0);
				}
			ENDCG
		}
	}
		Fallback "Transparent/Cutout/VertexLit"
}