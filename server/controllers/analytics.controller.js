const Booking = require("../models/Booking");
const Service = require("../models/Service");
const Addon = require("../models/Addon");
const User = require("../models/User");

// GET /api/analytics  (admin only)
const getAnalytics = async (req, res) => {
  try {
    const [
      totalBookings,
      totalServices,
      totalUsers,
      totalAdmins,
      bookings,
      topAddons,
    ] = await Promise.all([
      Booking.countDocuments(),
      Service.countDocuments(),
      User.countDocuments({ role: "user" }),
      User.countDocuments({ role: "admin" }),
      // FIX: Use .lean() to get plain objects — avoids ObjectId serialization issues
      Booking.find().sort({ createdAt: -1 }).lean(),
      Addon.find().sort({ selectCount: -1 }).limit(10).lean(),
    ]);

    // Revenue totals
    const totalRevenue = bookings.reduce((s, b) => s + (b.totalPrice || 0), 0);
    const totalDiscounts = bookings.reduce(
      (s, b) => s + (b.discountAmount || 0),
      0,
    );

    // Status breakdown
    const statusCounts = bookings.reduce((acc, b) => {
      acc[b.status] = (acc[b.status] || 0) + 1;
      return acc;
    }, {});

    // Revenue by service
    const revenueByService = bookings.reduce((acc, b) => {
      const name = b.serviceName || "Unknown";
      acc[name] = (acc[name] || 0) + (b.totalPrice || 0);
      return acc;
    }, {});

    // Bookings over the last 7 days
    const now = new Date();
    const last7Days = Array.from({ length: 7 }, (_, i) => {
      const d = new Date(now);
      d.setDate(d.getDate() - i);
      return d.toISOString().split("T")[0];
    }).reverse();

    const bookingsByDay = last7Days.map((day) => ({
      date: day,
      count: bookings.filter(
        (b) =>
          b.createdAt &&
          new Date(b.createdAt).toISOString().split("T")[0] === day,
      ).length,
      revenue: bookings
        .filter(
          (b) =>
            b.createdAt &&
            new Date(b.createdAt).toISOString().split("T")[0] === day,
        )
        .reduce((s, b) => s + (b.totalPrice || 0), 0),
    }));

    // Most booked combos (by add-on combo fingerprint)
    const comboCounts = bookings.reduce((acc, b) => {
      if (!b.selectedAddonNames || !b.selectedAddonNames.length) return acc;
      const key = [...b.selectedAddonNames].sort().join(" + ");
      acc[key] = (acc[key] || 0) + 1;
      return acc;
    }, {});

    const topCombos = Object.entries(comboCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([combo, count]) => ({ combo, count }));

    res.json({
      overview: {
        totalBookings,
        totalRevenue,
        totalDiscounts,
        totalServices,
        totalUsers,
        totalAdmins,
        averageOrderValue: totalBookings ? totalRevenue / totalBookings : 0,
      },
      statusBreakdown: statusCounts,
      revenueByService,
      bookingsByDay,
      topAddons: topAddons.map((a) => ({
        name: a.name,
        icon: a.icon,
        selectCount: a.selectCount,
        price: a.price,
      })),
      topCombos,
    });
  } catch (err) {
    console.error("Analytics error:", err);
    res.status(500).json({ message: err.message });
  }
};

module.exports = { getAnalytics };
