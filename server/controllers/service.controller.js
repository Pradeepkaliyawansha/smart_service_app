const Service = require("../models/Service");

// GET /api/services
const getServices = async (req, res) => {
  try {
    const { category, active } = req.query;
    const filter = {};
    if (category) filter.category = category;
    if (active !== undefined) filter.isActive = active === "true";

    const services = await Service.find(filter)
      .populate("addons")
      .sort({ bookingCount: -1, createdAt: -1 });

    res.json({ services });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET /api/services/:id
const getService = async (req, res) => {
  try {
    const service = await Service.findById(req.params.id).populate("addons");
    if (!service) return res.status(404).json({ message: "Service not found" });
    res.json({ service });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// POST /api/services  (admin only)
const createService = async (req, res) => {
  try {
    const {
      name,
      description,
      basePrice,
      pricePerHour,
      category,
      imageUrl,
      tags,
      minHours,
      maxHours,
    } = req.body;

    const service = await Service.create({
      name,
      description,
      basePrice,
      pricePerHour,
      category,
      imageUrl,
      tags,
      minHours,
      maxHours,
      createdBy: req.user._id,
    });

    // Populate addons (will be empty initially)
    await service.populate("addons");

    res.status(201).json({ service });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// PUT /api/services/:id  (admin only)
const updateService = async (req, res) => {
  try {
    const service = await Service.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    }).populate("addons");

    if (!service) return res.status(404).json({ message: "Service not found" });
    res.json({ service });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// DELETE /api/services/:id  (admin only)
const deleteService = async (req, res) => {
  try {
    const service = await Service.findByIdAndDelete(req.params.id);
    if (!service) return res.status(404).json({ message: "Service not found" });
    res.json({ message: "Service deleted" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

module.exports = {
  getServices,
  getService,
  createService,
  updateService,
  deleteService,
};
