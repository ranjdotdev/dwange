import { authRouter as auth } from "../routes/routers";
import { createNewUser, signin } from "../controllers/auth";

auth.post("/signup", createNewUser);
auth.post("/signin", signin);
