const mongoose = require("mongoose");

const carDataSchema = new mongoose.Schema({
    name: { type: String, required: true },
    image: { type: String, required: true },
    viewImage: { type: String, default: "assets/degrees.png" },
    compareImage: { type: String, default: "assets/compare.png" },
    compareText: { type: String, default: "Add to compare" },
    moreDetails1: { type: String, default: "Starting at" },
    details1: { type: String, required: true },
    details12: { type: String, required: true },
    details13: { type: String, required: true },
    moreDetails2: { type: String, default: "Engine Options" },
    dieselImage: { type: String, default: "assets/diesel.webp" },
    details2: { type: String, default: "Diesel" },
    moreDetails3: { type: String, default: "Transmission" },
    moreDetails31: { type: String, default: "Available" },
    manualImage: { type: String, default: "assets/manuel.png" },
    details3: { type: String, default: "Manual" },
    button1: { type: String, default: "Learn More" },
    button2: { type: String, default: "Book a Test Drive" },
});

const CarData = mongoose.model('CarData', carDataSchema);
module.exports = CarData;