Shader "Custom/QuadGeometryRendering"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_PointTex("Point Texture", 2D) = "white" {}
		_Size("Size of Points", Range(0,10)) = 0.5
		_Numbers("Number Of Points", Int) = 1
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent"  "LightMode" = "ForwardBase" }

		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
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
				float2 uv : TEXCOORD0;
				float4 color : TEXCOORD1;
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
			};

			struct g2f
			{
				float2 uv : TEXCOORD0;
				float4 color : TEXCOORD1;
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
			};

			sampler2D _MainTex;
			sampler2D _PointTex;
			float4 _MainTex_ST;
			float _Size;
			int _Numbers;
			
			v2g vert (appdata v)
			{
				v2g o;
				o.vertex = mul(unity_ObjectToWorld,v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = mul(v.normal, unity_WorldToObject);
				o.color = tex2Dlod(_MainTex, float4(o.uv,0,0));
				return o;
			}

			[maxvertexcount(78)]
			void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream )
			{
				float4 v0 = IN[0].vertex;
				float4 v1 = IN[1].vertex;
				float4 v2 = IN[2].vertex;

				float3 n0 = IN[0].normal;
				float3 n1 = IN[1].normal;
				float3 n2 = IN[2].normal;

				float3 normal = normalize((n0 + n1 + n2) / 3);
				float4 center = (v0 + v1 + v2) / 3;

				//billboarding: look is the view vector, by using the cross product with the view vector and the up vector 
				float3 look = _WorldSpaceCameraPos - center;
				look = normalize(look);
				float4 right = float4(cross(float3(0, 1, 0), look),0);

				float4x4 vp = mul(UNITY_MATRIX_MVP, unity_WorldToObject);

				float4 side = right * _Size;
				float4 up = float4(0, 1, 0, 0) * _Size;


				g2f pIn;

				//Quad on the center of the triangle

				pIn.vertex = mul(vp, center + side - up);
				pIn.uv = float2(0, 0);
				pIn.color = IN[0].color;
				pIn.normal = normal;
				triStream.Append(pIn);
				
				pIn.vertex = mul(vp, center + side + up);
				pIn.uv = float2(0, 1);
				pIn.color = IN[1].color;
				pIn.normal = normal;
				triStream.Append(pIn);

				pIn.vertex = mul(vp, center - side - up);
				pIn.uv = float2(1, 0);
				pIn.color = IN[2].color;
				pIn.normal = normal;
				triStream.Append(pIn);

				pIn.vertex = mul(vp, center - side + up);
				pIn.uv = float2(1, 1);
				pIn.color = IN[2].color;
				pIn.normal = normal;
				triStream.Append(pIn);

				triStream.RestartStrip();


				//Extra quads to add more point density

				float numbersOfPoints = _Numbers;
				float ratioNumbersOfPoints = 1/ numbersOfPoints;

				float4 newCenter = ((v0 - center) * ratioNumbersOfPoints) + center;

				for (int i = 0; i < numbersOfPoints; i++) {

					pIn.vertex = mul(vp, newCenter + side - up);
					pIn.uv = float2(0, 0);
					pIn.color = IN[0].color;
					triStream.Append(pIn);

					pIn.vertex = mul(vp, newCenter + side + up);
					pIn.uv = float2(0, 1);
					pIn.color = IN[1].color;
					pIn.normal = normal;
					triStream.Append(pIn);

					pIn.vertex = mul(vp, newCenter - side - up);
					pIn.uv = float2(1, 0);
					pIn.color = IN[2].color;
					pIn.normal = normal;
					triStream.Append(pIn);

					pIn.vertex = mul(vp, newCenter - side + up);
					pIn.uv = float2(1, 1);
					pIn.color = IN[2].color;
					pIn.normal = normal;
					triStream.Append(pIn);

					triStream.RestartStrip();
					newCenter = ((v0 - center) * ratioNumbersOfPoints * (i+1)) + center;
				}

				newCenter = ((v1 - center) * ratioNumbersOfPoints) + center;
				for (int i = 0; i < numbersOfPoints; i++) {

					pIn.vertex = mul(vp, newCenter + side - up);
					pIn.uv = float2(0, 0);
					pIn.color = IN[0].color;
					triStream.Append(pIn);

					pIn.vertex = mul(vp, newCenter + side + up);
					pIn.uv = float2(0, 1);
					pIn.color = IN[1].color;
					pIn.normal = normal;
					triStream.Append(pIn);

					pIn.vertex = mul(vp, newCenter - side - up);
					pIn.uv = float2(1, 0);
					pIn.color = IN[2].color;
					pIn.normal = normal;
					triStream.Append(pIn);

					pIn.vertex = mul(vp, newCenter - side + up);
					pIn.uv = float2(1, 1);
					pIn.color = IN[2].color;
					pIn.normal = normal;
					triStream.Append(pIn);

					triStream.RestartStrip();
					newCenter = ((v0 - center) * ratioNumbersOfPoints * (i + 1)) + center;
				}

				newCenter = ((v2 - center) * ratioNumbersOfPoints) + center;
				for (int i = 0; i < numbersOfPoints; i++) {

					pIn.vertex = mul(vp, newCenter + side - up);
					pIn.uv = float2(0, 0);
					pIn.color = IN[0].color;
					triStream.Append(pIn);

					pIn.vertex = mul(vp, newCenter + side + up);
					pIn.uv = float2(0, 1);
					pIn.color = IN[1].color;
					pIn.normal = normal;
					triStream.Append(pIn);

					pIn.vertex = mul(vp, newCenter - side - up);
					pIn.uv = float2(1, 0);
					pIn.color = IN[2].color;
					pIn.normal = normal;
					triStream.Append(pIn);

					pIn.vertex = mul(vp, newCenter - side + up);
					pIn.uv = float2(1, 1);
					pIn.color = IN[2].color;
					pIn.normal = normal;
					triStream.Append(pIn);

					triStream.RestartStrip();
					newCenter = ((v0 - center) * ratioNumbersOfPoints * (i + 1)) + center;
				}
			}
			
			fixed4 frag (g2f i) : SV_Target
			{
				// sample the texture
				float ldotn = max(dot(_WorldSpaceLightPos0, i.normal),.5);
				fixed4 col = i.color * tex2D(_PointTex, i.uv);
				col.rgb *= ldotn;
				if (col.a < .5)
					discard;
				return col;
			}
			ENDCG
		}
	}
}
