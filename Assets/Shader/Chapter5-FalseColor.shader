Shader "Unity Shaders Book/Chapter 5/False Color"
{
    
    SubShader
    {
      Pass {
        CGPROGRAM
        
        #pragma vertex vert
        #pragma fragment frag

        #include "UnityCG.cginc"

        struct v2f {
            float4 pos: SV_POSITION;
            fixed4 color : COLOR0;
        };

        // appdata_full������UnityCG.cginc����
        v2f vert (appdata_full v) {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);

            // ���ӻ�����
            o.color = fixed4(v.normal * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);

            // ���ӻ����߷���
            o.color = fixed4(v.tangent.xyz * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);
            return o;
        }

        fixed4 frag(v2f i): SV_Target {
            return i.color;
        }
        ENDCG
      }
        
    }
    
}
