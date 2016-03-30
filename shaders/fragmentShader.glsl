//Isabell Jansson, isaja187
//TNM084

precision mediump float;

uniform float time;

varying vec3 worldCoord;
varying vec3 waterNormal;
varying vec3 rockNormal;

// p is a position
vec4 rockColor(vec3 p)
{
    //colors for the rock
    vec4 rock  = vec4(0.53, 0.50, 0.49, 1.0);
    vec4 lightRock  = vec4(0.7, 0.7, 0.67, 1.0);
    vec4 darkRock  = vec4(0.22, 0.2, 0.2, 1.0);

    float noise  = 0.5  * snoise(vec3(worldCoord.x*0.1, 1.0, worldCoord.z*0.1));
          noise += 0.25 * snoise(vec3(worldCoord.x*0.3, 1.0, worldCoord.z*0.3));
          noise += 0.16 * snoise(vec3(worldCoord.x*0.9, 1.0, worldCoord.z*0.9));
    vec4 finalRock = mix(lightRock, darkRock, noise);

    return finalRock;
}


void main() 
{
    vec3 lightPos = normalize(vec3(0.0,300.0,0.0));
    vec3 lightDir = normalize(lightPos - worldCoord);
    vec3 viewDir = normalize(-worldCoord);
    vec4 finalColor, finalRock, finalWater;
    vec3 diffuseLight = vec3(0.5, 0.5, 0.5); //Color for diffuise light
    vec3 specularLight = vec3(1.0, 1.0, 1.0); //Color for specular light

    float depth = - worldCoord.y; //Depth of the water

    /*------------ROCKS-----------*/
    //Rock normal doesn't affect rock color atm
    finalRock = rockColor(worldCoord);


    /*------------WATER-----------*/
    finalWater =  vec4(0.0, 0.12, 0.6, 1.0);
   
    //simple phong shading
    float lambertian = max(dot(lightDir,waterNormal), 0.0);
    
    /*blinn phong shading
    float shininess = 6.0;
    vec3 halfDir = normalize(lightDir + viewDir);
    float specAngle = max(dot(halfDir, waterNormal), 0.0);
    float specular = pow(specAngle, shininess);*/

    /*phong shading*/
    float shininess = 6.0;
    vec3 reflectDir = reflect(-lightDir, waterNormal);
    float specAngle = max(dot(reflectDir, viewDir), 0.0);
    // note that the exponent is different here
    float specular = pow(specAngle, shininess/4.0);

    finalWater = vec4(finalWater.xyz + lambertian*diffuseLight + specular*specularLight, 1.0);

    depth > 0.0 ?
        finalColor = mix(finalRock, finalWater, 0.5) : 
        finalColor = finalRock;


    gl_FragColor = finalColor ;
}
