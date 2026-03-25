const Service = require("../models/Service");
const Addon = require("../models/Addon");

const DISCOUNT_THRESHOLD = 3; // min addons for 10% off
const DISCOUNT_RATE = 0.1;
const BULK_DISCOUNT_RATE = 0.15; // 5+ addons = 15% off

/**
 * POST /api/calculate-price
 * Body: { serviceId, durationHours, addonIds[] }
 */
const calculatePrice = async (req, res) => {
  try {
    const { serviceId, durationHours, addonIds = [] } = req.body;

    if (!serviceId || !durationHours) {
      return res
        .status(400)
        .json({ message: "serviceId and durationHours are required" });
    }

    // Fetch service
    const service = await Service.findById(serviceId);
    if (!service) return res.status(404).json({ message: "Service not found" });

    // Fetch selected addons
    const addons = addonIds.length
      ? await Addon.find({ _id: { $in: addonIds }, serviceId })
      : [];

    // ── Base calculation ──────────────────────────────────────────────────────

    const basePrice = service.basePrice;
    const durationCost = service.pricePerHour * Number(durationHours);
    const addonsCost = addons.reduce((sum, a) => sum + a.price, 0);
    const subtotal = basePrice + durationCost + addonsCost;

    // ── Smart discount logic ──────────────────────────────────────────────────

    let discountRate = 0;
    let discountReason = null;

    const itemCount = addons.length;
    if (itemCount >= 5) {
      discountRate = BULK_DISCOUNT_RATE;
      discountReason = `${BULK_DISCOUNT_RATE * 100}% off — Premium bundle!`;
    } else if (itemCount >= DISCOUNT_THRESHOLD) {
      discountRate = DISCOUNT_RATE;
      discountReason = `${DISCOUNT_RATE * 100}% off — Multi-item deal!`;
    }

    const discountAmount = subtotal * discountRate;
    const totalPrice = subtotal - discountAmount;

    // ── Smart recommendations ─────────────────────────────────────────────────

    let recommendation = null;
    let isBestValue = false;
    let isMostPopular = false;

    const popularCount = addons.filter((a) => a.isPopular).length;

    if (itemCount >= 3 && itemCount <= 5 && Number(durationHours) >= 3) {
      isBestValue = true;
      recommendation = "🏆 Best Value Combo — Great balance of features!";
    }

    if (popularCount >= 2) {
      isMostPopular = true;
      recommendation = recommendation ?? "🔥 Most Chosen Package by customers!";
    }

    if (discountRate > 0 && !recommendation) {
      recommendation = `💡 You qualify for a ${discountRate * 100}% bundle discount!`;
    }

    res.json({
      basePrice,
      durationCost,
      addonsCost,
      subtotal,
      discountAmount,
      discountRate,
      discountReason,
      totalPrice,
      recommendation,
      isBestValue,
      isMostPopular,
      addonCount: itemCount,
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

module.exports = { calculatePrice };
