//
// created by jiadong chen
// http://www.chenjd.me
//


Shader "chenjd/OutlineShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_OutlineFactor("Outline Factor", Range(0, 6)) = 3
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		// 第一个pass用来渲染正常的模型
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}

		//第二个pass渲染轮廓
		Pass
		{
			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"



			float _OutlineFactor;
			fixed4 _OutlineColor;

			float4 vert(appdata_base v) : SV_POSITION
			{

				float4 pos = UnityObjectToClipPos(v.vertex);

				float3 normal = mul((float3x3) UNITY_MATRIX_MVP, v.normal);

				pos.xy += _OutlineFactor * normal.xy;

				return pos;

			}


			fixed4 frag() : SV_Target {
				return _OutlineColor;
			}

			ENDCG
		}


	}
}
