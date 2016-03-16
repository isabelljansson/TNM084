//Isabell Jansson

require([
    "../libs/text!../shaders/vertexShader.glsl",
    "../libs/text!../shaders/fragmentShader.glsl",
    "../libs/text!../shaders/simplex-noise-3d.glsl",
    "../libs/noise",
    "../libs/orbit-controls"
],

function (
    vertexShader,
    fragmentShader,
    noiseglsl) 
{
    "use strict";


    var scene, refrScene, renderer, camera, controls;
    var terrain, terrainMaterial, terrainUniforms, terrainGeometry, vertexPos, vertexNormal, start = Date.now();
    var reflectionMap, refractionMap;

    init();
    animate();


    //initialize scene
    function init() 
    {
        //--------------------------------
        // SET UP SCENE, CAMERA, RENDERER
        //--------------------------------

    	//scene
    	container = document.getElementById( 'container' );
    	scene = new THREE.Scene();
        refrScene = new THREE.Scene();

    	//camera
        camera = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 1, 20000 );
        camera.position.set(0, 100, 200);
    	camera.lookAt(scene.position);
        scene.add(camera);

        //initialize reflection an refraction map
        reflectionMap = new THREE.WebGLRenderTarget( 
            window.innerWidth,
            window.innerHeight,
            { 
                minFilter: THREE.LinearFilter,
                magFilter: THREE.NearestFilter,
                format: THREE.RGBFormat
            }
        );

        refractionMap = new THREE.WebGLRenderTarget( 
            window.innerWidth,
            window.innerHeight,
            { 
                minFilter: THREE.LinearFilter,
                magFilter: THREE.NearestFilter,
                format: THREE.RGBFormat
            }
        );




        //Renderer
    	renderer = new THREE.WebGLRenderer();
        renderer.setClearColor( 0xffffff );
        renderer.setPixelRatio( window.devicePixelRatio );
        renderer.setSize( window.innerWidth, window.innerHeight );


        //--------------------------------
        // LIGHT
        //--------------------------------
    	var light = new THREE.PointLight(0xffffff);
    	light.position.set(0,250,0);
    	scene.add(light);



        //--------------------------------
        // TERRAIN  
        //--------------------------------

        //shader uniforms
        terrainUniforms = 
        {   
            time: { type: "f", value: 1.0 },
            reflectionMap: { type: "t", value: reflectionMap },
            refractionMap: { type: "t", value: refractionMap },
            normalSampler: { type: "t", value: null }
        };

        //material
        terrainMaterial = new THREE.ShaderMaterial( 
        {
            uniforms: terrainUniforms,
            vertexShader: noiseglsl + vertexShader,
            fragmentShader: noiseglsl + fragmentShader
        } );

        //geometry
        terrainGeometry = new THREE.PlaneBufferGeometry(200,200, 100, 100);

        //Copy attributes.position.array to vertexPos, every vertex will be a vec3
        //vertexPos = new THREE.BufferAttribute(terrainGeometry.attributes.position.array, 3);
        //vertexNormal = new THREE.BufferAttribute(terrainGeometry.attributes.normal.array, 3);       
                    
        //terrainGeometry.addAttribute( 'vertexPos', vertexPos );
        //terrainGeometry.addAttribute( 'vertexNormal', vertexNormal );
        

        //create a terrain mesh and add it to the scene
        terrain = new THREE.Mesh( terrainGeometry, terrainMaterial );
        terrain.position.set(0, 0, 0);
        terrain.rotation.x = - Math.PI/2;
        terrain.rotation.z = -Math.PI;
        scene.add( terrain );

        controls = new THREE.OrbitControls(camera, renderer.domElement);
        //updateVertexPos();

    	container.innerHTML = "";
        document.body.appendChild( renderer.domElement );  
        /*
        console.log('första');
        console.log(vertexPos.array[0])
        console.log(vertexPos.array[1])
        console.log(vertexPos.array[2])
        console.log('andra')
        console.log(vertexPos.array[3])
        console.log(vertexPos.array[4])
        console.log(vertexPos.array[5])
        */
    }
/*
    function updateVertexPos()
    {
        
        var height;
        for ( var i = 0; i < vertexPos.length; i += 3 ) 
        {
            height  = noise.simplex2(vertexPos.array[i] * 0.01, vertexPos.array[i + 1] * 0.01);
            height += noise.simplex2(vertexPos.array[i] * 0.05, vertexPos.array[i + 1] * 0.05) * 0.5;
            height += noise.simplex2(vertexPos.array[i] * 0.10, vertexPos.array[i + 1] * 0.10) * 0.25;
            //height += noise.simplex2(vertexPos.array[i] * 0.20, vertexPos.array[i + 1] * 0.20) * 0.125;

            vertexPos.array[i + 2] = height * 15;
        }
        
       


    }
*/

    function animate() 
    {
        requestAnimationFrame( animate );
        terrainUniforms.time.value +=  0.01;

        //Update vertex position, the position is applied to every vertex through the vertex shader
        //updateVertexPos();
        //terrainGeometry.attributes.vertexPos.array.needsUpdate = true;
        terrainGeometry.computeVertexNormals();
        terrainGeometry.normalsNeedUpdate = true;
        
        //render to reflection texture
        //renderer.render( scene, secCam, reflectionMap, true );
        //render to refraction texture
        //renderer.render( refrScene, camera, refractionMap, true );
    	renderer.render( scene, camera );		
        controls.update();

    }
});