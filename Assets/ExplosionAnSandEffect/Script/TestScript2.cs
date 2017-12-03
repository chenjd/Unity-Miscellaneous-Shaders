using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestScript2 : MonoBehaviour
{

    public Material explosionMat;

    private bool isClicked;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
        if(this.isClicked || this.explosionMat == null)
        {
            return;
        }

        if (Input.GetMouseButton(0))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit))
            {
                MeshRenderer[] renderers = hit.collider.GetComponentsInChildren<MeshRenderer>();
                this.explosionMat.SetFloat("_StartTime", Time.timeSinceLevelLoad);

                for(int i = 0; i< renderers.Length; i++)
                {
                    renderers[i].material = this.explosionMat;
                }

                this.isClicked = true;
            }
        }
    }

}
