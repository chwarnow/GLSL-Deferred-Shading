#version 120
varying float specularIntensity;
varying vec3 DiffuseColor;
varying vec3 Normal;

const vec3 Xunitvec = vec3(1.0, 0.0, 0.0);


	// get the final color
	vec4 finalColor = gl_Color;

	// add specular
	finalColor.rgb *= .5 + specularIntensity;

	// make depth to dust
	// finalColor.rgb *= depth*.1
	
	// add spherical harmonics lighting
	finalColor.rgb *= DiffuseColor;

	// environment texture
	// Compute reflection vector
	float MixRatio = 0.5;
   	
	finalColor.rgb *= envColor;

	gl_FragData[2] = finalColor;