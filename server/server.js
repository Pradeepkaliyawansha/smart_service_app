require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const morgan = require("morgan");

const authRoutes = require("./routes/auth.routes");
const serviceRoutes = require("./routes/service.routes");
const addonRoutes = require("./routes/addon.routes");
const bookingRoutes = require("./routes/booking.routes");
const analyticsRoutes = require("./routes/analytics.routes");
const priceRoutes = require("./routes/price.routes");

const app = express();

// ─── Middleware ───────────────────────────────────────────────────────────────

// FIX: Mobile apps (Flutter/Dio) don't send an Origin header.
// The previous CORS config blocked requests without an origin when
// ALLOWED_ORIGINS was set. Now we always allow origin-less requests
// (mobile apps, Postman, curl) and only gate browser-based origins.
const allowedOrigins = (process.env.ALLOWED_ORIGINS || "")
  .split(",")
  .map((o) => o.trim())
  .filter(Boolean); // remove empty strings

app.use(
  cors({
    origin: (origin, callback) => {
      // No origin = mobile app, Postman, curl — always allow
      if (!origin) {
        return callback(null, true);
      }
      // If no allowed origins configured, allow all
      if (allowedOrigins.length === 0) {
        return callback(null, true);
      }
      // Check against allowed list
      if (allowedOrigins.includes(origin)) {
        return callback(null, true);
      }
      callback(new Error(`CORS blocked: ${origin}`));
    },
    credentials: true,
  }),
);

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

if (process.env.NODE_ENV !== "production") {
  app.use(morgan("dev"));
}

// ─── Routes ───────────────────────────────────────────────────────────────────

app.get("/health", (_, res) =>
  res.json({ status: "ok", timestamp: new Date() }),
);

app.use("/api/auth", authRoutes);
app.use("/api/services", serviceRoutes);
app.use("/api/addons", addonRoutes);
app.use("/api/bookings", bookingRoutes);
app.use("/api/analytics", analyticsRoutes);
app.use("/api", priceRoutes);

// ─── 404 ──────────────────────────────────────────────────────────────────────

app.use((req, res) => {
  res.status(404).json({ message: `Route not found: ${req.originalUrl}` });
});

// ─── Global error handler ─────────────────────────────────────────────────────

// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  console.error("❌ Error:", err.message);
  res.status(err.status || 500).json({
    message: err.message || "Internal server error",
  });
});

// ─── DB + Start ───────────────────────────────────────────────────────────────

const PORT = process.env.PORT || 5000;

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    console.log("✅ MongoDB connected");
    app.listen(PORT, "0.0.0.0", () => {
      console.log(`🚀 Server running on http://0.0.0.0:${PORT}`);
    });
  })
  .catch((err) => {
    console.error("❌ MongoDB connection failed:", err.message);
    process.exit(1);
  });
