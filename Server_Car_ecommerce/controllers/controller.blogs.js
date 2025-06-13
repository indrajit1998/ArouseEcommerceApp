const Blog = require('../lib/models/blogs');

const addBlog = async (req, res) => {
  try {
    console.log('[addBlog] Adding blog(s):', { body: req.body });
    let results;
    if (Array.isArray(req.body)) {
      // Handle array of blogs (bulk insert)
      results = await Promise.all(
        req.body.map(async (blogData) => {
          const blog = new Blog(blogData);
          return await blog.save();
        })
      );
      console.log('[addBlog] Blogs created:', { count: results.length });
      return res.status(201).json({
        success: true,
        results,
        message: `Successfully created ${results.length} blogs`,
      });
    } else {
      // Handle single blog
      const blog = new Blog(req.body);
      results = await blog.save();
      console.log('[addBlog] Blog created:', { id: results._id, name: results.name });
      return res.status(201).json({
        success: true,
        result: results,
        message: 'Blog created successfully',
      });
    }
  } catch (error) {
    console.error('[addBlog] Error:', {
      errorName: error.name,
      errorMessage: error.message,
      errorStack: error.stack,
      timestamp: new Date().toISOString(),
    });
    return res.status(500).json({
      success: false,
      message: 'Internal Server Error',
      error: error.message,
    });
  }
};

const deleteBlog = async (req, res) => {
  try {
    console.log('[deleteBlog] Deleting blog:', { id: req.params.id });
    const blog = await Blog.findByIdAndDelete(req.params.id).lean();
    if (!blog) {
      console.log('[deleteBlog] Blog not found');
      return res.status(404).json({
        success: false,
        message: 'Blog not found',
      });
    }
    console.log('[deleteBlog] Blog deleted:', { id: blog._id, name: blog.name });
    return res.status(200).json({
      success: true,
      message: 'Blog deleted successfully',
    });
  } catch (error) {
    console.error('[deleteBlog] Error:', {
      errorName: error.name,
      errorMessage: error.message,
      errorStack: error.stack,
      timestamp: new Date().toISOString(),
    });
    return res.status(500).json({
      success: false,
      message: 'Internal Server Error',
      error: error.message,
    });
  }
};

const updateBlog = async (req, res) => {
  try {
    console.log('[updateBlog] Updating blog:', { id: req.params.id, body: req.body });
    const blog = await Blog.findByIdAndUpdate(
      req.params.id,
      { ...req.body, updatedAt: Date.now() },
      { new: true, runValidators: true }
    ).lean();
    if (!blog) {
      console.log('[updateBlog] Blog not found');
      return res.status(404).json({
        success: false,
        message: 'Blog not found',
      });
    }
    console.log('[updateBlog] Blog updated:', { id: blog._id, name: blog.name });
    return res.status(200).json({
      success: true,
      result: blog,
      message: 'Blog updated successfully',
    });
  } catch (error) {
    console.error('[updateBlog] Error:', {
      errorName: error.name,
      errorMessage: error.message,
      errorStack: error.stack,
      timestamp: new Date().toISOString(),
    });
    return res.status(500).json({
      success: false,
      message: 'Internal Server Error',
      error: error.message,
    });
  }
};

const getAllBlogs = async (req, res) => {
  try {
    console.log('[getAllBlogs] Received request:', {
      method: req.method,
      url: req.originalUrl,
      headers: req.headers,
      timestamp: new Date().toISOString(),
    });
    console.log('[getAllBlogs] Querying database for blogs...');
    const blogs = await Blog.find()
      .sort({ createdAt: -1 }) // Sort by creation date (newest first)
      .limit(3) // Limit to 3 blog posts for the UI
      .lean();
    console.log('[getAllBlogs] Query result:', {
      blogCount: blogs.length,
      blogs: blogs.map(b => ({
        id: b._id,
        name: b.name,
        date: b.date,
      })),
    });
    if (!blogs || blogs.length === 0) {
      console.log('[getAllBlogs] No blogs found');
      return res.status(204).json({
        success: false,
        message: 'No blogs found',
      });
    }
    console.log('[getAllBlogs] Successfully fetched blogs');
    return res.status(200).json({
      success: true,
      blogs,
    });
  } catch (error) {
    console.error('[getAllBlogs] Error occurred:', {
      errorName: error.name,
      errorMessage: error.message,
      errorStack: error.stack,
      timestamp: new Date().toISOString(),
    });
    return res.status(500).json({
      success: false,
      message: 'Internal Server Error',
      error: {
        name: error.name,
        message: error.message,
        stack: error.stack,
      },
    });
  }
};

const getBlogById = async (req, res) => {
  try {
    console.log('[getBlogById] Fetching blog:', { id: req.params.id });
    const blog = await Blog.findById(req.params.id).lean();
    if (!blog) {
      console.log('[getBlogById] Blog not found');
      return res.status(404).json({
        success: false,
        message: 'Blog not found',
      });
    }
    console.log('[getBlogById] Blog fetched:', { id: blog._id, name: blog.name });
    return res.status(200).json({
      success: true,
      blog,
    });
  } catch (error) {
    console.error('[getBlogById] Error occurred:', {
      errorName: error.name,
      errorMessage: error.message,
      errorStack: error.stack,
      timestamp: new Date().toISOString(),
    });
    return res.status(500).json({
      success: false,
      message: 'Internal Server Error',
      error: {
        name: error.name,
        message: error.message,
        stack: error.stack,
      },
    });
  }
};

module.exports = {
  addBlog,
  deleteBlog,
  updateBlog,
  getAllBlogs,
  getBlogById,
};