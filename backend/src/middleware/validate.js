'use strict';

/**
 * Joi validation middleware factory.
 * Returns an Express middleware that validates req.body against the provided schema.
 * On failure, calls next(err) with the Joi ValidationError (handled by global error handler).
 *
 * @param {import('joi').ObjectSchema} schema - Joi schema to validate against
 * @param {'body'|'params'|'query'} [source='body'] - Request part to validate
 * @returns {import('express').RequestHandler}
 *
 * @example
 * router.post('/loans', validate(createLoanSchema), loanController.createLoan);
 */
function validate(schema, source = 'body') {
  return function (req, res, next) {
    const { error, value } = schema.validate(req[source], {
      abortEarly: false,
      stripUnknown: true,
      convert: true,
    });

    if (error) {
      error.isJoi = true;
      return next(error);
    }

    // Replace the source with the sanitized/coerced value from Joi
    req[source] = value;
    return next();
  };
}

module.exports = { validate };
