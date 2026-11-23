@prism(type='fragment', name='PaperBoat CRT (subtle)', version='1.0.0', description='Light CRT look: soft scanlines, faint aperture mask, vignette. One texture fetch per pixel.', author='PaperBoat Switch')

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
    const float kScanStrength = 0.30; // how dark the gap between scanlines gets
    const float kMaskStrength = 0.08; // RGB aperture mask depth
    const float kVignette = 0.12;     // corner darkening
    const float kCurvature = 0.0;     // barrel distortion (0 = flat)

    @include("shaders/post/crt_common.glsli")
@end
