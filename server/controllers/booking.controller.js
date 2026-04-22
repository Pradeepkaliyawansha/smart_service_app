const Booking = require("../models/Booking");

// POST /api/bookings
const createBooking = async (req, res) => {
  try {
    const {
      serviceId,
      serviceName,
      packageName,
      selectedAddonIds,
      selectedAddonNames,
      durationHours,
      basePrice,
      addonsTotal,
      discountAmount,
      totalPrice,
      eventDate,
      notes,
    } = req.body;

    const booking = await Booking.create({
      userId: req.user._id,
      serviceId,
      serviceName,
      packageName: packageName || "My Package",
      selectedAddonIds: selectedAddonIds || [],
      selectedAddonNames: selectedAddonNames || [],
      durationHours,
      basePrice,
      addonsTotal: addonsTotal || 0,
      discountAmount: discountAmount || 0,
      totalPrice,
      eventDate: eventDate || null,
      notes: notes || null,
    });

    res.status(201).json({ booking });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET /api/bookings/my  (current user's bookings)
const getMyBookings = async (req, res) => {
  try {
    const bookings = await Booking.find({ userId: req.user._id }).sort({
      createdAt: -1,
    });
    res.json({ bookings });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET /api/bookings  (admin: all bookings)
// FIX: Do NOT populate userId — return the raw ObjectId string so Flutter
// BookingModel.fromJson can parse it as a plain string.
// If you need user info, add a separate "userInfo" field instead.
const getAllBookings = async (req, res) => {
  try {
    const { status, serviceId } = req.query;
    const filter = {};
    if (status) filter.status = status;
    if (serviceId) filter.serviceId = serviceId;

    const bookings = await Booking.find(filter).sort({ createdAt: -1 }).lean(); // lean() returns plain JS objects — faster + no Mongoose overhead

    // Convert ObjectId fields to strings so Flutter can parse them
    const serialized = bookings.map((b) => ({
      ...b,
      _id: b._id.toString(),
      userId: b.userId ? b.userId.toString() : "",
      serviceId: b.serviceId ? b.serviceId.toString() : "",
      selectedAddonIds: (b.selectedAddonIds || []).map((id) => id.toString()),
    }));

    res.json({ bookings: serialized });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET /api/bookings/:id
const getBooking = async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id).lean();
    if (!booking) return res.status(404).json({ message: "Booking not found" });

    // Only admin or the booking owner can view
    const bookingUserId = booking.userId ? booking.userId.toString() : "";
    if (
      req.user.role !== "admin" &&
      bookingUserId !== req.user._id.toString()
    ) {
      return res.status(403).json({ message: "Access denied" });
    }

    const serialized = {
      ...booking,
      _id: booking._id.toString(),
      userId: bookingUserId,
      serviceId: booking.serviceId ? booking.serviceId.toString() : "",
      selectedAddonIds: (booking.selectedAddonIds || []).map((id) =>
        id.toString(),
      ),
    };

    res.json({ booking: serialized });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// PATCH /api/bookings/:id/status  (admin only)
const updateBookingStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const allowed = ["pending", "confirmed", "cancelled", "completed"];
    if (!allowed.includes(status)) {
      return res.status(400).json({ message: "Invalid status" });
    }

    const booking = await Booking.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true },
    ).lean();
    if (!booking) return res.status(404).json({ message: "Booking not found" });

    const serialized = {
      ...booking,
      _id: booking._id.toString(),
      userId: booking.userId ? booking.userId.toString() : "",
      serviceId: booking.serviceId ? booking.serviceId.toString() : "",
      selectedAddonIds: (booking.selectedAddonIds || []).map((id) =>
        id.toString(),
      ),
    };

    res.json({ booking: serialized });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// DELETE /api/bookings/:id  (admin only)
const deleteBooking = async (req, res) => {
  try {
    await Booking.findByIdAndDelete(req.params.id);
    res.json({ message: "Booking deleted" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

module.exports = {
  createBooking,
  getMyBookings,
  getAllBookings,
  getBooking,
  updateBookingStatus,
  deleteBooking,
};
