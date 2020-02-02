using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//Author : #AUTHOR#
//CreateDate : #DATETIME#
//DESC : #DESC#
[ExecuteInEditMode]
public class PostEffectBase : MonoBehaviour {
	private Material material;
	protected Material Material
	{
		get
		{
			if(material = null)
			{
				material = gameObject.GetComponent<Material>();
			}
			return material;
		}
	}
}
