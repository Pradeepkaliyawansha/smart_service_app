const express = require("express");
const router = express.Router();
const {
  createBooking,
  getMyBookings,
  getAllBookings,
  getBooking,
  updateBookingStatus,
  deleteBooking,
} = require("../controllers/booking.controller");
const { protect, adminOnly } = require("../middleware/auth.middleware");

router.post("/", protect, createBooking); // any user
router.get("/my", protect, getMyBookings); // own bookings
router.get("/", protect, adminOnly, getAllBookings); // admin: all
router.get("/:id", protect, getBooking); // owner or admin
router.patch("/:id/status", protect, adminOnly, updateBookingStatus); // admin
router.delete("/:id", protect, adminOnly, deleteBooking); // admin

module.exports = router;
