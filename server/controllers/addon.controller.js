const Addon = require("../models/Addon");

// GET /api/addons?serviceId=xxx
const getAddons = async (req, res) => {
  try {
    const { serviceId } = req.query;
    const filter = serviceId ? { serviceId } : {};
    const addons = await Addon.find(filter).sort({ selectCount: -1 });
    res.json({ addons });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET /api/addons/:id
const getAddon = async (req, res) => {
  try {
    const addon = await Addon.findById(req.params.id);
    if (!addon) return res.status(404).json({ message: "Add-on not found" });
    res.json({ addon });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// POST /api/addons  (admin only)
const createAddon = async (req, res) => {
  try {
    const { serviceId, name, description, price, icon, isPopular } = req.body;
    const addon = await Addon.create({
      serviceId,
      name,
      description,
      price,
      icon,
      isPopular,
    });
    res.status(201).json({ addon });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// PUT /api/addons/:id  (admin only)
const updateAddon = async (req, res) => {
  try {
    const addon = await Addon.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    if (!addon) return res.status(404).json({ message: "Add-on not found" });
    res.json({ addon });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// DELETE /api/addons/:id  (admin only)
const deleteAddon = async (req, res) => {
  try {
    const addon = await Addon.findByIdAndDelete(req.params.id);
    if (!addon) return res.status(404).json({ message: "Add-on not found" });
    res.json({ message: "Add-on deleted" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

module.exports = { getAddons, getAddon, createAddon, updateAddon, deleteAddon };
