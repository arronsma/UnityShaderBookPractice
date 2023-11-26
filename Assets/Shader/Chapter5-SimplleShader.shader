// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 5/Simple Shader" {
    SubShader{
        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            // 简单的vertex shader和 fragment shader
            //float4 vert(float4 v : POSITION) : SV_Position
            //{
            //    return UnityObjectToClipPos(v);
            //}
            //fixed4 frag() : SV_Target {
            //    return fixed4(1.0, 1.0, 1.0, 1.0);
            //}

            // 顶点着色器输入
            struct  a2v {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float4 texcoord: TEXCOORD0;
            };

            // 顶点着色器输出
            struct v2f {
                float4 pos: SV_POSITION;
                fixed3 color: COLOR;
            };

            v2f vert (a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
                return o;
            }

            fixed4 frag(v2f i):SV_Target {
                return fixed4(i.color, 1.0);
            }


            ENDCG
        }
    }

}