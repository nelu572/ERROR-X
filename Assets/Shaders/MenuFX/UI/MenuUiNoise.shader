Shader "ERROR-X/MenuFX/UI Noise"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _NoiseIntensity ("Noise Intensity", Range(0, 0.2)) = 0.035
        _NoiseScale ("Noise Pixel Scale", Range(1, 16)) = 4
        _NoiseSpeed ("Noise Speed", Range(0, 4)) = 0.65
        _BandingStrength ("Vertical Banding", Range(0, 0.2)) = 0.03
        _BandingScale ("Banding Scale", Range(2, 64)) = 18

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
            float _NoiseIntensity;
            float _NoiseScale;
            float _NoiseSpeed;
            float _BandingStrength;
            float _BandingScale;
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
                float2 uv = PixelateUV(input.uv, _MainTex_TexelSize.xy, _NoiseScale);
                half4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv) * input.color;

                float3 gray = ToGrayscale(tex.rgb);
                float t = _Time.y * _NoiseSpeed;
                float noise = Noise21(uv * 256.0 + float2(0.0, t * 14.0)) - 0.5;
                float band = sin((input.uv.x + t * 0.03) * _BandingScale) * _BandingStrength;
                gray += (noise * _NoiseIntensity + band).xxx;

                half alpha = tex.a;
                #ifdef UNITY_UI_CLIP_RECT
                alpha = ApplyUIClipRect(alpha, input.localPos, _ClipRect);
                #endif

                half4 finalColor = half4(saturate(gray), alpha);
                finalColor.rgb *= finalColor.a;
                return finalColor;
            }
            ENDHLSL
        }
    }
}
