Shader "Custom/ExtrudeFace"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Size("Size of Cube", Range(0,10)) = 0.5
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase" }

		Cull Back
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2g
			{
				float4 color : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
			};

			struct g2f
			{
				float4 color : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Size;
			
			v2g vert (appdata v)
			{
				v2g o;
				o.vertex = mul(unity_ObjectToWorld,v.vertex);
				v.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = mul(v.normal, unity_WorldToObject);
				o.color = tex2Dlod(_MainTex, float4(v.uv,0,0));
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			[maxvertexcount(16)]
			void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream )
			{
				float4 v0 = IN[0].vertex;
				float4 v1 = IN[1].vertex;
				float4 v2 = IN[2].vertex;

				float3 n0 = IN[0].normal;
				float3 n1 = IN[1].normal;
				float3 n2 = IN[2].normal;

				float4 normal = float4(normalize((n0 + n1 + n2) / 3),0);
				normal = float4(normalize(cross(v1-v0, v2-v0)), 0);
				float4x4 vp = mul(UNITY_MATRIX_MVP, unity_WorldToObject);

				g2f pIn;

				pIn.vertex = mul(vp, v0 + normal * _Size);
				pIn.color = IN[0].color;
				pIn.normal = normal;
				triStream.Append(pIn);
				
				pIn.vertex = mul(vp, v1 + normal * _Size);
				pIn.color = IN[0].color;
				pIn.normal = normal;
				triStream.Append(pIn);

				pIn.vertex = mul(vp, v2 + normal * _Size);
				pIn.color = IN[0].color;
				pIn.normal = normal;
				triStream.Append(pIn);
				triStream.RestartStrip();

				//------------



			}
			
			fixed4 frag (g2f i) : SV_Target
			{
				fixed4 col = i.color;
				return col;
			}
			ENDCG
		}
	}
}
