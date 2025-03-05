import { createPostSchema, updatePostSchema } from "../constants/post-schemas";
import { Request, Response } from "express";
import prisma from "../lib/db";
import { z } from "zod";

export const createPost = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const validatedData = createPostSchema.parse(req.body);
    const userId = req.user!.id;

    const postType =
      validatedData.type ||
      (validatedData.parentId
        ? "COMMENT"
        : validatedData.sharedPostId
        ? "SHARE"
        : "POST");

    const postData = {
      user: { connect: { id: userId } },
      content: validatedData.content,
      parent: validatedData.parentId
        ? { connect: { id: validatedData.parentId } }
        : undefined,
      audience: validatedData.audience ?? "PUBLIC",
      sharedPost: validatedData.sharedPostId
        ? { connect: { id: validatedData.sharedPostId } }
        : undefined,
      type: postType,
      location: validatedData.location,
      scheduledFor: validatedData.scheduledFor
        ? new Date(validatedData.scheduledFor)
        : undefined,
    };

    const pollData = validatedData.poll
      ? {
          create: {
            question: validatedData.poll.question,
            closesAt: validatedData.poll.closesAt
              ? new Date(validatedData.poll.closesAt)
              : undefined,
            allowMultipleChoices:
              validatedData.poll.allowMultipleChoices ?? false,
            isAnonymous: validatedData.poll.isAnonymous ?? false,
            options: {
              create: validatedData.poll.options.map((option) => ({
                optionText: option,
              })),
            },
          },
        }
      : undefined;

    const createdPost = await prisma.post.create({
      data: {
        ...postData,
        community: validatedData.communityIds?.[0]
          ? { connect: { id: validatedData.communityIds[0] } }
          : undefined,
        poll: pollData,
      },
    });

    res.status(201).json(createdPost);
  } catch (error) {
    if (error instanceof z.ZodError) {
      res
        .status(400)
        .json({ error: "Validation failed", details: error.errors });
      return;
    }
    console.error(error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// ====================================================

export const getPostById = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const postId = req.params.id;

    const post = await prisma.post.findUnique({
      where: { id: postId },
      include: { poll: { include: { options: true } } },
    });

    if (!post) {
      res.status(404).json({ error: "Post not found" });
      return;
    }

    res.status(200).json(post);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// ====================================================

export const updatePost = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const postId: string = req.params.id;

    const existingPost = await prisma.post.findUnique({
      where: { id: postId },
      select: { id: true, userId: true, hasPoll: true },
    });
    if (!existingPost) {
      res.status(404).json({ error: "Post not found" });
      return;
    }
    if (existingPost.userId !== req.user!.id) {
      res.status(403).json({ error: "Not your post to edit" });
      return;
    }

    const validatedData = updatePostSchema.parse(req.body);

    const updateData: any = {
      ...validatedData,
      isEdited: true,
    };

    if (validatedData.poll) {
      if (existingPost.hasPoll) {
        updateData.poll = {
          update: {
            question: validatedData.poll.question,
            closesAt: validatedData.poll.closesAt
              ? new Date(validatedData.poll.closesAt)
              : null,
            allowMultipleChoices:
              validatedData.poll.allowMultipleChoices ?? false,
            isAnonymous: validatedData.poll.isAnonymous ?? false,
            options: {
              deleteMany: {},
              create: validatedData.poll.options.map((option: string) => ({
                optionText: option,
              })),
            },
          },
        };
      } else {
        updateData.poll = {
          create: {
            question: validatedData.poll.question,
            closesAt: validatedData.poll.closesAt
              ? new Date(validatedData.poll.closesAt)
              : undefined,
            allowMultipleChoices:
              validatedData.poll.allowMultipleChoices ?? false,
            isAnonymous: validatedData.poll.isAnonymous ?? false,
            options: {
              create: validatedData.poll.options.map((option: string) => ({
                optionText: option,
              })),
            },
          },
        };
        updateData.hasPoll = true;
      }
    }

    const updatedPost = await prisma.post.update({
      where: { id: postId },
      data: updateData,
      include: { poll: { include: { options: true } } },
    });

    res.status(200).json(updatedPost);
  } catch (error) {
    if (error instanceof z.ZodError) {
      res
        .status(400)
        .json({ error: "Validation failed", details: error.errors });
      return;
    }
    console.error(error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// ================================================

export const deletePost = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const postId: string = req.params.id;

    const existingPost = await prisma.post.findUnique({
      where: { id: postId },
      select: { id: true, userId: true },
    });
    if (!existingPost) {
      res.status(404).json({ error: "Post not found" });
      return;
    }
    if (existingPost.userId !== req.user!.id) {
      res.status(403).json({ error: "Not your post to delete" });
      return;
    }

    await prisma.post.delete({
      where: { id: postId },
    });

    res.status(200).json({ message: "Your post deleted successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal server error" });
  }
};
