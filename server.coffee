global.express = require('express')
global.app = app = express()

exec = require('child_process').exec


app.set('view engine', 'ejs')
app.use(express.static('public'));

app.get '/', (req, res) ->
  exec ' browserify -t coffeeify app.coffee > ./public/js/app.js', ->
    res.render 'main', layout : false

server = app.listen 3000, ->
  console.log("app listening at %d", server.address().port)

io = require('socket.io/')(server)

io.on 'connection', (socket)->
  console.log "User connect"

setInterval ->
  io.emit('position', 0.005)
,1000