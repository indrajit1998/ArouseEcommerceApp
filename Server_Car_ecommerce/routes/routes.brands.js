const express = require('express');
const router = express.Router();
const { addBrand, updateBrand, deleteBrand, getAllBrands, getBrandById } = require('../controllers/controller.brands');

// Routes for brands
router.post('/addBrand', addBrand);
router.put('/updateBrand/:id', updateBrand);
router.delete('/deleteBrand/:id', deleteBrand);
router.get('/getAllBrands', getAllBrands);
router.get('/getBrandById/:id', getBrandById);

module.exports = router;