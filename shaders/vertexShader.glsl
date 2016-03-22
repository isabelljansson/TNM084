precision mediump float;

//attribute vec3 vertexPos;

varying vec3 worldCoord;
varying vec3 waterNormal;
varying vec3 rockNormal;
varying float isWater; //Flag if point is water or terrain

uniform float time;

float getTerrainHeight(vec3 p)
{
    float height = 0.0;
    height  += snoise(vec3(p.x*0.01, 0.01, p.z*0.01));
    height += snoise(vec3(p.x*0.05, 0.05, p.z*0.05)*0.5);
    //n += snoise(vec3(pos.x*0.1,  pos.y*0.1, 1.0)*0.25);
    //n += snoise(vec3(pos.x*0.2,  pos.y*0.2, 1.0)*0.125);
    return height*10.0;
}


float getWaterHeight(vec3 p) 
{
    float height = 0.0;

    /*Method 1 - sinus
    height += sin(1.0*p.x - 1.0*time);
    height += sin(2.0*p.x - sqrt(2.0)*time)*0.5;
    */

    /*Method 2 - noise*/
    height += snoise(vec3(1.0*p.x-sqrt(1.0)*time, 0.1*1.0*p.y, 0.5*(1.0*p.z-sqrt(1.0)*time)));
    height += snoise(vec3(2.0*p.x-sqrt(2.0)*time, 0.1*2.0*p.y, 0.5*(2.0*p.z-sqrt(2.0)*time)))*0.5;
    height += snoise(vec3(4.0*p.x-sqrt(4.0)*time, 0.1*4.0*p.y, 0.5*(4.0*p.z-sqrt(4.0)*time)))*0.25;
    height += snoise(vec3(8.0*p.x-sqrt(8.0)*time, 0.1*8.0*p.y, 0.5*(8.0*p.z-sqrt(8.0)*time)))*0.16;

    
    //height = snoise(vec3(1.0, p.y*time*0.1, 1.0));
    return height*0.5;
}


void main() 
{

    //vertexPos is an attribute - the value is set in the main and applied to a single vertex in vs
    //For some reason...vertexPos is an attribute based on the position, 
    //and when vertexPos is set in the main, it is stored in the position attribute? 
    //Therefore it only works when I'm using 'position' here in the vs, and not 'vertexPos'? 
    vec4 worldPos = modelMatrix * vec4(position, 1.0); //position always needs to be in the vs...three.js bug?

    //Generate height for terrain
    //Entire plane is now terrain
    worldPos.y = getTerrainHeight(worldPos.xyz);

    worldCoord = worldPos.xyz;

    float h = getWaterHeight(worldPos.xyz);

    //Set pixel to either terrain (rock) or water
    //The pixel position, worldPos, is shared with the fragment shader

    //vec4 pos;
    worldPos.y < h ? 
        worldPos = vec4(worldPos.x, h, worldPos.z, 1.0) : 
        worldPos;
    
    /* 
    if(worldPos.y <= h)
    {
        worldPos = vec4(worldPos.x, h, worldPos.z, 1.0);
        isWater = 1.0; 
    }
    else
    {
        isWater = 0.0;
    }*/

    //CALCULATE NEW NORMAL SINCE THE HEIGHT HAS BEEN UPDATED
    //Normals are shared with the fragment shader
    vec3 xDelta = vec3(1.0,0.0,0.0)/20.0;
    vec3 zDelta = vec3(0.0,0.0,1.0)/20.0;

    // p1 = worldPos
    // v = p2 - p1
    // w = p3 - p1
    // p1---p2
    //  |  /
    //  | /
    //  p3

    //ROCK
    vec3 v = (vec3(worldPos.x + xDelta.x, getTerrainHeight(worldPos.xyz + xDelta), worldPos.z + xDelta.z)) - worldPos.xyz;
    vec3 w = (vec3(worldPos.x + zDelta.x, getTerrainHeight(worldPos.xyz + zDelta), worldPos.z + zDelta.z)) - worldPos.xyz;
    rockNormal.x = (v.y * w.z) - (v.z * w.y) + 0.001*snoise(worldPos.xyz);
    rockNormal.y = (v.z * w.x) - (v.x * w.z) + 0.001*snoise(worldPos.xyz);
    rockNormal.z = (v.x * w.y) - (v.y * w.x) + 0.001*snoise(worldPos.xyz);
    rockNormal = normalize(rockNormal);


    //WATER
    v = (vec3(worldPos.x + xDelta.x, getWaterHeight(worldPos.xyz + xDelta), worldPos.z + xDelta.z)) - worldPos.xyz;
    w = (vec3(worldPos.x + zDelta.x, getWaterHeight(worldPos.xyz + zDelta), worldPos.z + zDelta.z)) - worldPos.xyz;
    waterNormal.x = (v.y * w.z) - (v.z * w.y);
    waterNormal.y = (v.z * w.x) - (v.x * w.z);
    waterNormal.z = (v.x * w.y) - (v.y * w.x);

    waterNormal = normalize(waterNormal);

    gl_Position = projectionMatrix * viewMatrix * worldPos;
}

