const express = require('express');
const router = express.Router();
const { findCar, addCar, updateCar, deleteCar, getAllCars } = require('../controllers/controller.carData');

// Routes for car data
router.get('/getAll', getAllCars); // Get all cars
router.get('/findCar/:id', findCar); // Get a specific car by ID
router.post('/add', addCar); // Add a new car (Admin only)
router.put('/updateCar/:id', updateCar); // Update a car (Admin only)
router.delete('/deleteCar/:id', deleteCar); // Delete a car (Admin only)

module.exports = router;