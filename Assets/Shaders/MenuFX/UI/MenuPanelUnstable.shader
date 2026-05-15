Shader "ERROR-X/MenuFX/Panel Unstable"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _DistortionIntensity ("Distortion Intensity", Range(0, 1)) = 0.22
        _SmearStrength ("Smear Strength", Range(0, 0.08)) = 0.018
        _CorruptionAmount ("Corruption Amount", Range(0, 1)) = 0.18
        _NoiseIntensity ("Noise Intensity", Range(0, 0.15)) = 0.02
        _EdgeFade ("Edge Fade", Range(0.02, 0.45)) = 0.18
        _AnimationSpeed ("Animation Speed", Range(0, 4)) = 0.85
        _ScanOffsetStrength ("Scan Offset Strength", Range(0, 0.04)) = 0.005
        _VerticalSmear ("Vertical Smear", Range(0, 0.03)) = 0.003
        _BandingStrength ("Banding Strength", Range(0, 0.08)) = 0.012

        [HideInInspector] _StencilComp ("Stencil Comparison", Float) = 8
        [HideInInspector] _Stencil ("Stencil ID", Float) = 0
        [HideInInspector] _StencilOp ("Stencil Operation", Float) = 0
        [HideInInspector] _StencilWriteMask ("Stencil Write Mask", Float) = 255
        [HideInInspector] _StencilReadMask ("Stencil Read Mask", Float) = 255
        [HideInInspector] _ColorMask ("Color Mask", Float) = 15
        [HideInInspector] _ClipRect ("Clip Rect", Vector) = (-32767,-32767,32767,32767)
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
            "RenderPipeline"="UniversalPipeline"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend One OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/Shaders/MenuFX/Includes/MenuFxCommon.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                float2 localPos : TEXCOORD1;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_TexelSize;

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _Color;
            float4 _ClipRect;
            float _DistortionIntensity;
            float _SmearStrength;
            float _CorruptionAmount;
            float _NoiseIntensity;
            float _EdgeFade;
            float _AnimationSpeed;
            float _ScanOffsetStrength;
            float _VerticalSmear;
            float _BandingStrength;
            CBUFFER_END

            float EdgeMask(float2 uv, float fade)
            {
                float edgeDistance = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
                return pow(saturate(1.0 - edgeDistance / max(fade, 0.0001)), 1.85);
            }

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                output.color = input.color * _Color;
                output.localPos = input.positionOS.xy;
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float2 uv = input.uv;
                float t = _Time.y * _AnimationSpeed;

                float edgeMask = EdgeMask(uv, _EdgeFade);
                float burstSeed = floor(t * 0.55);
                float burst = smoothstep(0.78, 0.98, Noise21(float2(burstSeed, 4.7)));
                float microPulse = 0.65 + 0.35 * sin(t * 1.9 + uv.y * 9.0);
                float activity = _DistortionIntensity * edgeMask * lerp(0.18, 1.0, burst) * microPulse;

                float lineId = floor(uv.y / max(_MainTex_TexelSize.y, 0.00001) / 3.0);
                float lineNoise = Hash11(lineId * 0.73 + floor(t * 9.0));
                float lineTrigger = step(0.965 - _CorruptionAmount * 0.22, lineNoise) * (0.2 + 0.8 * burst);
                float scanOffset = (Hash11(lineId * 1.91 + floor(t * 13.0)) - 0.5) * _ScanOffsetStrength * lineTrigger * activity * 12.0;

                float edgeSide = sign(uv.x - 0.5);
                float stretchMask = smoothstep(0.25, 1.0, edgeMask) * activity;
                float stretch = edgeSide * stretchMask * _SmearStrength * (0.45 + burst * 0.55);
                float vSmear = (Noise21(float2(lineId * 0.11, floor(t * 5.0))) - 0.5) * _VerticalSmear * stretchMask;

                float2 distortedUv = uv;
                distortedUv.x += stretch + scanOffset;
                distortedUv.y += vSmear;

                float2 blockCoord = floor(uv / max(_MainTex_TexelSize.xy * 4.0, float2(0.0001, 0.0001)));
                float blockNoise = Hash21(blockCoord * 0.17 + floor(t * 2.0));
                float corruptionMask = step(1.0 - _CorruptionAmount * 0.16, blockNoise) * edgeMask * (0.3 + 0.7 * burst);
                float2 blockShift = (float2(Hash21(blockCoord + 2.7), Hash21(blockCoord + 8.4)) - 0.5) * _MainTex_TexelSize.xy * 6.0 * corruptionMask;
                distortedUv += float2(blockShift.x, blockShift.y * 0.35);

                half4 baseTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, distortedUv) * input.color;

                float2 smearUv = distortedUv;
                smearUv.x -= edgeSide * _SmearStrength * (1.6 + edgeMask * 1.2);
                half4 smearTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, smearUv) * input.color;

                float smearAlpha = stretchMask * (0.35 + 0.45 * burst);
                float3 baseGray = ToGrayscale(baseTex.rgb);
                float3 smearGray = ToGrayscale(smearTex.rgb);
                float3 combined = lerp(baseGray, max(baseGray, smearGray * 0.92), smearAlpha);

                float dissolveNoise = Noise21(blockCoord * 0.09 + float2(t * 0.23, -t * 0.11));
                float dissolve = step(dissolveNoise, edgeMask * _CorruptionAmount * (0.22 + burst * 0.5));
                dissolve *= smoothstep(0.35, 1.0, edgeMask);

                float clipNoise = step(0.992 - _CorruptionAmount * 0.05, Hash21(blockCoord + floor(t * 3.0)));
                float alphaMask = 1.0 - saturate(dissolve * 0.55 + clipNoise * corruptionMask * 0.85);

                float staticNoise = (Noise21(uv * 220.0 + float2(0.0, t * 8.0)) - 0.5) * _NoiseIntensity;
                float banding = sin((uv.y + t * 0.04) * 90.0) * _BandingStrength * (0.3 + 0.7 * edgeMask);
                combined += (staticNoise + banding).xxx;

                half alpha = baseTex.a * alphaMask;
                alpha = max(alpha, smearTex.a * smearAlpha * 0.22);
                alpha *= saturate(1.0 - dissolve * 0.35);

                #ifdef UNITY_UI_CLIP_RECT
                alpha = ApplyUIClipRect(alpha, input.localPos, _ClipRect);
                #endif

                half4 finalColor = half4(saturate(combined), alpha);
                finalColor.rgb *= finalColor.a;
                return finalColor;
            }
            ENDHLSL
        }
    }
}
