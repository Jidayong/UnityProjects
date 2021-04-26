Shader "Unlit/GlassRefraction"
{
    Properties
    {
		_MainTex("Main Tex", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
		_Cubemap("Environment Cubemap", Cube) = "_Skybox" {}
		_Distortion("Distortion", Range(0, 100)) = 10
		_RefractAmount("Refract Amount", Range(0.0, 1.0)) = 1.0
    }

    SubShader
    {
		Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }

		GrabPass { "_RefractionTex" }
        Pass
        {
			Tags
			{
				"LightMode"="ForwardBase"
			}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
				float4 scrPos : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float4 uv : TEXCOORD2;

				float3 worldTangent : TEXCOORD3;
				float3 worldBinormal : TEXCOORD4;
				float3 worldNormal : TEXCOORD5;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;


			float _RefractAmount;
			float _Distortion;

			samplerCUBE _Cubemap;

			sampler2D _BumpMap;
			float4 _BumpMap_ST;

			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize;

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
				o.scrPos = ComputeGrabScreenPos(o.pos);							// 顶点在屏幕空间的坐标,注意该坐标是在齐次空间空间下的坐标，xy的范围为[0, w],因此在计算uv时，需要使用scrPos.xy / scrPos.w;
				
				o.worldPos = UnityObjectToWorldDir(v.vertex.xyz);				
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

				o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				o.worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));
				o.worldBinormal = normalize(cross(o.worldNormal, o.worldTangent) * v.tangent.w);
                return o;
            }

			fixed4 frag(v2f i) : SV_Target
			{
				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				// 切线空间下的法线方向
				float3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));

				// 根据像素的法线方向，求得折射的偏移
				float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
				i.scrPos.xy = offset + i.scrPos.xy;
				fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy / i.scrPos.w).rgb;
				
				// 将切线空间下的法线变换到世界空间下，结算反射方向，进而通过环境球，得到反射color
				float3x3 rot = float3x3(
					i.worldTangent.x, i.worldBinormal.x, i.worldNormal.x,
					i.worldTangent.y, i.worldBinormal.y, i.worldNormal.y,
					i.worldTangent.z, i.worldBinormal.z, i.worldNormal.z);
				
				float3 reflDir = reflect(-worldViewDir, mul(rot, bump));
				fixed4 texColor = tex2D(_MainTex, i.uv.xy);
				
				// 反射
				fixed3 reflCol = texCUBE(_Cubemap, reflDir).rgb * texColor.rgb;

				fixed3 color = lerp(reflCol, refrCol, _RefractAmount);

				return fixed4(color.rgb, 1.0);
            }
            ENDCG
        }
    }
	FallBack "Diffuse"
}
