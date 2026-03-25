const mongoose = require("mongoose");

const bookingSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: [true, "User ID is required"],
    },
    serviceId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Service",
      required: [true, "Service ID is required"],
    },
    serviceName: {
      type: String,
      required: true,
    },
    packageName: {
      type: String,
      default: "My Package",
    },
    selectedAddonIds: {
      type: [mongoose.Schema.Types.ObjectId],
      ref: "Addon",
      default: [],
    },
    selectedAddonNames: {
      type: [String],
      default: [],
    },
    durationHours: {
      type: Number,
      required: true,
      min: 1,
    },
    basePrice: {
      type: Number,
      required: true,
    },
    addonsTotal: {
      type: Number,
      default: 0,
    },
    discountAmount: {
      type: Number,
      default: 0,
    },
    totalPrice: {
      type: Number,
      required: true,
    },
    status: {
      type: String,
      enum: ["pending", "confirmed", "cancelled", "completed"],
      default: "pending",
    },
    eventDate: {
      type: Date,
      default: null,
    },
    notes: {
      type: String,
      default: null,
    },
  },
  { timestamps: true },
);

// After a booking is created, increment bookingCount on the service
bookingSchema.post("save", async function () {
  try {
    const Service = require("./Service");
    await Service.findByIdAndUpdate(this.serviceId, {
      $inc: { bookingCount: 1 },
    });
  } catch (_) {}
});

// After a booking is created, increment selectCount on selected addons
bookingSchema.post("save", async function () {
  try {
    const Addon = require("./Addon");
    if (this.selectedAddonIds && this.selectedAddonIds.length) {
      await Addon.updateMany(
        { _id: { $in: this.selectedAddonIds } },
        { $inc: { selectCount: 1 } },
      );
    }
  } catch (_) {}
});

module.exports = mongoose.model("Booking", bookingSchema);
