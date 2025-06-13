const Review = require('../lib/models/reviews');

const addReview = async (req, res) => {
    try {
        console.log('[addReview] Adding review:', { body: req.body });
        let results;
        if (Array.isArray(req.body)) {
            // Handle array of reviews (bulk insert)
            results = await Promise.all(
                req.body.map(async (reviewData) => {
                    const review = new Review(reviewData);
                    return await review.save();
                })
            );
            console.log('[addReview] Reviews created:', { count: results.length });
            return res.status(200).json({ success: true, results, message: `Successfully created ${results.length} reviews` });
        } else {
            // Handle single review
            const review = new Review(req.body);
            results = await review.save();
            console.log('[addReview] Review created:', { id: results._id, name: results.name });
            return res.status(200).json({ success: true, result: results, message: "Review created successfully" });
        }
    } catch (error) {
        console.error('[addReview] Error:', {
            errorName: error.name,
            errorMessage: error.message,
            errorStack: error.stack,
            timestamp: new Date().toISOString()
        });
        return res.status(500).json({
            success: false,
            message: 'Internal Server Error',
            error: error.message
        });
    }
};

const deleteReview = async (req, res) => {
    try {
        console.log('[deleteReview] Deleting review:', { id: req.params.id });
        const review = await Review.findByIdAndDelete(req.params.id).lean();
        if (!review) {
            console.log('[deleteReview] Review not found');
            return res.status(204).json({ success: false, message: "Review not found" });
        }
        console.log('[deleteReview] Review deleted:', { id: review._id, name: review.name });
        return res.status(200).json({ success: true, message: "Review deleted successfully" });
    } catch (error) {
        console.error('[deleteReview] Error:', {
            errorName: error.name,
            errorMessage: error.message,
            errorStack: error.stack,
            timestamp: new Date().toISOString()
        });
        return res.status(500).json({
            success: false,
            message: 'Internal Server Error',
            error: error.message
        });
    }
};

const getHighRatedReviews = async (req, res) => {
  try {
    console.log('[getHighRatedReviews] Received request:', {
      method: req.method,
      url: req.originalUrl,
      headers: req.headers,
      timestamp: new Date().toISOString(),
    });
    console.log('[getHighRatedReviews] Querying database for high-rated reviews...');

    // Fetch high-rated reviews (4 and 5 stars)
    const reviews = await Review.find({ rating: { $in: [4, 5] } })
      .limit(6)
      .lean();

    // Fetch the total number of reviews (all ratings)
    const totalReviews = await Review.countDocuments();

    console.log('[getHighRatedReviews] Query result:', {
      reviewCount: reviews.length,
      reviews: reviews.map(r => ({
        id: r._id,
        name: r.name,
        rating: r.rating,
      })),
      totalReviews: totalReviews,
    });

    if (!reviews || reviews.length === 0) {
      console.log('[getHighRatedReviews] No high-rated reviews found');
      return res.status(204).json({
        success: false,
        message: 'No high-rated reviews found',
      });
    }

    console.log('[getHighRatedReviews] Successfully fetched high-rated reviews');
    return res.status(200).json({
      success: true,
      reviews,
      totalReviews, // Include the total number of reviews
    });
  } catch (error) {
    console.error('[getHighRatedReviews] Error occurred:', {
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
    addReview,
    deleteReview,
    getHighRatedReviews
};