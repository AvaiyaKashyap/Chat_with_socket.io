const express = require('express');

const app = express();
const PORT = process.env.PORT || 4000;
const server = app.listen(PORT,()=>{
    console.log('server is Started on', PORT);
});

const io = require('socket.io')(server)

io.on('connection',(socket) => {
    console.log("Connected Successfully",socket.id);
    socket.on('disconnect',()=> {
        console.log("Disconnected",socket.id);
    });

    socket.on('message',(data)=>{
        console.log(data);
        socket.broadcast.emit('message-receive',data);
    })
});


// const express = require('express');
// const app = express();
// const http = require('http');
// const server = http.createServer(app);
// const { Server } = require("socket.io");
// const io = new Server(server);
// const messages = []


// io.on('connection', (socket) => {
//   const username = socket.handshake.query.username
//   socket.on('message', (data) => {
//     const message = {
//       message: data.message,
//       senderUsername: username,
//       sentAt: Date.now()
//     }
//     messages.push(message)
//     io.emit('message', message)

//   })
// });

// server.listen(3000, () => {
//   console.log('listening on *:3000');
// });