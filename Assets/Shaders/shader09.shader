// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/shader09"{
	Properties{
		_Diffuse("Diffuse Color",Color) = (1,1,1,1)
		_TextTure("TextTure",2D) = "red"{}
		_NormalMap("Normal Map",2D) = "bump"{} //切线空间的法线，法线贴图，bump表示使用模型顶点自带的法线
		_BumpScale("Bump Scale", Float) = 1.0
	}
	SubShader{
		Pass{
			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM
				#include "Lighting.cginc" //取到第一个直射光的颜色 _LightColor0
				#pragma vertex vert	
				#pragma fragment frag 
				fixed4 _Diffuse;
				sampler2D _TextTure;
				float4 _TextTure_ST;		//该名字固定，_TextTure与材质变量保持保持一致，后面再加上_ST就能获取到 _TextTure所对应的偏移值（面板上的Tiling和Offset）
				sampler2D _NormalMap;
				float4 _NormalMap_ST;
				float _BumpScale;

				//application to vertex
				struct a2v{
					float4 vertex : POSITION;	//告诉Unity把模型空间下的顶点坐标填充给vertex
					float3 normal : NORMAL;
					float4 tangent : TANGENT;	//tangent.w是用来确定切线空间总坐标轴的方向
					float4 textColor : TEXCOORD0;
				};
				struct v2f{
					float4 position : SV_POSITION;
					fixed3 normalDir : COLOR0;
					float3 lightDir : TEXCOORD0; 	//切线空间下平行光的方向
					float3 worldPos : COLOR1;
					float4 textColor : TEXCOORD1; //xy用来存储TextTure的纹理坐标，zw用来存储法线贴图
				};

				v2f vert(a2v v){ 
					v2f f;
					f.position = UnityObjectToClipPos(v.vertex);//return mul(UNITY_MATRIX_MVP,v);
					fixed3 normalDir = normalize(UnityObjectToWorldNormal(v.normal));			//获得法线方向 //normalize(mul(v.normal,(float3x3)unity_WorldToObject));
					f.normalDir = normalDir;
					f.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz; //顶点坐标从模型空间转化到世界空间

					//textColor.xy是UV坐标，假如当前纹理坐标是（0.4，0.4），如果不做处理，则会显示贴图上（0.4，0.4）位置的颜色
					//如果乘以（2，2），那么（0.4，0.4）位置将会显示贴图（0.8，0.8位置的颜色），如果加（0.2，0.2），那么则会显示贴图上（0.6，0.6）位置的颜色
					f.textColor.xy = v.textColor.xy * _TextTure_ST.xy + _TextTure_ST.zw; //+ _Time.x / 2
					f.textColor.zw = v.textColor.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
					
					TANGENT_SPACE_ROTATION; //调用这个之后，会得到一个矩阵rotation这个矩阵用来把模型空间下的方向转换成切线空间下的 方向
					f.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));//得到模型空间下的平行光方向，并转化为切线空间下的平行光方向

					return f;
				}
				//把所有跟法线方向有关的运算都放在切线空间下
				//从法线贴图里面取得的法线方向是在切线空间下的
				fixed4 frag(v2f f) : SV_Target{
					fixed4 normalColor = tex2D(_NormalMap, f.textColor.zw);		//根据法线UV坐标从法线贴图中采样出对应的像素颜色
					fixed3 tangenNormal = normalize(normalColor.xyz * 2 - 1);	//切线空间下的法线，把（0，1）的颜色值转换为（-1， 1）范围的法线值
					tangenNormal.xy *= _BumpScale;
					tangenNormal.z = sqrt(1.0 - saturate(dot(tangenNormal.xy, tangenNormal.xy)));


					fixed3 textColor = tex2D(_TextTure, f.textColor.xy);
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * textColor; //获取环境光
					float3 lightDir = normalize(WorldSpaceLightDir((f.worldPos,0)).xyz);//normalize(_WorldSpaceLightPos0.xyz);//获取光照方向
					fixed3 diffuse = _LightColor0.rgb * max(0,dot(tangenNormal, f.lightDir) * 0.5 + 0.5) * _Diffuse.rgb * textColor;
					fixed3 allColor = diffuse + ambient; 
					return fixed4(allColor,1);
				}  
			ENDCG
		}
	}
	FallBack "Diffuse"
}
