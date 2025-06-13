const User = require("../lib/models/User");
const { comparePassword } = require("../helper/bcryptHelper");
const { accessToken } = require("../helper/jwtHelper");
const bcrypt = require("bcrypt");

// Login user
const loginUser = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ success: false, message: "Email and password are required" });
        }

        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ success: false, message: "User not found" });
        }

        const isMatch = await comparePassword(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ success: false, message: "Invalid credentials" });
        }

        const token = accessToken(user._id, user.role);

        return res.status(200).json({
            success: true,
            token,
            user: {
                id: user._id,
                email: user.email,
                role: user.role,
            },
        });
    } catch (error) {
        return res.status(500).json({ success: false, message: "Internal Server Error" });
    }
};

// Register user
const registerUser = async (req, res) => {
    try {
        const { firstName, lastName, email, password, phone, gender, dateOfBirth, role, address } = req.body;

        if (!email || !password || !firstName || !phone || !dateOfBirth) {
            return res.status(400).json({ success: false, message: "Required fields are missing" });
        }

        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ success: false, message: "User already exists" });
        }

        const newUser = new User({
            firstName,
            lastName,
            email,
            password,
            phone,
            gender,
            dateOfBirth,
            address,
            role: role || "User",
        });

        await newUser.save();
        return res.status(201).json({ success: true, message: "User registered successfully" });
    } catch (error) {
        return res.status(500).json({ success: false, message: error.message });
    }
};

// Get authenticated user info
const getUserInfo = async (req, res) => {
    try {
        const { userId } = req.user;
        const user = await User.findById(userId).select("-password");
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        return res.status(200).json({ success: true, user });
    } catch (err) {
        return res.status(500).json({ success: false, message: err.message });
    }
};

// Find user details by ID
const findUserDetails = async (req, res) => {
    try {
        const userId = req.params.id;
        const userInfo = await User.findById(userId).select("firstName lastName email phone gender role address");

        if (!userInfo) {
            return res.status(404).json({ message: "User not found" });
        }

        return res.status(200).json({ success: true, user: userInfo });
    } catch (error) {
        return res.status(500).json({ success: false, message: error.message });
    }
};

// Update user profile
const updateUserInfo = async (req, res) => {
    try {
        const { userId } = req.user;
        const userid = req.params.id;

        const { firstName, lastName, email, phone, gender, dateOfBirth, address } = req.body;

        if (userId != userid) {
            return res.status(403).json({ message: 'Unauthorized Access!' });
        }

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found!' });
        }

        // Prevent email duplication
        if (user.email !== email) {
            const existingUser = await User.findOne({ email });
            if (existingUser) {
                return res.status(400).json({ message: 'Email already exists!' });
            }
        }

        // Prevent phone duplication
        if (user.phone !== phone) {
            const existingUser = await User.findOne({ phone });
            if (existingUser && existingUser._id.toString() !== user._id.toString()) {
                return res.status(400).json({ message: 'Phone number already exists!' });
            }
        }

        const updatedUser = await User.findByIdAndUpdate(
            userid,
            {
                firstName,
                lastName,
                email,
                phone,
                gender,
                dateOfBirth,
                address
            },
            { new: true }
        );

        const userDetails = await User.findById(userid).select("-password");
        return res.status(200).json({ success: true, user: userDetails, message: 'User Updated Successfully' });

    } catch (error) {
        return res.status(500).json({ success: false, message: error.message || "Server Error" });
    }
};

// Forgot/reset password
const forgotPassword = async (req, res) => {
    try {
        const { email, phone, currentPassword, newPassword } = req.body;

        let user = null;

        if (email) {
            user = await User.findOne({ email });
        } else if (phone) {
            user = await User.findOne({ phone });
        }

        if (!user) {
            return res.status(404).json({ message: 'Invalid Credentials' });
        }

        const isValidPassword = await comparePassword(currentPassword, user.password);
        if (!isValidPassword) {
            return res.status(400).json({ message: 'Invalid Current Password' });
        }

        const hashedPassword = await bcrypt.hash(newPassword, 10);

        await User.findByIdAndUpdate(user._id, { password: hashedPassword }, { new: true });

        return res.status(200).json({ success: true, message: 'Password Updated Successfully' });

    } catch (error) {
        return res.status(500).json({ success: false, message: error.message });
    }
};

module.exports = {
    loginUser,
    registerUser,
    getUserInfo,
    findUserDetails,
    updateUserInfo,
    forgotPassword
};
