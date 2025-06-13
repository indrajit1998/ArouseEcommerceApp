const CarData = require('../lib/models/carData');

const findCar = async (req, res) => {
    try {
        console.log('[findCar] Finding car:', { id: req.params.id });
        const car = await CarData.findById(req.params.id).lean();
        if (!car) {
            console.log('[findCar] Car not found');
            return res.status(204).json({ success: false, message: "Car not found" });
        }
        console.log('[findCar] Car found:', { id: car._id, name: car.name });
        return res.status(200).json({ success: true, car });
    } catch (error) {
        console.error('[findCar] Error:', {
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

const addCar = async (req, res) => {
    try {
        console.log('[addCar] Adding car:', { body: req.body });
        
        let results;
        if (Array.isArray(req.body)) {
            // Handle array of cars (bulk insert)
            results = await Promise.all(
                req.body.map(async (carData) => {
                    const car = new CarData(carData);
                    return await car.save();
                })
            );
            console.log('[addCar] Cars created:', { count: results.length });
            return res.status(200).json({ success: true, results, message: `Successfully created ${results.length} cars` });
        } else {
            // Handle single car
            const car = new CarData(req.body);
            results = await car.save();
            console.log('[addCar] Car created:', { id: results._id, name: results.name });
            return res.status(200).json({ success: true, result: results, message: "Car created successfully" });
        }
    } catch (error) {
        console.error('[addCar] Error:', {
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

const updateCar = async (req, res) => {
    try {
        console.log('[updateCar] Updating car:', { id: req.params.id });
        const updatedCar = await CarData.findByIdAndUpdate(req.params.id, req.body, { new: true }).lean();
        if (!updatedCar) {
            console.log('[updateCar] Car not found');
            return res.status(204).json({ success: false, message: "Car not found" });
        }
        console.log('[updateCar] Car updated:', { id: updatedCar._id, name: updatedCar.name });
        return res.status(200).json({ success: true, updatedCar, message: "Car updated successfully" });
    } catch (error) {
        console.error('[updateCar] Error:', {
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

const deleteCar = async (req, res) => {
    try {
        console.log('[deleteCar] Deleting car:', { id: req.params.id });
        const car = await CarData.findByIdAndDelete(req.params.id).lean();
        if (!car) {
            console.log('[deleteCar] Car not found');
            return res.status(204).json({ success: false, message: "Car not found" });
        }
        console.log('[deleteCar] Car.STATUS deleted:', { id: car._id, name: car.name });
        return res.status(200).json({ success: true, message: "Car deleted successfully" });
    } catch (error) {
        console.error('[deleteCar] Error:', {
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

const getAllCars = async (req, res) => {
    try {
        console.log('[getAllCars] Received request:', {
            method: req.method,
            url: req.originalUrl,
            headers: req.headers,
            timestamp: new Date().toISOString()
        });
        console.log('[getAllCars] Querying database for cars...');
        const cars = await CarData.find().lean();
        console.log('[getAllCars] Query result:', {
            carCount: cars.length,
            cars: cars.map(c => ({
                id: c._id,
                name: c.name,
                image: c.image,
                details1: c.details1,
                details2: c.details2,
                details3: c.details3
            }))
        });
        if (!cars || cars.length === 0) {
            console.log('[getAllCars] No cars found in database');
            return res.status(204).json({
                success: false,
                message: 'No cars found'
            });
        }
        console.log('[getAllCars] Successfully fetched cars');
        return res.status(200).json({
            success: true,
            cars
        });
    } catch (error) {
        console.error('[getAllCars] Error occurred:', {
            errorName: error.name,
            errorMessage: error.message,
            errorStack: error.stack,
            timestamp: new Date().toISOString()
        });
        return res.status(500).json({
            success: false,
            message: 'Internal Server Error',
            error: {
                name: error.name,
                message: error.message,
                stack: error.stack
            }
        });
    }
};

module.exports = {
    findCar,
    addCar,
    updateCar,
    deleteCar,
    getAllCars
};