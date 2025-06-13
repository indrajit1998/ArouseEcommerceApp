const mongoose = require('mongoose');
const Client = require('../lib/models/Client');

exports.createClient = async (req, res) => {
    try {
        console.log("Create Client Request Received");
        console.log("Request Body:", req.body);

        const {
            vendorName,
            contactPerson,
            contactNumber,
            address,
            location,
            vendorCategory,
            gstNumber,
            email,
            area,
        } = req.body;

        if (!vendorName || !contactPerson || !contactNumber || !address || !vendorCategory || !email || !area || !location || !location.coordinates) {
            return res.status(400).json({ success: false, message: 'All required fields must be filled' });
        }

        console.log("Location Field:", location);
        console.log("Coordinates:", location.coordinates);

        const existingClient = await Client.findOne({ vendorName });
        if (existingClient) {
            return res.status(400).json({ success: false, message: 'Client with this vendor name already exists' });
        }

        const newClient = new Client({
            vendorName,
            contactPerson,
            contactNumber,
            address,
            location,
            vendorCategory,
            gstNumber,
            email,
            area,
        });

        const savedClient = await newClient.save();
        console.log("Client Created:", savedClient);

        return res.status(201).json({ success: true, message: 'Client created successfully', client: savedClient });
    } catch (error) {
        console.error("Error in createClient:", error.message);
        return res.status(500).json({ success: false, message: 'Internal Server Error', error: error.message });
    }
};

exports.updateClient = async (req, res) => {
    try {
        const { vendorId } = req.params;
        const { vendorName, contactNumber, contactPerson, address, vendorCategory, gstNumber, email, area, location } = req.body;

        if (!vendorName || !email || !vendorCategory || !contactPerson || !contactNumber || !address || !area) {
            return res.status(400).json({ success: false, message: 'All fields are required' });
        }

        if (!mongoose.Types.ObjectId.isValid(vendorId)) {
            return res.status(400).json({ success: false, message: 'Invalid vendorId' });
        }

        const existingClient = await Client.findById(vendorId);
        if (!existingClient) {
            return res.status(404).json({ success: false, message: 'Client not found' });
        }

        if (existingClient.vendorName !== vendorName) {
            const clientNameExist = await Client.findOne({ vendorName });
            if (clientNameExist) {
                return res.status(400).json({ success: false, message: 'Vendor name already exists' });
            }
        }

        const updatedClient = await Client.findByIdAndUpdate(
            vendorId,
            {
                vendorName,
                contactNumber,
                contactPerson,
                address,
                vendorCategory,
                gstNumber,
                email,
                area,
                location,
                updatedAt: Date.now(),
            },
            { new: true }
        );

        if (!updatedClient) {
            return res.status(400).json({ success: false, message: 'Failed to update client' });
        }

        return res.status(200).json({
            success: true,
            message: 'Client updated successfully',
            client: updatedClient,
        });
    } catch (error) {
        console.error('Error updating client:', error.message);
        return res.status(500).json({ success: false, message: 'Internal Server Error', error: error.message });
    }
};

exports.getClientDetails = async (req, res) => {
    try {
        const { vendorId } = req.params;

        if (!vendorId || !mongoose.Types.ObjectId.isValid(vendorId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid or missing vendorId'
            });
        }

        const clientData = await Client.findById(vendorId);

        if (!clientData) {
            return res.status(404).json({
                success: false,
                message: 'Client not found'
            });
        }
        res.status(200).json({
            success: true,
            message: 'Client fetched successfully',
            client: clientData
        });
    } catch (error) {
        console.error(`Error fetching client with vendorId ${req.params.vendorId}:`, error);
        res.status(500).json({
            success: false,
            message: `Internal Server Error: ${error.message}`
        });
    }
};

exports.getClientHistoryDetails = async (req, res) => {
    try {
        const { VendorName } = req.body;
        const { vendorId } = req.params;

        let clientData = null;

        if (vendorId) {
            clientData = await Client.findById(vendorId);
        } else {
            clientData = await Client.findOne({ vendorName: VendorName });
        }

        if (!clientData) {
            res.status(404).json({ success: false, message: 'Client not found. Please check the vendor name or ID.' });
            return;
        }

        
        res.status(200).json({
            success: true,
            message: 'Client history fetched successfully',
            clientHistory: clientData.history
        });
        return;
    } catch (error) {
        res.status(500).json({ success: false, message: 'Internal Server Error' });
        return;
    }
};

exports.getAllClients = async (req, res) => {
    try {
        const clients = await Client.find({}).sort({ createdAt: -1 });
        res.status(200).json({
            success: true,
            message: 'Clients fetched successfully',
            clients
        });
        return;
    } catch (error) {
        res.status(500).json({ success: false, message: 'Internal Server Error' });
        return;
    }
};

exports.checkVendorName = async (req, res) => {
    try {
      const { vendorName } = req.body;
  
      if (!vendorName) {
        return res.status(400).json({ success: false, message: 'Vendor name is required' });
      }
  
      const existingClient = await Client.findOne({ vendorName });
      if (existingClient) {
        return res.status(200).json({ success: true, exists: true });
      }
  
      return res.status(200).json({ success: true, exists: false });
    } catch (error) {
      console.error('Error checking vendor name:', error.message);
      return res.status(500).json({ success: false, message: 'Internal Server Error', error: error.message });
    }
  };