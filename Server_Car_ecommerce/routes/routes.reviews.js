const express = require('express');
const router = express.Router();
const { addReview, deleteReview, getHighRatedReviews } = require('../controllers/controller.reviews');

//Routes for reivews
router.post('/addReview', addReview);
router.delete('/deleteReview/:id', deleteReview);
router.get('/getHighRatedReviews', getHighRatedReviews);

module.exports = router;