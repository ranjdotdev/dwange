import { Request, Response } from "express";
import prisma from "../lib/db";
import { z } from "zod";
import { updateUserSchema } from "../constants/user-schemas";
import { hashPassword } from "../modules/auth";

export async function getUser(req: Request, res: Response): Promise<void> {
  if (!req.user) {
    res.status(401).json({ message: "Unauthorized" });
    return;
  }

  const userToFindID = req.params.id;

  try {
    const user = await prisma.user.findUnique({
      where: { id: userToFindID },
      select: {
        id: true,
        name: true,
        username: true,
        email: true,
        status: true,
        gender: true,
        bio: true,
        location: true,
        website: true,
        imageUrl: true,
        followingCount: true,
        followersCount: true,
        postsCount: true,
        birthDate: true,
      },
    });

    if (!user) {
      res.status(404).json({ message: "User not found" });
      return;
    }
    res.status(200).json(user);
    return;
  } catch (error: any) {
    res.status(500).json({
      message: "Internal server error",
      error: error.message,
    });
  }
}

export async function getCurrentUser(
  req: Request,
  res: Response
): Promise<void> {
  if (!req.user) {
    res.status(401).json({ message: "Unauthorized" });
    return;
  }

  const userToFindID = req.user.id;

  try {
    const user = await prisma.user.findUnique({
      where: { id: userToFindID },
      select: {
        id: true,
        name: true,
        username: true,
        email: true,
        emailVerified: true,
        status: true,
        deactivatedAt: true,
        gender: true,
        bio: true,
        location: true,
        website: true,
        imageUrl: true,
        followingCount: true,
        followersCount: true,
        postsCount: true,
        role: true,
        createdAt: true,
        updatedAt: true,
        birthDate: true,
        lastLoginAt: true,
      },
    });

    if (!user) {
      res.status(404).json({ message: "User not found" });
      return;
    }

    if (user.status !== "ACTIVE") {
      const { deactivatedAt, ...data } = user;
      res.status(200).json(data);
      return;
    } else {
      res.status(200).json(user);
    }
    return;
  } catch (error: any) {
    res.status(500).json({
      message: "Internal server error",
      error: error.message,
    });
  }
}

export async function updateUser(req: Request, res: Response): Promise<void> {
  if (!req.user) {
    res.status(401).json({ message: "Unauthorized" });
    return;
  }

  try {
    // Validate the incoming data (status is intentionally not allowed)
    const data = updateUserSchema.parse(req.body);

    // If a password update is requested, hash it before saving.
    if (data.password) {
      data.password = await hashPassword(data.password);
    }

    const updatedUser = await prisma.user.update({
      where: { id: req.user.id },
      data,
    });

    res.status(200).json(updatedUser);
  } catch (error: any) {
    if (error instanceof z.ZodError) {
      res.status(400).json({ message: "Invalid input", errors: error.errors });
    } else {
      res.status(500).json({
        message: "Internal server error",
        error: error.message,
      });
    }
  }
}

export async function deactivateUser(
  req: Request,
  res: Response
): Promise<void> {
  if (!req.user) {
    res.status(401).json({ message: "Unauthorized" });
    return;
  }

  try {
    const user = await prisma.user.findUnique({ where: { id: req.user.id } });
    if (!user) {
      res.status(404).json({ message: "User not found" });
      return;
    }
    if (user.status === "BANNED") {
      res
        .status(403)
        .json({ message: "Banned users cannot deactivate their account." });
      return;
    }

    const updatedUser = await prisma.user.update({
      where: { id: req.user.id },
      data: {
        status: "DEACTIVATED",
        deactivatedAt: new Date(),
      },
    });

    res.status(200).json({
      message: "Account deactivated successfully",
      user: updatedUser,
    });
  } catch (error: any) {
    res.status(500).json({
      message: "Internal server error",
      error: error.message,
    });
  }
}

export async function deleteUser(req: Request, res: Response): Promise<void> {
  if (!req.user) {
    res.status(401).json({ message: "Unauthorized" });
    return;
  }

  try {
    const user = await prisma.user.findUnique({ where: { id: req.user.id } });
    if (!user) {
      res.status(404).json({ message: "User not found" });
      return;
    }
    if (user.status === "BANNED") {
      res
        .status(403)
        .json({ message: "Banned users cannot delete their account." });
      return;
    }

    // Mark the account for deletion by setting status to PENDING_DELETION.
    const updatedUser = await prisma.user.update({
      where: { id: req.user.id },
      data: {
        status: "PENDING_DELETION",
        deactivatedAt: new Date(),
      },
    });

    res.status(200).json({
      message:
        "Account deletion requested. It will be permanently deleted after 30 days if not reactivated.",
      user: updatedUser,
    });
  } catch (error: any) {
    res.status(500).json({
      message: "Internal server error",
      error: error.message,
    });
  }
}

// export async function cleanupDeletedUsers(): Promise<void> {
//   try {
//     const thresholdDate = new Date();
//     thresholdDate.setDate(thresholdDate.getDate() - 30);

//     const usersToDelete = await prisma.user.findMany({
//       where: {
//         status: "PENDING_DELETION",
//         deactivatedAt: { lt: thresholdDate },
//       },
//     });

//     for (const user of usersToDelete) {
//       await prisma.user.delete({ where: { id: user.id } });
//       console.log(`Permanently deleted user ${user.id}`);
//     }

//     console.log("Cleanup of deletion-requested users complete.");
//   } catch (error: any) {
//     console.error("Error during cleanup:", error.message);
//   }
// }
