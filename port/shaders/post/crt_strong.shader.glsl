@prism(type='fragment', name='PaperBoat CRT (strong)', version='1.0.0', description='Pronounced CRT look: deep scanlines, aperture mask, vignette and slight screen curvature. One texture fetch per pixel.', author='PaperBoat Switch')

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
    const float kScanStrength = 0.55;
    const float kMaskStrength = 0.18;
    const float kVignette = 0.25;
    const float kCurvature = 0.035;

    @include("shaders/post/crt_common.glsli")
@end
