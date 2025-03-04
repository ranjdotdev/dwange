import { Request, Response } from "express";
import { apiRouter as api } from "../routes/routers";
import * as user from "@/src/controllers/user";

api.get("/", (req: Request, res: Response) => {
  res.json({ message: "Testing, Attention Please!" });
});

api.get("/user", user.getCurrentUser);
api.get("/user/:id", user.getUser);
api.put("/user", user.updateUser);
api.post("/user/deactivate", user.deactivateUser);
api.post("/user/delete", user.deleteUser);
