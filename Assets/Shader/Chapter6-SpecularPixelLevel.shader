// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unity Shaders Book/Chapter 6/Specular Pixel Level"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 256) )= 20
    }
    SubShader
    {
        

        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Lighting.cginc"
            
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;


            struct a2v {
                float4 vertex: POSITION;
                float3 normal : NORMAL;
            };
            struct v2f {
                float4 pos: SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
                fixed3 worldPos: TEXCOORD1;
            };

            // 在顶点着色器中进行计算
            v2f vert(a2v v) {
                v2f o;
                // 屏幕空间位置
                o.pos = UnityObjectToClipPos(v.vertex);
                // 世界空间法线
                o.worldNormal = normalize(mul(normalize(v.normal), (float3x3)unity_WorldToObject));
                // 世界空间位置
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i): SV_Target {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                float3 worldNormal = i.worldNormal;
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));

                fixed3 reflectDir = normalize(reflect(-worldLight, i.worldNormal));
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

                fixed3 outColor = ambient + diffuse + specular;
                return fixed4(outColor, 1.0);
            }

            ENDCG
        }
    }
}
