//Isabell Jansson

var scene, renderer, plane, start = Date.now();


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


    //Init plane
    var geometry = new THREE.PlaneGeometry( 100, 100, 40, 40 );
    
    material = new THREE.ShaderMaterial( {
        //define uniforms to use...
        uniforms: 
        { 
            time: 
            {
                type: "f",  //float
                value: 0.0  //initialized to 0
            }
        },

        vertexShader: document.getElementById( 'vertexShader' ).textContent,
        fragmentShader: document.getElementById( 'fragmentShader' ).textContent
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
    material.uniforms.time.value +=  0.01;
     //Another way to increase time: = .00025 * ( Date.now() - start );
    
	renderer.render( scene, camera );		

}
