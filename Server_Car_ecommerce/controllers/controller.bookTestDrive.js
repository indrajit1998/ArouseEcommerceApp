const BookTestDrive = require('../lib/models/bookTestDrive');

exports.createTestDriveBooking = async (req, res) => {
    try{
        const{
            state,
            city,
            address,
            brand,
            model,
            testDriveDate,
            testDriveTime,
            name,
            phoneNumber,
            alternatePhoneNumber,
            email,
            drivingLicense
        } = req.body;

        if(!state || !city || !address || !brand || !model || !testDriveDate || !testDriveTime || !name || !phoneNumber || !alternatePhoneNumber || !email || !drivingLicense) {
            return res.status(400).json({ message: "All fields are required" });
        }

        const newBooking = new BookTestDrive({
            state,
            city,
            address,
            brand,
            model,
            testDriveDate : new Date(testDriveDate),
            testDriveTime,
            name,
            phoneNumber,
            alternatePhoneNumber : alternatePhoneNumber || null,
            email,
            drivingLicense,
            createdAt: new Date(),
            updatedAt: new Date()
        });

        await newBooking.save();
        res.status(201).json({success: true, message: 'Booking created successfully', data: newBooking})
    } catch (error) {
        console.error("Error creating test drive booking:", error);
        res.status(500).json({ success: false, message: 'Internal server error', error: error.message });
    }
}