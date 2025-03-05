import { z } from "zod";

export const createPostSchema = z.object({
  content: z.string().min(1, "Content is required"),
  parentId: z.string().optional(),
  communityIds: z.array(z.string()).optional(),
  sharedPostId: z.string().optional(),
  audience: z
    .enum(["ONLY_ME", "FRIENDS", "MY_COMMUNITIES", "PUBLIC"])
    .optional(),
  location: z.string().max(255).optional(),
  scheduledFor: z.string().datetime().optional(),
  type: z.enum(["POST", "COMMENT", "SHARE"]).optional(),
  poll: z
    .object({
      question: z.string().min(1, "Poll question is required"),
      closesAt: z.string().datetime().optional(),
      allowMultipleChoices: z.boolean().optional(),
      isAnonymous: z.boolean().optional(),
      options: z.array(z.string().min(1, "Option text is required")).min(2),
    })
    .optional(),
});

export const updatePostSchema = z.object({
  content: z.string().optional(),
  audience: z
    .enum(["ONLY_ME", "FRIENDS", "MY_COMMUNITIES", "PUBLIC"])
    .optional(),
  location: z.string().max(255).optional(),
  isPinned: z.boolean().optional(),
  scheduledFor: z.string().datetime().optional(),
  poll: z
    .object({
      question: z.string().min(1, "Poll question is required"),
      closesAt: z.string().datetime().optional(),
      allowMultipleChoices: z.boolean().optional(),
      isAnonymous: z.boolean().optional(),
      options: z.array(z.string().min(1, "Option text is required")).min(2),
    })
    .optional(),
});
