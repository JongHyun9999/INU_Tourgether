const express = require('express');
const app = express();
const port = 3000;
const cors = require('cors');
const mysql = require('mysql2');
const path = require('path');
const AWS = require('aws-sdk');
const fs = require('fs');
const multer = require('multer');
const upload = multer({ dest: 'uploads/' });
const sharp = require('sharp');

const dbconfig = require('./cfg/dbconfig.json');
const awsconfig = require('./cfg/awsconfig.json');

AWS.config.update({
  accessKeyId: awsconfig.accessKeyId,
  secretAccessKey: awsconfig.secretAccessKey,
  region: awsconfig.region,
});

app.use(express.urlencoded({ extended: false }));
app.use(express.json({ limit: '100mb' }));
app.use(cors());

app.use(express.static(path.join(__dirname, '')));

let pool = mysql.createPool(dbconfig);

// ====================== AWS S3 ======================
const s3 = new AWS.S3();

const params = {
  Bucket: 'inutestbucket',
  Key: 'background.jpg',
  Body: fs.createReadStream('./image/background.jpg'),
  ContentType: 'image/jpeg',
  ACL: 'public-read', // set the file to be publicly accessible
};


app.post('/api/upload', async (req, res) => {
  // const fileContent = fs.readFileSync(req.file.path);
  // console.log(req);
  const { message, image } = req.body;
  console.log(`hello, ${message}!`);

  const imageBuffer = Buffer.from(image, 'base64');
  const processedImage = await sharp(imageBuffer).jpeg().toBuffer()
  params.Key = `${req.body.message}.jpg`;
  params.Body = processedImage;

  s3.upload(params, (err, data) => {
    if (err) {
      console.error(err);
      res.status(500).send('Failed to upload to S3');
    } else {
      console.log(`File uploaded successfully. ${data.Location}`);
      res.send(data.Location);
    }
  });
});

// post 요청 받기 예시
app.post('/api', async (req, res) => {
  const { message } = req.body;
  console.log(req.body);
  console.log(message);

  // const data = await s3.upload(params).promise();
  // const url = `https://${params.Bucket}.s3.amazonaws.com/${params.Key}`;
  // console.log(url);

  // s3.upload(params, (err, data) => {
  //     if (err) {
  //         console.log('Error:', err);
  //     } else {
  //         console.log('File uploaded:', data.Location);
  //         // save the S3 file URL to your database

  //         const imageUrl = s3.getObjectUrl('inutestbucket', 'my_image_key');
  //         console.log('Image URL:', imageUrl);
  //     }
  //   });

  // pool.getConnection((err, conn) => {
  //     if (err) {
  //         console.log(err);
  //         res.send('DB connection error');
  //         return;
  //     }
  //     conn.query('SELECT * FROM test', (err, rows) => {
  //         if (err) {
  //             conn.release();
  //             console.log(err);
  //             res.send('DB query error');
  //             return;
  //         }

  //         if(rows.affectedRows){
  //             console.log('affectedRows : ' + rows.affectedRows);
  //         }
  //         else{
  //             console.log('affectedRows : 0');
  //         }

  //         conn.release();
  //         res.send(rows.affectedRows);
  //     });
  // });

  res.send(`Hello ${message}`);
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
