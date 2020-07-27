using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//各种排序算法
//快速排序啊；
// 1、i从左往右寻找第一位大于基数（6）的数字，j从右往左寻找第一位小于基数（6）的数字；
// 2、找到后将两个数字进行交换。继续循环交换直到i>=j结束循环；
// 3、最终指针i=j,此时交换基数和i(j)指向的数字即可将数组划分为小于基数（6）/基数（6）/大于基数（6）的三部分，即完成一趟快排；
public class test : MonoBehaviour
{
    void Awake()
    {
       BurnHelper a = transform.GetChild(0).GetComponent<BurnHelper>();
       Debug.Log(a);
    }
    // Use this for initialization
    void Start()
    {
        int[] args = new int[] { 50, 30, 12, 40, 1 };
        QuickSort(args, 0, args.Length - 1);
		for (int k = 0; k < args.Length; ++k)
        {
           // Debug.Log(args[k]);
        }
    }

    // Update is called once per frame
    void Update()
    {

    }
    void QuickSort(int[] args, int left, int right)
    {
        if (left >= right) return;
        int temp = args[left]; //关键值
        int i = left;
        int j = right;
        while (i < j)
        {
            while (args[j] >= temp && i < j) j--;
            while (args[i] <= temp && i < j) i++;
            Swap(args, i, j);
        }
        args[left] = args[i];
        args[i] = temp;
        QuickSort(args, left, i - 1);
        QuickSort(args, i + 1, right);
    }

    void Swap(int[] args, int i, int j)
    {
        int temp = args[i];
        args[i] = args[j];
        args[j] = temp;
    }
}