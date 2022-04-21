require('dotenv').config();

const express = require('express');
const pkg = require('../package.json');
const routes = require('./routes');

const app = express();
app.use(express.json({limit: '50mb'}));
app.use(express.urlencoded({ limit: '50mb', extended: false }));
app.use(routes);

const NODE_PORT = process.env.NODE_PORT || 3000;

app.use((err, req, res, next) => {
  console.error(err.stack)
  res.status(500).send('Something broke!')
})

app.listen(NODE_PORT, (err) => {
  if (err) { throw err; }
  console.info(`${pkg.description || pkg.name} v${pkg.version}`);
  console.info(`PORT: ${NODE_PORT}`);
});
