import { Server } from 'socket.io';
import { Server as HttpServer } from 'http';
import { logger } from '../utils/logger';

let io: Server;

export const initSocket = (server: HttpServer) => {
  io = new Server(server, {
    cors: {
      origin: '*',
      methods: ['GET', 'POST'],
    },
  });

  io.on('connection', (socket) => {
    logger.info(`✓ New socket connection: ${socket.id}`);

    socket.on('join', (userId: string) => {
      socket.join(userId);
      logger.info(`✓ User ${userId} joined room`);
    });

    socket.on('disconnect', () => {
      logger.info(`✗ Socket disconnected: ${socket.id}`);
    });
  });

  return io;
};

export const getIO = () => {
  if (!io) {
    throw new Error('Socket.io not initialized');
  }
  return io;
};

export const emitToUser = (userId: string, event: string, data: any) => {
  if (io) {
    io.to(userId).emit(event, data);
  }
};
