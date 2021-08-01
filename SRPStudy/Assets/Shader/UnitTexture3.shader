Shader "Unlit/UnitTexture3"
{
    Properties
    {
		_Color("Tine Color", Color) = (1, 1, 1, 1)
		_DiffuseFactor("Diffuse Factor", Range(0, 1)) = 1
		_SpecularFactor("Specular Factor", Range(0, 1)) = 1
		_SpecularPower("Specular Power", Float) = 5
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100

        Pass
        {
			Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
				float4 color : COLOR;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				fixed4 color : COLOR0;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			uniform float4 _LightDir;
			uniform float4 _LightColor;
			uniform float4 _CameraPos;
			uniform float4 _Color;
			uniform float _DiffuseFactor;
			uniform float _SpecularFactor;
			uniform float _SpecularPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.color = v.color;
				o.worldPos = UnityObjectToWorldDir(v.vertex);
                return o;
            }

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 ambient = fixed3(0, 0, 0);

				fixed3 diffuse = _DiffuseFactor * _LightColor.rgb * _Color.rgb * max(0, dot(i.worldNormal, _LightDir));

				float3 viewDir = normalize(_CameraPos.xyz - i.worldPos);
				float3 h = viewDir + normalize(_LightDir.xyz);
				fixed3 specular = _SpecularFactor * _LightColor.rgb * _Color.rgb * pow(max(0, dot(i.worldNormal, h)), _SpecularPower);
                return fixed4(ambient + diffuse + specular, 1.0f);
            }
            ENDCG
        }
    }
}
