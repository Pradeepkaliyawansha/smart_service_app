const express = require("express");
const router = express.Router();
const {
  getServices,
  getService,
  createService,
  updateService,
  deleteService,
} = require("../controllers/service.controller");
const { protect, adminOnly } = require("../middleware/auth.middleware");

router.get("/", getServices); // public
router.get("/:id", getService); // public
router.post("/", protect, adminOnly, createService); // admin
router.put("/:id", protect, adminOnly, updateService); // admin
router.delete("/:id", protect, adminOnly, deleteService); // admin

module.exports = router;
