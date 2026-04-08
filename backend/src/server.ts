import express, { Express } from "express";
import cors from "cors";
import { authRouter, apiRouter } from "./routes/routers";
import "./routes/auth";
import "./routes/api";
import { errorHandler, notFoundHandler } from "./middleware/error";

const app: Express = express();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use("/auth", authRouter);
app.use("/api", apiRouter);
app.use(notFoundHandler);
app.use(errorHandler);

export default app;
