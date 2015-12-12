//Isabell Jansson

var scene, renderer, plane;


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
	renderer = new THREE.WebGLRenderer(container);
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
	render();		

}

function render() 
{	
	renderer.render( scene, camera );
}