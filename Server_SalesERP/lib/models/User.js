const mongoose = require("mongoose");
const bcrypt = require("bcrypt");

const UserSchema = new mongoose.Schema({
    firstName: { type: String, required: true },
    lastName: { type: String, default: "" },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    phone: { type: Number, required: true },
    gender: { type: String, enum: ["Male", "Female", "Other"], default: "Male" },
    dateOfBirth: {
        type: String,
        validate: {
            validator: function (value) {
                return /^\d{2}-\d{2}-\d{4}/.test(value);
            },
            message: (props) => `${props.value} is not a valid date! Use DD-MM-YYYY format.`,
        },
        required: true,
    },
    role: { type: String, enum: ["User", "Admin"] },
    address: {type: String, default: ''},
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now },
});

// Hash password before saving
UserSchema.pre("save", async function (next) {
    if (!this.isModified("password")) return next();
    this.password = await bcrypt.hash(this.password, 10);
    next();
});

// Check if model is already compiled
const User = mongoose.models.User || mongoose.model("User", UserSchema);
module.exports = User;
