import { Request, Response } from "express";
import { apiRouter as api } from "../routes/routers";

api.get("/", (req: Request, res: Response) => {
  res.json({ message: "Testing, Attention Please!" });
});
