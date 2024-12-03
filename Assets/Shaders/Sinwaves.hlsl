float sinWave(float t, float amplitude, float frequency, float phase)
{
    return amplitude * sin(2 * 3.14159265359 * frequency * t + phase);
}

void Sinwaves_float(float3 worldPos, float time, float amplitude, out float3 offset)
{
    // horizontal waves that consists of different frequencies, amplitues and phases
    float wave1 = sinWave(worldPos.x, 1.0, 1.0, time);
    float wave2 = sinWave(worldPos.x, 0.5, 2.0, time + 1.0);
    float wave3 = sinWave(worldPos.x, 0.25, 4.0, time + 2.0);
    float wave4 = sinWave(worldPos.x, 0.125, 8.0, time + 3.0);

    // vertical waves that consists of different frequencies, amplitues and phases
    float wave5 = sinWave(worldPos.z, 1.0, 1.0, time + 4.0);
    float wave6 = sinWave(worldPos.z, 0.5, 2.0, time + 5.0);
    float wave7 = sinWave(worldPos.z, 0.25, 4.0, time + 6.0);
    float wave8 = sinWave(worldPos.z, 0.125, 8.0, time + 7.0);

    // combine all waves
    offset = float3(0, wave1 + wave2 + wave3 + wave4 + wave5 + wave6 + wave7 + wave8, 0) / 3.75 * amplitude;
}