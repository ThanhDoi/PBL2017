var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.send({tan:"totemo hansamu"});
});

module.exports = router;
