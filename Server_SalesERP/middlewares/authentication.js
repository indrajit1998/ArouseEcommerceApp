const { verifyToken } = require("../helper/jwtHelper");

const authenticate = async (req, res, next) => {
    const authHeader = req.headers.authorization;
    console.log('[authenticate] Processing authentication:', {
        method: req.method,
        url: req.originalUrl,
        authHeader: authHeader || 'None',
        timestamp: new Date().toISOString()
    });

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        console.log('[authenticate] No valid Bearer token provided');
        return res.status(401).json({ success: false, message: "No token provided. Authorization denied." });
    }

    const token = authHeader.split(" ")[1];
    try {
        console.log('[authenticate] Verifying token:', token.substring(0, 20) + '...');
        const decoded = verifyToken(token);
        console.log('[authenticate] Decoded token:', {
            userId: decoded.userId,
            role: decoded.role,
            iat: new Date(decoded.iat * 1000).toISOString(),
            exp: new Date(decoded.exp * 1000).toISOString()
        });
        req.user = {
            userId: decoded.userId || decoded.id || decoded._id,
            role: decoded.role
        };
        console.log('[authenticate] Set req.user:', req.user);
        next();
    } catch (error) {
        console.error('[authenticate] Token verification failed:', {
            errorName: error.name,
            errorMessage: error.message,
            errorStack: error.stack,
            timestamp: new Date().toISOString()
        });
        return res.status(401).json({
            success: false,
            message: "Invalid or expired token. Authorization denied.",
            error: error.message
        });
    }
};

module.exports = { authenticate };