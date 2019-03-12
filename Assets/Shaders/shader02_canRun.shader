// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/shader02_canRun"{
	Properties{

	}
	SubShader{
		Pass{
			CGPROGRAM
				//固定内置函数，顶点函数，vert是函数名，可随意设置
				//模型的每个顶点都会执行这个函数
				//最基本作用：利用矩阵把每个顶点从模型空间转换到裁剪空间
				#pragma vertex vert	
				//内置函数，片元函数
				//片元相当于模型在屏幕上的每个像素，每个像素点都会经过片元函数的处理
				#pragma fragment frag 

				//顶点函数函数体。POSITION是语义，表示把模型的顶点坐标传递给参数v，SV_POSITION用于告诉系统返回值是一个剪裁空间下的顶点坐标	
				float4 vert(float4 v : POSITION) : SV_POSITION{  
					//return mul(UNITY_MATRIX_MVP,v) //mul()用于完成矩阵相乘，UNITY_MATRIX_MVP矩阵与v相乘，可以把v从模型空间转换到剪裁空间
					return UnityObjectToClipPos(v);  
				}

				//片元函数函数体。
				fixed4 frag() : SV_Target{
					return fixed4(0.5,0.5,0.5,1);
				}
			ENDCG
		}
	}
	FallBack "VertexLit"
}
