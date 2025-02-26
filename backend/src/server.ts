import express, { Express } from "express";
import cors from "cors";
import { authRouter, apiRouter } from "./routes/routers";
import "./routes/auth";
import "./routes/api";
import { protect } from "./modules/auth";

const app: Express = express();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use("/auth", authRouter);
app.use("/api", protect, apiRouter);

export default app;
