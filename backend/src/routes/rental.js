'use strict';

const { Router } = require('express');
const Joi = require('joi');
const rentalController = require('../controllers/rentalController');
const { requireAuth, requireAdmin } = require('../middleware/auth');
const { injectTenant } = require('../middleware/tenant');
const { validate } = require('../middleware/validate');

const router = Router();

const createUnitSchema = Joi.object({
  unit_name: Joi.string().min(1).max(255).required(),
  address: Joi.string().max(500).optional(),
  description: Joi.string().max(1000).optional(),
});

const createTenantSchema = Joi.object({
  unit_id: Joi.string().uuid().optional(),
  full_name: Joi.string().min(2).max(255).required(),
  phone: Joi.string().pattern(/^\+?[1-9]\d{7,14}$/).optional(),
  rent_amount: Joi.number().positive().precision(4).required(),
  lease_start: Joi.string().pattern(/^\d{4}-\d{2}-\d{2}$/).required(),
  lease_end: Joi.string().pattern(/^\d{4}-\d{2}-\d{2}$/).optional(),
  notes: Joi.string().max(1000).optional(),
});

const recordRentPaymentSchema = Joi.object({
  rental_tenant_id: Joi.string().uuid().required(),
  cycle_month: Joi.string().pattern(/^\d{4}-\d{2}-01$/).required(),
  amount_paid: Joi.number().positive().precision(4).required(),
  idempotency_key: Joi.string().uuid().required(),
  notes: Joi.string().max(500).optional(),
});

const listTenantsSchema = Joi.object({
  is_active: Joi.boolean().optional(),
  unit_id: Joi.string().uuid().optional(),
});

// All rental routes require auth + tenant context
router.use(requireAuth, injectTenant);

// Shop units
router.get('/units', rentalController.getUnits);
router.post('/units', requireAdmin, validate(createUnitSchema), rentalController.createUnit);

// Rental tenants
router.get('/tenants', validate(listTenantsSchema, 'query'), rentalController.getTenants);
router.post('/tenants', requireAdmin, validate(createTenantSchema), rentalController.createTenant);
router.get('/tenants/:id', rentalController.getTenantLedger);

// Rent payments
router.post('/payments', requireAdmin, validate(recordRentPaymentSchema), rentalController.recordRentPayment);

module.exports = router;
