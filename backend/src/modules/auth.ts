import jwt from "jsonwebtoken";
import { User } from "../constants/auth-types";
import { Request, Response, NextFunction } from "express";
import bcrypt from "bcrypt";

interface UserPayload {
  id: string;
  role: string;
}

declare global {
  namespace Express {
    interface Request {
      user?: UserPayload;
    }
  }
}

export function createJWT(user: User): string {
  const secret = process.env.JWT_SECRET;
  if (!secret) {
    throw new Error("JWT_SECRET is not defined!");
  }

  return jwt.sign(
    {
      id: user.id,
      role: user.role,
    },
    secret,
    { expiresIn: "7d" }
  );
}

export function protect(req: Request, res: Response, next: NextFunction): void {
  const bearer = req.headers.authorization;

  if (!bearer || !bearer.startsWith("Bearer ")) {
    res.status(401).json({ message: "Not authorized" });
    return;
  }

  const token = bearer.split(" ")[1];

  if (!token) {
    res.status(401).json({ message: "Not authorized" });
    return;
  }

  const secret = process.env.JWT_SECRET;
  if (!secret) {
    console.error("JWT_SECRET is not defined!");
    res.status(500).json({ message: "Internal server error" });
    return;
  }

  try {
    const payload = jwt.verify(token, secret) as UserPayload;
    req.user = payload; // req.user.id is a string
    console.log("Authenticated user:", payload);
    next();
  } catch (error) {
    console.error("JWT verification failed:", error);
    res.status(401).json({ message: "Invalid token" });
    return;
  }
}

export async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, 10);
}

export async function comparePasswords(
  password: string,
  hashedPassword: string
): Promise<boolean> {
  return bcrypt.compare(password, hashedPassword);
}
