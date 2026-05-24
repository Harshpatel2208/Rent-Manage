'use strict';

const { Router } = require('express');

const authRoutes = require('./auth');
const userRoutes = require('./users');
const loanRoutes = require('./loans');
const rentalRoutes = require('./rental');
const expenseRoutes = require('./expenses');
const dashboardRoutes = require('./dashboard');
const syncRoutes = require('./sync');
const reportRoutes = require('./reports');

const router = Router();

// ─── Route Mounting ───────────────────────────────────────────────────────────
router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/loans', loanRoutes);
router.use('/rental', rentalRoutes);
router.use('/expenses', expenseRoutes);
router.use('/dashboard', dashboardRoutes);
router.use('/sync', syncRoutes);
router.use('/reports', reportRoutes);

module.exports = router;
