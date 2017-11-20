Shader "chenjd/SnowTrackShader" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_SnowTrackTex ("SnowTrackTex", 2D) = "white" {}
		_NormalMap ("NormalMap", 2D) = "bump" {}
		_SnowTrackFactor("SnowTrackFactor", float) = 0
	}

	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard addshadow fullforwardshadows vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _SnowTrackTex;
		sampler2D _NormalMap;

		float _SnowTrackFactor;

		struct Input {
			float2 uv_MainTex;
		};

		void vert(inout appdata_full vertex)
		{
			vertex.vertex.y -= tex2Dlod(_SnowTrackTex, float4(vertex.texcoord.xy, 0, 0)).r * _SnowTrackFactor;
		}


		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}



