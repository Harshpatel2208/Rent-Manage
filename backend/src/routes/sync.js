'use strict';

const { Router } = require('express');
const Joi = require('joi');
const syncController = require('../controllers/syncController');
const { requireAuth } = require('../middleware/auth');
const { injectTenant } = require('../middleware/tenant');
const { validate } = require('../middleware/validate');

const router = Router();

const batchSyncSchema = Joi.object({
  operations: Joi.array()
    .items(
      Joi.object({
        entity_type: Joi.string().required(),
        operation: Joi.string().optional(),
        payload: Joi.object().required(),
        idempotency_key: Joi.string().uuid().required(),
      })
    )
    .min(1)
    .max(100)
    .required(),
});

const resolveConflictSchema = Joi.object({
  status: Joi.string().valid('resolved', 'dismissed').optional(),
  action: Joi.string().valid('resolve', 'dismiss').optional(),
}).or('status', 'action');

router.use(requireAuth, injectTenant);

router.post('/batch', validate(batchSyncSchema), syncController.batchSync);
router.get('/conflicts', syncController.getConflicts);
router.patch('/conflicts/:id', validate(resolveConflictSchema), syncController.resolveConflict);

module.exports = router;
