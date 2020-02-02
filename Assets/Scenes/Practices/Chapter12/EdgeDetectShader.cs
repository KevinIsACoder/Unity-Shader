using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//Author : #AUTHOR#
//CreateDate : #DATETIME#
//DESC : #DESC#
public class EdgeDetectShader : PostEffectBase 
{
	[Range(0.0f, 1.0f)]
	public float edgeOnly = 0.0f;
	public Color edgeColor = Color.black;
	public Color backGroundColor = Color.white;

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if(Material != null)
		{
			Material.SetFloat("_EdgeOnly", edgeOnly);
			Material.SetColor("_EdgeColor", edgeColor);
			Material.SetColor("_BackGroundColor", backGroundColor);
			Graphics.Blit(src, dest, Material);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}
