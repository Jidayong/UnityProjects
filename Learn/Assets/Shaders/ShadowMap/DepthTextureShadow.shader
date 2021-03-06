// Upgrade NOTE: replaced 'defined UNITY_REVERSED_Z' with 'defined (UNITY_REVERSED_Z)'

Shader "Unlit/DepthTextureShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float2 depth : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.depth = o.vertex.zw;
                return o;
            }

			fixed4 frag(v2f i) : SV_Target
			{
				float depth = i.depth.x / i.depth.y;

#ifdef SHADER_TARGET_GLSL
				depth = depth * 0.5 + 0.5;
#elif defined (UNITY_REVERSED_Z)
				depth = 1 - depth;
#endif
				depth += 0.0001;

				fixed4 col = EncodeFloatRGBA(depth);
				return col;
            }
            ENDCG
        }
    }
}
