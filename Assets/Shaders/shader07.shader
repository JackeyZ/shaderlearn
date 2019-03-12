// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/shader07"{
	Properties{
		_Diffuse("Diffuse Color",Color) = (1,1,1,1)
		_Pro1("High Light",Range(1,100)) = 1
		_HighLightColor("High Light Color",Color) = (1,1,1,1)
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

				//application to vertex
				struct a2v{
					float4 vertex : POSITION;	//告诉Unity把模型空间下的顶点坐标填充给vertex
					float3 normal : NORMAL;
				};
				struct v2f{
					float4 position : SV_POSITION;
					fixed3 normalDir : COLOR0;
					float3 worldPos : COLOR1;

				};

				v2f vert(a2v v){ 
					v2f f;
					f.position = UnityObjectToClipPos(v.vertex);//return mul(UNITY_MATRIX_MVP,v);
					fixed3 normalDir = normalize(UnityObjectToWorldNormal(v.normal));			//获得法线方向 //normalize(mul(v.normal,(float3x3)unity_WorldToObject));
					f.normalDir = normalDir;
					f.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz; //顶点坐标从模型空间转化到世界空间
					return f;
				}
 
				fixed4 frag(v2f f) : SV_Target{
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb; //获取环境光
					float3 lightDir = normalize(WorldSpaceLightDir((f.worldPos,0)).xyz);//normalize(_WorldSpaceLightPos0.xyz);//获取光照方向
					fixed3 diffuse = _LightColor0.rgb * max(0,dot(f.normalDir,lightDir) * 0.5 + 0.5) * _Diffuse.rgb ; 
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
