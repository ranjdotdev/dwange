import { Request, Response } from "express";
import prisma from "../lib/db";
import { z } from "zod";
import { updateUserSchema } from "../constants/user-schemas";
import { hashPassword } from "../modules/auth";

export async function getUser(req: Request, res: Response): Promise<void> {
  const userToFindID = req.params.id;
  try {
    const user = await prisma.user.findUnique({
      where: { id: userToFindID },
      select: {
        id: true,
        name: true,
        username: true,
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
  const userToFindID = req.user!.id;
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
    } else {
      res.status(200).json(user);
    }
  } catch (error: any) {
    res.status(500).json({
      message: "Internal server error",
      error: error.message,
    });
  }
}

export async function updateUser(req: Request, res: Response): Promise<void> {
  const userIdToUpdate = req.params.id || req.user!.id;
  if (userIdToUpdate !== req.user!.id && req.user!.role !== "admin") {
    res
      .status(403)
      .json({ message: "Forbidden: You can only update your own profile" });
    return;
  }
  try {
    const data = updateUserSchema.parse(req.body);
    if (data.password) {
      data.password = await hashPassword(data.password);
    }
    const updatedUser = await prisma.user.update({
      where: { id: userIdToUpdate },
      data,
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
        updatedAt: true,
      },
    });
    res.status(200).json({
      message: "Profile updated successfully",
      user: updatedUser,
    });
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
  const userIdToDeactivate = req.params.id || req.user!.id;
  if (userIdToDeactivate !== req.user!.id && req.user!.role !== "admin") {
    res
      .status(403)
      .json({ message: "Forbidden: You can only deactivate your own account" });
    return;
  }
  try {
    const user = await prisma.user.findUnique({
      where: { id: userIdToDeactivate },
    });
    if (!user) {
      res.status(404).json({ message: "User not found" });
      return;
    }
    if (user.status === "BANNED") {
      res.status(403).json({ message: "Banned users cannot be deactivated" });
      return;
    }
    const updatedUser = await prisma.user.update({
      where: { id: userIdToDeactivate },
      data: {
        status: "DEACTIVATED",
        deactivatedAt: new Date(),
      },
      select: {
        id: true,
        name: true,
        username: true,
        status: true,
        deactivatedAt: true,
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
  const userIdToDelete = req.params.id || req.user!.id;
  if (userIdToDelete !== req.user!.id && req.user!.role !== "admin") {
    res
      .status(403)
      .json({ message: "Forbidden: You can only delete your own account" });
    return;
  }
  try {
    const user = await prisma.user.findUnique({
      where: { id: userIdToDelete },
    });
    if (!user) {
      res.status(404).json({ message: "User not found" });
      return;
    }
    if (user.status === "BANNED") {
      res.status(403).json({ message: "Banned users cannot be deleted" });
      return;
    }
    const updatedUser = await prisma.user.update({
      where: { id: userIdToDelete },
      data: {
        status: "PENDING_DELETION",
        deactivatedAt: new Date(),
      },
      select: {
        id: true,
        name: true,
        username: true,
        status: true,
        deactivatedAt: true,
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
