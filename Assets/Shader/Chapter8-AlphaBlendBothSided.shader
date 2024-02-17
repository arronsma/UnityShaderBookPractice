Shader "Unity Shaders Book/Chapter 8/Aplpha Blend"
{
    Properties
    {
        _Color ("Main Tint", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _AlphaScale ("Alpha Scale", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        
        // 使用CGINCLUDE因为两个pass只有Cull不同，其他的是一样的
        CGINCLUDE
            #include "Lighting.cginc"
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaScale;
            
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos :TEXCOORD1;
                float2 uv : TEXCOORD2;

            };
            
            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 使用内置函数要注意归一化
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed4 texColor = tex2D(_MainTex, i.uv);
                
                fixed3 albedo = texColor.rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLightDir));
                
                fixed3 outColor = ambient + diffuse;
                // 输出的alpha值不再为1，而是根据主纹理加上人为缩放
                return fixed4(outColor, texColor.a * _AlphaScale);
            }
        ENDCG

        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            // 关闭深度写入和设置Blend，可以在SubShader级别操作，也可以在Pass内操作
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha 
            Cull Front
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            ENDCG
        }

        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            // 关闭深度写入和设置Blend，可以在SubShader级别操作，也可以在Pass内操作
            ZWrite          Off
            Blend SrcAlpha OneMinusSrcAlpha 
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            ENDCG
        }
    }
}
