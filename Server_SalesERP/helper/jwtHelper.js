const jwt = require('jsonwebtoken');

const secret = process.env.JWT_SECRET || "nasn@ne&wDFdkKsj%nfSDf*&@SDjkfn";

const accessToken = (userId, role) => {
    return jwt.sign({ userId, role }, secret, { expiresIn: '1h' });
};

const verifyToken = (token) => {
    try {
        const decoded = jwt.verify(token, secret);
        console.log("Decoded JWT:", decoded);
        return decoded;
    } catch (err) {
        throw new Error('Invalid token');
    }
};

module.exports = { accessToken, verifyToken };