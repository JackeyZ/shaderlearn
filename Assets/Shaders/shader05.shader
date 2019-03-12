// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/shader05"{
	Properties{
		_Diffuse("Diffuse Color",Color) = (1,1,1,1)
	}
	SubShader{
		Pass{
			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM
				#include "Lighting.cginc" //取到第一个直射光的颜色 _LightColor0
				#pragma vertex vert	
				#pragma fragment frag 
				fixed4 _Diffuse;

				//application to vertex
				struct a2v{
					float4 vertex : POSITION;	//告诉Unity把模型空间下的顶点坐标填充给vertex
					float3 normal : NORMAL;
				};
				struct v2f{
					float4 position : SV_POSITION;
					fixed3 normalDir : COLOR0;
				};

				v2f vert(a2v v){ 
					v2f f;
					f.position = UnityObjectToClipPos(v.vertex);//return mul(UNITY_MATRIX_MVP,v);
					fixed3 normalDir = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
					f.normalDir = normalDir;
					return f;
				}

				fixed4 frag(v2f f) : SV_Target{
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb; //获取环境光
					fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
					fixed3 diffuse = _LightColor0.rgb * max(0,dot(f.normalDir,lightDir)) * _Diffuse.rgb ;
					diffuse = diffuse + ambient; 
					return fixed4(diffuse,1);
				}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
