// This shader is converted from 
// Heartfelt(https://www.shadertoy.com/view/ltffzl) - by Martijn Steinrucken aka BigWings - 2017
// countfrolic@gmail.com
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

Shader "Custom/NoRaindrop" {
	Properties {
		iChannel0("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        Pass {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D iChannel0;

            fixed4 frag(v2f_img i) : SV_Target {
                // 直接读取传入纹理
                float2 UV = i.uv;
                float3 col = tex2D(iChannel0, UV).rgb;

                return fixed4(col, 1.0); // 输出纹理颜色
            }
            ENDCG
        }
	}
	FallBack "Diffuse"
}