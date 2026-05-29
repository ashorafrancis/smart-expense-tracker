const Due = require("../models/DueModel");


// CREATE DUE
const createDue = async (req, res) => {
  try {
    const { title, amount, dueDate, notes, remindBefore } = req.body;

    const due = await Due.create({
      user: req.user,
      title,
      amount,
      dueDate,
      notes,
      remindBefore,
    });

    res.status(201).json(due);
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};


// GET ALL DUES
const getDues = async (req, res) => {
  try {
    const dues = await Due.find({
      user: req.user,
    }).sort({
      dueDate: 1,
    });

    res.status(200).json(dues);
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};


// MARK AS PAID
const markDuePaid = async (req, res) => {
  try {
    const due = await Due.findById(req.params.id);

    if (!due) {
      return res.status(404).json({
        message: "Due not found",
      });
    }

    due.paid = true;

    await due.save();

    res.status(200).json(due);
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};


module.exports = {
  createDue,
  getDues,
  markDuePaid,
};