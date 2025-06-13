const mongoose = require('mongoose');

const mongooseSchema = new mongoose.Schema({
    image: { type: String, required: true },
    name: { type: String, required: true }
});

const Brand = mongoose.model('Brand', mongooseSchema);
module.exports = Brand;