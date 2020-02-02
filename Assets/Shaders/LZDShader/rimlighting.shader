//最终颜色 = 漫反射系数 * 纹理颜色 * 发光颜色 + 自发光
//纹理计算其uv坐标，即根据mesh上的uv坐标来计算真正的纹理上对应的位置。我们使用了Unity.CG.cginc中的宏TRANSFORM_TEX来实现。
//宏TRANSFORM_TEX的定义：#define TRANSFORM_TEX(tex,name) (tex.xy * name##_ST.xy + name##_ST.zw)。我们需要在shader中定义一些额外的变量，即必须定义一个名为_YourTextureName_ST (也就是你的纹理的名字加一个 _ST后缀)。
Shader "Custom/rimlighting" {
	Properties {
		_MainColor("[主颜色] Main Color", Color) = (0.5, 0.5, 0.5, 1)
		_DiffuseTex("[漫反射纹理] Diffuse Texture", 2D) =  "white"{}
		_RimColor("[边缘发光颜色] Rim Color", Color) = (0.5, 0.5, 0.5, 1)
		_RimPower("[边缘发光强度] Rim Power", Range(0, 36)) = 0.1
		_RimIntensity("[发光系数] Rim Intensity]", Range(0, 100)) = 1
	}
	SubShader {
		Tags { "Queue" = "Transparent" "RenderType"="Opaque" }
		LOD 200
        pass
		{
			Name "FowardBase"  //设定通道名称
			Tags{
				"LightMode" = "ForwardBase"  //光照模式
			}

		CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members viewDirection)
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma vertex vert
		#pragma fragment frag

		// Use shader mo()del 3.0 target, to get nicer looking lighting
		#include "UnityCG.cginc"
		#include "AutoLight.cginc"
		#pragma target 3.0
	    
		float4 _LightColor0; //系统光照颜色
		float4 _MainColor;
		sampler2D _TextureDiffuse; //漫反射纹理
		
		float4 _TextureDiffuse_ST; //
		float4 _RimColor; //边缘光颜色
		float _RimPower; //边缘光强度
		float _RimIntensity; //边缘光强度系数

		struct VertexInput //顶点输入结构体
		{
			float4 vertex : POSITION; //顶点位置
			float4 normal : NORMAL; //顶点法线
			float4 texcoord : TEXCOORD0; //第一纹理坐标
		};
		struct VertexOutPut //顶点输出结构体
		{
			float4 pos : SV_POSITION; //像素位置
			float4 texcoord : TEXCOORD0; //第一纹理坐标
			float3 normal : NORMAL;
			float4 posWorld : TEXCOORD1; //顶点世界坐标
			LIGHTING_COORDS(3, 4)
		};
		VertexOutPut vert(VertexInput v) //顶点输出
		{
			VertexOutPut o;
			o.texcoord = v.texcoord;
			o.normal = UnityObjectToWorldNormal(v.normal); //注意：5.6之前的写法是mul(UNITY_MATRIX_MVP, v.vertex),且不是归一化的， 新版是归一化的
			o.pos = UnityWorldToClipPos(v.vertex); //裁剪空间坐标
			o.posWorld = mul(unity_ObjectToWorld, v.vertex);
			return o;
		}
		fixed4 frag(VertexOutPut i) : COLOR
		{
			//视角方向
			float3 viewDirection = normalize(UnityWorldSpaceViewDir(i.posWorld.xyz));
			//法线方向
			float3 normalDirection = i.normal;
			//光照方向
			float3 lightDirection = UnityWorldSpaceLightDir(i.posWorld);

			//计算光照的衰减
			//衰减值
			UNITY_LIGHT_ATTENUATION(atten, i, i.posWorld)
			//计算漫反射
			float3 diffuse = max(0, dot(normalDirection, lightDirection)) *  atten + UNITY_LIGHTMODEL_AMBIENT.xyz;
			//自发光
			//计算边缘强度
			half Rim = 1.0 - max(0, dot(i.normal, viewDirection));
			//自发光
			float3 Emissive = _RimColor.rgb * pow(Rim, _RimColor) * _RimIntensity;
			//计算最终颜色
			float3 finalColor = diffuse * (tex2D(_TextureDiffuse, TRANSFORM_TEX(i.texcoord, _TextureDiffuse)).rgb * _MainColor.rgb) + Emissive;
			return fixed4(finalColor, 1);
		}
		ENDCG
	}
	}
}
