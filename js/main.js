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


    var scene, renderer, camera, controls;
    var terrain, terrainMaterial, terrainUniforms, terrainGeometry, vertexPos, vertexNormal, start = Date.now();
    
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

    	//camera
        camera = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 1, 20000 );
        camera.position.set(0, 100, 200);
    	camera.lookAt(scene.position);
        scene.add(camera);

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
            time: 
            {
                type: "f",  //float
                value: 0.0  //initialized to 0
            }
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
        vertexPos = new THREE.BufferAttribute(terrainGeometry.attributes.position.array, 3);
        //vertexNormal = new THREE.BufferAttribute(terrainGeometry.attributes.normal.array, 3);       
                    
        terrainGeometry.addAttribute( 'vertexPos', vertexPos );
        //terrainGeometry.addAttribute( 'vertexNormal', vertexNormal );
        

        //create a terrain mesh and add it to the scene
        terrain = new THREE.Mesh( terrainGeometry, terrainMaterial );
        terrain.position.set(0, 0, 0);
        terrain.rotation.x = - Math.PI/2;
        scene.add( terrain );

        controls = new THREE.OrbitControls(camera, renderer.domElement);
      

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


    function animate() 
    {
        requestAnimationFrame( animate );
        terrainUniforms.time.value +=  0.01;

        //Update vertex position, the position is applied to every vertex through the vertex shader
        updateVertexPos();
        terrainGeometry.attributes.vertexPos.array.needsUpdate = true;
        //terrainGeometry.attributes.vertexNormal.needsUpdate = true;

        
    	renderer.render( scene, camera );		
        controls.update();

    }
});