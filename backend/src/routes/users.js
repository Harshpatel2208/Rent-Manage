'use strict';

const { Router } = require('express');
const Joi = require('joi');
const userController = require('../controllers/userController');
const { requireAuth, requireAdmin } = require('../middleware/auth');
const { injectTenant } = require('../middleware/tenant');
const { validate } = require('../middleware/validate');

const router = Router();

const inviteUserSchema = Joi.object({
  email: Joi.string().email({ tlds: { allow: false } }).optional(),
  phone: Joi.string().pattern(/^\+?[1-9]\d{7,14}$/).optional(),
  role: Joi.string().valid('admin', 'viewer').default('viewer'),
}).or('email', 'phone');

const updateRoleSchema = Joi.object({
  role: Joi.string().valid('admin', 'viewer').optional(),
  is_active: Joi.boolean().optional(),
}).or('role', 'is_active');

// All user routes require auth + tenant context
router.use(requireAuth, injectTenant);

router.get('/', userController.getUsers);
router.post('/invite', requireAdmin, validate(inviteUserSchema), userController.inviteUser);
router.patch('/:id/role', requireAdmin, validate(updateRoleSchema), userController.updateUserRole);

module.exports = router;
