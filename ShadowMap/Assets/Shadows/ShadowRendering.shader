// Upgrade NOTE: replaced 'defined UNITY_REVERSED_Z' with 'defined (UNITY_REVERSED_Z)'

Shader "Unlit/ShadowRendering"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float4 color : COLOR;
            };

            struct v2f
            {
				float4 pos : SV_POSITION;
				float4 color : COLOR;
                float2 uv : TEXCOORD0;
				float4 shadowCoord : TEXCOORD1;			// 光源空间坐标			
                
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			float4x4 _ProjectionMatrix;
			sampler2D _DepthTexture;
			float4 _DepthTexture_TexelSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.color = v.color;

				_ProjectionMatrix = mul(_ProjectionMatrix, unity_ObjectToWorld);
				o.shadowCoord = mul(_ProjectionMatrix, v.vertex);				// 计算光源空间的坐标，先将顶点位置从模型空间转到世界空间，再转到光源空间
                return o;
            }

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv) * i.color;

				float depth = i.shadowCoord.z / i.shadowCoord.w;
#ifdef SHADER_TARGET_GLSL
				depth = depth * 0.5 + 0.5;
#elif defined (UNITY_REVERSED_Z)
				depth = 1 - depth;
#endif

				i.shadowCoord.xy = i.shadowCoord.xy / i.shadowCoord.w;
				float2 uv = i.shadowCoord.xy;
				uv = uv * 0.5 + 0.5;
				float shadow = 0.0;
				for (int x = -1; x <= 1; x++)
				{
					for (int y = -1; y <= 1; y++)
					{
						float4 col = tex2D(_DepthTexture, uv + float2(x, y) * _DepthTexture_TexelSize.xy);
						float sampleDepth = DecodeFloatRGBA(col);
						shadow += lerp(1, 0.55, step(sampleDepth, depth));
					}
				}

				shadow /= 9;
				return col * shadow;
			}
            ENDCG
        }
    }
}
