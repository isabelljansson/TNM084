//Isabell Jansson

require([
    "../libs/text!../shaders/vertexShader.glsl",
    "../libs/text!../shaders/fragmentShader.glsl",
    "../libs/text!../shaders/simplex-noise-3d.glsl"
],

function (
    VertexShader,
    FragmentShader,
    Noise) 
{
    "use strict";


    var scene, renderer, camera;
    var plane, material, waterUniforms, waterAttributes, start = Date.now();


    init();
    animate();


    //initialize scene
    function init() 
    {

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

        //light
        // add subtle ambient lighting
    	var light = new THREE.PointLight(0xffffff);
    	light.position.set(0,250,0);
    	scene.add(light);

        /*
         * WATER
         */

         //geometry
        var geometry = new THREE.PlaneGeometry( 200, 200, 100, 100 );
        
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
        material = new THREE.ShaderMaterial( 
        {
            uniforms: waterUniforms,
            attributes: waterAttributes,
            vertexShader: Noise + VertexShader,
            fragmentShader: FragmentShader
        } );

        plane = new THREE.Mesh( geometry, material );
        plane.position.set(0, -50, -100);
    	scene.add( plane );
    	plane.rotation.x = - Math.PI/2;
      
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

    }
});