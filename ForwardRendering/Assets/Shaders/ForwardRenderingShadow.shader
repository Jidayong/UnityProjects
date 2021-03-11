// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Unlit/ForwardRenderingShadow"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Diffuse("Diffuse Color", Color) = (1, 1, 1, 1)
		_Specular("Specular Color", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 255)) = 20.0
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }

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
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				SHADOW_COORDS(2)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = UnityObjectToWorldDir(v.vertex.xyz);

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				float3 worldNormal = normalize(i.worldNormal);
				float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				float3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

				fixed3 diffuse = _LightColor0.xyz * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

				float3 halfDir = (worldViewDir + worldLightDir) * 0.5;
				fixed3 specular = _LightColor0.xyz * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				return fixed4(ambient + (diffuse + specular) * atten, 1.0);
			}
			ENDCG
		}

		Pass
		{
			Tags { "LightMode" = "ForwardAdd" }

			Blend One One

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdadd

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				SHADOW_COORDS(2)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = UnityObjectToWorldDir(v.vertex.xyz);

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{

				float3 worldNormal = normalize(i.worldNormal);

#ifdef USING_DIRECTIONAL_LIGHT
				float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
#else
				float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
#endif

				float3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

				fixed3 diffuse = _LightColor0.xyz * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

				float3 halfDir = (worldViewDir + worldLightDir) * 0.5;
				fixed3 specular = _LightColor0.xyz * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				/*
#ifdef USING_DIRECTIONAL_LIGHT
				fixed atten = 1.0;
#else
				float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
				fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
#endif
*/

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				return fixed4((diffuse + specular) * atten, 1.0);
			}
			ENDCG
		}
	}
	Fallback "Specular"
}
