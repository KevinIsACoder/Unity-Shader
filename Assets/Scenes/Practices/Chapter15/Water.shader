//菲涅尔系数，fresnel = pow(1 - max(0, v * n), 4), v代表视角方向，n代表法线方向，夹角越小，代表反射越弱，折射越强
//复制代码
// /*反射
// o.worldRefl =reflect(-o.worldViewDir,o.worldNormal)
// --
// fixed3 reflection = texCBUE(_Cubemap,i.worldRefl).rgb

// 折射
// o.worldRefr = refract(-o.worldViewDir,o.worldNormal,_RefractRatio);
// --
// fixed3 refraction = texCUBE(_Cubemap,i.worldRefr).rgb;
// --菲涅尔反射
// o.worldRefl =reflect(-o.worldViewDir,o.worldNormal)
// --
// fixed3 reflection = texCBUE(_Cubemap,i.worldRefl).rgb
// fixed fresnel = _FresnelScale + (1 - _FresnelScale)*pow(1-dot(worldViewDir,worldNormal),5);
// fixed3 color = lerp(diffuse,reflection,saturate(fresnel));
Shader "Custom/WaveWater" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_WaveMap("Wave Map", 2D) = "bump" {}
		_CubeMap("Environment Map", Cube) = "_Skybox" {}

		_WaveXSpeed("Wave Horizontal Speed", Range(-0.1, 0.1)) = 0.01
		_WaveYSpeed("Wave Vertical Speed", Range(-0.1, 0.1)) = 0.01
		_Distortion("Distortion", Range(0, 100)) = 10
		// _Glossiness ("Smoothness", Range(0,1)) = 0.5
		// _Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "Queue"="Transparent" "LightMode"="ForwardBase"}
		GrabPass {"_RefractionTex"}
		Pass
		{
			CGPROGRAM
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#pragma multi_compile_fwdbase  //。forwardbase pass只能以逐像素的方式处理平行光，点光源和聚光灯都会被忽略掉，对应的_LightColor0都将是黑色

			#pragma vertex vert
			#pragma fragment frag
            
			fixed4 _Color; //控制水的颜色
			sampler2D _MainTex; //水面波纹材质纹理
			float4 _MainTex_ST;
			sampler2D _WaveMap;
			float4 _WaveMap_ST;
			samplerCUBE _CubeMap;
			fixed _WaveXSpeed;
			fixed _WaveYSpeed;
			float _Distortion; //用于控制模拟折射的弯曲程度

			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize; //得到该纹理的纹素大小， 如256x256 的文素大小为（1/256， 1/256），我们需要对屏幕图像的采样坐标进行偏移时使用
            
			struct a2v
			{
				float4 vertex : POSITION; //顶点坐标
				float3 normal : NORMAL; //法线
				float4 tangent : TANGENT; //切线
				float4 texcoord : TEXCOORD0;
			};
			//定义顶点着色器
			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 srcPos : TEXCOORD0; //
				float4 uv : TEXCOORD1;
				float4 TtoW0 : TEXCOORD2;
				float4 TtoW1 : TEXCOORD3;
				float4 TtoW2 : TEXCOORD4;
			};
			v2f vert(a2v i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex); //将顶点坐标转换成齐次裁剪坐标
				o.srcPos = ComputeGrabScreenPos(o.pos);
				o.uv.xy = TRANSFORM_TEX(i.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(i.texcoord, _WaveMap);

				float3 worldPos = mul(unity_ObjectToWorld, i.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(i.normal); //将法线从模型空间转换为世界空间
				fixed3 worldTangent = UnityObjectToWorldDir(i.tangent.xyz); //切线转换到世界空间
				
				fixed3 worldBinormal = cross(worldNormal, worldTangent); //求副切线， 为甚乘以v.tangent.w 呢
				
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x,  worldNormal.x, worldPos.x);  //这个是转换矩阵，是切线空间转换到世界空间的转换矩阵
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);  
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  
			    return o;
			}
			fixed4 frag(v2f o) : SV_Target
			{
				float3 worldPos = float3(o.TtoW0.w, o.TtoW1.w, o.TtoW2.w);
				float3 viewDir = normalize((UnityWorldSpaceViewDir(worldPos)));
				float2 speed = _Time.y * float2(_WaveXSpeed, _WaveYSpeed);
				
				//
				fixed3 bump1 = UnpackNormal(tex2D(_WaveMap, o.uv.zw + speed)).rgb;
			    fixed3 bump2 = UnpackNormal(tex2D(_WaveMap, o.uv.zw - speed)).rgb;
				fixed3 bump = normalize(bump1 + bump2);

				float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
				o.srcPos.xy = offset + o.srcPos.xy;
				fixed3 refrColor = tex2D(_RefractionTex, o.srcPos.xy/o.srcPos.w).rgb;

				bump = normalize(half3(dot(o.TtoW0.xyz, bump), dot(o.TtoW1.xyz, bump), dot(o.TtoW2.xyz, bump)));
				fixed4 texColor = tex2D(_MainTex, o.uv.xy + speed);
				
				fixed3 reflDir = reflect(-viewDir, bump); //求出反射向量
				fixed3 reflColor = texCUBE(_CubeMap, reflDir).rgb * texColor * _Color.rgb; //用反射向量对立方图纹理进行采样，然后混合图片颜色

				fixed fresnel = pow(1 - saturate(dot(viewDir, bump)), 4);
				fixed3 finalColor = reflColor * fresnel + refrColor * (1 - fresnel);
				return fixed4(finalColor, 1);
			}
			ENDCG
		}
	}
	FallBack Off
}
