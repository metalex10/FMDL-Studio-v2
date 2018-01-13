﻿Shader "FoxShaders/Base"
{
	Properties
	{
		_MainTex("Albedo", 2D) = "white" {}
		Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		LayerColor("Secondary Color", Color) = (1.0, 1.0, 1.0, 1.0)
		Layer_Tex_SRGB("Secondary Albedo", 2D) = "white" {}
		LayerMask_Tex_LIN("Secondary Albedo Mask", 2D) = "black" {}
		NormalMap_Tex_NRM("Normal Map", 2D) = "bump" {}
		Metalness("Metalness", Range(0,1)) = 0
		SpecularMap_Tex_LIN("Roughness", 2D) = "white" {}
		Translucent_Tex_LIN("Transmissive - placeholder", 2D) = "white" {}
	}

	SubShader
	{
		Tags{ "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "Opaque" }
		LOD 200

		// Alpha blending
		Blend SrcAlpha OneMinusSrcAlpha     

		// paste in forward rendering passes from Transparent/Diffuse
		UsePass "Legacy Shaders/Transparent/Cutout/Diffuse/FORWARD"

		// extra pass that renders to depth buffer only
		Pass
		{
			ZWrite On
			ColorMask 0
		}

		CGPROGRAM

		#pragma surface surf Standard fullforwardshadows alpha:premul
		#pragma target 3.0

		//Normal textures; Translucent_Tex_LIN is still temporary
		sampler2D _MainTex;
		sampler2D NormalMap_Tex_NRM;
		sampler2D SpecularMap_Tex_LIN;
		sampler2D Translucent_Tex_LIN;

		//Secondary textures for camos and other materials using a lerp-derived albedo
		sampler2D Layer_Tex_SRGB;
		sampler2D LayerMask_Tex_LIN;

		struct Input 
		{
			float2 uv_Main;
		};

		half Metalness;
		fixed4 Color;
		fixed4 LayerColor;

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			//Albedo
			fixed4 mainTex = tex2D(_MainTex, IN.uv_Main);
			Color.a = 1.0f;
			fixed4 mainTinted = mainTex * Color;
			fixed4 layerTex = tex2D(Layer_Tex_SRGB, IN.uv_Main);
			LayerColor.a = 1.0f;
			fixed4 layerTinted = layerTex * LayerColor;
			fixed4 layerMask = tex2D(LayerMask_Tex_LIN, IN.uv_Main);
			fixed4 finalColor = lerp(mainTinted, layerTinted, layerMask);
			o.Albedo = finalColor.rgb;
			o.Alpha = finalColor.a;

			//Specular
			o.Metallic = Metalness;
			o.Smoothness = 1.0f - tex2D(SpecularMap_Tex_LIN, IN.uv_Main).g;

			//Normal
			fixed4 finalNormal = tex2D(NormalMap_Tex_NRM, IN.uv_Main);
			finalNormal.r = finalNormal.a;
			finalNormal.g = 1.0f - finalNormal.g;
			finalNormal.b = 1.0f;
			finalNormal.a = 1.0f;
			o.Normal = UnpackNormal(finalNormal);
		}
		ENDCG
	}
	FallBack "Standard"
}