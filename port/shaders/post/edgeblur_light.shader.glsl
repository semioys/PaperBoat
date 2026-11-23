@prism(type='fragment', name='PaperBoat Edge Blur (light)', version='1.0.0', description='Tilt-shift style blur towards the top and bottom of the screen (less on the sides); the centre stays sharp.', author='PaperBoat Switch')

@{GLSL_VERSION}

@if(VERTEX_SHADER)
    @include("shaders/opengl/include/fast3d_vs.glsli")

@else
    @if(core_opengl || opengles)
    out vec4 vOutColor;
    @end

    @{attr} vec2 vTexCoord0;

    uniform sampler2D uTex0;

    // Tuning for this variant.
    const float kStart = 0.45;      // where the blur begins: 0 = centre, 1 = screen edge
    const float kMaxRadius = 4.0;   // blur radius at the very edge, in pixels at 720p
    const float kSideWeight = 0.55; // left/right edges blur less than top/bottom

    void main() {
        vec2 uv = vTexCoord0;
        vec3 sharp = @{texture}(uTex0, uv).rgb;

        vec2 fromCentre = abs(uv - 0.5) * 2.0;
        float dist = max(fromCentre.y, fromCentre.x * kSideWeight);
        float amount = smoothstep(kStart, 1.0, dist);
        if (amount < 0.02) {
            // Sharp area: a single fetch.
            @{vOutColor} = vec4(sharp, 1.0);
            return;
        }

        vec2 size = vec2(textureSize(uTex0, 0));
        vec2 radius = vec2(amount * kMaxRadius * (size.y / 720.0)) / size;

        // 12 taps on a golden-angle spiral filling the disc.
        vec3 sum = sharp;
        for (int i = 0; i < 12; i++) {
            float fi = float(i) + 0.5;
            float r = sqrt(fi / 12.0);
            float a = fi * 2.3999632;
            sum += @{texture}(uTex0, uv + vec2(cos(a), sin(a)) * r * radius).rgb;
        }
        vec3 blurred = sum / 13.0;
        @{vOutColor} = vec4(mix(sharp, blurred, smoothstep(0.0, 0.5, amount)), 1.0);
    }
@end
