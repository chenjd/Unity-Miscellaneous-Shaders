Shader "chenjd/geomShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Speed("Speed", Float) = 10
		_AccelerationValue("AccelerationValue", Float) = 10
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2g
			{
				float2 uv : TEXCOORD0;
				float4 vertex : POSITION;
			};

			struct g2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;

			float _Speed;
			float _AccelerationValue;
			float _StartTime;
			
			v2g vert (appdata v)
			{
				v2g o;
				o.vertex = v.vertex;
				o.uv = v.uv;
				return o;
			}

			[maxvertexcount(1)]
			void geom(triangle v2g IN[3], inout PointStream<g2f> pointStream)
			{
				g2f o;

				float3 v1 = IN[1].vertex - IN[0].vertex;
				float3 v2 = IN[2].vertex - IN[0].vertex;

				float3 norm = normalize(cross(v1, v2));

				float3 tempPos = (IN[0].vertex + IN[1].vertex + IN[2].vertex) / 3;

				float realTime = _Time.y - _StartTime;
				tempPos += norm * (_Speed * realTime + .5 * _AccelerationValue * pow(realTime, 2));

				o.vertex = UnityObjectToClipPos(tempPos);

				o.uv = (IN[0].uv + IN[1].uv + IN[2].uv) / 3;

				pointStream.Append(o);
			}
			
			fixed4 frag (g2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
