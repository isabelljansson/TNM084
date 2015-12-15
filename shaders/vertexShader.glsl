varying vec2 vUv;
//varying vec3 pos;
uniform float time;
varying vec4 curvePos;

void main() 
{
	vUv = uv;
    vec3 pos = position;
    curvePos = modelMatrix * vec4(position, 1.0);
    float n1 = snoise(vec3(pos.x*0.01, pos.y*sin(time)*0.05, 1.0));

    curvePos.y = n1;
    gl_Position = projectionMatrix * viewMatrix * curvePos;
}

/*
varying vec2 vUv;
uniform float time;
varying vec4 curvePos;
attribute float displacement;

void main() 
{
    vUv = uv;
    curvePos = modelMatrix * vec4(position, 1.0);

    curvePos.y = sin(time)*20.0;
    //vec4 newPos = position + vec4(displacement)
    gl_Position = projectionMatrix * viewMatrix * curvePos;
}
*/