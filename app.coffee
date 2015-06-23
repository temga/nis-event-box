$ = require './assets/jquery'
THREE = require './node_modules/THREE'
socketD = require './node_modules/socket.io-client'

socketC = null
speed = 0
WIDTH = window.innerWidth
HEIGHT = window.innerHeight

renderer = new THREE.WebGLRenderer()
renderer.setSize WIDTH, HEIGHT
renderer.setClearColor(0xFFFFFF, 1)

scene = new THREE.Scene()

camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1500)
camera.position.z = 500

grass = THREE.ImageUtils.loadTexture('images/grass.jpg')
grassMat = new THREE.MeshBasicMaterial({map:grass})

grassGeo = new THREE.PlaneGeometry(1500, 1500)

road = THREE.ImageUtils.loadTexture('images/asp.jpg')
roadMat = new THREE.MeshBasicMaterial({map:road})

roadGeo = new THREE.PlaneGeometry(500, 1500)

asphalt = new THREE.Mesh(roadGeo, roadMat)
asphalt.position.y = -99.9
asphalt.rotation.x = -Math.PI/2
asphalt.doubleSided = true
scene.add(asphalt)

ground = new THREE.Mesh(grassGeo,grassMat)
ground.position.y = -100
ground.rotation.x = -Math.PI/2
ground.doubleSided = true
scene.add(ground)

loader = new THREE.OBJLoader()

girl = new THREE.Mesh()

loader.load '/obj/IronMan.obj', (object)->
  object.position.y = -100
  girl = object
  scene.add(girl)

urls = [
  "images/text.jpg",
  "images/text.jpg",
  "images/text.jpg",
  "images/text.jpg",
  "images/text.jpg",
  "images/text.jpg",
]
textureCube = THREE.ImageUtils.loadTextureCube(urls)

shader = THREE.ShaderLib["cube"]
shader.uniforms['tCube'].value = textureCube
material = new THREE.ShaderMaterial({
  fragmentShader : shader.fragmentShader,
  vertexShader   : shader.vertexShader,
  uniforms       : shader.uniforms
  side           : THREE.BackSide
})

skybox = new THREE.Mesh(new THREE.BoxGeometry( 1500, 1500, 1500) ,material)
skybox.flipSided= true
skybox.position.z = 0

scene.add skybox

light = new THREE.SpotLight()
light.position.set(0,500,-500)
scene.add(light)

draw = ->
  girl.position.z -= speed
  console.log speed
  girl.rotation.y += speed
  camera.position.z = girl.position.z + 500
  renderer.render scene, camera
  requestAnimationFrame(draw)

$("#gameCanvas").append renderer.domElement

$(document).ready =>
  socketC = socketD.connect 'http://localhost:3000'
  socketC.on 'position', (pos)=>
    speed += pos
  draw()
  return
