precision mediump float;

uniform float time;
uniform sampler2D normalSampler;
uniform sampler2D reflectionMap;
uniform sampler2D refractionMap;

varying vec3 worldCoord;
varying vec3 waterNormal;
varying vec3 rockNormal;
varying float n1; //not used for the moment

// p is a position
vec4 rockColor(vec3 p)
{
    //colors for the rock
    vec4 rock  = vec4(0.53, 0.50, 0.49, 1.0);
    vec4 lightRock  = vec4(0.7, 0.7, 0.67, 1.0);
    vec4 darkRock  = vec4(0.22, 0.2, 0.2, 1.0);

    //vec3 pos = position;
    float n  = 0.0;//= 0.5 * snoise(p*2.0);
    //n += 0.25 * snoise(p*4.0);

    for(float i = 1.0; i < 3.0; i += 1.0) 
    {
        n += (1.0/pow(2.0,i*0.5))*(snoise(0.08*p*pow(2.0,i))+1.0);
    }

    vec4 finalRock = mix(lightRock, rock, smoothstep(0.8, 1.5,n));
    //finalRock = mix(finalRock, darkRock, smoothstep(0.8, 1.5,n)); 
    // Darker color near the water surface
    finalRock -= 0.8*(smoothstep(0.0,0.2, 0.07*(1.0-abs(worldCoord.y))));

    return finalRock;
}

vec4 waterColor(vec3 p)
{
    vec4 finalWater = vec4(0.0, 0.12, 0.6, 1.0);
    return finalWater;
}

vec3 rockNormalBump(vec3 p) {
    vec3 normal = p; //points upwards
    float amp = 0.08;
    float temp;
    
    normal += snoise(p);
    normal += snoise(2.0*p)*0.5*amp;
    normal += snoise(4.0*p)*0.25*amp;
    normal += snoise(16.0*p)*0.125*amp;

    return normalize(normal);
}



/**
 * @author jbouny / https://github.com/jbouny
 *
 * Work based on :
 * @author Slayvin / http://slayvin.net : Flat mirror for three.js
 * @author Stemkoski / http://www.adelphi.edu/~stemkoski : An implementation of water shader based on the flat mirror
 * @author Jonas Wagner / http://29a.ch/ && http://29a.ch/slides/2012/webglwater/ : Water shader explanations in WebGL
 */

void sunLight( const vec3 surfaceNormal, const vec3 eyeDirection, float shiny, float spec, 
    float diffuse, inout vec3 diffuseColor, inout vec3 specularColor, vec3 sunDirection )
{
    vec3 sunColor = vec3(1.0, 1.0, 1.0);
    vec3 reflection = normalize( reflect( -sunDirection, surfaceNormal ) );
    float direction = max( 0.0, dot( eyeDirection, reflection ) );
    specularColor += pow( direction, shiny ) * sunColor * spec;
    diffuseColor += max( dot( sunDirection, surfaceNormal ), 0.0 ) * sunColor * diffuse;
}

/*----------------------------------------*/

void main() 
{
    vec3 lightPos = normalize(vec3(0.0, 1.0, 0.5));
    vec3 lightDir = normalize(lightPos - worldCoord);
    vec3 viewDir = normalize(-worldCoord);
    vec4 finalColor, finalRock, finalWater;
    vec3 diffuseLight = vec3(0.0); //Color for diffuise light
    vec3 specularLight = vec3(0.0); //Color for specular light

    //Calculate specular and diffuse light 
    sunLight(waterNormal, viewDir, 100.0, 2.0, 0.5, diffuseLight, specularLight, lightDir);

    float depth = - worldCoord.y; //Depth of the water

    /*------------ROCKS-----------*/
    //Rock normal doesn't affect rock color atm
    finalRock = rockColor(worldCoord);

    //Add some bumb mapping to the rocks
    vec3 objectNormal = rockNormal;
    vec3 tangent = normalize(cross(objectNormal, vec3(0.0,1.0,0.0)));
    vec3 bitangent = cross (objectNormal, tangent);
    vec3 v;
    v.x = dot (lightPos, tangent);
    v.z = dot (lightPos, bitangent);
    v.y = dot (lightPos, objectNormal);
    vec3 adjustedLightPos = normalize (v);
    
    //add diffuse light to the rocks
    vec3 surfaceNormal;
    depth > 3.0 ? 
        surfaceNormal = rockNormalBump(rockNormal) :
        surfaceNormal = rockNormal; //eller vec3(0.0,1.0,0.0)?

    float lambertian = dot(normalize(adjustedLightPos), surfaceNormal);
    lambertian = max(0.05, lambertian);
    finalRock *= lambertian; //*color depending on the sun's position
    



    /*------------WATER-----------*/
    finalWater = waterColor(worldCoord);

    //vec4 noise = getNoise(worldCoord.xz);


    //Schlick's approximation
    float R0 = 0.1; //Minimal reflection, hould be 0.02 for air to water
    float minOpacity = 0.15;
    float opaqueDepth = 3.0;
    float cosTheta = abs(dot(viewDir, waterNormal));
    
    //Reflectance
    float reflectance = R0 + (1.0 - R0) * pow( ( 1.0 - cosTheta ), 5.0 );
   
    /*alt 1*/
    vec3 scatter = max(0.0, dot(waterNormal, viewDir)) * finalWater.rgb;
    vec3 albedo = mix(diffuseLight * 0.3 + scatter, vec3(0.1) + specularLight, reflectance);

    /*alt 2*/
    vec4 sky = vec4(0.6, 0.8, 1.0, 1.0);
    float thickness = depth / max (cosTheta, 0.01);
    float dWater = minOpacity + (1.0 - minOpacity) * sqrt (min (thickness / opaqueDepth, 1.0));
    finalWater = finalWater * dWater;

    finalWater *= max(0.2, dot(normalize(lightPos), surfaceNormal));
    finalWater = (1.0 - reflectance) * finalWater + reflectance * sky;
    float alpha = reflectance + (1.0 - reflectance) * dWater;
    //alpha should be used as the alpha chanel in finalColor = mix(finalRock, vec4(albedo, 1.0), 0.7) 
    //not working atm


    //simple phong shading
    float lambertian2 = max(dot(lightDir,waterNormal), 0.0);
    vec4 phong = vec4(lambertian2*diffuseLight + 2.0*specularLight, 1.0);

    //set finalColor to either water or rock
    //alt 1
    
    //finalColor = mix(finalRock, phong, 0.7) : 
    /*depth > 0.0 ?
        finalColor = mix(finalRock, vec4(albedo, 1.0), 0.7) : 
        finalColor = finalRock;*/

    //alt 2
    
    depth > 0.0 ?
        finalColor = mix(finalRock, vec4(finalWater.rgb, 1.0), alpha) : 
        finalColor = finalRock;


    gl_FragColor = finalColor ;
}




/*
PHONG SHADING

const vec3 lightPos = vec3(1.0, 1.0, 1.0);
const vec3 diffuseColor = vec3(0.5, 0.0, 0.0);
const vec3 specColor = vec3(1.0, 1.0, 1.0);

void main(){
  gl_Position = projection * modelview * vec4(inputPosition, 1.0);

  // all following gemetric computations are performed in the
  // camera coordinate system (aka eye coordinates)
  vec3 normal = vec3(normalMat * vec4(inputNormal, 0.0));
  vec4 vertPos4 = modelview * vec4(inputPosition, 1.0);
  vec3 vertPos = vec3(vertPos4) / vertPos4.w;
  vec3 lightDir = normalize(lightPos - vertPos);
  vec3 reflectDir = reflect(-lightDir, normal);
  vec3 viewDir = normalize(-vertPos);

  float lambertian = max(dot(lightDir,normal), 0.0);
  float specular = 0.0;
  
  if(lambertian > 0.0) {
    float specAngle = max(dot(reflectDir, viewDir), 0.0);
    specular = pow(specAngle, 4.0);

    // the exponent controls the shininess (try mode 2)
    if(mode == 2)  specular = pow(specAngle, 16.0);
       
    // according to the rendering equation we would need to multiply
    // with the the "lambertian", but this has little visual effect
    if(mode == 3) specular *= lambertian;
    // switch to mode 4 to turn off the specular component
    if(mode == 4) specular *= 0.0;
  }
  
  forFragColor = vec4(lambertian*diffuseColor + specular*specColor, 1.0);
}
*/
