var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function(req, res, next) {
  res.send({thanh:"dm thanh"});
});

module.exports = router;
