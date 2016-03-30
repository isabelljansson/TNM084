precision mediump float;

//attribute vec3 vertexPos;

varying vec3 worldCoord;
varying vec3 waterNormal;
varying vec3 rockNormal;


uniform float time;

float getTerrainHeight(vec3 p)
{
    float height = 0.0;
    height += snoise(vec3(p.x*0.01, 0.01, p.z*0.01));
    height += snoise(vec3(p.x*0.05, 0.05, p.z*0.05)*0.5);

    return height*10.0;
}


float getWaterHeight(vec3 p) 
{
    float height = 0.0;

    height += snoise(vec3(1.0*p.x-sqrt(1.0)*time*0.5, 0.1*time, 0.05*1.0*p.z));
    height += snoise(vec3(2.0*p.x-sqrt(2.0)*time*0.5, 0.1*time, 0.05*2.0*p.z))*0.5;
    height += snoise(vec3(4.0*p.x-sqrt(4.0)*time*0.5, 0.1*time, 0.05*4.0*p.z))*0.25;
    height += snoise(vec3(8.0*p.x-sqrt(8.0)*time*0.5, 0.1*time, 0.05*8.0*p.z))*0.16;

    return height*0.5;
}


void main() 
{

    vec4 worldPos = modelMatrix * vec4(position, 1.0);

    //Generate height for terrain
    //Entire plane is now terrain
    worldPos.y = getTerrainHeight(worldPos.xyz);

    worldCoord = worldPos.xyz;

    //Generate a water height
    float h = getWaterHeight(worldPos.xyz);

    //Set pixel to either terrain (rock) or water
    //The pixel position, worldPos, is shared with the fragment shader
    worldPos.y < h ? 
        worldPos = vec4(worldPos.x, h, worldPos.z, 1.0) : 
        worldPos;
    

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

    //ROCK, also add a noise to normal for bumpmapping, but this normal is not used atm
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

