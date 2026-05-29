const express = require("express");

const router = express.Router();

const protect = require("../middleware/authMiddleware");

const {
  createDue,
  getDues,
  markDuePaid,
} = require("../controllers/dueController");

router.post("/", protect, createDue);

router.get("/", protect, getDues);

router.put("/:id/paid", protect, markDuePaid);

module.exports = router;