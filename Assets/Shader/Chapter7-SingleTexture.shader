// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unity Shaders Book/Chapter 7/Single Texture"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
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
            
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Specular;
            float _Gloss;


            struct a2v {
                float4 vertex: POSITION;
                float3 normal : NORMAL;
                float4 texcoord: TEXCOORD0;
            };
            struct v2f {
                float4 pos: SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
                fixed3 worldPos: TEXCOORD1;
                float2 uv: TEXCOORD2;
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
                // 考虑变换获得真实的uv坐标
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                
                return o;
            }

            fixed4 frag(v2f i): SV_Target {

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                float3 worldNormal = i.worldNormal;
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLight));

                
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 halfDir = normalize(worldLight + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, worldNormal)), _Gloss);

                fixed3 outColor = ambient + diffuse + specular;
                return fixed4(outColor, 1.0);
            }

            ENDCG
        }
    }
}
