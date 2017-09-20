var express = require('express');
var router = express.Router();
var GPIO_function = require("../GPIO_function/GPIO_function");
router.get('/left', function (req, res, next) {
    GPIO_function.turn_left();
    res.json({ result: "turn left", err: "null" });
});

router.get('/right', function (req, res, next) {
    GPIO_function.turn_riht();
    res.json({ rsult: "turn right", err: "null" });
});

router.get('/straight', function (req, res, next) {
    GPIO_function.straight();
    res.json({ result: "go straight", err: "null" });
});

router.get('/rotate', function (req, res, next) {
    GPIO_function.rotate();
    res.json({ result: "rotate", err: "null" });
});

module.exports = router;
