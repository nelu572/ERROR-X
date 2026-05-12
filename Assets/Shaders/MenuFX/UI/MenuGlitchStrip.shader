Shader "ERROR-X/MenuFX/Glitch Strip"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _Intensity ("Glitch Intensity", Range(0, 0.2)) = 0.045
        _StripFrequency ("Strip Frequency", Range(8, 240)) = 72
        _TriggerRate ("Intermittency", Range(0, 1)) = 0.18
        _ArtifactStrength ("Clip Artifact Strength", Range(0, 1)) = 0.35
        _JitterSpeed ("Jitter Speed", Range(0, 8)) = 1.5

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
            float _Intensity;
            float _StripFrequency;
            float _TriggerRate;
            float _ArtifactStrength;
            float _JitterSpeed;
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
                float t = _Time.y * _JitterSpeed;
                float slice = floor(input.uv.y * _StripFrequency);
                float trigger = step(1.0 - _TriggerRate, Hash11(slice + floor(t * 6.0)));
                float offset = (Hash11(slice * 1.73 + floor(t * 11.0)) - 0.5) * _Intensity * trigger;

                float2 uv = input.uv;
                uv.x += offset;

                half4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv) * input.color;
                float3 gray = ToGrayscale(tex.rgb);

                float edgeClip = step(0.0, uv.x) * step(uv.x, 1.0);
                float artifact = lerp(1.0, edgeClip, saturate(trigger * _ArtifactStrength));

                half alpha = tex.a * artifact;
                #ifdef UNITY_UI_CLIP_RECT
                alpha = ApplyUIClipRect(alpha, input.localPos, _ClipRect);
                #endif

                half4 finalColor = half4(gray, alpha);
                finalColor.rgb *= finalColor.a;
                return finalColor;
            }
            ENDHLSL
        }
    }
}
