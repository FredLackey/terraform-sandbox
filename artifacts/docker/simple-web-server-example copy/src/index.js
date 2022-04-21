const http = require('http');

const NODE_PORT = process.env.NODE_PORT || 3000;

const listener = (req, res) => {
  console.log(`Request at ${new Date()}`)
  res.writeHead(200);
  res.end('Server Functional');
};

const server = http.createServer(listener);
server.listen(NODE_PORT, () => {
  console.log(`NODE_PORT: ${NODE_PORT}`)
});
