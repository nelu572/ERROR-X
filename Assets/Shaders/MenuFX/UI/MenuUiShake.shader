Shader "ERROR-X/MenuFX/UI Shake"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _AmplitudeX ("Amplitude X", Range(0, 0.02)) = 0.003
        _AmplitudeY ("Amplitude Y", Range(0, 0.02)) = 0.002
        _Speed ("Motion Speed", Range(0, 4)) = 0.8
        _NoiseScale ("Noise Scale", Range(0.1, 8)) = 2
        _SnapStep ("Pixel Snap Step", Range(0, 0.01)) = 0.001

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
            float _AmplitudeX;
            float _AmplitudeY;
            float _Speed;
            float _NoiseScale;
            float _SnapStep;
            CBUFFER_END

            Varyings vert(Attributes input)
            {
                Varyings output;

                float t = _Time.y * _Speed;
                float2 noiseCoord = input.positionOS.xy * _NoiseScale + float2(t, -t * 0.73);
                float2 offset = float2(
                    sin(t + noiseCoord.y * 1.7) + (Noise21(noiseCoord) - 0.5),
                    cos(t * 0.87 + noiseCoord.x * 1.9) + (Noise21(noiseCoord.yx + 9.3) - 0.5));
                offset *= float2(_AmplitudeX, _AmplitudeY);

                if (_SnapStep > 0.0)
                {
                    offset = round(offset / _SnapStep) * _SnapStep;
                }

                float3 positionOS = input.positionOS.xyz;
                positionOS.xy += offset;

                output.positionCS = TransformObjectToHClip(positionOS);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                output.color = input.color * _Color;
                output.localPos = positionOS.xy;
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                half4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv) * input.color;
                float3 gray = ToGrayscale(tex.rgb);

                half alpha = tex.a;
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
