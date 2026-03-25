const mongoose = require("mongoose");

const addonSchema = new mongoose.Schema(
  {
    serviceId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Service",
      required: [true, "Service ID is required"],
    },
    name: {
      type: String,
      required: [true, "Add-on name is required"],
      trim: true,
    },
    description: {
      type: String,
      required: [true, "Description is required"],
      trim: true,
    },
    price: {
      type: Number,
      required: [true, "Price is required"],
      min: 0,
    },
    icon: {
      type: String,
      default: "⚙️",
    },
    isPopular: {
      type: Boolean,
      default: false,
    },
    selectCount: {
      type: Number,
      default: 0,
    },
  },
  { timestamps: true },
);

module.exports = mongoose.model("Addon", addonSchema);
