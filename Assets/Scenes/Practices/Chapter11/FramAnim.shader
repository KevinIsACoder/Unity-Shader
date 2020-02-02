Shader "Custom/FramAnim" {
	Properties
	{
		_Color("Main Color", Color) = (1, 1, 1, 1)
		_MainTex("Squence Textuer", 2D) = "white"{}
		_HorizontalAmount("Horizontal Image", Float) = 4
		_VerticalAmount("Vertical Amount", Float) = 4
		_Speed("Move Speed", RANGE(1, 100)) =  40
	}
	SubShader
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		pass
		{
			// Tags{"LightMode" = "ForwardBase"}
			// ZWrite Off //关闭深度写入
			// Blend SrcAlpha OneMinusSrcAlpha
			Tags { "LightMode"="ForwardBase" }
			
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM  //代码模块声明
			#pragma vertex vert //顶点着色器声明
			#pragma fragment frag	//片元着色器
			#include "UnityCG.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _HorizontalAmount;
			float _VerticalAmount;
			float _Speed;

			struct a2v
			{
				float4 vertex : POSITION; //顶点位置
				float2 texcoord : TEXCOORD0;//第一套纹理
			}; 
			//
			struct v2f
			{
				float4 pos : SV_POSITION; //片元着色器的顶点位置输入
				float2 uv : TEXCOORD0;
			};

			//顶点着色器
			v2f vert(a2v v)
			{
				v2f o;  
				o.pos = UnityObjectToClipPos(v.vertex);  
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);  
				return o;
			}
			//片元着色器
			fixed4 frag(v2f i) : SV_Target
			{	
				// float time = floor(_Time.y * _Speed);
				// float row = floor(time / _HorizontalAmount); //行索引
				// float column = time - row * _VertiaclAmount; //列索引

				// half2 uv = i.uv + half2(column, -row);
				// uv.x /= _HorizontalAmount;
				// uv.y /= _VertiaclAmount;

				// fixed4 c = tex2D(_MainTex, uv);
				// c.rgb *= _Color;
				// return c;
				float time = floor(_Time.y * _Speed);  
				float row = floor(time / _HorizontalAmount);
				float column = time - row * _HorizontalAmount;
				
//				half2 uv = float2(i.uv.x /_HorizontalAmount, i.uv.y / _VerticalAmount);
//				uv.x += column / _HorizontalAmount;
//				uv.y -= row / _VerticalAmount;
				half2 uv = i.uv + half2(column, -row);
				uv.x /=  _HorizontalAmount;
				uv.y /= _VerticalAmount;
				
				fixed4 c = tex2D(_MainTex, uv);
				c.rgb *= _Color;
				
				return c;	
			}
			ENDCG
		}
	}
	FallBack "Transparent/VertexLit"
}
