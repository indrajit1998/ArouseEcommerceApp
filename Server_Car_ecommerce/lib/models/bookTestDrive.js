const mongoose = require("mongoose");

const bookTestDriveSchema = new mongoose.Schema({
    state: {
        type: String,
        rquired: true,
    },
    city: {
        type: String,
        required: true,
    },
    address: {
        type: String,
        required: true,
    },
    brand: {
        type: String,
        required: true,
    },
    model: {
        type: String,
        required: true,
    },
    testDriveDate: {
        type: Date,
        required: true,
    },
    testDriveTime: {
        type: String,
        required: true,
    },
    name: {
        type: String,
        required: true,
    },
    phoneNumber: {
        type: Number,
        required: true,
    },
    alternatePhoneNumber: {
        type: Number,
        required: true,
    },
    email: {
        type: String,
        required: true,
    },
    drivingLicense: {
        type: String,
        required: true,
    },
    createdAt:{
        type: Date,
        dafault: Date.now,
    },
    updatedAt: {
        type: Date,
        default: Date.now,
    }
});

const BookTestDrive = mongoose.model("BookTestDrive", bookTestDriveSchema);
module.exports = BookTestDrive;