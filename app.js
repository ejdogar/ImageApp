const express = require("express");
const bodyParser = require("body-parser");
const mongoose = require("mongoose");
const _ = require("lodash");
const multer = require("multer");

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "./uploads");
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + file.originalname);
  },
});
const upload = multer({ storage: storage });

var multipleUploads = multer({ storage: storage }).array("pictureUpload", 10);

const app = express();

app.set("view engine", "ejs");

app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static("public"));
app.use(express.static("images"));


app.post("/imageUpload", function (req, res) {
  const fileNames = [];
  multipleUploads(req, res, function (err) {
    //console.log(req.body);
    console.log(req.files);
      const picturesArray = req.files;

    picturesArray.forEach((picture) => {
      fileNames.push(picture.originalname);
    });

    if (err) {
      return res.end("Error uploading file.");
    }
    console.log(fileNames);

    res.setHeader("Content-Type", "application/json");
    res.send(JSON.stringify(fileNames));
  });

});



app.post("/upload", (req, res) => {

  const { image } = req.files;

  if (!image) return res.sendStatus(400);

  image.mv(__dirname + "/uploadnew/" + image.name);

  res.sendStatus(200);
});

app.listen(3000, function () {
  console.log("App is active on port 3000...");
});
