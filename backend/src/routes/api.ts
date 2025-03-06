import { apiRouter as api } from "../routes/routers";
import * as user from "@/src/controllers/user";
import * as post from "@/src/controllers/post";
import * as follow from "@/src/controllers/follow";
import * as block from "@/src/controllers/block";
import { protect } from "@/src/modules/auth";

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

api.get("/follow/:id", protect, follow.getFollowingStatus);
api.post("/follow/:id", protect, follow.follow);
api.delete("/follow/:id", protect, follow.unfollow);

api.get("/block/:id", protect, block.getBlockingStatus);
api.post("/block/:id", protect, block.block);
api.delete("/block/:id", protect, block.unblock);
