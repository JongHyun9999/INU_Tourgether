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
const bodyParser = require('body-parser');

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


// 2023.07.25, jdk /get API
app.get('/getUserInfo', (req, res) => {

  pool.getConnection((err, conn) => {
    if (err) {
      res.statusMessage(404).send('Database Connection error')
    }

    let query = 'select * from User_Info';

    conn.query(query, (err, response, fields) => {

      if(err) {
        console.log('failed to get a connection from DB');
        console.log(err);
        return;
      }

      console.log("DB query succesfully");

      if (response) {
        res.status(200).json({
          user_info: response
        });
      }
      else {
        console.log('can not receive response');
      }
    })
  })
})

app.post('/updateUserStatus', async (req, res) => {
  console.log('check');
  const user_schoolnum = req.body.user_schoolnum;
  const user_status = parseInt(req.body.user_status);
  
  console.log(`user_schoolnum : ${user_schoolnum}`);
  console.log(`user_status : ${user_status}`);

  let conn = null;

  // ------------------------
  // 2023.07.29, jdk
  // try/catch
  // try는 시도하는 부분, catch는 에러를 처리하는 부분이다.
  // try 부분에서 에러가 발생하면, catch로 넘어가게 된다.
  // 이때 catch에서 error message에 대한 내용을 인자로 받게 되고
  // 이를 출력해 볼수도 있다.
  // ------------------------

  try {
    let QUERY_STR = null;
    if(req.body.user_schoolnum){
      QUERY_STR = `UPDATE User_Info SET user_status = '${user_status}' WHERE user_schoolnum = '${user_schoolnum}';`
    }
  
  // Promise가 무엇인지 잘 알아보기!
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
  }
  catch (err) {

    console.log('error content'); 
    console.log(err);

    res.status(404).json({
      error: "An error occurred while updateUserStatus"
    });
  } finally {
    if (conn) conn.release();
  }
})
// 2023.07.25, jke
// app.get('/get', function(req, res){
//   pool.getConnection((err, conn)=>{
//     if(err) {
//       res.statusMessage(404).send('Database Connection error')
//     }
//     let sql = 'select * User_Info';
//     conn.query(sql, (err, id, fields) => {
//       if(err){
//         console.log('failed to get a connection from DB');
//         console.log(err);
//         return;
//       }
//       console.log("DB query succesfully");
//       var user_id = req.params.id;
//      
//       if(id){
//         var sql= 'select * from User_Info';
//         conn.query(sql, function(err, id, fields){
//           if(err){
//             console.log(err);
//           }
//           else{
//             res.json(id);
//             console.log('users:', user_id);
//             console.log('users:', fields);
//           }
//         })
//       }
//     })
//   })
// })