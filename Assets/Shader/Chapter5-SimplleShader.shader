// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 5/Simple Shader" {
    Properties{
        // 声明_Color名称的Color类型的属性和材质交互
        _Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader{
        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            // 名称和类型相同的变量与Properties的交互
            fixed4 _Color;

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
                // return fixed4(i.color, 1.0);
                fixed3 c = i.color;
                // 在原本的颜色上加上材质color的影响
                c *= _Color.rgb;
                return fixed4(c, 1.0);
            }


            ENDCG
        }
    }

}