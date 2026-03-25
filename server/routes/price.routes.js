const express = require("express");
const router = express.Router();
const { calculatePrice } = require("../controllers/price.controller");
const { protect } = require("../middleware/auth.middleware");

router.post("/calculate-price", protect, calculatePrice);

module.exports = router;
