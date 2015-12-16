//Isabell Jansson

require([
    "../libs/text!../shaders/wVertexShader.glsl",
    "../libs/text!../shaders/wFragmentShader.glsl",
    "../libs/text!../shaders/bVertexShader.glsl",
    "../libs/text!../shaders/bFragmentShader.glsl",
    "../libs/text!../shaders/simplex-noise-3d.glsl",
    "../libs/orbit-controls"
],

function (
    waterVertexShader,
    waterFragmentShader,
    bottomVertexShader,
    bottomFragmentShader,
    Noise) 
{
    "use strict";


    var scene, renderer, camera, controls;
    var water, waterMaterial, waterUniforms, waterAttributes, start = Date.now();
    var bottom, bottomMaterial, bottomUniforms, bottomAttributes;


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
        camera.position.set(0, 40, 100);
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
        // WATER
        //--------------------------------

        //geometry
        var waterGeometry = new THREE.PlaneGeometry( 200, 200, 100, 100 );
        
        //shader variables
        waterUniforms = 
        { 
            time: 
            {
                type: "f",  //float
                value: 0.0  //initialized to 0
            }
        }
        waterAttributes = 
        {
            displacement:
            {
                type: 'f',  //float
                value: []   //empty array
            }
        }

        //material
        waterMaterial = new THREE.ShaderMaterial( 
        {
            uniforms: waterUniforms,
            attributes: waterAttributes,
            vertexShader: Noise + waterVertexShader,
            fragmentShader: waterFragmentShader
        } );

        //create the water and add it to the scene
        water = new THREE.Mesh( waterGeometry, waterMaterial );
        water.position.set(0, -50, -100);
    	scene.add( water );
    	water.rotation.x = - Math.PI/2;


        //--------------------------------
        // BOTTOM
        //--------------------------------

        //geometry
        var bottomGeometry = new THREE.PlaneGeometry( 200, 200, 100, 100 );
        
        //shader variables
        bottomUniforms = 
        {   
            /*time: 
            {
                type: "f",  //float
                value: 0.0  //initialized to 0
            }*/
        }
        bottomAttributes = 
        {
            displacement:
            {
                type: 'f',  //float
                value: []   //empty array
            }
        }

        //material
        bottomMaterial = new THREE.ShaderMaterial( 
        {
            uniforms: bottomUniforms,
            attributes: bottomAttributes,
            vertexShader: Noise + bottomVertexShader,
            fragmentShader: Noise + bottomFragmentShader
        } );

        //create the water and add it to the scene
        bottom = new THREE.Mesh( bottomGeometry, bottomMaterial );
        bottom.position.set(0, -50, -100);
        scene.add( bottom );
        bottom.rotation.x = - Math.PI/2;
      

        controls = new THREE.OrbitControls(camera);
    	container.innerHTML = "";
        document.body.appendChild( renderer.domElement );       
    }


    function animate() 
    {
        requestAnimationFrame( animate );
        waterUniforms.time.value +=  0.01;
        //material.attributes.displacement.value += Math.sin(10.0);
        //Another way to increase time: = .00025 * ( Date.now() - start );
        
    	renderer.render( scene, camera );		
        controls.update();

    }
});