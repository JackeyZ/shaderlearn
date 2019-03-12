Shader "MyShader/shader_01"{ //""里是shader的路径和名字，名字不要求和文件名相同
	
	//属性
	Properties{
		_Color("颜色",Color) = (1,1,0,0) 			//参数1是在面板显示的名字,参数2是内置类型,等号后面是默认值（RGBA）
		_Vector("向量",Vector) = (0,0,10,0) 		//向量
		_Int("整数",Int) = 10
		_Float("浮点数",Float) = 0.1
		_Range("范围",Range(-10,10)) = 0
		_2D("纹理",2D) = "red"{} 					//如果没有图则显示红色
		_Cube("立方体纹理",Cube) = "while"{}		//天空盒（六个面） 
		_3D("3D纹理",3D) = "blue"{} 	
	}
	//子shader块，可有多个（显卡运行效果的时候从第一个SubShader开始,如果第一个SubShader里面的效果都可以实现，则使用第一个，否则检查下一个）
	SubShader{ 
		Pass{ //功能方法（至少一个、可有多个）
			CGPROGRAM //使用CG语言编写代码
				//重新定义属性(只需要定义要使用的，默认值会自动取得面板上设置的值)
				fixed4 _Color; 				//名字对应Properties里面的名字（Color对应fixed4）颜色一般用fixed
											//浮点数的三种精度：float（32位） half（16位 -6w ~ +6w） fixed（11位 -2 ~ +2）
				float4 _Vector;
				float _Int;
				float _Float;
				float _Range;
				sampler2d _2D;
				samplerCube _Cube;
				sampler3D _3D;


			ENDCG
		}

	}
	//后备方案，如果以上SubShader都无法执行，则执行这个Shader
	Fallback "VertexLit"
}
  

Shader "MyShader/shader001"
{
	Properties{
		_Color("颜色", Color) = (1, 0, 0, 0)
	}
}