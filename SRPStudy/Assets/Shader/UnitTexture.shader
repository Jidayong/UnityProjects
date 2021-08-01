Shader "SRPStudy/UnitTexture"
{
    Properties
    {
		_Color("Color Tint", Color) = (0.5,0.5,0.5)
		_MainTex("Texture", 2D) = "white" {}
    }

	HLSLINCLUDE
	#include "UnityCG.cginc"

	uniform float4 _Color;
	uniform float4 _Color2;
	sampler2D _MainTex;

	struct a2v
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		float2 uv : TEXCOORD0;
		float4 vertex : SV_POSITION;
	};

	v2f vert(a2v v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv;
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 col = tex2D(_MainTex, i.uv) * half4(_Color.rgb, 1.0f);
		return col;
	}

	ENDHLSL

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        LOD 100

        Pass
        {
			Tags { "LightMode"="Always" }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			ENDHLSL
        }
    }
}
