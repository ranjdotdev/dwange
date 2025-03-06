import { Request, Response } from "express";
import prisma from "../lib/db";

export const follow = async (req: Request, res: Response): Promise<void> => {
  try {
    const followerId = req.user!.id;
    const followedId = req.params.id;

    if (followerId === followedId) {
      res.status(200).json({ message: "Cannot follow yourself" });
      return;
    }

    const followedUser = await prisma.user.findUnique({
      where: { id: followedId },
    });
    if (!followedUser) {
      res.status(404).json({ message: "User to follow not found" });
      return;
    }

    const alreadyFollowing = await prisma.follower.findUnique({
      where: {
        followerId_followedId: {
          followerId,
          followedId,
        },
      },
    });

    if (alreadyFollowing) {
      res.status(409).json({ message: "Already following this user" });
      return;
    }

    const createdFollow = await prisma.$transaction(async (tx) => {
      const follow = await tx.follower.create({
        data: {
          followerId,
          followedId,
        },
      });

      await tx.user.update({
        where: { id: followerId },
        data: { followingCount: { increment: 1 } },
      });

      await tx.user.update({
        where: { id: followedId },
        data: { followersCount: { increment: 1 } },
      });

      return follow;
    });

    res.status(201).json(createdFollow);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// =========================================

export const unfollow = async (req: Request, res: Response): Promise<void> => {
  try {
    const followerId = req.user!.id;
    const followedId = req.params.id;

    if (followerId === followedId) {
      res.status(400).json({ message: "Cannot unfollow yourself" });
      return;
    }

    const followedUser = await prisma.user.findUnique({
      where: { id: followedId },
    });
    if (!followedUser) {
      res.status(404).json({ message: "User to follow not found" });
      return;
    }

    const isFollowed = await prisma.follower.findUnique({
      where: {
        followerId_followedId: {
          followerId,
          followedId,
        },
      },
    });

    if (!isFollowed) {
      res.status(404).json({ message: "You are not following this user" });
      return;
    }
    const response = await prisma.$transaction(async (tx) => {
      const follow = await tx.follower.delete({
        where: {
          followerId_followedId: {
            followerId,
            followedId,
          },
        },
      });

      await tx.user.update({
        where: { id: followerId },
        data: { followingCount: { decrement: 1 } },
      });

      await tx.user.update({
        where: { id: followedId },
        data: { followersCount: { decrement: 1 } },
      });
      return follow;
    });

    res.status(200).json(response);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// =======================================

export const getFollowingStatus = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const followerId = req.user!.id;
    const followedId = req.params.id;

    if (followerId === followedId) {
      res.status(400).json({ message: "Cannot follow yourself" });
      return;
    }

    const response = await prisma.follower.findUnique({
      where: {
        followerId_followedId: {
          followerId,
          followedId,
        },
      },
    });

    if (response) {
      res.status(200).json({ isFollowing: true, data: response });
    } else {
      res.status(200).json({ isFollowing: false, data: response });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal server error" });
  }
};
