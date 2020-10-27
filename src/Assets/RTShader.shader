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

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                float noise = 1.0;// todo: ノイズを実装して下さい
                return float4(noise, noise, noise, 1.0);
            }
            ENDCG
        }
    }
}
