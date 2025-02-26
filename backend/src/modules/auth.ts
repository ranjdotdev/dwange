import jwt from "jsonwebtoken";
import { User } from "../types/auth-types";
import { Request, Response, NextFunction } from "express";
import * as bcrypt from "bcrypt";

declare global {
  namespace Express {
    interface Request {
      user?: any;
    }
  }
}

export function createJWT(user: User) {
  const token: string = jwt.sign(
    {
      id: user.id,
      role: user.role,
    },
    process.env.JWT_SECRET!
  );
  return token;
}

export function protect(req: Request, res: Response, next: NextFunction) {
  const bearer = req.headers.authorization;
  if (!bearer) {
    res.status(401).json({ message: "Not authorized" });
    return;
  }

  const [, token] = bearer.split(" ");
  if (!token) {
    res.status(401).send("Not authorized");
    return;
  }
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET!);
    req.user = payload;
    console.log(payload);
    next();
  } catch (e) {
    console.error(e);
    res.status(401);
    res.send("Not authorized");
    return;
  }
}

export async function hashPassword(p: string): Promise<string> {
  return (await bcrypt.hash(p, 5)) as string;
}

export async function comparePasswords(
  p: string,
  hashedP: string
): Promise<boolean> {
  return (await bcrypt.compare(p, hashedP)) as boolean;
}
