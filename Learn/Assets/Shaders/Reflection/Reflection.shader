﻿Shader "Unlit/Reflection"
{
	Properties
	{
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_ReflectionColor("Reflection Color", Color) = (1, 1, 1, 1)
		_ReflectAmount("Reflect Amount", Range(0, 1)) = 1
		_Cubemap("Reflection Cubemap", Cube) = "_Skybox" {}
	}

	SubShader
	{
		Tags { "RenderType" = "Opaque"}
		LOD 100

		Pass
		{

			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fwdbase

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float3 worldViewDir : TEXCOORD2;
				float3 worldRefl : TEXCOORD3;

				SHADOW_COORDS(4)
			};

			fixed4 _Color;
			fixed4 _ReflectionColor;
			float _ReflectAmount;
			samplerCUBE _Cubemap;

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = UnityObjectToWorldDir(v.vertex);
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);

				o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);

				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldViewDir = normalize(i.worldViewDir);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));

				fixed3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb * _ReflectionColor.rgb;

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

				fixed3 color = ambient + lerp(diffuse, reflection, _ReflectAmount) * atten;

				return fixed4(color, 1.0);
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
