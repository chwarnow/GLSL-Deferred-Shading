GLSLShader deferredShader, ssaoShader;
GLGraphics pgl;
GL gl;
/*
int[] tex = {  
 0 };
 */
int[] fbo = {  
  0
};
int[] fboDepth = {  
  0
};

GLTexture tex0, tex1, tex2, ssaoRandTexture, envMap;

void initShader() {
  pgl = (GLGraphics) g;
  gl = pgl.gl;
  
  // shader
  deferredShader = new GLSLShader(this, "deferredvert.glsl", "deferredfrag.glsl");
  ssaoShader = new GLSLShader(this, "secondDeferredvert.glsl", "secondDeferredfrag.glsl");
  envMap = new GLTexture(this, "1211.jpg");

  // fbo
  gl.glGenFramebuffersEXT(1, fbo, 0);
  gl.glBindFramebufferEXT(GL.GL_FRAMEBUFFER_EXT, fbo[0]);

  // depth buffer
  gl.glGenRenderbuffersEXT(1, fboDepth, 0);
  gl.glBindRenderbufferEXT(GL.GL_RENDERBUFFER_EXT, fboDepth[0]);
  gl.glRenderbufferStorageEXT(GL.GL_RENDERBUFFER_EXT, GL.GL_DEPTH_COMPONENT, width, height);
  gl.glFramebufferRenderbufferEXT(GL.GL_FRAMEBUFFER_EXT, GL.GL_DEPTH_ATTACHMENT_EXT, GL.GL_RENDERBUFFER_EXT, fboDepth[0]);

  // texture
  tex0 = new GLTexture(this, width, height);
  gl.glBindTexture(GL.GL_TEXTURE_2D, tex0.getTextureID());
  gl.glFramebufferTexture2DEXT(GL.GL_FRAMEBUFFER_EXT, GL.GL_COLOR_ATTACHMENT0_EXT, GL.GL_TEXTURE_2D, tex0.getTextureID(), 0);

  tex1 = new GLTexture(this, width, height);
  gl.glBindTexture(GL.GL_TEXTURE_2D, tex1.getTextureID());
  gl.glFramebufferTexture2DEXT(GL.GL_FRAMEBUFFER_EXT, GL.GL_COLOR_ATTACHMENT1_EXT, GL.GL_TEXTURE_2D, tex1.getTextureID(), 0);

  tex2 = new GLTexture(this, width, height);
  gl.glBindTexture(GL.GL_TEXTURE_2D, tex2.getTextureID());
  gl.glFramebufferTexture2DEXT(GL.GL_FRAMEBUFFER_EXT, GL.GL_COLOR_ATTACHMENT2_EXT, GL.GL_TEXTURE_2D, tex2.getTextureID(), 0);


  // ssao random texture
  ssaoRandTexture = new GLTexture(this, "randomNormals.png");
  // gl.glBindTexture(GL.GL_TEXTURE_2D, ssaoRandTexture.getTextureID());

  int stat = gl.glCheckFramebufferStatusEXT(GL.GL_FRAMEBUFFER_EXT);
  if (stat != GL.GL_FRAMEBUFFER_COMPLETE_EXT)
    System.out.println("FBO error");
  // gl.glGenFramebuffersEXT(1, fbo, 0);    // <-- this is in twice, probably an oversight :P but maybe NVidia drivers just ignore it while ATI drivers get confused. Removing this line makes this chunk of code work...

  // clear color
  gl.glClearColor(1.0, 1.0, 1.0, 1.0f);

  // antialiasing
  gl.glHint(GL.GL_POINT_SMOOTH, GL.GL_NICEST);
  gl.glHint(GL.GL_LINE_SMOOTH, GL.GL_NICEST);
  // gl.glHint(GL.GL_POLYGON_SMOOTH, GL.GL_NICEST);

  gl.glEnable(GL.GL_POINT_SMOOTH);
  gl.glEnable(GL.GL_LINE_SMOOTH);
  // gl.glEnable(GL.GL_POLYGON_SMOOTH);

  gl.glEnable (GL.GL_BLEND);
  gl.glBlendFunc (GL.GL_SRC_ALPHA, GL.GL_ONE_MINUS_SRC_ALPHA);

  // lighting
  // gl.glShadeModel ( GL.GL_SMOOTH );
  gl.glClearColor (0.8,0.8,0.8,1.0);
  gl.glEnable(GL.GL_DEPTH_TEST);
  gl.glEnable(GL.GL_BLEND);
  gl.glEnable(GL.GL_COLOR_MATERIAL);
  gl.glEnable(GL.GL_POINT_SMOOTH); 
  gl.glEnable(GL.GL_TEXTURE_2D);
  gl.glColorMaterial(GL.GL_FRONT_AND_BACK, GL.GL_AMBIENT_AND_DIFFUSE);
  gl.glHint(GL.GL_PERSPECTIVE_CORRECTION_HINT, GL.GL_NICEST); 
  // glu.gluPerspective(50.0, 1.0, 1.0, 5500.0); //50
  //((PGraphicsOpenGL) g).endGL();
  // gl.glEnable(GL.GL_CULL_FACE);
  // gl.glCullFace(GL.GL_BACK);
  gl.glLightModeli(GL.GL_LIGHT_MODEL_TWO_SIDE, GL.GL_TRUE);
}

void beginDeferring() {
  pgl.beginGL();

  gl.glDisable(GL.GL_COLOR_MATERIAL);  
  //gl.glColorMaterial(GL.GL_FRONT_AND_BACK, GL.GL_DIFFUSE);
  gl.glColor3f(0.7,0.7,0.7);

  float mat_specular[] = {
    0.7,0.7,0.7,1.0
  };
  gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_SPECULAR, mat_specular,0); //specular reflection, defines effect mat has on the reflected light

  float mat_shininess[] = {
    1
  };
  gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_SHININESS, mat_shininess,0);  //specular exponent (shininess), control the size and brightness of the specular reflection

  float mat_diffuseb[] = {
    0.9,0.9,0.9,1.0
  };
  gl.glMaterialfv(GL.GL_FRONT, GL.GL_DIFFUSE, mat_diffuseb,0);

  float mat_diffuse[] = {
    0.9,0.9,0.9,1.0
  };
  gl.glMaterialfv(GL.GL_BACK, GL.GL_DIFFUSE, mat_diffuse,0);

  float light0_diffuse[] = {
    0.5,0.5,0.5,1
  };
  gl.glLightfv(gl.GL_LIGHT0, gl.GL_DIFFUSE,  light0_diffuse,0);

  float light0_ambient[] = {
    0.8,0.8,0.8,1
  };
  gl.glLightfv(gl.GL_LIGHT0, gl.GL_AMBIENT,  light0_ambient,0);
  gl.glEnable ( GL.GL_LIGHT0 );

  lights();

/*
  gl.glBindTexture(GL.GL_TEXTURE_2D, tex0.getTextureID());
  gl.glFramebufferTexture2DEXT(GL.GL_FRAMEBUFFER_EXT, GL.GL_COLOR_ATTACHMENT0_EXT, GL.GL_TEXTURE_2D, tex0.getTextureID(), 0);

  gl.glBindTexture(GL.GL_TEXTURE_2D, tex1.getTextureID());
  gl.glFramebufferTexture2DEXT(GL.GL_FRAMEBUFFER_EXT, GL.GL_COLOR_ATTACHMENT1_EXT, GL.GL_TEXTURE_2D, tex1.getTextureID(), 0);

  gl.glBindTexture(GL.GL_TEXTURE_2D, tex2.getTextureID());
  gl.glFramebufferTexture2DEXT(GL.GL_FRAMEBUFFER_EXT, GL.GL_COLOR_ATTACHMENT2_EXT, GL.GL_TEXTURE_2D, tex2.getTextureID(), 0);
*/
  // bind environment map
  gl.glActiveTexture(GL.GL_TEXTURE0);
  gl.glBindTexture(GL.GL_TEXTURE_2D, envMap.getTextureID());

  // Bind FBO, now everything is rendered into the texture.
  gl.glBindFramebufferEXT(GL.GL_FRAMEBUFFER_EXT, fbo[0]);    

  /* clear the color buffer */
  gl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);

  // gl.glDrawBuffer(GL.GL_COLOR_ATTACHMENT0_EXT);
  int[] buffers = {
    GL.GL_COLOR_ATTACHMENT0_EXT, GL.GL_COLOR_ATTACHMENT1_EXT, GL.GL_COLOR_ATTACHMENT2_EXT
  };
  gl.glDrawBuffers( 3, buffers, 0);

  deferredShader.start();
  deferredShader.setFloatUniform("near", 00.0);
  deferredShader.setFloatUniform("far", 2000.0);
  deferredShader.setIntUniform("EnvMap", 0);
}

void endDeferring() {
  deferredShader.stop();

  // Unbind FBO.
  gl.glBindFramebufferEXT(GL.GL_FRAMEBUFFER_EXT, 0);
  
  gl.glActiveTexture(GL.GL_TEXTURE0);
  gl.glBindTexture(GL.GL_TEXTURE_2D, 0);
}
void doDeferredShading() {
  /* ssao */

  gl.glActiveTexture(GL.GL_TEXTURE0 + 0);
  gl.glBindTexture(GL.GL_TEXTURE_2D, tex0.getTextureID());
  gl.glActiveTexture(GL.GL_TEXTURE0 + 1);
  gl.glBindTexture(GL.GL_TEXTURE_2D, tex1.getTextureID());
  gl.glActiveTexture(GL.GL_TEXTURE0 + 2);
  gl.glBindTexture(GL.GL_TEXTURE_2D, tex2.getTextureID());
  gl.glActiveTexture(GL.GL_TEXTURE0 + 3);
  gl.glBindTexture(GL.GL_TEXTURE_2D, ssaoRandTexture.getTextureID());

  ssaoShader.start();
  ssaoShader.setIntUniform( "positions", 0 );
  ssaoShader.setIntUniform( "normals", 1 );
  ssaoShader.setIntUniform( "albedo", 2 );
  ssaoShader.setIntUniform( "random", 3 );
  // ssaoShader.setIntUniform( "iterations", 16);  
  
  ssaoShader.setVecUniform("light", cos(frameCount*.1)*250.0, 250.0,sin(frameCount*.1)*250.0);

  gl.glBegin(GL.GL_POLYGON);
  gl.glColor3f(0.5f, 1.0f, 0.5f); // light green

  // 0
  gl.glTexCoord2f (0.0, 0.0);
  gl.glVertex3f(.0f, .0f, .0f);
  
  // 1
  gl.glTexCoord2f (1.0, 0.0);
  gl.glVertex3f(width, .0f, .0f);

  // 2
  gl.glTexCoord2f (1.0, 1.0);
  gl.glVertex3f(width, height, .0f);
  
  // 3
  gl.glTexCoord2f (0.0, 1.0);
  gl.glVertex3f(.0f, height, .0f);
  gl.glEnd();

  ssaoShader.stop();
}
