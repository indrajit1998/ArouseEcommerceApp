const express = require('express');
const router = express.Router();
const { addBlog, deleteBlog, updateBlog, getAllBlogs, getBlogById } = require('../controllers/controller.blogs');

// Routes for blogs
router.post('/addBlog', addBlog);
router.delete('/deleteBlog/:id', deleteBlog);
router.put('/updateBlog/:id', updateBlog);
router.get('/getAllBlogs', getAllBlogs);
router.get('/getBlogById/:id', getBlogById);

module.exports = router;