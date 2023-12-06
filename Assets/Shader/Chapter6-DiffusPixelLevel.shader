Shader "Unity Shaders Book/Chapter 6/Diffuse Pixel Level"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }
        Pass
        {
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #include "Lighting.cginc"
            fixed4 _Diffuse;
            struct a2v 
            {
                float4 vertex:  POSITION;
                float3 normal:  NORMAL;
            };

            struct v2f
            {
                // screen position
                float4 pos: SV_POSITION;
                float3 worldNormal: TEXCOORD0;
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(mul(normalize(v.normal), (float3x3)unity_WorldToObject));
                return o;
            }

            fixed4  frag(v2f i): SV_Target {

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                float3 worldNormal = i.worldNormal;
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
                fixed3 outColor = ambient + diffuse;
                return fixed4(outColor, 1.0);
            }  
            ENDCG
        }
    }
}
