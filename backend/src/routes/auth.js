'use strict';

const { Router } = require('express');
const Joi = require('joi');
const authController = require('../controllers/authController');
const { validate } = require('../middleware/validate');

const router = Router();

const registerSchema = Joi.object({
  tenant_name: Joi.string().min(2).max(255).required(),
  email: Joi.string().email({ tlds: { allow: false } }).optional(),
  phone: Joi.string().pattern(/^\+?[1-9]\d{7,14}$/).optional(),
  password: Joi.string().min(8).required(),
}).or('email', 'phone');

const loginSchema = Joi.object({
  email: Joi.string().email({ tlds: { allow: false } }).optional(),
  phone: Joi.string().optional(),
  password: Joi.string().required(),
}).or('email', 'phone');

const sendOtpSchema = Joi.object({
  phone: Joi.string().pattern(/^\+?[1-9]\d{7,14}$/).required(),
});

const verifyOtpSchema = Joi.object({
  phone: Joi.string().required(),
  otp: Joi.string().length(6).required(),
});

const googleAuthSchema = Joi.object({
  id_token: Joi.string().required(),
  tenant_name: Joi.string().max(255).optional(),
});

const refreshSchema = Joi.object({
  refresh_token: Joi.string().required(),
});

const logoutSchema = Joi.object({
  refresh_token: Joi.string().required(),
});

router.post('/register', validate(registerSchema), authController.register);
router.post('/login', validate(loginSchema), authController.login);
router.post('/otp/send', validate(sendOtpSchema), authController.sendOtp);
router.post('/otp/verify', validate(verifyOtpSchema), authController.verifyOtp);
router.post('/google', validate(googleAuthSchema), authController.googleAuth);
router.post('/refresh', validate(refreshSchema), authController.refresh);
router.post('/logout', validate(logoutSchema), authController.logout);

module.exports = router;
