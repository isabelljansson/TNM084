precision mediump float;

//attribute vec3 vertexPos;

varying vec3 worldCoord;
//varying vec3 worldNormal;

uniform float time;

void main() 
{
    float n;

    //vertexPos is an attribute - the value is set in the main and applied to a single vertex in vs
    //For some reason...vertexPos is an attribute based on the position, 
    //and when vertexPos is set in the main, it is stored in the position attribute? 
    //Therefore it only works when I'm using 'position' here in the vs, and not 'vertexPos'? 
    vec4 worldPos = modelMatrix * vec4(position, 1.0); //position always needs to be in the vs...three.js bug?
    worldCoord = worldPos.xyz;


    //WATER
    float n1 = snoise(vec3(1.0, worldPos.y*time*0.2, 1.0));
    //float n1 = 0.0;

    //Set pixel to either terrain or water
    vec4 pos;
    worldPos.y < 0.0 ? 
        worldPos = vec4(worldPos.x, n1, worldPos.z, 1.0) : 
        worldPos = vec4(worldPos.x, worldPos.y, worldPos.z, 1.0);



    gl_Position = projectionMatrix * viewMatrix * worldPos;
}

