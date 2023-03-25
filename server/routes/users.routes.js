const router = require("express").Router();
const { User, validate } = require("../models/users");
const bcrypt = require("bcryptjs");
const auth = require("../middleware/auth");
const admin = require("../middleware/admin");
const validObjectId = require("../middleware/valideObjectId");

/** Create User Route */
router.post("/signup", async (req, res) => {
  const { error } = validate(req.body);
  if (error) return res.status(400).send({ message: error.details[0].message });

  const user = await User.findOne({ email: req.body.email });
  if (user) {
    return res.status(403).send("User with given email already exists!");
  }

  const salt = await bcrypt.genSalt(Number(process.env.SALT));
  const hashPassword = await bcrypt.hash(req.body.password, salt);

  const newUser = await User.create({
    ...req.body,
    password: hashPassword,
  });

  newUser.password = undefined;
  newUser._v = undefined;

  res
    .status(200)
    .send({ data: newUser, message: "Account Created Successfully!" });
});

/** Login User Route */
router.post("/login", async (req, res) => {
  const user = await User.findOne({ email: req.body.email });
  if (!user) {
    return res
      .status(400)
      .send({ message: "User with given email does not exist!" });
  }

  const validPassword = await bcrypt.compare(req.body.password, user.password);
  if (!validPassword) {
    return res.status(400).send({ message: "Invalid Password" });
  }

  const token = user.generateAuthToken();
  res
    .status(200)
    .send({ data: token, message: "Signing In! Please wait......." });
});

/** Get All Users Route */
router.get("/", admin, async (req, res) => {
  const users = await User.find().select("-password -__v");
  res.status(200).send({ data: users });
});

/** Get User By ID Route */
router.get("/:id", [validObjectId, auth], async (req, res) => {
  const user = await User.findById(req.params.id).select("-password -__v");
  res.status(200).send({ data: user });
});

/** Update User By ID Route */
router.put("/:id", [validObjectId, auth], async (req, res) => {
  const user = await User.findByIdAndUpdate(
    req.params.id,
    {
      $set: req.body,
    },
    { new: true }
  ).select("-password -__v");
  res.status(200).send({ data: user });
});

/** Delete User By ID Route */
// [validObjectId, admin]
router.delete("/:id", async (req, res) => {
  await User.deleteOne(req.params.id);
  res.status(200).send({ message: "User deleted successfully!" });
});

module.exports = router;
