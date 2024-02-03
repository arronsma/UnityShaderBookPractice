Shader "Unity Shaders Book/Chapter 7/Ramp Texture"
{
    Properties
    {
        // 渐变纹理中不用漫反射贴图了
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        
        _RampTex ("Ramp tex", 2D) = "white" {}
        
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 256) )= 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            fixed4 _Color;

            sampler2D _RampTex;
            float4 _RampTex_ST;

            fixed4 _Specular;
            float _Gloss;

            #include "Lighting.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                // 我们需要计算half-Lambert光照
                float3 worldNormal:TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv: TEXCOORD2;
            };
            

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 使用内置函数要注意归一化
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                // 环境光没有使用贴图
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed halfLambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;
                // 普通 halfLambert 的做法，用于计算漫反射
                // fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;
                // 用halfLambert去采样渐变纹理
                // 定性原理：因为halfLambert的大小反映了法线的朝向，在边缘处法线朝向不同于中心，所以用不同纹理区域来控制颜色
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb;

                // 使用内置函数要记得归一化
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, worldNormal)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
                
            }
            ENDCG
        }
    }
}
