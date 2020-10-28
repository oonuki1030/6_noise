Shader "Unlit/ObjShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal map", 2D) = "bump" {}
        _AOMap ("AO map", 2D) = "bump" {}
        _RoughnessMap ("Roughness map", 2D) = "bump" {}
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _Threshold("Threshold", Range(-1.0, 1.0)) = -1.0
        _GradetionTex("Gradetion Texture", 2D) = "white" {}
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                half3 tspace0 : TEXCOORD2;
                half3 tspace1 : TEXCOORD3;
                half3 tspace2 : TEXCOORD4;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            sampler2D _AOMap;
            sampler2D _RoughnessMap;
            sampler2D _NoiseTex;
            sampler2D _GradetionTex;
            float _Threshold;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);

                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
                half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                half3 wBitangent = cross(worldNormal, wTangent) * tangentSign;
                o.tspace0 = half3(wTangent.x, wBitangent.x, worldNormal.x);
                o.tspace1 = half3(wTangent.y, wBitangent.y, worldNormal.y);
                o.tspace2 = half3(wTangent.z, wBitangent.z, worldNormal.z);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture

                half3 tnormal = UnpackNormal(tex2D(_NormalMap, i.uv));
                half3 worldNormal;
                worldNormal.x = dot(i.tspace0, tnormal);
                worldNormal.y = dot(i.tspace1, tnormal);
                worldNormal.z = dot(i.tspace2, tnormal);

                //光の計算
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float luminance = saturate(dot(worldNormal, lightDir));
                fixed4 decal = tex2D(_MainTex, i.uv);
                fixed AO = tex2D(_AOMap, i.uv).x;
                fixed roughness = tex2D(_RoughnessMap, i.uv).x;
                // 適当に物体の表面の色を付ける
                fixed4 col = decal * AO * (luminance * roughness * 3.0 + 0.5);

                // ノイズを使って、ディゾルブしよう
                float fbm = tex2D(_NoiseTex, i.uv) + _Threshold;
                fbm += frac(_Time.x) * 2.0 - 1.0;
                if (1.0 < fbm)discard;
                float4 gradetion = tex2D(_GradetionTex, float2(fbm, 0));
                col = lerp(col, gradetion, max(0.0, fbm));

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
