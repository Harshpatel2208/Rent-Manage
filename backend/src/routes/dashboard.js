'use strict';

const { Router } = require('express');
const dashboardController = require('../controllers/dashboardController');
const { requireAuth } = require('../middleware/auth');
const { injectTenant } = require('../middleware/tenant');

const router = Router();

router.use(requireAuth, injectTenant);

router.get('/', dashboardController.getDashboard);

module.exports = router;
