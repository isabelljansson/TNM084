//Isabell Jansson, isaja187
//TNM084

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
    var terrain, terrainMaterial, terrainUniforms, terrainGeometry, start = Date.now();

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


        //--------------------------------
        // LIGHT
        //--------------------------------
    	var light = new THREE.PointLight(0xffffff);
    	light.position.set(0,250,0);
    	scene.add(light);


        //--------------------------------
        // TERRAIN  (water + rocks)
        //--------------------------------

        //shader uniforms
        terrainUniforms = 
        {   
            time: { type: "f", value: 1.0 },
        };

        //material
        terrainMaterial = new THREE.ShaderMaterial( 
        {
            uniforms: terrainUniforms,
            vertexShader: noiseglsl + vertexShader,
            fragmentShader: noiseglsl + fragmentShader
        } );

        //geometry
        terrainGeometry = new THREE.PlaneBufferGeometry(200,200, 200, 200);

        //Renderer
        renderer = new THREE.WebGLRenderer();
        renderer.setClearColor( 0xffffff );
        renderer.setPixelRatio( window.devicePixelRatio );
        renderer.setSize( window.innerWidth, window.innerHeight );

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
    }


    function animate() 
    {
        requestAnimationFrame( animate );
        terrainUniforms.time.value +=  0.01;

        terrainGeometry.computeVertexNormals();
        terrainGeometry.normalsNeedUpdate = true;

    	renderer.render( scene, camera);		
        controls.update();
    }
});