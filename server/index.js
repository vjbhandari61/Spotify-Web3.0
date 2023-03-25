require("dotenv").config();
require("express-async-errors");
const express = require("express");
const cors = require("cors");
const connection = require("./config/db");
const userRoutes = require("./routes/users.routes");
const app = express();

const port = process.env.PORT || 8080;

/** Connecting to Database*/
connection();

/** Middlewares */
app.use(cors());
app.use(express.json());
app.use("/api", userRoutes);

app.listen(port, () => {
  console.log(`Listening on port ${port}...`);
});
