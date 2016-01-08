precision mediump float;

varying vec4 vertexPos;
varying vec3 worldCoord;

void main() 
{

	vec4 finalColor, finalRock, finalWater;
	float n, m;

	//colors for the rock
	vec4 rock  = vec4(0.5, 0.47, 0.46, 1.0);
    vec4 lightRock  = vec4(0.7, 0.7, 0.67, 1.0);
    vec4 darkRock  = vec4(0.22, 0.2, 0.2, 1.0);
    
    //Color for grass/moss
    //vec4 lightGrass = vec4(0.2, 0.4, 0.03, 1.0);
    //vec4 darkGrass = vec4(0.1, 0.3, 0.03, 1.0);

	//vec3 pos = position;
    n  = 0.5 * snoise(vec3(vertexPos.x*0.3, vertexPos.y*0.3, 1.0));
    n += 0.25 * snoise(vec3(vertexPos.x*0.9,  vertexPos.y*0.9, 1.0));

    finalRock = mix(rock, lightRock, clamp(n, 0.0, 1.0));
    finalRock = mix(finalRock, darkRock, clamp(m, 0.0, 1.0)); 
    
    float depth = - vertexPos.y; //Depth of the water

    finalWater = vec4(0.0, 0.0, 0.5, 1.0);

    depth < 0.0 ?
        finalColor = mix(finalWater, finalRock, 1.0) : 
        finalColor = finalWater;


    gl_FragColor = finalColor;
    

    //gl_FragColor = vec4(1.0, 0.5, 0.2, 1.0);
}