//AuthorName : Kenvin;
//CreateDate : 11/27/2018 9:53:35 PM;
// 1. 新认识了decimal 类型，decimal与浮点数不同，浮点数是用二进制表示十进制，除非分母是2的整数次幂，否则很难表示正确的
//数字，比如0.1，浮点数可能会表示成0.0999999999999，而decimal只要不超出允许范围，就能精确的表示出数字+
// 2. 每一个数值类型都包含了parse这个方法，允许将一个字符串类型的值转换成一个值类型的值，int a  = int.parse("1");
//TryParse()与Parse一样，但是转换失败后不会引发异常，只会返回false
//3. const和readonly的区别：const是编译型常量，必须初始化，并且值应该是字面值常量，readonly是运行时常量（可以改变）
//4.null 条件操作符，是一种组合调用链，当args[0]?.tolower().startswidth；如果args[0]是null，表达式后不会继续求值，
//返回的是一个值类型，判断返回值的时候一般用？？或者if（返回值）,若果没有返回null
//5 逻辑操作符，|按位或，&按位与 异或
//6 参数数组： 格式，void multiParams(params string[] strs)
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class BaseDataType : MonoBehaviour 
{
	private const string a = "lzd";
	
	private static readonly  int b;
	// Use this for initialization
	void Start () {
		//test
		var a = (decimal) 1/10;
		var b = (float)1/10;
		
	    var price = 100000;
		Debug.Log(string.Format("{0:C3}",price).Trim());
		//Debug.Log(${"price",20:C2})
		//parse  test
		string strNum = "999";
		string str_Num = "lzd";
		Debug.Log(int.Parse(strNum));
		//Debug.Log(int.Parse(str_Num)); //出错，无法转换
		//null操作符
		bool? booltest = 2 > 3;
		Debug.Log(booltest);
		if(booltest == false)
		{

		}
		//利用按位操作符建一个整数转换成一个二进制字符串
         LongToString();
		//复合移位和赋值操作符
		//int test = 2 >> 1;
		int test = 2;
		test >>= 1;
		Debug.Log(test);
		int test2 = 2;
		test2 <<= 1;
		Debug.Log(test2);
		PramaWarning();
		string nowTime = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss:ms");
		Debug.Log(nowTime);
	}
	
	void PramaWarning()
	{
		#pragma warning abandoned method;
	}
	// Update is called once per frame
	void Update () {
		
	}
	void LongToString()
	{
		const int size = 64;
		ulong a = 32;
		//掩码
		ulong mask = 1UL << size - 1;
		for(int count = 0;count < size;++count)
		{
			char bit = ((a & mask) != 0) ? '1' : '0';
			Debug.Log(bit);
			mask >>= 1;
		}
	}
}
