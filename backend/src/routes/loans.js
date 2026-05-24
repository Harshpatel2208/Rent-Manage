'use strict';

const { Router } = require('express');
const Joi = require('joi');
const loanController = require('../controllers/loanController');
const { requireAuth, requireAdmin } = require('../middleware/auth');
const { injectTenant } = require('../middleware/tenant');
const { validate } = require('../middleware/validate');

const router = Router();

const createLoanSchema = Joi.object({
  borrower_id: Joi.string().uuid().required(),
  principal: Joi.number().positive().precision(4).required(),
  interest_rate: Joi.number().min(0).max(1).precision(4).default(0.01),
  registered_at: Joi.date().iso().optional(),
  notes: Joi.string().max(1000).optional(),
});

const recordPaymentSchema = Joi.object({
  amount: Joi.number().positive().precision(4).required(),
  payment_date: Joi.string().pattern(/^\d{4}-\d{2}-\d{2}$/).required(),
  type: Joi.string().valid('interest', 'principal').required(),
  idempotency_key: Joi.string().uuid().required(),
  cycle_month: Joi.string().pattern(/^\d{4}-\d{2}-01$/).when('type', {
    is: 'interest',
    then: Joi.required(),
    otherwise: Joi.optional(),
  }),
  notes: Joi.string().max(500).optional(),
});

const listLoansSchema = Joi.object({
  status: Joi.string().valid('active', 'closed').optional(),
  limit: Joi.number().integer().min(1).max(100).default(50),
  offset: Joi.number().integer().min(0).default(0),
});

const createBorrowerSchema = Joi.object({
  full_name: Joi.string().min(2).max(100).required(),
  phone: Joi.string().min(5).max(20).required(),
  address: Joi.string().min(5).max(300).required(),
  notes: Joi.string().max(1000).optional(),
});

// All loan routes require auth + tenant context
router.use(requireAuth, injectTenant);

router.get('/borrowers', loanController.getBorrowers);
router.post('/borrowers', requireAdmin, validate(createBorrowerSchema), loanController.createBorrower);

router.get('/', validate(listLoansSchema, 'query'), loanController.getLoans);
router.post('/', requireAdmin, validate(createLoanSchema), loanController.createLoan);
router.get('/:id', loanController.getLoanById);
router.post('/:id/payments', requireAdmin, validate(recordPaymentSchema), loanController.recordPayment);
router.get('/:id/schedule', loanController.getSchedule);

module.exports = router;
