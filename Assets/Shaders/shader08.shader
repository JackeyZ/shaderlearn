// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/shader08"{
	Properties{
		_Diffuse("Diffuse Color",Color) = (1,1,1,1)
		_Pro1("High Light",Range(1,100)) = 1
		_HighLightColor("High Light Color",Color) = (1,1,1,1)
		_TextTure("TextTure",2D) = "red"{}
	}
	SubShader{
		Pass{
			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM
				#include "Lighting.cginc" //取到第一个直射光的颜色 _LightColor0
				#pragma vertex vert	
				#pragma fragment frag 
				fixed4 _Diffuse;
				float _Pro1;
				fixed3 _HighLightColor;
				sampler2D _TextTure;
				float4 _TextTure_ST;		//该名字固定，_TextTure与材质变量保持保持一致，后面再加上_ST就能获取到 _TextTure所对应的偏移值（面板上的Tiling和Offset）

				//application to vertex
				struct a2v{
					float4 vertex : POSITION;	//告诉Unity把模型空间下的顶点坐标填充给vertex
					float3 normal : NORMAL;
					float4 textColor : TEXCOORD0;
				};
				struct v2f{
					float4 position : SV_POSITION;
					fixed3 normalDir : COLOR0;
					float3 worldPos : COLOR1;
					float2 textColor : TEXCOORD0;
				};

				v2f vert(a2v v){ 
					v2f f;
					f.position = UnityObjectToClipPos(v.vertex);//return mul(UNITY_MATRIX_MVP,v);
					fixed3 normalDir = normalize(UnityObjectToWorldNormal(v.normal));			//获得法线方向 //normalize(mul(v.normal,(float3x3)unity_WorldToObject));
					f.normalDir = normalDir;
					f.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz; //顶点坐标从模型空间转化到世界空间

					//textColor.xy是UV坐标，假如当前纹理坐标是（0.4，0.4），如果不做处理，则会显示贴图上（0.4，0.4）位置的颜色
					//如果乘以（2，2），那么（0.4，0.4）位置将会显示贴图（0.8，0.8位置的颜色），如果加（0.2，0.2），那么则会显示贴图上（0.6，0.6）位置的颜色
					f.textColor = v.textColor.xy * _TextTure_ST.xy + _TextTure_ST.zw; 
					return f;
				}
 
				fixed4 frag(v2f f) : SV_Target{
					fixed3 textColor = tex2D(_TextTure, f.textColor.xy);
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * textColor; //获取环境光
					float3 lightDir = normalize(WorldSpaceLightDir((f.worldPos,0)).xyz);//normalize(_WorldSpaceLightPos0.xyz);//获取光照方向
					fixed3 diffuse = _LightColor0.rgb * max(0,dot(f.normalDir,lightDir) * 0.5 + 0.5) * _Diffuse.rgb * textColor; 
					fixed3 viewDir = normalize(UnityWorldSpaceViewDir(f.worldPos));//normalize(_WorldSpaceCameraPos.xyz - f.worldPos);
					fixed3 reflectDir = reflect(-lightDir,f.normalDir);
					fixed3 specular = _LightColor0.rgb * pow(max(dot(reflectDir,viewDir),0),_Pro1) * _HighLightColor.rgb;
					fixed3 allColor = diffuse + ambient + specular; 
					return fixed4(allColor,1);
				}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
