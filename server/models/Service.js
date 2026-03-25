const mongoose = require("mongoose");

const serviceSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Service name is required"],
      trim: true,
    },
    description: {
      type: String,
      required: [true, "Description is required"],
      trim: true,
    },
    basePrice: {
      type: Number,
      required: [true, "Base price is required"],
      min: 0,
    },
    pricePerHour: {
      type: Number,
      required: [true, "Price per hour is required"],
      min: 0,
    },
    category: {
      type: String,
      enum: [
        "photography",
        "videography",
        "aquaculture",
        "event",
        "construction",
        "custom",
      ],
      default: "custom",
    },
    imageUrl: {
      type: String,
      default: null,
    },
    tags: {
      type: [String],
      default: [],
    },
    minHours: {
      type: Number,
      default: 1,
      min: 1,
    },
    maxHours: {
      type: Number,
      default: 24,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    bookingCount: {
      type: Number,
      default: 0,
    },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  },
);

// Virtual: populate addons when fetching a service
serviceSchema.virtual("addons", {
  ref: "Addon",
  localField: "_id",
  foreignField: "serviceId",
});

module.exports = mongoose.model("Service", serviceSchema);
