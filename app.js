const express = require("express");
const multer = require("multer");
const fs = require("fs");

const app = express();

const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

app.use(express.json());

app.post("/upload", upload.single("image"), (req, res) => {
  const imageTitle = "test" || "default";
  const encryptedImage = req.file.buffer;

  const path = fs.writeFileSync(`uploads/${imageTitle}.enc`, encryptedImage);

  res.send("image uploaded and saved");
});

app.get("/images", (req, res) => {
  const imageTitle = req.header("image-title") || "default";

  const encryptedImage = fs.readFileSync("uploads/test.enc");

  res.send(encryptedImage);
});

app.listen(3000, () => {
  console.log("App is running on port 3000...");
});
