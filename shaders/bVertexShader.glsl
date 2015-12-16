varying vec4 curvePos;
varying float n;

void main() 
{
    vec3 pos = position;
    curvePos = modelMatrix * vec4(position, 1.0);

    n  = snoise(vec3(pos.x*0.1,  pos.y*0.1, 1.0));
    n += snoise(vec3(pos.x*0.2,  pos.y*0.2, 1.0)*0.5);
    n += snoise(vec3(pos.x*0.4,  pos.y*0.4, 1.0)*0.25);

    curvePos.y = n*5.0;
    gl_Position = projectionMatrix * viewMatrix * curvePos;
}
