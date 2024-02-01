// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shaders Book/Chapter 6/Diffuse Vertex Level"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
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
            struct a2v {
                float4 vertex: POSITION;
                float3 normal : NORMAL;
            };
            struct v2f {
                float4 pos: SV_POSITION;
                fixed3 color : COLOR;
            };

            // 在顶点着色器中进行计算
            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // 环境光相
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // 模型空间法线到世界空间的法线
                fixed3 worldNormal = normalize(mul(normalize(v.normal), (float3x3)unity_WorldToObject));
                // 光源, 假设只有单光源并且是平行光，只需要知道方向
                fixed3 worldLight =  normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.xyz * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
                o.color = ambient + diffuse;
                return o;
            }

            fixed4 frag(v2f i): SV_Target {
                return fixed4(i.color, 1.0);
            }

            ENDCG
        }
    }
}
