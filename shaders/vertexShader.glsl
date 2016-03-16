precision mediump float;

//attribute vec3 vertexPos;

varying vec3 worldCoord;
varying vec3 waterNormal;
varying vec3 rockNormal;
varying float n1;

uniform float time;

float getTerrainHeight(vec3 p)
{
    float height = 0.0;
    height  += snoise(vec3(p.x*0.01, 0.01, p.z*0.01));
    height += snoise(vec3(p.x*0.05, 0.05, p.z*0.05)*0.5);
    //n += snoise(vec3(pos.x*0.1,  pos.y*0.1, 1.0)*0.25);
    //n += snoise(vec3(pos.x*0.2,  pos.y*0.2, 1.0)*0.125);
    return height*15.0;
}


float getWaterHeight(vec3 p) 
{
    float height = 0.0;
/*
    vec3 shift1 = -0.001*vec3( time*160.0*2.0, 0.0, time*120.0*2.0 );
    vec3 shift2 = -0.0015*vec3( time*190.0*2.0, 0.0, time*130.0*2.0 );

    float wave = 0.0;

    wave += sin(p.x*0.02+p.z*0.002+shift2.x*3.4)*5.0;
    wave += sin(p.x*0.03+p.z*0.01+shift2.x*4.2)*2.5 ;
    wave *= 0.05;

    wave += (snoise(vec3(p*0.004 + shift1))-.5)*0.8*0.5;
    wave += (snoise(vec3(p*0.010 + shift1*1.3))-.5)*0.8*0.15;

    float amp = 0.8;
    float smoothamp = 1.0;

    for (float i=0.0; i<5.0; i+=1.0) {
    float n = (sin(snoise(vec3(p.xz*0.01+shift1.xz, time*0.2))-.5))*amp*1.0;

    // smoothed abs value. Less grainy and smoother waves than abs(n)
    float mu = 0.03*smoothamp;
    abs(n) < mu ? n = n*n/(2.0*mu): n = abs(n)-mu*0.5;
    //n = abs(n); 
    wave -= n;
    amp *= 0.5;
    shift1 *= 1.8;
    //p *= m2*0.9;
    smoothamp *= 0.65;
    }

  height += wave;

    //height =  sin(snoise(vec3(p.x*0.01, 0.0, p.z*0.05)))*0.1;

    //height += wave;*/
    height = snoise(vec3(1.0, p.y*time*0.1, 1.0));
    return height;
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

    n1 = getWaterHeight(worldPos.xyz);

    //Set pixel to either terrain or water
    //vec4 pos;
    worldPos.y < 0.0 ? 
        worldPos = vec4(worldPos.x, n1, worldPos.z, 1.0) : 
        worldPos;

    //update terrain normal
    vec3 xDelta = vec3(1.0,0.0,0.0)/20.0;
    vec3 zDelta = vec3(0.0,0.0,1.0)/20.0;

    // p1 = worldPos
    // v = p2 - p1
    // w = p3 - p1
    vec3 v = (vec3(worldPos.x + xDelta.x, getTerrainHeight(worldPos.xyz + xDelta), worldPos.z + xDelta.z)) - worldPos.xyz;
    vec3 w = (vec3(worldPos.x + zDelta.x, getTerrainHeight(worldPos.xyz + zDelta), worldPos.z + zDelta.z)) - worldPos.xyz;
    rockNormal.x = (v.y * w.z) - (v.z * w.y);
    rockNormal.y = (v.z * w.x) - (v.x * w.z);
    rockNormal.z = (v.x * w.y) - (v.y * w.x);
    rockNormal = normalize(rockNormal);


    //WATER

    // p1 = worldPos
    v = (vec3(worldPos.x + xDelta.x, getWaterHeight(worldPos.xyz + xDelta), worldPos.z + xDelta.z)) - worldPos.xyz;
    w = (vec3(worldPos.x + zDelta.x, getWaterHeight(worldPos.xyz + zDelta), worldPos.z + zDelta.z)) - worldPos.xyz;
    waterNormal.x = (v.y * w.z) - (v.z * w.y);
    waterNormal.y = (v.z * w.x) - (v.x * w.z);
    waterNormal.z = (v.x * w.y) - (v.y * w.x);

    waterNormal = normalize(waterNormal);

   
    
    gl_Position = projectionMatrix * viewMatrix * worldPos;
}

