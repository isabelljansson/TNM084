precision mediump float;

varying vec4 vertexPos;

varying vec3 worldCoord;


uniform float time;

void main() 
{
	//vec3 height;
    float n;
    //pos = position;
    vertexPos = modelMatrix * vec4(position, 1.0);
    worldCoord = vertexPos.xyz;

    //TERRAIN
    n  = snoise(vec3(position.x*0.01, position.y*0.01, 1.0));
    n += snoise(vec3(position.x*0.05,  position.y*0.05, 1.0)*0.5);
    //n += snoise(vec3(pos.x*0.1,  pos.y*0.1, 1.0)*0.25);
    //n += snoise(vec3(pos.x*0.2,  pos.y*0.2, 1.0)*0.125);

    vertexPos.y = n*20.0;

    //WATER
    float n1 = snoise(vec3(0.01, position.y*time*0.05, 0.03));

    //Set pixel to either terrain or water
    vec4 pos;
    vertexPos.y < 0.0 ? 
    	pos = vec4(vertexPos.x, n1, vertexPos.z, 1.0) : 
    	pos = vertexPos;

    gl_Position = projectionMatrix * viewMatrix * pos;
}
