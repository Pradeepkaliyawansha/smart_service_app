require("dotenv").config();
const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");

const User = require("./models/User");
const Service = require("./models/Service");
const Addon = require("./models/Addon");
const Booking = require("./models/Booking");

const seed = async () => {
  await mongoose.connect(process.env.MONGO_URI);
  console.log("✅ Connected to MongoDB");

  // Clear existing data
  await Promise.all([
    User.deleteMany({}),
    Service.deleteMany({}),
    Addon.deleteMany({}),
    Booking.deleteMany({}),
  ]);
  console.log("🧹 Cleared existing data");

  // ─── Users ────────────────────────────────────────────────────────────────
  const adminUser = await User.create({
    name: "Admin User",
    email: "admin@demo.com",
    password: "demo123",
    role: "admin",
  });

  const customerUser = await User.create({
    name: "John Customer",
    email: "user@demo.com",
    password: "demo123",
    role: "user",
  });

  console.log("👤 Users created");

  // ─── Services ─────────────────────────────────────────────────────────────
  const photoService = await Service.create({
    name: "Professional Photography",
    description:
      "High-quality photography sessions for weddings, events, portraits and more.",
    basePrice: 5000,
    pricePerHour: 2000,
    category: "photography",
    tags: ["photography", "wedding", "event", "portrait"],
    minHours: 2,
    maxHours: 12,
    isActive: true,
    bookingCount: 48,
    createdBy: adminUser._id,
  });

  const videoService = await Service.create({
    name: "Videography Package",
    description:
      "Professional video production including filming, editing and color grading.",
    basePrice: 8000,
    pricePerHour: 3500,
    category: "videography",
    tags: ["video", "filming", "editing", "production"],
    minHours: 3,
    maxHours: 16,
    isActive: true,
    bookingCount: 29,
    createdBy: adminUser._id,
  });

  const aquaService = require("./models/Service");
  const fishService = await Service.create({
    name: "Aquaculture Consulting",
    description:
      "Expert consultation on fish farming, water quality, disease management and yield optimization.",
    basePrice: 3500,
    pricePerHour: 1500,
    category: "aquaculture",
    tags: ["fish", "farming", "consulting", "water"],
    minHours: 1,
    maxHours: 8,
    isActive: true,
    bookingCount: 15,
    createdBy: adminUser._id,
  });

  const eventService = await Service.create({
    name: "Event Management",
    description:
      "End-to-end event planning and coordination for corporate events, birthdays, and celebrations.",
    basePrice: 10000,
    pricePerHour: 2500,
    category: "event",
    tags: ["events", "planning", "coordination", "corporate"],
    minHours: 4,
    maxHours: 24,
    isActive: true,
    bookingCount: 22,
    createdBy: adminUser._id,
  });

  console.log("🛠️  Services created");

  // ─── Add-ons: Photography ─────────────────────────────────────────────────
  const photoAddons = await Addon.insertMany([
    {
      serviceId: photoService._id,
      name: "Drone Aerial Shots",
      description: "Stunning aerial photography using professional drones.",
      price: 3500,
      icon: "🚁",
      isPopular: true,
      selectCount: 31,
    },
    {
      serviceId: photoService._id,
      name: "Photo Editing & Retouching",
      description:
        "Professional post-processing and colour grading of all photos.",
      price: 2000,
      icon: "✏️",
      isPopular: true,
      selectCount: 44,
    },
    {
      serviceId: photoService._id,
      name: "Second Photographer",
      description: "An additional photographer to capture every angle.",
      price: 4000,
      icon: "📷",
      isPopular: false,
      selectCount: 18,
    },
    {
      serviceId: photoService._id,
      name: "Printed Album (40 pages)",
      description: "Luxury hardcover photo album with 40 premium pages.",
      price: 5000,
      icon: "📖",
      isPopular: false,
      selectCount: 12,
    },
    {
      serviceId: photoService._id,
      name: "Same-Day Highlights",
      description: "A curated set of edited photos delivered on the same day.",
      price: 1500,
      icon: "⚡",
      isPopular: true,
      selectCount: 26,
    },
    {
      serviceId: photoService._id,
      name: "Social Media Package",
      description:
        "Optimized photos sized and captioned for Instagram, Facebook & more.",
      price: 1000,
      icon: "📱",
      isPopular: false,
      selectCount: 20,
    },
  ]);

  // ─── Add-ons: Videography ─────────────────────────────────────────────────
  await Addon.insertMany([
    {
      serviceId: videoService._id,
      name: "Drone Video Footage",
      description: "Cinematic aerial video shots with 4K drone.",
      price: 4500,
      icon: "🚁",
      isPopular: true,
      selectCount: 22,
    },
    {
      serviceId: videoService._id,
      name: "Professional Audio Recording",
      description: "High-quality audio capture with professional microphones.",
      price: 2000,
      icon: "🎤",
      isPopular: false,
      selectCount: 14,
    },
    {
      serviceId: videoService._id,
      name: "Colour Grading",
      description: "Cinematic colour grading to match your desired look.",
      price: 3000,
      icon: "🎨",
      isPopular: true,
      selectCount: 19,
    },
    {
      serviceId: videoService._id,
      name: "Motion Graphics & Titles",
      description: "Animated lower thirds, title cards and transitions.",
      price: 2500,
      icon: "✨",
      isPopular: false,
      selectCount: 10,
    },
    {
      serviceId: videoService._id,
      name: "Express Delivery (48h)",
      description: "Receive your finished video within 48 hours.",
      price: 3500,
      icon: "🚚",
      isPopular: true,
      selectCount: 17,
    },
  ]);

  // ─── Add-ons: Aquaculture ─────────────────────────────────────────────────
  await Addon.insertMany([
    {
      serviceId: fishService._id,
      name: "Water Quality Analysis",
      description: "Full chemical and biological water quality testing report.",
      price: 2500,
      icon: "🌊",
      isPopular: true,
      selectCount: 12,
    },
    {
      serviceId: fishService._id,
      name: "Fish Disease Diagnosis",
      description:
        "On-site diagnosis and treatment plan for common fish diseases.",
      price: 2000,
      icon: "🔬",
      isPopular: false,
      selectCount: 8,
    },
    {
      serviceId: fishService._id,
      name: "Feed Optimization Report",
      description:
        "Customized feeding schedule and nutrition plan for maximum yield.",
      price: 1500,
      icon: "🐟",
      isPopular: true,
      selectCount: 10,
    },
    {
      serviceId: fishService._id,
      name: "Pond Infrastructure Review",
      description: "Structural assessment and recommendations for pond setup.",
      price: 3000,
      icon: "🏗️",
      isPopular: false,
      selectCount: 5,
    },
  ]);

  // ─── Add-ons: Event ───────────────────────────────────────────────────────
  await Addon.insertMany([
    {
      serviceId: eventService._id,
      name: "Sound System & DJ",
      description: "Professional PA system and DJ services for the event.",
      price: 6000,
      icon: "🔊",
      isPopular: true,
      selectCount: 18,
    },
    {
      serviceId: eventService._id,
      name: "Floral Decoration",
      description: "Custom floral arrangements and table centrepieces.",
      price: 8000,
      icon: "🌸",
      isPopular: true,
      selectCount: 15,
    },
    {
      serviceId: eventService._id,
      name: "Catering (50 pax)",
      description: "Buffet-style catering for up to 50 guests.",
      price: 25000,
      icon: "🍽️",
      isPopular: false,
      selectCount: 9,
    },
    {
      serviceId: eventService._id,
      name: "LED Backdrop",
      description:
        "Full HD LED display backdrop for presentations or ambiance.",
      price: 5000,
      icon: "💡",
      isPopular: false,
      selectCount: 7,
    },
    {
      serviceId: eventService._id,
      name: "MC / Emcee",
      description: "Professional bilingual emcee to host your event.",
      price: 4000,
      icon: "🎙️",
      isPopular: true,
      selectCount: 13,
    },
  ]);

  console.log("⚡ Add-ons created");

  // ─── Sample Bookings ───────────────────────────────────────────────────────
  await Booking.create({
    userId: customerUser._id,
    serviceId: photoService._id,
    serviceName: "Professional Photography",
    packageName: "Wedding Photography Bundle",
    selectedAddonIds: [
      photoAddons[0]._id,
      photoAddons[1]._id,
      photoAddons[4]._id,
    ],
    selectedAddonNames: [
      "Drone Aerial Shots",
      "Photo Editing & Retouching",
      "Same-Day Highlights",
    ],
    durationHours: 8,
    basePrice: 21000, // basePrice + 8h * pricePerHour
    addonsTotal: 7000,
    discountAmount: 2800,
    totalPrice: 25200,
    status: "confirmed",
    eventDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
    notes: "Beach location, sunset timing preferred",
  });

  await Booking.create({
    userId: customerUser._id,
    serviceId: videoService._id,
    serviceName: "Videography Package",
    packageName: "Corporate Video Package",
    selectedAddonIds: [],
    selectedAddonNames: [],
    durationHours: 5,
    basePrice: 25500,
    addonsTotal: 0,
    discountAmount: 0,
    totalPrice: 25500,
    status: "pending",
    eventDate: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000),
    notes: null,
  });

  await Booking.create({
    userId: customerUser._id,
    serviceId: eventService._id,
    serviceName: "Event Management",
    packageName: "Birthday Bash Premium",
    selectedAddonIds: [],
    selectedAddonNames: [
      "Sound System & DJ",
      "Floral Decoration",
      "MC / Emcee",
    ],
    durationHours: 6,
    basePrice: 25000,
    addonsTotal: 17000,
    discountAmount: 4200,
    totalPrice: 37800,
    status: "completed",
    eventDate: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
    notes: "Great event!",
  });

  console.log("📋 Sample bookings created");
  console.log("\n🎉 Database seeded successfully!");
  console.log("─────────────────────────────────────");
  console.log("Demo Credentials:");
  console.log("  Admin  → admin@demo.com / demo123");
  console.log("  User   → user@demo.com  / demo123");
  console.log("─────────────────────────────────────");

  await mongoose.disconnect();
  process.exit(0);
};

seed().catch((err) => {
  console.error("❌ Seed failed:", err);
  process.exit(1);
});
