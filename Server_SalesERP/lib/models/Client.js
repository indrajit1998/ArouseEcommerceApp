"use strict";
const mongoose = require("mongoose");

const clientSchema = new mongoose.Schema({
  vendorName: { type: String, required: true, unique: true },
  contactPerson: { type: String, required: true },
  contactNumber: { type: String, required: true },
  address: { type: String, required: true },
  location: {
    type: {
      type: String,
      enum: ['Point'],
      required: true,
      default: 'Point'
    },
    coordinates: {
      type: [Number],
      required: true,
      validate: {
        validator: (value) => value.length === 2,
        message: 'Coordinates must be an array of two numbers (longitude, latitude)'
      }
    }
  },
  vendorCategory: {
    type: [String],
    required: true,
    validate: {
      validator: (value) => value.length > 0,
      message: 'At least one vendor category must be selected'
    }
  },
  gstNumber: { type: String },
  email: {
    type: String,
    required: true,
    match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please enter a valid email address']
  },
  area: { type: String, required: true },
  history: { type: [String], default: [] },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

clientSchema.index({ location: '2dsphere' });

const Client = mongoose.models.Client || mongoose.model("Client", clientSchema);

module.exports = Client;
