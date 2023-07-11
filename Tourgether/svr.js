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
let pool = mysql.createPool(dbconfig);
const awsconfig = require('./cfg/awsconfig.json');

AWS.config.update({
  accessKeyId: awsconfig.accessKeyId,
  secretAccessKey: awsconfig.secretAccessKey,
  region: awsconfig.region,
});

app.use(express.urlencoded({ extended: false }));
app.use(express.json({ limit: '50mb' }));
app.use(cors());

app.use(express.static(path.join(__dirname, '')));

// ====================== AWS S3 ======================
const s3 = new AWS.S3();

const params = {
  Bucket: 'inutourgether',
  Key: 'background.jpg',
  Body: fs.createReadStream('./image/background.jpg'),
  ContentType: 'image/jpeg',
  ACL: 'public-read', // set the file to be publicly accessible
};

// =====================================================





// S3 이미지 업로드 테스트용 API
app.post('/api/upload', async (req, res) => {
  const { message, image } = req.body;
  console.log(`hello, ${message}!`);

  const imageBuffer = Buffer.from(image, 'base64');
  const processedImage = await sharp(imageBuffer).jpeg().toBuffer()
  params.Key = `${req.body.message}.jpg`;
  params.Body = processedImage;

  // Upload Image to S3 and receive Image link
  s3.upload(params, (err, data) => {
    if (err) {
      console.error(err);
      res.status(500).send('Failed to upload to S3');
    } else {
      console.log(`File uploaded successfully. ${data.Location}`);
      pool.getConnection((err, conn) => {
        if (err) {
          res.statusMessage(404).send('Database Connection error')
        }
        const QUERY_STR = `INSERT INTO Text_Image_Info_202307(userId, text_content, image_content, location) \
                        VALUES('test', 'jonghyun testing!!', '${data.Location}', POINT(30,35));`
        
        conn.query(QUERY_STR, (error, rows) => {
          if (error) {
            console.log('failed to get a connection from DB');
            console.log(error);
            res.status(404).send('Database query failed')
            conn.release();
            return;
          }
          console.log("DB insert successfuly.")
          res.status(200).send();
          conn.release();
        })
      })
    }
  });
});


// 23.07.11. PJH 
// 사용자의 텍스트, 이미지 업로드 요청 API
app.post('/postMessageData', async (req, res)=>{
  const userId = req.body.author
  const textContent = req.body.content
  const latitude = req.body.latitude
  const longitude = req.body.longitude

  let conn = null;
  try {
    let QUERY_STR = null;
    if (req.body.image === null){
      // 이미지없이 글만 올리려는 경우.
      QUERY_STR = `INSERT INTO Text_Image_Info_202307(userId, text_content, image_content, location) \
                        VALUES('${userId}', '${textContent}', NULL, POINT(${latitude},${longitude}));`
    }
    else {
      // 업로드할 이미지가 있는 경우.
      s3.upload(params, (err, data) => {
        if (err) {
          console.error(err);
          res.status(500).send('Failed to upload to S3');
        } else {
          console.log(`File uploaded successfully. ${data.Location}`);
    
          pool.getConnection((err, conn) => {
            if (err) { res.status(404).send('Database Connection error') }
    
            QUERY_STR = `INSERT INTO Text_Image_Info_202307(userId, text_content, image_content, location) \
                            VALUES('${userId}', '${textContent}', '${data.Location}', POINT(${latitude},${longitude}));`
          })
        }});
    }
    
    // DB에 저장
    conn = await new Promise((resolve, reject) => {
      pool.getConnection((err, connection) => {
        if (err) reject(err);
        resolve(connection);
      });
    }).catch((err) => {
      throw err;
    })

    const [rows] = await conn.promise().query(QUERY_STR)
    res.status(200).json(rows);
  } catch (err) {
    res.status(404).json({
      error: "An error occurred while postMessageData"
    });
  } finally {
    if (conn) conn.release();
  }
})


app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
