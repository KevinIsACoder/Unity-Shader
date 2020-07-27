using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//正弦波运动。 y = Asin(wx + f)
//Author : #AUTHOR#
//CreateDate : #DATETIME#
//DESC : #DESC#
public class SinMove : MonoBehaviour {

	public GameObject cube;
	[SerializeField]
	private float frequency = 20f;
	[SerializeField]
	private float magnitude = 2.0f;
	[SerializeField]
	private float speed = 10f;
	private Vector3 originPos;
	// Use this for initialization
	void Start () {
		originPos = cube.transform.localPosition;
	}
	
	// Update is called once per frame
	void Update () {
		originPos.x += speed * Time.deltaTime;
		originPos.y = Mathf.Sin(frequency * originPos.x) * magnitude;
		cube.transform.localPosition = new Vector3(originPos.x, originPos.y, originPos.z);
	}
}
