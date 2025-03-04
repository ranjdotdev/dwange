import { z } from "zod";

export const registrationSchema = z.object({
  name: z.string().min(1, { message: "Name is required" }),
  email: z.string().email({ message: "A valid email is required" }),
  username: z.string().min(1, { message: "Username is required" }),
  password: z
    .string()
    .min(6, { message: "Password must be at least 6 characters long" }),
  role: z.enum(["USER", "MODERATOR", "ADMIN"]).optional(),
  gender: z.enum(["MALE", "FEMALE"]).optional(),
  imageUrl: z.string().optional(),
});

export const loginSchema = z.object({
  username: z.string().min(1, { message: "Username is required" }),
  password: z
    .string()
    .min(6, { message: "Password must be at least 6 characters long" }),
});

export const updateUserSchema = z.object({
  name: z.string().min(1, { message: "Name is required" }).optional(),
  email: z.string().email({ message: "A valid email is required" }).optional(),
  username: z.string().min(1, { message: "Username is required" }).optional(),
  password: z
    .string()
    .min(6, { message: "Password must be at least 6 characters long" })
    .optional(),
  role: z.enum(["USER", "MODERATOR", "ADMIN"]).optional(),
  gender: z.enum(["MALE", "FEMALE"]).optional(),
  imageUrl: z.string().optional(),
});
