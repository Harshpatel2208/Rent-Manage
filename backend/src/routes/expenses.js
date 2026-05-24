'use strict';

const { Router } = require('express');
const Joi = require('joi');
const expenseController = require('../controllers/expenseController');
const { requireAuth, requireAdmin } = require('../middleware/auth');
const { injectTenant } = require('../middleware/tenant');
const { validate } = require('../middleware/validate');

const router = Router();

const createExpenseSchema = Joi.object({
  amount: Joi.number().positive().precision(4).required(),
  category: Joi.string().valid('food', 'maintenance', 'travel', 'business', 'other').required(),
  expense_date: Joi.string().pattern(/^\d{4}-\d{2}-\d{2}$/).required(),
  description: Joi.string().max(255).optional(),
  idempotency_key: Joi.string().uuid().required(),
});

const listExpensesSchema = Joi.object({
  category: Joi.string().valid('food', 'maintenance', 'travel', 'business', 'other').optional(),
  date_from: Joi.string().pattern(/^\d{4}-\d{2}-\d{2}$/).optional(),
  date_to: Joi.string().pattern(/^\d{4}-\d{2}-\d{2}$/).optional(),
  limit: Joi.number().integer().min(1).max(200).default(50),
  offset: Joi.number().integer().min(0).default(0),
});

router.use(requireAuth, injectTenant);

router.get('/', validate(listExpensesSchema, 'query'), expenseController.getExpenses);
router.post('/', requireAdmin, validate(createExpenseSchema), expenseController.createExpense);

module.exports = router;
