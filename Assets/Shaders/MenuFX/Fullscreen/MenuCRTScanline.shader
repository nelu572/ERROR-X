Shader "ERROR-X/MenuFX/CRT Scanline"
{
    Properties
    {
        _Brightness ("Brightness", Range(0.5, 1)) = 0.88
        _ScanlineDensity ("Scanline Density", Range(120, 1200)) = 420
        _ScanlineStrength ("Scanline Strength", Range(0, 0.25)) = 0.075
        _VignetteStrength ("Vignette Strength", Range(0, 0.4)) = 0.16
        _Curvature ("Screen Curvature", Range(0, 0.08)) = 0.015
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
        ZWrite Off
        ZTest Always
        Cull Off

        Pass
        {
            Name "CRTScanlinePass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
            #include "Assets/Shaders/MenuFX/Includes/MenuFxCommon.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float _Brightness;
            float _ScanlineDensity;
            float _ScanlineStrength;
            float _VignetteStrength;
            float _Curvature;
            CBUFFER_END

            float2 WarpUv(float2 uv, float curvature)
            {
                float2 centered = uv * 2.0 - 1.0;
                float2 warped = centered * (1.0 + dot(centered, centered) * curvature);
                return warped * 0.5 + 0.5;
            }

            half4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = WarpUv(input.texcoord.xy, _Curvature);
                half4 source = SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_LinearClamp, uv, _BlitMipLevel);

                float3 gray = ToGrayscale(source.rgb);
                float scan = sin(uv.y * _ScanlineDensity) * 0.5 + 0.5;
                float scanMask = 1.0 - scan * _ScanlineStrength;

                float2 vignetteUv = uv * (1.0 - uv.yx);
                float vignetteBase = saturate(vignetteUv.x * vignetteUv.y * 24.0);
                float vignette = pow(vignetteBase, 0.22);
                vignette = lerp(1.0 - _VignetteStrength, 1.0, vignette);

                float edgeMask = step(0.0, uv.x) * step(uv.x, 1.0) * step(0.0, uv.y) * step(uv.y, 1.0);
                float3 finalRgb = gray * _Brightness * scanMask * vignette * edgeMask;

                return half4(finalRgb, source.a);
            }
            ENDHLSL
        }
    }
}
