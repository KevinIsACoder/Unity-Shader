
//常我们所见的法线纹理还是基于原法线信息构建的坐标系来构建出来的。那种偏蓝色的法线纹理其实就是存储了在每个顶点各自的Tangent Space中，法线的扰动方向。也就是说，如果一个顶点的法线方向不变，那么在它的Tangent Space中，新的normal值就是z轴方向，也就是说值为(0, 0, 1)。但这并不是法线纹理中存储的最终值，因为一个向量每个维度的取值范围在(-1, 1)，而纹理每个通道的值范围在(0, 1)，因此我们需要做一个映射，即pixel = (normal + 1) / 2。这样，之前的法线值(0, 0, 1)实际上对应了法线纹理中RGB的值为(0.5, 0.5, 1)，而这个颜色也就是法线纹理中那大片的蓝色。这些蓝色实际上说明顶点的大部分法线是和模型本身法线一样的，不需要改变。
//总结一下就是，法线纹理的RGB通道存储了在每个顶点各自的Tangent Space中的法线方向的映射值。

//法线贴图： 通过改变面上某点的光照条间
//TANGENT_SPACE_ROTATION 宏 相当于嵌入如下两行代码：
//float3 binormal = cross( v.normal, v.tangent.xyz ) * v.tangent.w;
//float3x3 rotation = float3x3( v.tangent.xyz, binormal, v.normal );
//也就是构造出  tangent  space 的坐标系， 定义转换world space的向量到tangent space的rotation 矩阵。
Shader "Custom/DisappearShader" {
	Properties {
		_MainTex ("Base Texture", 2D) = "white" {} //反射贴图，主要是用来计算漫反射率的
		_BurnAmount("Burn Amount", Range(0.0, 1.0)) = 0.0 //用于控制消融程度
		_BumpMap("Normal Map", 2D) = "bump" {} //法线贴图
		_BurnMap("Burn Map", 2D) = "white"{}  //噪声纹理
        _BurnFirstColor("Burn First Color", Color) = (1, 0, 0, 1)
		_BurnSecondColor("Burn Second Color", Color) = (1, 0, 0, 1)
		_LineWidth("Line Width", Range(0.0, 0.2)) = 0.1
	}
	SubShader
	{

		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		pass {
				Tags { "LightMode" = "ForwardBase"}
				Cull Off
				CGPROGRAM
				#include "Lighting.cginc"
				#include "AutoLight.cginc"
				#pragma multi_compile_fwdbase
        
				#pragma vertex vert
				#pragma fragment frag

				fixed _BurnAmount;
				fixed _LineWidth;
				fixed _BurnFirstColor;
				fixed _BurnSecondColor;

				float4 _MainTex_ST;  //必须带_ST后缀的,_MainTex_ST可以得到该纹理的缩放和平移值，对应面板的Tiling（平铺）和Offset（偏移）。
				float4 _BumpMap_ST;
				float4 _BurnMap_ST;

				sampler2D _MainTex;
				sampler2D _BumpMap;
				sampler2D _BurnMap;
				
				//顶点着色器数据结构
				struct a2v
				{
					float4 vertex : POSITION;
					float4 tangent : TANGENT;
					float4 texcoord : TEXCOORD0;
					float3 normal : NORMAL;
				};
				//定义片元着色器数据结构
				struct v2f
			    {
					float4 pos : SV_POSITION;
					float2 uvMainTex : TEXCOORD0;
					float2 uvBumpMap : TEXCOORD1;
					float2 uvBurnMap : TEXCOORD2;
					float3 lightDir : TEXCOORD3;
					float3 worldPos : TEXCOORD4;
					SHADOW_COORDS(5) //存储阴影纹理的坐标
				};

				v2f vert(a2v v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex); //将顶点坐标转换成齐次裁剪坐标
					
					o.uvMainTex = TRANSFORM_TEX(v.texcoord, _MainTex);  //对纹理进行采样
					o.uvBumpMap = TRANSFORM_TEX(v.texcoord, _BumpMap);
					o.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);
					TANGENT_SPACE_ROTATION;
					o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz; //这个就是将入射光方向和视线方向从本地空间转换到切线空间传给片段着色器用来参与计算光照
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; //模型空间坐标转换为世界坐标空间

					TRANSFER_SHADOW(o); //计算阴影纹理的采样坐标

					return o;
				}

				fixed4 frag(v2f i) : SV_TARGET
				{
					fixed3 burn = tex2D(_BurnMap, i.uvBurnMap).rgb;
					clip(burn.r - _BurnAmount);  //剔除结果小于0的数
					float3 tangentLightDir = normalize(i.lightDir);
					fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uvBurnMap)); //，就是将法线纹理中的颜色值重新映射回正确的法线方向值

					fixed3 albedo = tex2D(_MainTex, i.uvMainTex).rgb; //获取反射贴图的颜色值
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo; //获取环境光
					
					fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentLightDir, tangentNormal));

					//smoothstep 函数
					fixed3 t = 1 - smoothstep(0.0, _LineWidth, burn.r - _BurnAmount);  //这个应该算是根据_BurnAmout的改变改变t值的过程, smoothStep是一个平滑插值函数，返回值介于（0， 1）之间
				 	fixed3 burnColor = lerp(_BurnFirstColor, _BurnSecondColor, t);
					burnColor = pow(burnColor, 5); //对消融颜色做了一个加强

					UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);  //光照衰减
					
					fixed3 finalColor = lerp(ambient + diffuse * atten, burnColor, t * step(0.0001, _BurnAmount));
					
					return fixed4(finalColor, 1);
				}
				ENDCG
			}

			//投射阴影的pass
			// pass
			// {
			// 	Tags{"LightMode" = "ShadowCaster"}
			// 	CGPROGRAM
			// 	#pragma vertex vert_1;
			// 	#pragma fragment frag_2;
			// 	#pragma multi_compile_shadowcaster
				
			// 	#include "UnityCG.cginc"
			// 	fixed _BurnAmount;
			// 	sampler2D _BurnMap;
			// 	float4 _BurnMap_ST;

			// 	struct v2f
			// 	{
			// 		V2F_SHADOW_CASTER;
			// 		float2 uvBurnMap : TEXCOORD1;
			// 	};

			// 	v2f vert_1(appdata_base v)
			// 	{
			// 		v2f o;
			// 		TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)  //宏定义不需要分号
			// 		o.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);
			// 		return o;
			// 	}
				
			// 	fixed4 frag_2(v2f i) : SV_TARGET
			// 	{
			// 		fixed3 burn = tex2D(_BurnMap, i.uvBurnMap).rgb; //
			// 		clip(burn.r - _BurnAmount);
			// 		SHADOW_CASTER_FRAGMENT(i);
			// 	}
			// 	ENDCG
			// }
					// Pass to render object as a shadow caster
		Pass {
			Tags { "LightMode" = "ShadowCaster" }
			
			CGPROGRAM
			
			#pragma vertex vert1
			#pragma fragment frag2
			
			#pragma multi_compile_shadowcaster
			
			#include "UnityCG.cginc"
			
			fixed _BurnAmount;
			sampler2D _BurnMap;
			float4 _BurnMap_ST;
			
			struct v2f {
				V2F_SHADOW_CASTER;
				float2 uvBurnMap : TEXCOORD1;
			};
			
			v2f vert1(appdata_base v) {
				v2f o;
				
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				
				o.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);
				
				return o;
			}
			
			fixed4 frag2(v2f i) : SV_Target {
				fixed3 burn = tex2D(_BurnMap, i.uvBurnMap).rgb;
				
				clip(burn.r - _BurnAmount);
				
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
