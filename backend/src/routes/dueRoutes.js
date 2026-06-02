const express = require("express");

const router = express.Router();

const protect = require("../middleware/authMiddleware");

const {
  createDue,
  getDues,
  updateDue,
  deleteDue,
  markDuePaid,
   toggleDuePaid,
} = require("../controllers/dueController");

router.post("/", protect, createDue);

router.get("/", protect, getDues);

router.put("/:id", protect, updateDue);

router.delete("/:id", protect, deleteDue);

router.put("/:id/paid", protect, markDuePaid);

router.put("/:id/toggle-paid", protect, toggleDuePaid);

module.exports = router;