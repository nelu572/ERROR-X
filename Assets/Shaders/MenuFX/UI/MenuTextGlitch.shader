Shader "ERROR-X/MenuFX/Text Glitch"
{
    Properties
    {
        [PerRendererData] _MainTex ("Font Atlas", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _GlyphOffset ("Glyph Offset", Range(0, 0.03)) = 0.008
        _Intermittency ("Intermittency", Range(0, 1)) = 0.12
        _ScanShift ("Scan Shift", Range(0, 0.02)) = 0.004
        _ClipChance ("Clip Chance", Range(0, 1)) = 0.08
        _StripFrequency ("Row Frequency", Range(8, 320)) = 110

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

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _Color;
            float4 _ClipRect;
            float _GlyphOffset;
            float _Intermittency;
            float _ScanShift;
            float _ClipChance;
            float _StripFrequency;
            CBUFFER_END

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
                float t = _Time.y;
                float row = floor(input.uv.y * _StripFrequency);
                float active = step(1.0 - _Intermittency, Hash11(row + floor(t * 13.0)));
                float offset = (Hash11(row * 2.19 + floor(t * 17.0)) - 0.5) * _GlyphOffset * active;
                float scan = sin((input.uv.y + t * 0.6) * 140.0) * _ScanShift;

                float2 uv = input.uv + float2(offset + scan, 0.0);
                half4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv) * input.color;

                float clipBand = step(_ClipChance, Hash11(row * 0.77 + floor(t * 9.0)));
                half alpha = tex.a * lerp(clipBand, 1.0, 1.0 - active * 0.65);
                #ifdef UNITY_UI_CLIP_RECT
                alpha = ApplyUIClipRect(alpha, input.localPos, _ClipRect);
                #endif

                float3 gray = ToGrayscale(tex.rgb);
                half4 finalColor = half4(gray, alpha);
                finalColor.rgb *= finalColor.a;
                return finalColor;
            }
            ENDHLSL
        }
    }
}
