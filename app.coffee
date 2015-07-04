$ = require './assets/jquery'
THREE = require './node_modules/THREE'
socketD = require './node_modules/socket.io-client'
datGui = require './node_modules/dat-gui'
Stats = require './assets/stats'

socketC = null
speed = 0
WIDTH = window.innerWidth
HEIGHT = window.innerHeight

$ ()->
  window.stats = new Stats
  stats.setMode(0)
  stats.domElement.position = 'fixed'
  stats.domElement.left = '0px'
  stats.domElement.top =  '0px'
  $("#stats-output").append stats.domElement
  stats.update()
  stats

#console.log @stats
###statsUpdate = ()->
  @stats.begin()
  @stats.end()###

#requestAnimationFrame statsUpdate

class Cameraz
  constructor: ->
    @rot_x = -0.2
    @pos_y = -20.0
    @pos_z = 100

cameraz = new Cameraz()
gui = new datGui.GUI()
gui.add cameraz, 'rot_x', -1, 0
gui.add cameraz, 'pos_y', -100, 0
gui.add cameraz, 'pos_z', 0, 200

renderer = new THREE.WebGLRenderer()
renderer.setSize WIDTH, HEIGHT
renderer.setClearColor(0xFFFFFF, 1)
renderer.shadowMapEnabled = true

scene = new THREE.Scene()

camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1500)

grass = THREE.ImageUtils.loadTexture('images/grass.jpg')
#grass.wrapS = grass.wrapT = THREE.RepeatWrapping
grass.repeat.set 1,1
grassMat = new THREE.MeshBasicMaterial({map:grass})
grassGeo = new THREE.PlaneGeometry(500, 500)

road = THREE.ImageUtils.loadTexture('images/asp.jpg')
road.minFilter = THREE.LinearFilter
#road.magFilter = THREE.NearestFilter
road.wrapT = road.wrapS = THREE.RepeatWrapping
road.repeat.set 1,10
roadMat = new THREE.MeshBasicMaterial({
  map:road,
  combine: THREE.MixOperation})

roadGeo = new THREE.PlaneGeometry(100, 600)

asphalt = new THREE.Mesh(roadGeo, roadMat)
asphalt.position.y = -99.9
asphalt.rotation.x = -Math.PI/2
asphalt.doubleSided = true
asphalt.receiveShadow = true
scene.add(asphalt)

ground = new THREE.Mesh(grassGeo,grassMat)
ground.position.y = -100
ground.rotation.x = -Math.PI/2
ground.doubleSided = true
scene.add(ground)

loader = new THREE.OBJMTLLoader()

girl = new THREE.Mesh()

loader.load '/obj/tank/Abrams_BF3.obj', '/obj/tank/Abrams_BF3.mtl', (object)->
  object.position.y = -96.0
  object.position.z = 300
  girl = object
  girl.scale.multiplyScalar(10)
  girl.castShadow = true
  scene.add(girl)

urls = [
  "images/sky.jpg",
  "images/sky.jpg",
  "images/sky.jpg",
  "images/sky.jpg",
  "images/sky.jpg",
  "images/sky.jpg",
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

draw = =>
  camera.position.z = cameraz.pos_z
  camera.position.y = cameraz.pos_y
  camera.rotation.x = cameraz.rot_x
  girl.position.z -= speed
  stats.update()
  #girl.rotation.y += speed
  camera.position.z = girl.position.z + cameraz.pos_z
  renderer.render scene, camera
  requestAnimationFrame(draw)

$("#gameCanvas").append renderer.domElement

$(document).ready =>
  socketC = socketD.connect 'http://localhost:3000'
  socketC.on 'position', (pos)=>
    speed += pos
  draw()
  return
