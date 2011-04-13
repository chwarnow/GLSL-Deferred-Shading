/**
 * deferred shading added to Karstens Demo. 
 * Christopher Warnow 2011
 */
 
/**
 * AnimatedNoise demo showing how to utilize the IsoSurface class to efficiently
 * visualise volumetric data, in this case using animated 4D SimplexNoise. The demo also
 * shows how to save the generated mesh as binary STL file (or alternatively in
 * OBJ format) for later use in other 3D tools/digital fabrication.
 * 
 * I've planned further classes for the toxi.geom.volume package to easier draw
 * and manipulate volumetric data.
 * 
 * Controls:
 * Click mouse button to toggle rendering style between shaded/wireframe.
 * Press 's' to save generated mesh as STL file
 */

/* 
 * Copyright (c) 2010 Karsten Schmidt
 * 
 * This demo & library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * http://creativecommons.org/licenses/LGPL/2.1/
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.volume.*;
import toxi.math.noise.*;
import toxi.processing.*;
import toxi.geom.mesh.subdiv.*;

import processing.opengl.*;
import javax.media.opengl.*;
import codeanticode.glgraphics.*;

int DIMX= 48;
int DIMY= 48;
int DIMZ= 48;

float ISO_THRESHOLD = 0.1;
float NS=0.03;
Vec3D SCALE=new Vec3D(1,1,1).scaleSelf(300);

boolean isWireframe=false;
float currScale=1;

VolumetricSpaceArray volume=new VolumetricSpaceArray(SCALE,DIMX,DIMY,DIMZ);
IsoSurface surface=new ArrayIsoSurface(volume);
TriangleMesh mesh;

ToxiclibsSupport gfx;
SubdivisionStrategy subdiv = new MidpointSubdivision();
boolean isDebug = false;
void setup() {
  size(640,480,GLConstants.GLGRAPHICS);
  gfx=new ToxiclibsSupport(this);
  initShader();
}

void draw() {
  float[] volumeData=volume.getData();
  // fill volume with noise
  for(int z=0,index=0; z<DIMZ; z++) {
    for(int y=0; y<DIMY; y++) {
      for(int x=0; x<DIMX; x++) {
        volumeData[index++]=(float)SimplexNoise.noise(x*NS,y*NS,z*NS,frameCount*NS)*0.5;
      } 
    } 
  }
  volume.closeSides();
  long t0=System.nanoTime();
  // store in IsoSurface and compute surface mesh for the given threshold value
  surface.reset();
  mesh=(TriangleMesh)surface.computeSurfaceMesh(mesh, ISO_THRESHOLD);
  float timeTaken=(System.nanoTime()-t0)*1e-6;
  println(timeTaken+"ms to compute "+mesh.getNumFaces()+" faces");
  background(0);
  
  beginDeferring();
  pushMatrix();
  translate(width,height,450);
  // scale(currScale);
  pushMatrix();
  // translate(-DIMX,-DIMY, -DIMZ);
  rotateX(radians(frameCount*.1));
  rotateY(radians(frameCount*.1));
  
  /*
  ambientLight(48,48,48);
  lightSpecular(230,230,230);
  directionalLight(255,255,255,0,-0.5,-1);
  specular(255,255,255);
  shininess(16.0);
  */
  if (isWireframe) {
    stroke(255);
    noFill();
  } 
  else {
    noStroke();
    fill(255);
  }
  
   // create WETriangleMesh
  WETriangleMesh weMesh = new WETriangleMesh();
  weMesh.addMesh(mesh);

  // subdivide weMesh
  /*
  weMesh.subdivide(subdiv,10);
  new LaplacianSmooth().filter(weMesh, 1);
  weMesh.subdivide(subdiv,10);
  new LaplacianSmooth().filter(weMesh, 2);
  */
  
  gfx.mesh(weMesh,true);
  
  popMatrix();
  popMatrix();
  
  endDeferring();

  if(!isDebug) doDeferredShading();

  pgl.endGL();

  if(isDebug) {
    image(tex0, 0, 0, width/2, height/2); // position
    image(tex1, width/2, 0, width/2, height/2); // normals
    image(tex2, 0, height/2, width/2, height/2);  // color
  }
  
}

void mousePressed() {
  isWireframe=!isWireframe;
}
void keyPressed() {
  if(key=='-') currScale=max(currScale-0.1,0.5);
  if(key=='=') currScale=min(currScale+0.1,10);
  if (key=='s') {
    // save mesh as STL or OBJ file
    //surface.saveAsÒBJ(sketchPath("noise.obj"));
    mesh.saveAsSTL(sketchPath("noise.stl"));
  }
}
