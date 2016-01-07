precision mediump float;

varying vec4 curvePos;
varying vec3 pos;

void main() 
{
    float n;
    pos = position;
    curvePos = modelMatrix * vec4(position, 1.0);

    n  = snoise(vec3(pos.x*0.01, pos.y*0.01, 1.0));
    n += snoise(vec3(pos.x*0.05,  pos.y*0.05, 1.0)*0.5);
    //n += snoise(vec3(pos.x*0.1,  pos.y*0.1, 1.0)*0.25);
    //n += snoise(vec3(pos.x*0.2,  pos.y*0.2, 1.0)*0.125);

    curvePos.y = n*20.0;
    gl_Position = projectionMatrix * viewMatrix * curvePos;
}
