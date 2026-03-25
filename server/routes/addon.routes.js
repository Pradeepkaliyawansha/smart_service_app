const express = require("express");
const router = express.Router();
const {
  getAddons,
  getAddon,
  createAddon,
  updateAddon,
  deleteAddon,
} = require("../controllers/addon.controller");
const { protect, adminOnly } = require("../middleware/auth.middleware");

router.get("/", getAddons); // public
router.get("/:id", getAddon); // public
router.post("/", protect, adminOnly, createAddon); // admin
router.put("/:id", protect, adminOnly, updateAddon); // admin
router.delete("/:id", protect, adminOnly, deleteAddon); // admin

module.exports = router;
