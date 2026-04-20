import { prisma } from '../../config/database';
import { AppError } from '../../utils/AppError';
import { UpdateProfileInput, UserQueryInput } from './user.schema';

export class UserService {
  async getUserById(userId: string, requesterId?: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        username: true,
        avatarUrl: true,
        role: true,
        pointBalance: true,
        isPremium: true,
        premiumUntil: true,
        createdAt: true,
        _count: {
          select: {
            mangas: true,
            followers: true,
            following: true,
          },
        },
      },
    });

    if (!user) throw new AppError('Không tìm thấy người dùng', 404);

    let isFollowed = false;
    if (requesterId && requesterId !== userId) {
      const follow = await prisma.userFollow.findUnique({
        where: {
          followerId_followingId: {
            followerId: requesterId,
            followingId: userId,
          },
        },
      });
      isFollowed = !!follow;
    }

    const { _count, ...userData } = user;
    return {
      ...userData,
      mangaCount: _count.mangas,
      followerCount: _count.followers,
      followingCount: _count.following,
      isFollowed,
    };
  }

  async updateProfile(userId: string, data: UpdateProfileInput) {
    if (data.username) {
      const existing = await prisma.user.findUnique({
        where: { username: data.username },
      });
      if (existing && existing.id !== userId) {
        throw new AppError('Username đã tồn tại', 409);
      }
    }

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        username: data.username,
        avatarUrl: data.avatar_url,
      },
      select: {
        id: true,
        email: true,
        username: true,
        avatarUrl: true,
        role: true,
        pointBalance: true,
        isPremium: true,
        premiumUntil: true,
        createdAt: true,
      },
    });

    return updatedUser;
  }

  async getReadingHistory(userId: string, query: UserQueryInput) {
    const { page, limit } = query;
    const skip = (page - 1) * limit;

    const [data, total] = await Promise.all([
      prisma.readingHistory.findMany({
        where: { userId },
        skip,
        take: limit,
        orderBy: { readAt: 'desc' },
        include: {
          chapter: {
            select: {
              id: true,
              chapterNumber: true,
              title: true,
              manga: {
                select: { id: true, title: true, coverUrl: true },
              },
            },
          },
        },
      }),
      prisma.readingHistory.count({ where: { userId } }),
    ]);

    return {
      data,
      pagination: { page, limit, total },
    };
  }

  async updateReadingHistory(userId: string, chapterId: string, lastPage: number) {
    const history = await prisma.readingHistory.upsert({
      where: {
        userId_chapterId: { userId, chapterId },
      },
      update: {
        lastPage,
        readAt: new Date(),
      },
      create: {
        userId,
        chapterId,
        lastPage,
      },
    });

    return history;
  }

  async getBookmarks(userId: string, query: UserQueryInput) {
    const { page, limit } = query;
    const skip = (page - 1) * limit;

    const [follows, total] = await Promise.all([
      prisma.mangaFollow.findMany({
        where: { userId },
        skip,
        take: limit,
        orderBy: {
          manga: { updatedAt: 'desc' },
        },
        include: {
          manga: {
            include: {
              chapters: {
                orderBy: { chapterNumber: 'desc' },
                take: 1,
              },
            },
          },
        },
      }),
      prisma.mangaFollow.count({ where: { userId } }),
    ]);

    const data = follows.map((f) => ({
      ...f.manga,
      latestChapter: f.manga.chapters[0] || null,
    }));

    return {
      data,
      pagination: { page, limit, total },
    };
  }

  async getUserMangas(userId: string, query: UserQueryInput) {
    const { page, limit } = query;
    const skip = (page - 1) * limit;

    const [data, total] = await Promise.all([
      prisma.manga.findMany({
        where: { authorId: userId },
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      prisma.manga.count({ where: { authorId: userId } }),
    ]);

    return {
      data,
      pagination: { page, limit, total },
    };
  }
}
