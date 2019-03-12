Shader "Mask/Mask01" {
	Properties {
		_StencilComp("Stencil Comparison", Float) = 8

		_Stencil("Stencil ID", Float) = 0

		_StencilOp("Stencil Operation", Float) = 0

		_StencilWriteMask("Stencil Write Mask", Float) = 255

		_StencilReadMask("Stencil Read Mask", Float) = 255
	}
	SubShader {
		Tags { "RenderType"="Opaque" }

		Stencil
		{
			Ref[_Stencil]

			Comp[_StencilComp]

			Pass[_StencilOp]

			ReadMask[_StencilReadMask]

			WriteMask[_StencilWriteMask]
		}

		Pass
		{
			CGPROGRAM

			ENDCG
		}
	}
	FallBack "Diffuse"
}
