import { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError } from 'zod';
import { sendError } from '../utils/response';

export const validateBody = (schema: ZodSchema) => (req: Request, res: Response, next: NextFunction) => {
  try {
    schema.parse(req.body);
    next();
  } catch (error) {
    if (error instanceof ZodError) {
      const errorMessages = error.errors.map(e => `${e.path.join('.')}: ${e.message}`).join(', ');
      return sendError(res, 'Dữ liệu không hợp lệ', 400, errorMessages);
    }
    next(error);
  }
};

export const validateQuery = (schema: ZodSchema) => (req: Request, res: Response, next: NextFunction) => {
  try {
    schema.parse(req.query);
    next();
  } catch (error) {
    if (error instanceof ZodError) {
      const errorMessages = error.errors.map(e => `${e.path.join('.')}: ${e.message}`).join(', ');
      return sendError(res, 'Tham số truy vấn không hợp lệ', 400, errorMessages);
    }
    next(error);
  }
};

export const validateParams = (schema: ZodSchema) => (req: Request, res: Response, next: NextFunction) => {
  try {
    schema.parse(req.params);
    next();
  } catch (error) {
    if (error instanceof ZodError) {
      const errorMessages = error.errors.map(e => `${e.path.join('.')}: ${e.message}`).join(', ');
      return sendError(res, 'Tham số đường dẫn không hợp lệ', 400, errorMessages);
    }
    next(error);
  }
};
