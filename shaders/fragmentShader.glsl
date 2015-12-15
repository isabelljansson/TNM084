varying vec2 vUv;
varying vec4 curvePos;

void main() 
{
    //curvePos is passed through the vertex shader
    // color is RGBA: u, v, 0, 1
    gl_FragColor = vec4( vec3( vUv, curvePos.y ), 1. );
}