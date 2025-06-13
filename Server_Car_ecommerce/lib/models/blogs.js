const mongoose = require("mongoose");

const blogSchema = new mongoose.Schema({
    name: { type: String, required: true },
    image: { type: String, required: true },
    position: { type: String, required: true },
    date: { type: String, required: true },
    description: { type: String, required: true },
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now }
});

const Blog = mongoose.model('Blog', blogSchema);
module.exports = Blog;