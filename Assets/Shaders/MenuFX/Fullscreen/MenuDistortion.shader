Shader "ERROR-X/MenuFX/Distortion"
{
    Properties
    {
        _BaseStrength ("Base Strength", Range(0, 0.05)) = 0.006
        _EventStrength ("Event Strength", Range(0, 0.2)) = 0
        _HorizontalWarp ("Horizontal Warp", Range(0, 0.05)) = 0.01
        _RippleFrequency ("Ripple Frequency", Range(1, 48)) = 14
        _RippleSpeed ("Ripple Speed", Range(0, 6)) = 1.2
        _Center ("Ripple Center", Vector) = (0.5, 0.5, 0, 0)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
        ZWrite Off
        ZTest Always
        Cull Off

        Pass
        {
            Name "DistortionPass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
            #include "Assets/Shaders/MenuFX/Includes/MenuFxCommon.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float _BaseStrength;
            float _EventStrength;
            float _HorizontalWarp;
            float _RippleFrequency;
            float _RippleSpeed;
            float4 _Center;
            CBUFFER_END

            half4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = input.texcoord.xy;
                float t = _Time.y * _RippleSpeed;
                float2 center = _Center.xy;
                float2 delta = uv - center;
                float distanceToCenter = length(delta);

                float ripple = sin(distanceToCenter * _RippleFrequency - t * 6.0);
                float horizontal = sin((uv.y + t * 0.07) * 22.0) * _HorizontalWarp;
                float eventEnvelope = saturate(_EventStrength);
                float strength = _BaseStrength + eventEnvelope * 0.5 * _BaseStrength + eventEnvelope * 0.03;

                float2 offset = float2(horizontal, 0.0);
                if (distanceToCenter > 0.0001)
                {
                    offset += normalize(delta) * ripple * strength * (0.35 + eventEnvelope);
                }

                float2 distortedUv = uv + offset;
                half4 source = SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_LinearClamp, distortedUv, _BlitMipLevel);
                source.rgb = ToGrayscale(source.rgb);
                return source;
            }
            ENDHLSL
        }
    }
}
