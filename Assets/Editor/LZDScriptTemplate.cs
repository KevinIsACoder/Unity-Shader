//AuthorName : #authtor#;
//CreateDate : #dateTime#;
using System.Collections;

using System.Collections.Generic;

using UnityEngine;
using UnityEditor;
using System.IO;

public class LZDScriptTemplate : UnityEditor.AssetModificationProcessor 
{

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}
    public static void OnWillCreateAsset(string path)
    {
        string file = path.Replace(".meta", "");
        if (!file.EndsWith(".cs")) return;
        string str = File.ReadAllText(file);
        string newstr = str.Replace("#author#", "Kenvin");
        newstr = newstr.Replace("#dateTime#", System.DateTime.Now.ToString());
        File.WriteAllText(file,newstr);
        AssetDatabase.Refresh();

    }
}
