import * as dotenv from "dotenv";
import app from "./server";

dotenv.config();

const port = Number(process.env.PORT || 3002);

app.listen(port, () => {
  console.log(`Listening on "http://localhost:${port}"`);
});
