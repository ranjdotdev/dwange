import { Request, Response } from "express";
import prisma from "../lib/db";

export async function getUser(req: Request, res: Response): Promise<void> {
  if (!req.user) {
    return;
  }

  const userToFindID = req.body.user.id || req.user.id;

  try {
    const user = await prisma.user.findUnique({
      where: { id: userToFindID.id },
    });

    if (!user) {
      res.status(404).json({ message: "User not found" });
      return;
    }

    res.status(200).json(user);
  } catch (error: any) {
    res.status(500).json({
      message: "Internal server error",
      error: error.message,
    });
    return;
  }
}

export async function updateUser(req: Request, res: Response): Promise<void> {
  if (!req.user) {
    return;
  }

  try {
    const user = await prisma.user.update({
      where: { id: req.user.id },
      data: req.body,
    });

    res.status(200).json(user);
  } catch (error: any) {
    res.status(500).json({
      message: "Internal server error",
      error: error.message,
    });
    return;
  }
}

export async function deactivateUser(
  req: Request,
  res: Response
): Promise<void> {
  if (!req.user) {
    return;
  }
  try {
    const user = await prisma.user.findUnique({ where: { id: req.user.id } });
    if (!user) {
      res.status(404).json({ message: "User not found" });
      return;
    }
    const updatedUser = await prisma.user.update({
      where: { id: req.user.id },
      data: {
        status: "DEACTIVATED",
        deactivatedAt: new Date(),
      },
    });
    res
      .status(200)
      .json({ message: "Account deactivated successfully", user: updatedUser });
  } catch (error: any) {
    res
      .status(500)
      .json({ message: "Internal server error", error: error.message });
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
    // Mark the account for deletion: set status to PENDING_DELETION and record deactivation date.
    const updatedUser = await prisma.user.update({
      where: { id: req.user.id },
      data: {
        status: "PENDING_DELETION",
        deactivatedAt: new Date(),
      },
    });
    res.status(200).json({
      message:
        "Account deletion requested. It will be permanently deleted after 30 days.",
      user: updatedUser,
    });
  } catch (error: any) {
    res
      .status(500)
      .json({ message: "Internal server error", error: error.message });
  }
}

export async function cleanupDeletedUsers(): Promise<void> {
  try {
    const thresholdDate = new Date();
    thresholdDate.setDate(thresholdDate.getDate() - 30);

    const usersToDelete = await prisma.user.findMany({
      where: {
        status: "PENDING_DELETION",
        deactivatedAt: {
          lt: thresholdDate,
        },
      },
    });

    for (const user of usersToDelete) {
      await prisma.user.delete({ where: { id: user.id } });
      console.log(`Permanently deleted user ${user.id}`);
    }
    console.log("Cleanup of deletion-requested users complete.");
  } catch (error: any) {
    console.error("Error during cleanup:", error.message);
  }
}
