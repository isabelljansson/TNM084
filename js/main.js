//Isabell Jansson

require([
    "../libs/text!../shaders/vertexShader.glsl",
    "../libs/text!../shaders/fragmentShader.glsl",
    "../libs/text!../shaders/simplex-noise-3d.glsl",
    "../libs/orbit-controls"
],

function (
    vertexShader,
    fragmentShader,
    noise) 
{
    "use strict";


    var scene, renderer, camera, controls;
    var terrain, terrainMaterial, terrainUniforms, terrainAttributes, start = Date.now();


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
        // BOTTOM
        //--------------------------------

        //geometry
        var terrainGeometry = new THREE.PlaneBufferGeometry( 200, 200, 100, 100 );
        
        //shader variables
        terrainUniforms = 
        {   
            time: 
            {
                type: "f",  //float
                value: 0.0  //initialized to 0
            }
        }
        terrainAttributes = 
        {
            /*
            displacement:
            {
                type: 'f',  //float
                value: []   //empty array
            }*/
        }

        //material
        terrainMaterial = new THREE.ShaderMaterial( 
        {
            uniforms: terrainUniforms,
            attributes: terrainAttributes,
            vertexShader: noise + vertexShader,
            fragmentShader: noise + fragmentShader
        } );

        //create the water and add it to the scene
        terrain = new THREE.Mesh( terrainGeometry, terrainMaterial );
        terrain.position.set(0, 0, 0);
        scene.add( terrain );
        terrain.rotation.x = - Math.PI/2;
      

        controls = new THREE.OrbitControls(camera, renderer.domElement);
      

    	container.innerHTML = "";
        document.body.appendChild( renderer.domElement );       
    }


    function animate() 
    {
        requestAnimationFrame( animate );
        terrainUniforms.time.value +=  0.01;
        
        
    	renderer.render( scene, camera );		
        controls.update();

    }
});