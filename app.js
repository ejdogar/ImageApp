const express = require("express");
const multer = require("multer");
const path = require("path");
const fs = require("fs");

const app = express();
const port = 3000;
const uploadDir = "./uploads";

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir);
    }
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    cb(null, file.originalname);
  },
});

const upload = multer({ storage: storage });

app.use(express.static(path.join(__dirname, "uploads")));

app.post("/upload", upload.single("image"), (req, res) => {
  if (!req.file) {
    return res.status(400).send("no file uploaded!!");
  }

  const imagePath = path.join(__dirname, "uploads", req.file.filename);
  res.send("Image uploaded and saved at: ${imagePath}");
});

app.get("/images", (req, res) => {
  fs.readdir(uploadDir, (err, files) => {
    if (err) {
      return res
        .status(500)
        .send("Error occured while finding image directory => ${err}");
    }

    if (files.length === 0) {
      return res.status(404).send("No images found!!");
    }

    const imageFiles = files.filter((file) =>
      /\.(jpg|jpeg|png|gif)$/i.test(file)
    );

    if (imageFiles.length === 0) {
      console.warn("no vlid files in the directory");
      return res.status(404).send("no valid image files in the directory");
    }

    const imagePromises = imageFiles.map((file) => {
      const filePath = path.join(uploadDir, file);
      return fs.promises.readFile(filePath);
    });

    Promise.all(imagePromises)
      .then((images) => {
        const base64Images = images.map((image) => image.toString("base64"));
        res.json(base64Images);
      })
      .catch((err) => {
        res.status(500).send("error occured while reading images ==> ${err}");
      });
  });
});

app.listen(3000, function () {
  console.log("App is active on port 3000...");
});
