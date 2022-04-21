const router = require('express').Router();
const pkg = require('../package.json');

router.use((req, res, next) => {
  console.log(JSON.stringify({
    url: `${req.method} ${req.url}`,
    body: req.body
  }, null, 2));
  return next();
});

router.get('/status', (req, res) => {
  const env = {};
  Object.keys(process.env).filter(x => (x && x.trim().toUpperCase() === x)).sort().forEach(key => {
    env[key] = process.env[key];
  });

  res.json({
    name: pkg.name,
    desc: pkg.description,
    ver:  pkg.version,
    date: (new Date()).toISOString(),
    env
  });
});

router.get('/', (req, res) => {
  res.json({
    name: pkg.name,
    desc: pkg.description,
    ver:  pkg.version,
    date: (new Date()).toISOString()
  });
});

module.exports = router;

