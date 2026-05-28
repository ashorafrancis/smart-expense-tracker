const express = require("express");

const {
  registerUser,
  loginUser,
  updateProfile,
} = require("../controllers/authController");

const protect = require("../middleware/authMiddleware");

const router = express.Router();

// REGISTER
router.post("/register", registerUser);

// LOGIN
router.post("/login", loginUser);

// UPDATE PROFILE
router.put("/profile", protect, updateProfile);

// PROTECTED ROUTE
router.get("/profile", protect, (req, res) => {
  res.json({
    message: "Protected route accessed",
    userId: req.user,
  });
});

module.exports = router;