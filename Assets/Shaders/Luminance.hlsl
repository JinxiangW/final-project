void Luminance_float(float3 color, out float luminance)
{
    luminance = dot(color, float3(0.2126, 0.7152, 0.0722));
}