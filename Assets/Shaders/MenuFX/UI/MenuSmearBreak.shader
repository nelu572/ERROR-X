Shader "ERROR-X/MenuFX/Smear Break"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _Break ("Break Amount", Range(0, 1)) = 0
        _Smear ("Smear Distance", Range(0, 0.15)) = 0.035
        _ShardScale ("Shard Scale", Range(8, 160)) = 48
        _StripJitter ("Strip Jitter", Range(0, 0.2)) = 0.03
        _TrailSoftness ("Trail Softness", Range(0.2, 4)) = 1.25
        _EdgeBoost ("Edge Boost", Range(0, 2)) = 0.7
        _Speed ("Animation Speed", Range(0, 8)) = 1.5

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
            float _Break;
            float _Smear;
            float _ShardScale;
            float _StripJitter;
            float _TrailSoftness;
            float _EdgeBoost;
            float _Speed;
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
                float t = _Time.y * _Speed;
                float2 cellUv = input.uv * _ShardScale;
                float2 cellId = floor(cellUv);
                float2 cellFrac = frac(cellUv);

                float shardNoise = Noise21(cellId + float2(t * 0.6, t * 0.18));
                float survive = step(_Break, shardNoise);
                float shardBreak = saturate((_Break - shardNoise + 0.18) * 2.6);

                float strip = floor(input.uv.y * (_ShardScale * 0.75 + 8.0));
                float jitter = (Hash11(strip + floor(t * 10.0)) - 0.5) * _StripJitter * _Break;
                float smearDir = sign(Hash11(cellId.x + cellId.y * 13.37) - 0.5);
                float2 offsetUv = input.uv;
                offsetUv.x += jitter + smearDir * shardBreak * _Smear;

                half4 baseTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, offsetUv) * input.color;

                float trailMask = pow(saturate(shardBreak * 1.35), max(_TrailSoftness, 0.2));
                float2 trailUv = offsetUv;
                trailUv.x -= smearDir * (_Smear * (1.5 + trailMask));
                half4 trailTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, trailUv) * input.color;

                float edge = smoothstep(0.18, 0.0, abs(cellFrac.x - 0.5) + abs(cellFrac.y - 0.5));
                float edgeGlow = shardBreak * edge * _EdgeBoost;

                float3 baseGray = ToGrayscale(baseTex.rgb);
                float3 trailGray = ToGrayscale(trailTex.rgb) * (0.45 + trailMask * 0.55 + edgeGlow);
                float3 combined = max(baseGray * survive, trailGray * trailMask);

                half alpha = max(baseTex.a * survive, trailTex.a * trailMask * 0.8);
                alpha *= saturate(1.0 - shardBreak * 0.35);

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
