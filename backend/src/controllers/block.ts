import { Request, Response } from "express";
import prisma from "../lib/db";

export const block = async (req: Request, res: Response): Promise<void> => {
  try {
    const blockerId = req.user!.id;
    const blockedId = req.params.id;

    if (blockerId === blockedId) {
      res.status(200).json({ message: "Cannot block yourself" });
      return;
    }

    const blockedUser = await prisma.user.findUnique({
      where: { id: blockedId },
    });
    if (!blockedUser) {
      res.status(404).json({ message: "User to block not found" });
      return;
    }

    const alreadyBlocking = await prisma.blocker.findUnique({
      where: {
        blockerId_blockedId: {
          blockerId,
          blockedId,
        },
      },
    });

    if (alreadyBlocking) {
      res.status(409).json({ message: "Already blocking this user" });
      return;
    }

    const createdBlock = await prisma.$transaction(async (tx) => {
      const block = await tx.blocker.create({
        data: {
          blockerId,
          blockedId,
        },
      });

      await tx.user.update({
        where: { id: blockerId },
        data: { blockingCount: { increment: 1 } },
      });

      await tx.user.update({
        where: { id: blockedId },
        data: { blockersCount: { increment: 1 } },
      });

      return block;
    });

    res.status(201).json(createdBlock);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// =========================================

export const unblock = async (req: Request, res: Response): Promise<void> => {
  try {
    const blockerId = req.user!.id;
    const blockedId = req.params.id;

    if (blockerId === blockedId) {
      res.status(400).json({ message: "Cannot unblock yourself" });
      return;
    }

    const blockedUser = await prisma.user.findUnique({
      where: { id: blockedId },
    });
    if (!blockedUser) {
      res.status(404).json({ message: "User to block not found" });
      return;
    }

    const isBlocked = await prisma.blocker.findUnique({
      where: {
        blockerId_blockedId: {
          blockerId,
          blockedId,
        },
      },
    });

    if (!isBlocked) {
      res.status(404).json({ message: "You are not blocking this user" });
      return;
    }
    const response = await prisma.$transaction(async (tx) => {
      const block = await tx.blocker.delete({
        where: {
          blockerId_blockedId: {
            blockerId,
            blockedId,
          },
        },
      });

      await tx.user.update({
        where: { id: blockerId },
        data: { blockingCount: { decrement: 1 } },
      });

      await tx.user.update({
        where: { id: blockedId },
        data: { blockersCount: { decrement: 1 } },
      });
      return block;
    });

    res.status(200).json(response);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// =======================================

export const getBlockingStatus = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const blockerId = req.user!.id;
    const blockedId = req.params.id;

    if (blockerId === blockedId) {
      res.status(400).json({ message: "Cannot block yourself" });
      return;
    }

    const response = await prisma.blocker.findUnique({
      where: {
        blockerId_blockedId: {
          blockerId,
          blockedId,
        },
      },
    });

    if (response) {
      res.status(200).json({ isblocking: true, data: response });
    } else {
      res.status(200).json({ isblocking: false, data: response });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal server error" });
  }
};
