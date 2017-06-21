﻿Shader "Custom/CubeGeometryRenderingPerFaceRendering"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Size("Size of Cube", Range(0,10)) = 0.5
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
			};

			struct v2g
			{
				float2 uv : TEXCOORD0;
				float4 color : TEXCOORD1;
				float4 vertex : SV_POSITION;
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
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.color = tex2Dlod(_MainTex, float4(o.uv,0,0));
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			[maxvertexcount(24)]
			void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream )
			{
				float4 v0 = IN[0].vertex;
				float4 v1 = IN[1].vertex;
				float4 v2 = IN[2].vertex;

				float4 center = (v0 + v1 + v2) / 3;

				float4x4 vp = mul(UNITY_MATRIX_MVP, unity_WorldToObject);

				float4 side = float4(1, 0, 0, 0) * _Size;
				float4 up = float4(0, 1, 0, 0) * _Size;
				float4 back = float4(0, 0, 1, 0) * _Size;

				g2f pIn;

				pIn.vertex = mul(vp, center + side - up + back);
				pIn.color = IN[0].color;
				pIn.normal = normalize(back);
				triStream.Append(pIn);
				
				pIn.vertex = mul(vp, center + side + up + back);
				pIn.color = IN[1].color;
				pIn.normal = normalize(back);
				triStream.Append(pIn);

				pIn.vertex = mul(vp, center - side - up + back);
				pIn.color = IN[2].color;
				pIn.normal = normalize(back);
				triStream.Append(pIn);

				//----------------- tri

				pIn.vertex = mul(vp, center - side + up + back);
				pIn.color = IN[2].color;
				pIn.normal = normalize(back);
				triStream.Append(pIn);

				triStream.RestartStrip();


				//----------------- tri strip

				pIn.vertex = mul(vp, center + side - up - back);
				pIn.color = IN[0].color;
				pIn.normal = -normalize(back);
				triStream.Append(pIn);

				pIn.vertex = mul(vp, center - side - up - back);
				pIn.color = IN[2].color;
				pIn.normal = -normalize(back);
				triStream.Append(pIn);

				pIn.vertex = mul(vp, center + side + up - back);
				pIn.color = IN[1].color;
				pIn.normal = -normalize(back);
				triStream.Append(pIn);

				//----------------- tri

				pIn.vertex = mul(vp, center - side + up - back);
				pIn.color = IN[2].color;
				pIn.normal = -normalize(back);
				triStream.Append(pIn);

				triStream.RestartStrip();




				//----------------- tri strip

				pIn.vertex = mul(vp, center - side + up - back);
				pIn.color = IN[2].color;
				pIn.normal = normalize(up);
				triStream.Append(pIn);

				pIn.vertex = mul(vp, center - side + up + back);
				pIn.color = IN[0].color;
				pIn.normal = normalize(up);
				triStream.Append(pIn);

				pIn.vertex = mul(vp, center + side + up - back);
				pIn.color = IN[1].color;
				pIn.normal = normalize(up);
				triStream.Append(pIn);

				//----------------- tri

				pIn.vertex = mul(vp, center + side + up + back);
				pIn.color = IN[0].color;
				pIn.normal = normalize(up);
				triStream.Append(pIn);

				triStream.RestartStrip();



				//----------------- tri strip

				pIn.vertex = mul(vp, center - side - up - back);
				pIn.color = IN[2].color;
				pIn.normal = -normalize(up);
				triStream.Append(pIn);

				pIn.vertex = mul(vp, center + side - up - back);
				pIn.color = IN[1].color;
				pIn.normal = -normalize(up);
				triStream.Append(pIn);

				pIn.vertex = mul(vp, center - side - up + back);
				pIn.color = IN[0].color;
				pIn.normal = -normalize(up);
				triStream.Append(pIn);

				//----------------- tri

				pIn.vertex = mul(vp, center + side - up + back);
				pIn.color = IN[0].color;
				pIn.normal = -normalize(up);
				triStream.Append(pIn);

				triStream.RestartStrip();




				//----------------- tri strip

				pIn.vertex = mul(vp, center - side + up - back);
				pIn.color = IN[2].color;
				pIn.normal = -normalize(side);
				triStream.Append(pIn);

				pIn.vertex = mul(vp, center - side - up - back);
				pIn.color = IN[0].color;
				pIn.normal = -normalize(side);
				triStream.Append(pIn);

				pIn.vertex = mul(vp, center - side + up + back);
				pIn.color = IN[1].color;
				pIn.normal = -normalize(side);
				triStream.Append(pIn);

				//----------------- tri

				pIn.vertex = mul(vp, center - side - up + back);
				pIn.color = IN[0].color;
				pIn.normal = -normalize(side);
				triStream.Append(pIn);

				triStream.RestartStrip();



				//----------------- tri strip

				pIn.vertex = mul(vp, center + side + up - back);
				pIn.color = IN[2].color;
				pIn.normal = normalize(side);
				triStream.Append(pIn);

				pIn.vertex = mul(vp, center + side + up + back);
				pIn.color = IN[1].color;
				pIn.normal = normalize(side);
				triStream.Append(pIn);

				pIn.vertex = mul(vp, center + side - up - back);
				pIn.color = IN[0].color;
				pIn.normal = normalize(side);
				triStream.Append(pIn);

				//----------------- tri

				pIn.vertex = mul(vp, center + side - up + back);
				pIn.color = IN[0].color;
				pIn.normal = normalize(side);
				triStream.Append(pIn);

				triStream.RestartStrip();


			}
			
			fixed4 frag (g2f i) : SV_Target
			{
				float ldotn = max(dot(_WorldSpaceLightPos0, i.normal),.5);
				fixed4 col = i.color;
				col.rgb *= ldotn;
				return col;
			}
			ENDCG
		}
	}
}