#version 120varying vec4 albedo;varying vec4 diffuse;varying vec4 specular;varying vec4 pos;varying vec3 normal;varying float depth;
varying float specularIntensity;varying float depthIntensity;
varying vec3 DiffuseColor;
varying vec3 Normal;varying vec3 EyeDir;varying float LightIntensity;

const vec3 Xunitvec = vec3(1.0, 0.0, 0.0);const vec3 Yunitvec = vec3(0.0, 1.0, 0.0);uniform vec3 BaseColor;uniform float MixRatio;uniform sampler2D EnvMap; // = 4
void main(){	gl_FragData[0] = pos;	gl_FragData[1] = vec4(normal.x * 0.5f + 0.5f, normal.y * 0.5f + 0.5f, normal.z * 0.5f + 0.5f, depth );

	// get the final color
	vec4 finalColor = gl_Color;

	// add specular
	finalColor.rgb *= .5 + specularIntensity;

	// make depth to dust
	// finalColor.rgb *= depth*.1
	
	// add spherical harmonics lighting
	finalColor.rgb *= DiffuseColor;

	// environment texture
	// Compute reflection vector	vec3 reflectDir = reflect(EyeDir, Normal);	// Compute altitude and azimuth angles	vec2 index;	index.t = dot(normalize(reflectDir), Yunitvec);	reflectDir.y = 0.0;	index.s = dot(normalize(reflectDir), Xunitvec) * 0.5;	// Translate index values into proper range	if (reflectDir.z >= 0.0)		index = (index + 1.0) * 0.5;	else	{		index.t = (index.t + 1.0) * 0.5;		index.s = (-index.s) * 0.5 + 1.0;	}	// if reflectDir.z >= 0.0, s will go from 0.25 to 0.75	// if reflectDir.z < 0.0, s will go from 0.75 to 1.25, and	// that's OK, because we've set the texture to wrap.	// Do a lookup into the environment map.	vec3 envColor = vec3(texture2D(EnvMap, index));	// Add lighting to base color and mix	vec3 base = vec3(1.0, 1.0, 1.0);// LightIntensity;// * BaseColor;
	float MixRatio = 0.5;	envColor = mix(envColor, base, MixRatio);
   	
	finalColor.rgb *= envColor;

	gl_FragData[2] = finalColor;}