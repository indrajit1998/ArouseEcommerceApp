const User = require("../lib/models/User");
const { comparePassword, hashPassword } = require("../helper/bcryptHelper");
const { accessToken } = require("../helper/jwtHelper");

const createUser = async (req, res) => {
    try {
        const { firstName, lastName, email, password, phone, gender, dateOfBirth } = req.body;

        // Validate required fields
        if (!firstName || !email || !password || !phone || !gender || !dateOfBirth) {
            res.status(400).json({ success: false, message: 'All fields are required' });
            return;
        }

        // Check if the user already exists with the same email
        const existingEmail = await User.findOne({ email });
        if (existingEmail) {
            res.status(400).json({ success: false, message: 'User already exists' });
            return;
        }

        // Check if the user already exists with the same phone
        const existingPhone = await User.findOne({ phone });
        if (existingPhone) {
            res.status(400).json({ success: false, message: 'User already exists' });
            return;
        }

        // Hash the password
        const hashedPassword = await hashPassword(password);

        // Create a new user
        const newUser = new User({
            firstName,
            lastName,
            email,
            password: hashedPassword,
            phone,
            gender,
            dateOfBirth,
        });

        // Save user to database
        const userData = await newUser.save();

        // Send a success response
        res.status(200).json({
            success: true,
            message: 'User registered successfully'
        });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
};

const loginUser = async (req, res) => {
    try {
        const { email, phone, password } = req.body;

        // Validate required fields
        if (!password) {
            res.status(400).json({ success: false, message: 'Password is required' });
            return;
        }

        let user = null;
        if (email) {
            user = await User.findOne({ email });
        } else {
            user = await User.findOne({ phone });
        }

        if (!user) {
            res.status(400).json({ success: false, message: 'Invalid Credentials!' });
            return;
        }

        // Compare the entered password with the stored hashed password
        const isMatch = await comparePassword(password, user.password);
        if (!isMatch) {
            res.status(400).json({ success: false, message: 'Invalid Credentials!' });
            return;
        }

        const token = accessToken(user._id, user.role);

        res.status(200).json({
            token: token,
            success: true,
            message: 'User login successfully'
        });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
};

module.exports = {
    createUser,
    loginUser
};
