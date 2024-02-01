Shader "Unity Shaders Book/Chapter 7/Normal Map World Space"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Range(0,2) ) = 1.0
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 256) )= 20
    }
    SubShader
    {
        // 在切线空间中计算凹凸贴图

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
            
            sampler2D _BumpMap;
            float4 _BumpMap_ST;

            float _BumpScale;

            fixed4 _Specular;
            float _Gloss;


            struct a2v {
                float4 vertex: POSITION;
                float3 normal : NORMAL;
                float4 tangent: TANGENT; // 告诉unity填充顶点的法线
                float4 texcoord: TEXCOORD0;
            };
            struct v2f {
                float4 pos: SV_POSITION;
                float4 uv: TEXCOORD0;
                float4 ToW0: TEXCOORD1;
                float4 ToW1: TEXCOORD2;
                float4 ToW2: TEXCOORD3;
                // 矩阵的第四行是0 0 0 1所以不用存
                // 实际上我们还需要世界空间的坐标以计算光线方向和视角方向
                // 但是由于toW的最后一列也是0 0 0 1，所以我们把worldpos的xyz藏在ToW的每一行的最后
            };

            // 在顶点着色器中进行计算
            v2f vert(a2v v) {
                v2f o;
                // 屏幕空间位置
                o.pos = UnityObjectToClipPos(v.vertex);
                // 由于在切线空间计算，不需要世界空间
                // 世界空间法线
                // o.worldNormal = normalize(mul(normalize(v.normal), (float3x3)unity_WorldToObject));
                // 世界空间位置
                // o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                // 考虑变换获得真实的uv坐标
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

                // 现在是在世界空间计算凹凸贴图，而不是切线空间了
                // // 计算模型空间到切线空间矩阵
                // float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
                // float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
                // 把光线转化到切线空间
                // o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                // 把视线方向转化到切线空间
                // o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;


                // 我们需要世界空间的坐标\
                // unity_ObjectToWorld是个矩阵，而不是函数
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                
                
                // 计算切线空间到世界空间的转换矩阵，我们要把切线空间表示的法线转换到世界空间
                // 先写出切线空间的坐标轴在世界空间的表示
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 wworldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
                // 把向量拼成矩阵，同时注意把位置藏进去
                o.ToW0 = float4(worldTangent.x, wworldBinormal.x, worldNormal.x, worldPos.x);
                o.ToW1 = float4(worldTangent.y, wworldBinormal.y, worldNormal.y, worldPos.y);
                o.ToW2 = float4(worldTangent.z, wworldBinormal.z, worldNormal.z, worldPos.z);
                
                return o;
            }

            fixed4 frag(v2f i): SV_Target {

                fixed3 worldPos = fixed3(i.ToW0.w, i.ToW1.w, i.ToW2.w); 
                
                // 计算世界空间的光和视线，而不是切线空间了
                // fixed3 tangentLightDir = normalize(i.lightDir);
                // fixed3 tangentViewDir = normalize(i.viewDir);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                // 采样贴图得到的是压缩的法线
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                fixed3 tangentNormal = UnpackNormal(packedNormal);
                // _BumpScale是额外添加的控制强度的变量
                tangentNormal.xy *= _BumpScale;
                // 纹理只存了xy，用模长为1去计算z
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                // 把切线空间的法线转为世界空间
                fixed3 worldNormal = normalize(half3(dot(i.ToW0.xyz, tangentNormal), dot(i.ToW1.xyz, tangentNormal), dot(i.ToW2.xyz, tangentNormal)));

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                // float3 worldNormal = i.worldNormal;
                // fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, lightDir));

                // view已经算好了
                // fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, worldNormal)), _Gloss);

                fixed3 outColor = ambient + diffuse + specular;
                return fixed4(outColor, 1.0);
            }

            ENDCG
        }
    }
}
