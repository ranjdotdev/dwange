import { Request, Response } from "express";
import prisma from "../lib/db";
import { comparePasswords, createJWT, hashPassword } from "../modules/auth";
import { z } from "zod";
import { loginSchema, registrationSchema } from "../constants/user-schemas";
import { UserRole } from "@prisma/client";

export const createNewUser = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const { name, email, username, password, gender } =
      registrationSchema.parse(req.body);
    const existedUser = await prisma.user.findFirst({
      where: { OR: [{ username }, { email }] },
    });

    if (existedUser) {
      res
        .status(409)
        .json({ message: "User with this email or username already exists" });
      return;
    }

    const hashedPassword = await hashPassword(password);

    const user = await prisma.user.create({
      data: {
        name,
        email,
        username,
        password: hashedPassword,
        gender,
        role: UserRole.USER,
      },
    });

    const token = createJWT(user);
    res.status(200).json({ message: "Account created successfully!", token });
  } catch (error) {
    if (error instanceof z.ZodError) {
      res.status(400).json({ errors: error.errors });
    } else {
      console.error(error); // Log the error for debugging
      res.status(500).json({ message: "Internal server error" });
    }
  }
};

export const signin = async (req: Request, res: Response): Promise<void> => {
  try {
    const { username, password } = loginSchema.parse(req.body);
    const user = await prisma.user.findUnique({ where: { username } });

    if (!user) {
      res.status(401).json({ message: "Could not find the user!" });
      return;
    }

    const isValid = await comparePasswords(password, user.password);
    if (!isValid) {
      res.status(401).json({ message: "You wrote a wrong password!" });
      return;
    }

    const token = createJWT(user);
    res.status(200).json({ message: "Logged in successfully!", token });
  } catch (error) {
    if (error instanceof z.ZodError) {
      res.status(400).json({ errors: error.errors });
    } else {
      console.error(error); // Log the error for debugging
      res.status(500).json({ message: "Internal server error" });
    }
  }
};
