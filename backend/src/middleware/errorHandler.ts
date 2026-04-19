import { Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/AppError';
import { logger } from '../utils/logger';
import { Prisma } from '@prisma/client';

export const errorHandler = (err: any, req: Request, res: Response, next: NextFunction) => {
  let statusCode = err.statusCode || 500;
  let message = err.message || 'Lỗi server, vui lòng thử lại';

  // Log error (only non-operational or server errors in dev)
  if (!err.isOperational) {
    logger.error(`[${statusCode}] ${req.method} ${req.url}: ${err.message}\n${err.stack}`);
  }

  // Prisma Errors
  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    switch (err.code) {
      case 'P2002':
        statusCode = 409;
        message = 'Dữ liệu đã tồn tại';
        break;
      case 'P2025':
        statusCode = 404;
        message = 'Không tìm thấy dữ liệu';
        break;
      case 'P2003':
        statusCode = 400;
        message = 'Dữ liệu liên quan không hợp lệ';
        break;
    }
  }

  // JWT Errors
  if (err.name === 'JsonWebTokenError') {
    statusCode = 401;
    message = 'Token không hợp lệ';
  }
  if (err.name === 'TokenExpiredError') {
    statusCode = 401;
    message = 'Token đã hết hạn';
  }

  res.status(statusCode).json({
    success: false,
    data: null,
    message: err.isOperational ? message : 'Lỗi server, vui lòng thử lại',
  });
};
