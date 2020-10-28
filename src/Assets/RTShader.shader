Shader "Unlit/RTShader"
{
    Properties
    {
    }
    SubShader
    {
        Lighting Off

        Pass
        {
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 3.0


            float random2(float2 uv) 
            {
                uv = float2(dot(uv,float2(127.1,311.7)),
                           dot(uv,float2(269.5,183.3)));

                return -1.0 + 2.0 * frac(sin(uv) + 43758.5453123);
            }

            float Noise(float2 uv)
            {
                float2 p=  floor(uv);
                float2 f= frac(uv);
                float2 u = f * f * (3.0 - 2.0 * f);


                float v00 = random2(p + fixed2(0, 0));
                float v10 = random2(p + fixed2(1, 0));
                float v01 = random2(p + fixed2(0, 1));
                float v11 = random2(p + fixed2(1, 1));

                return lerp(lerp(dot(v00, f - float2(0, 0)),
                    dot(v10, f - float2(1, 0)), u.x),
                    lerp(dot(v01, f - float2(0, 1)),
                        dot(v11, f - float2(1, 1)), u.x), u.y); //* 0.5 + 0.5;
            }

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                float noise =
                    Noise(IN.globalTexcoord * 64 + _Time.y * 0.64) * 0.25 +
                    Noise(IN.globalTexcoord * 16 + _Time.y * 0.16) * 0.5 +
                    Noise(IN.globalTexcoord * 8 + _Time.y * 0.08) +
                    Noise(IN.globalTexcoord * 16 + _Time.y * 0.16) * 0.5 +
                    Noise(IN.globalTexcoord * 64 + _Time.y * 0.64) * 0.25;
                noise /= 1.0 + 0.25 + 0.25 + 0.5 + 0.5;
                noise = noise * 0.5 + 0.5;
                //noise = sin(100 * noise);
                return float4(noise, noise, noise, 1.0);
            }
            ENDCG
        }
    }
}
