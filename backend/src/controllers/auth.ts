import { Request, Response } from "express";
import prisma from "../lib/db";
import { comparePasswords, createJWT, hashPassword } from "../modules/auth";
import { z } from "zod";
import { loginSchema, registrationSchema } from "../schemas/auth-schema";

export const createNewUser = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const { name, email, username, password, gender, image } =
      registrationSchema.parse(req.body);

    const existedUser = await prisma.user.findUnique({
      where: { username },
    });
    if (existedUser) {
      res.status(409).json({ message: "User already exists" });
      return;
    }

    const hashedPassword = await hashPassword(password);

    const user = await prisma.user.create({
      data: {
        name,
        email,
        role: "user",
        username,
        password: hashedPassword,
        gender,
        image: image ?? null,
      },
    });

    const token = createJWT(user);
    res.json({ token });
  } catch (error) {
    if (error instanceof z.ZodError) {
      res.status(400).json({ errors: error.errors });
    } else {
      console.error(error);
      res.status(500).json({ message: "Internal server error" });
    }
  }
};

export const signin = async (req: Request, res: Response): Promise<void> => {
  try {
    const { username, password } = loginSchema.parse(req.body);
    const user = await prisma.user.findUnique({ where: { username } });

    if (!user) {
      res.status(401).json({ message: "Invalid credentials" });
      return;
    }

    const isValid = await comparePasswords(password, user.password);
    if (!isValid) {
      res.status(401).json({ message: "Invalid credentials" });
      return;
    }

    const token = createJWT(user);
    res.json({ token });
  } catch (error) {
    if (error instanceof z.ZodError) {
      res.status(400).json({ errors: error.errors });
    } else {
      console.error(error); // Log the error for debugging
      res.status(500).json({ message: "Internal server error" });
    }
  }
};
