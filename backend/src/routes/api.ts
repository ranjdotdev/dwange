import { Request, Response } from "express";
import { apiRouter as api } from "../routes/routers";
import * as user from "@/src/controllers/user";

api.get("/", (req: Request, res: Response) => {
  res.json({ message: "Testing, Attention Please!" });
});

api.get("/user", user.getUser);
api.patch("/user", user.updateUser);
api.delete("/user", user.deleteUser);
