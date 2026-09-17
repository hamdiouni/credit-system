// MongoDB Backend Server for Credit App
// Run: node server.js

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// MongoDB Connection
const mongoUri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/credit_app';

mongoose
  .connect(mongoUri)
  .then(() => console.log('✅ MongoDB connected'))
  .catch(err => {
    console.error('❌ MongoDB connection error:', err);
    process.exit(1);
  });

// ================= SCHEMAS =================

const customerSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    phone: String
  },
  { timestamps: true }
);

const transactionSchema = new mongoose.Schema(
  {
    customerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Customer',
      required: true
    },
    type: {
      type: String,
      enum: ['credit', 'payment', 'balance_credit'],
      required: true
    },
    amount: {
      type: Number,
      required: true
    },
    note: String,
    selectedItems: [String]
  },
  { timestamps: true }
);

// ================= MODELS =================

const Customer = mongoose.model('Customer', customerSchema);
const Transaction = mongoose.model('Transaction', transactionSchema);

// ================= CUSTOMER ROUTES =================

// Get all customers
app.get('/api/customers', async (req, res) => {
  const customers = await Customer.find().sort({ createdAt: -1 });
  res.json(customers);
});

// Create customer
app.post('/api/customers', async (req, res) => {
  const customer = await Customer.create({
    name: req.body.name,
    phone: req.body.phone
  });
  res.status(201).json(customer);
});

// Delete customer + transactions
app.delete('/api/customers/:id', async (req, res) => {
  await Transaction.deleteMany({ customerId: req.params.id });
  await Customer.findByIdAndDelete(req.params.id);
  res.json({ message: 'Customer deleted' });
});

// ================= TRANSACTION ROUTES =================

// Get all transactions
app.get('/api/transactions', async (req, res) => {
  const transactions = await Transaction.find().sort({ createdAt: -1 });
  res.json(transactions);
});

// Get transactions by customer
app.get('/api/transactions/customer/:customerId', async (req, res) => {
  const transactions = await Transaction.find({
    customerId: req.params.customerId
  }).sort({ createdAt: -1 });

  res.json(transactions);
});

// Create transaction
app.post('/api/transactions', async (req, res) => {
  const transaction = await Transaction.create({
    customerId: req.body.customerId,
    type: req.body.type,
    amount: req.body.amount,
    note: req.body.note,
    selectedItems: req.body.selectedItems || []
  });

  res.status(201).json(transaction);
});

// Delete transaction
app.delete('/api/transactions/:id', async (req, res) => {
  await Transaction.findByIdAndDelete(req.params.id);
  res.json({ message: 'Transaction deleted' });
});

// ================= SERVER =================

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
