import { Request, Response } from "express";
import { apiRouter as api } from "../routes/routers";
import * as user from "@/src/controllers/user";
import * as post from "@/src/controllers/post";
import { protect } from "@/src/modules/auth";

api.get("/", (req: Request, res: Response) => {
  res.json({ message: "Testing, Attention Please!" });
});

api.get("/users/me", protect, user.getCurrentUser);
api.put("/users/me", protect, user.updateUser);
api.post("/users/me/deactivate", protect, user.deactivateUser);
api.delete("/users/me", protect, user.deleteUser);

api.get("/users/:id", user.getUser);
api.put("/users/:id", protect, user.updateUser);
api.post("/users/:id/deactivate", protect, user.deactivateUser);
api.delete("/users/:id", protect, user.deleteUser);

api.get("/posts/:id", post.getPostById);
api.post("/posts", protect, post.createPost);
api.patch("/posts/:id", protect, post.updatePost);
api.delete("/posts/:id", protect, post.deletePost);
