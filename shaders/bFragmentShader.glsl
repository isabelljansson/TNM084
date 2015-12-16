varying vec4 curvePos;
varying float n;

void main() 
{
    vec4 sand  = vec4(0.7, 0.6, 0.5, 1.0);
    vec4 grass = vec4(0.1, 0.7, 0.2, 1.0);

    vec4 finalColor = mix(sand, grass, clamp(n, 0.0, 1.0)); 
    // color is RGBA: u, v, 0, 1

    gl_FragColor = finalColor;
}