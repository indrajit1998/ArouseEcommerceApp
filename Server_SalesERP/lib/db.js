const dotenv = require('dotenv');
const mongoose = require('mongoose');

dotenv.config();

const ConnectToMongoDB = async () => {
    try {
        const url = process.env.MONGODB_URI || 'mongodb://localhost:27017/SalesERP';
        await mongoose.connect(url);
        console.log("Successfully connected to the Database");
    } catch (error) {
        console.log("Failed to connect to the Database. ", error);
    }
};

module.exports = { ConnectToMongoDB };