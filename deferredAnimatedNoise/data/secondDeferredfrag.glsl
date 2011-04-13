#version 120#extension GL_EXT_gpu_shader4 : enableuniform sampler2D albedo;uniform sampler2D normals;uniform sampler2D positions;uniform sampler2D random;uniform float sampleRadius;uniform float intensity;uniform float scale;uniform float bias;uniform float jitter;uniform float selfOcclusion;uniform vec2 screenSize;uniform vec2 invScreenSize;uniform vec3 light;vec3 getPosition(vec2 uv){	return texture2D(positions, uv).xyz;}vec3 getNormal(vec2 uv){	return normalize(texture2D(normals, uv).xyz * 2.0 - 1.0);}vec2 getRandom(vec2 uv){	return texture2D(random, screenSize * uv / jitter ).xy * 2.0f - 1.0f;}float doAmbientOcclusion(vec2 tcoord, vec2 uv, vec3 p, vec3 cnorm){	vec3 diff = getPosition(tcoord + uv) - p;	vec3 v = normalize(diff);	float d = length(diff)*scale;	return max(0.0,dot(cnorm,v)-bias)*(1.0/(1.0+d*d))*intensity;}vec2 vec[4];// = vec2[4]( vec2(1,0), vec2(0,1), vec2(-1,0), vec2(0,-1) );void main(){

	vec[0] = vec2(1,0);	vec[1] = vec2(-1,0);	vec[2] = vec2(0,1);	vec[3] = vec2(0,-1);
	vec2 uv = gl_TexCoord[0].st;
	uv.y = 1.0 - uv.y;	float depth = texture2D(normals, uv).a;	if( depth < 0.00001 || depth > 0.999 ) discard;	vec3 position = getPosition(uv);	vec3 normal = getNormal(uv);	vec2 rand = getRandom(uv);	float rad = sampleRadius/position.z;	/*
	int iterations = 6;
	// int iterations = lerp(6.0,2.0,p.z/g_far_clip); 	float ao = 0.0;	for (int j = 0; j < iterations; ++j) {		vec2 coord1 = reflect(vec[j],rand)*rad;		vec2 coord2 = vec2(coord1.x*0.707 - coord1.y*0.707, coord1.x*0.707 + coord1.y*0.707);		ao += doAmbientOcclusion(uv,coord1*0.25, position, normal);		ao += doAmbientOcclusion(uv,coord2*0.5, position, normal);		ao += doAmbientOcclusion(uv,coord1*0.75, position, normal);		ao += doAmbientOcclusion(uv,coord2, position, normal);	}	ao/=float(iterations)*4.0;	// ao+= selfOcclusion;
*/
	// blinn test lighting
/*
	// vec3 light = vec3(150,250,0);
   	vec3 lightDir = light - position.xyz ;

   	normal = normalize(normal);
   	lightDir = normalize(lightDir);

	vec3 cameraPosition = vec3(320.0, 240.0, 150.0);

   	vec3 eyeDir = normalize(cameraPosition-position.xyz);
   	vec3 vHalfVector = normalize(lightDir.xyz+eyeDir);

	vec3 lightColor = max(dot(normal,lightDir),0) * texture2D(albedo, uv).rgb +
                      pow(max(dot(normal,vHalfVector),0.0),9)*2;
	// lightColor *= ao;
*/
	// multilighting
	
	vec3 cameraPosition = vec3(320.0, 240.0, 150.0);
	vec3	eyeDir	 = normalize(cameraPosition-position.xyz);
	vec4 imageColor = texture2D(albedo, uv);
	vec3	diffuse	 = vec3(0,0,0);
   	vec3	specular	= vec3(0,0,0);
   	vec3	thislight	 = vec3(0,0,0);
  	vec3	lightDir	= vec3(0,0,0);
  	vec3	vHalfVector = vec3(0,0,0);
	float	lightIntensity	 = 0;
	float	specularIntensity = imageColor.a;
	float	selfLighting = 0.25 + position.z;
   	// normal.w = 0;
   	normal = normalize(normal);

  	float lightCount = 10;
   	for(float i=0.0; i<lightCount; i++){
      		thislight = vec3(cos(light.x*.01 + i)*light.x + cos(i*.1)*235 + i*10, cos(light.x*.01 + i)*light.y + cos(i*0.5)*235, cos(light.x*.01 + i)*light.z + sin(i*1.1)*235 + i*10);//texture2D( lightTexture,vec2(0.01,i*0.99/lightCount) ).xyz;
      		lightDir = thislight - position.xyz ;
      		float lightDistance = length(lightDir);
      		lightDir /= lightDistance;
      		lightIntensity = 1 / ( 1.0 + 0.00005 * lightDistance + 0.00009 * pow(lightDistance,2) );

      		vec3 lightColor = vec3(1.0, 1.0, 1.0);//texture2D( lightTexture, vec2(0.99,i*0.99/lightCount) ).xyz;
      		vHalfVector = normalize(lightDir+eyeDir);

      		float localDiffuse = max(dot(normal,lightDir),0);
      		diffuse += lightColor * localDiffuse * lightIntensity;

      		if(localDiffuse>0)
        	specular += lightColor * pow(max(dot(normal,vHalfVector),0.0),10) * lightIntensity * 2;
   	}

for(float i=0.0; i<lightCount; i++){
      		thislight = vec3(cos(light.x*.01 + i)*light.x + cos(i*.1)*1135 + i*10, cos(light.x*.01 + i)*light.y + cos(i*0.5)*1135, cos(light.x*.01 + i)*light.z + sin(i*1.1)*1135 + i*10);//texture2D( lightTexture,vec2(0.01,i*0.99/lightCount) ).xyz;
      		lightDir = thislight - position.xyz ;
      		float lightDistance = length(lightDir);
      		lightDir /= lightDistance;
      		lightIntensity = 1 / ( 1.0 + 0.00005 * lightDistance + 0.00009 * pow(lightDistance,2) );

      		vec3 lightColor = vec3(1.0, 1.0, 1.0);//texture2D( lightTexture, vec2(0.99,i*0.99/lightCount) ).xyz;
      		vHalfVector = normalize(lightDir+eyeDir);

      		float localDiffuse = max(dot(normal,lightDir),0);
      		diffuse += lightColor * localDiffuse * lightIntensity;

      		if(localDiffuse>0)
        	specular += lightColor * pow(max(dot(normal,vHalfVector),0.0),5) * lightIntensity * 2;
   	}

	gl_FragColor = vec4(diffuse,1) * imageColor + 
                  vec4(specular * specularIntensity * 2, 10) + 
                  selfLighting * (imageColor);

   	// gl_FragColor = vec4(lightColor, 1.0);

	// gl_FragColor = vec4(texture2D(albedo, uv).xyz, 1.0);	// gl_FragColor = vec4(ao, ao, ao, 1.0);
	// gl_FragColor = vec4(ao, 1.0, 1.0, 1.0);}