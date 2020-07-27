Shader "Custom/Water"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_Magnitude("Distortion Magnitude", Float) = 1
		_Frequency("Distortion Magnitude", Float) = 1
		_InvWaveLength("Distortion Inverse Wave Length", Float) = 10
		_Speed("Speed", Float) = 0.5
	}
	SubShader
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "DisableBatching"="True" "RenderType"="Transparent" }
		Pass
		{
			Tags{"LightBase"="ForwardBase"}
			ZWrite Off  //关闭深度写入
			Blend SrcAlpha OneMinusSrcAlpha //
			Cull Off //关闭裁剪
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			//#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
            sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			float _Magnitude;
			float _Frequency;
			float _InvWaveLength;
			float _Speed;
			
			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				float4 offset;
				offset.yzw = float3(0.0, 0.0, 0.0);
				//offset.x = sin(_Frequency * _Time.y + v.vertex * _InvWaveLength) * _Magnitude;
			    offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;
				o.pos = UnityObjectToClipPos(v.vertex + offset);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv += float2(0.0, -_Speed * _Time.y);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv); //对纹理进行采样
				c.rgb *= _Color.rgb;
				return c;
			}
			ENDCG
		}
	}
	FallBack "Transparent/VertexLit"
}
