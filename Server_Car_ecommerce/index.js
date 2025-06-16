const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const dotenv = require("dotenv");
const { ConnectToMongoDB } = require("./lib/db");
const bookingRoutes = require("./routes/router.bookTestDrive");
const carDataRoutes = require("./routes/router.carData");
const reviewRoutes = require("./routes/routes.reviews");
const blogRoutes = require("./routes/routes.blogs");
const brandRoutes = require("./routes/routes.brands");

dotenv.config();
const app = express();
const PORT = process.env.PORT || 7500;

// Middleware
app.use(
  cors({
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE"],
    credentials: true,
  })
);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Connect to MongoDB
ConnectToMongoDB().catch((error) => {
  console.error(
    "[server] Failed to start server due to MongoDB connection error:",
    {
      errorName: error.name,
      errorMessage: error.message,
      errorStack: error.stack,
      timestamp: new Date().toISOString(),
    }
  );
  process.exit(1);
});

app.get("/", (req, res) => {
  res.json({
    success: true,
    message: "Welcome to the Car Ecommerce API",
  });
});

// Routes
app.use("/api", bookingRoutes);
app.use("/api/carData", carDataRoutes);
app.use("/api/reviews", reviewRoutes);
app.use("/api/blogs", blogRoutes);
app.use("/api/brands", brandRoutes);

// Global error handler
app.use((error, req, res, next) => {
  console.error("[server] Unhandled error:", {
    errorName: error.name,
    errorMessage: error.message,
    errorStack: error.stack,
    request: {
      method: req.method,
      url: req.originalUrl,
      headers: req.headers,
    },
    timestamp: new Date().toISOString(),
  });
  res.status(500).json({
    success: false,
    message: "Internal Server Error",
    error: {
      name: error.name,
      message: error.message,
    },
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
