import { z } from "zod";

export const registrationSchema = z.object({
  name: z.string().min(1, { message: "Name is required" }),
  email: z.string().email({ message: "A valid email is required" }),
  role: z.string().min(1, { message: "Role is required" }).optional(),
  username: z.string().min(1, { message: "Username is required" }),
  password: z
    .string()
    .min(6, { message: "Password must be at least 6 characters long" }),
  gender: z.boolean({ invalid_type_error: "Gender must be a boolean" }),
  image: z.string().optional(),
});

export const loginSchema = z.object({
  username: z.string().min(1, { message: "Username is required" }),
  password: z
    .string()
    .min(6, { message: "Password must be at least 6 characters long" }),
});
