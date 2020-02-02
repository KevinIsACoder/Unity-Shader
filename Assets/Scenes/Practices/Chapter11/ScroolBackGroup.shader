Shader "Custom/ScroolBackGroup" {
	Properties {
		_MainTex("Base Layer (RGB)", 2D) = "white"{}
		_DetailTex("2nd Layer Tex(RGB)", 2D) = "white"{}
		_Scrollx("Base Layer Scroll Speed", Float) = 1.0
		_Scroll2x("2nd layer Tex(RGB)", Float) = 1.0
		_Multiplier("Layer Nultiplier", Float) = 1
	}
	SubShader {
	    Tags {"RederType" = "Opaque" "Queue" = "Geometry"}
		Pass
		{
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			sampler2D _MainTex;
			sampler2D _DetailTex;
			float4 _MainTex_ST;
			float4 _DetailTex_ST;
			float _Scrollx;
			float _Scroll2x;
			float _Multiplier;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : POSITION;
				float4 uv : TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + frac((float2(_Scrollx, 0.0)) * _Time.y);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _DetailTex) + frac((float2(_Scroll2x, 0.0)) * _Time.y);
				return o;
			}
			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 firstLayer = tex2D(_MainTex, i.uv.xy);
				fixed4 seconndLayer = tex2D(_DetailTex, i.uv.zw);
				fixed4 c = lerp(firstLayer, seconndLayer, seconndLayer.a);
				c.rgb *= _Multiplier;
				return c;
			}
			ENDCG
		}
	}
	FallBack "VertexLit"
}
