'use strict';

const { Router } = require('express');
const Joi = require('joi');
const reportController = require('../controllers/reportController');
const { requireAuth, requireAdmin } = require('../middleware/auth');
const { injectTenant } = require('../middleware/tenant');
const { validate } = require('../middleware/validate');

const router = Router();

const monthlyReportSchema = Joi.object({
  year: Joi.number().integer().min(2020).max(2100).required(),
  month: Joi.number().integer().min(1).max(12).required(),
});

const exportSchema = Joi.object({
  year: Joi.number().integer().min(2020).max(2100).required(),
  month: Joi.number().integer().min(1).max(12).required(),
  type: Joi.string().valid('all', 'loans', 'rent', 'expenses').default('all'),
});

router.use(requireAuth, injectTenant, requireAdmin);

router.get('/monthly', validate(monthlyReportSchema, 'query'), reportController.getMonthlyReport);
router.get('/export/pdf', validate(exportSchema, 'query'), reportController.exportPdf);
router.get('/export/csv', validate(exportSchema, 'query'), reportController.exportCsv);

module.exports = router;
