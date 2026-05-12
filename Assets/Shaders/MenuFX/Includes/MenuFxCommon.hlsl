#ifndef ERRORX_MENU_FX_COMMON_INCLUDED
#define ERRORX_MENU_FX_COMMON_INCLUDED

inline float Hash11(float p)
{
    p = frac(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return frac(p);
}

inline float Hash21(float2 p)
{
    float3 p3 = frac(float3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return frac((p3.x + p3.y) * p3.z);
}

inline float Noise21(float2 p)
{
    float2 i = floor(p);
    float2 f = frac(p);

    float a = Hash21(i);
    float b = Hash21(i + float2(1.0, 0.0));
    float c = Hash21(i + float2(0.0, 1.0));
    float d = Hash21(i + float2(1.0, 1.0));

    float2 u = f * f * (3.0 - 2.0 * f);
    return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
}

inline float Luma(float3 color)
{
    return dot(color, float3(0.299, 0.587, 0.114));
}

inline float3 ToGrayscale(float3 color)
{
    return Luma(color).xxx;
}

inline float2 PixelateUV(float2 uv, float2 texelSize, float scale)
{
    float safeScale = max(scale, 1.0);
    float2 pixelSize = texelSize * safeScale;
    return (floor(uv / pixelSize) + 0.5) * pixelSize;
}

inline float Quantize(float value, float steps)
{
    float safeSteps = max(steps, 2.0);
    return floor(saturate(value) * (safeSteps - 1.0) + 0.5) / (safeSteps - 1.0);
}

inline float Bayer4x4(float2 pixelCoord)
{
    int2 p = int2(pixelCoord) & 3;
    static const float bayer[16] =
    {
        0.0, 8.0, 2.0, 10.0,
        12.0, 4.0, 14.0, 6.0,
        3.0, 11.0, 1.0, 9.0,
        15.0, 7.0, 13.0, 5.0
    };

    return bayer[p.x + p.y * 4] / 16.0;
}

inline half ApplyUIClipRect(half alpha, float2 localPosition, float4 clipRect)
{
    float2 inside = step(clipRect.xy, localPosition) * step(localPosition, clipRect.zw);
    return alpha * inside.x * inside.y;
}

#endif
