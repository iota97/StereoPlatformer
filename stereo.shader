// Place a MeshInstance (Quad) with this material in front of the camera

shader_type spatial;
render_mode unshaded, depth_test_disable, depth_draw_never;

// https://www.shadertoy.com/view/ldGfDG
// https://www.shadertoy.com/view/4djSRW
// http://www.techmind.org/stereo/stech.html

const float XDPI = 200.;
const float EYE_SEP = XDPI*5.0;
const float OBS_DIST = XDPI*12.;
const float BASE_DEPTH = 150.;
const float BASE_SEP = EYE_SEP*BASE_DEPTH/(BASE_DEPTH + OBS_DIST);

float depthMap(vec2 coord, sampler2D d, mat4 m) {
	float depth = textureLod(d, coord, 0.0).r;
	vec4 upos = m * vec4(coord * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
	vec3 pixel_position = upos.xyz / upos.w;
	float z = (1.0 - pixel_position.z) * 0.5;
	return BASE_DEPTH + 20. * z;
}

void fragment() {
	vec2 currCoord = SCREEN_UV*1024.0;
	for(int i = 0; i < 64; i++) {
		float depth = depthMap(currCoord/1024.0, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		float sep = EYE_SEP*depth/(depth + OBS_DIST);
		sep = floor(sep);
		if(sep < 1.0 || currCoord.x < 0.0)
			break;
		currCoord.x -= sep;
		currCoord.x = floor(currCoord.x);
	}
	vec2 p = currCoord * 1024.0 + TIME;
	vec3 p3  = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 19.19);
	ALBEDO = vec3(fract((p3.x + p3.y) * p3.z));
}
