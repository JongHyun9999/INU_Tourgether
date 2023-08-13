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
  Body: fs.createReadStream('./images/background.jpg'),
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
// app.post('/postMessageData', async (req, res) => {
//   const userId = req.body.author
//   const textContent = req.body.content
//   const latitude = req.body.latitude
//   const longitude = req.body.longitude

//   let conn = null;
//   try {
//     let QUERY_STR = null;
//     if (req.body.image === null) {
//       // 이미지없이 글만 올리려는 경우.
//       QUERY_STR = `INSERT INTO Text_Image_Info_202307(userId, text_content, image_content, location) \
//                         VALUES('${userId}', '${textContent}', NULL, POINT(${latitude},${longitude}));`
//     }
//     else {
//       // 업로드할 이미지가 있는 경우.
//       s3.upload(params, (err, data) => {
//         if (err) {
//           console.error(err);
//           res.status(500).send('Failed to upload to S3');
//         } else {
//           console.log(`File uploaded successfully. ${data.Location}`);

//           pool.getConnection((err, conn) => {
//             if (err) { res.status(404).send('Database Connection error') }

//             QUERY_STR = `INSERT INTO Text_Image_Info_202307(userId, text_content, image_content, location) \
//                             VALUES('${userId}', '${textContent}', '${data.Location}', POINT(${latitude},${longitude}));`
//           })
//         }
//       });
//     }

//     // DB에 저장
//     conn = await new Promise((resolve, reject) => {
//       pool.getConnection((err, connection) => {
//         if (err) reject(err);
//         resolve(connection);
//       });
//     }).catch((err) => {
//       throw err;
//     })

//     const [rows] = await conn.promise().query(QUERY_STR)
//     res.status(200).json(rows);
//   } catch (err) {
//     res.status(404).json({
//       error: "An error occurred while postMessageData"
//     });
//   } finally {
//     if (conn) conn.release();
//   }
// })

// 2023.07.29, jdk
// postUserContent : 유저가 작성한 쪽지 게시글을 DB에 업로드 하는 API.
// 이후에는 /api router를 만들어서 기능을 분리하도록 한다.
app.post('/api/postUserContent', async (req, res) => {
  const postData = req.body;
  console.log('postData : ', postData);

  const user_name = postData.user_name;
  const title = postData.title;
  const content = postData.content;
  let posted_time = new Date(postData.posted_time);
  posted_time = posted_time.toISOString().slice(0, 19).replace('T', ' ');

  const latitude = postData.latitude;
  const longitude = postData.longitude;

  console.log(user_name);
  console.log(title);
  console.log(content);
  console.log(posted_time);
  console.log(latitude);
  console.log(longitude);

  let conn = null;
  try {

    let QUERY_STR = `INSERT INTO User_Posts(user_name, title, content, posted_time, latitude, longitude) \ 
                        VALUES('${user_name}', '${title}', '${content}', '${posted_time}', '${latitude}', '${longitude}');`;

    conn = await new Promise((resolve, reject) => {
      pool.getConnection((err, connection) => {
        if (err) reject(err);
        resolve(connection);
      });
    }).catch((err) => {
      throw err;
    })

    const [rows] = await conn.promise().query(QUERY_STR);
    console.log('Successfully uploaded the content on DB. [/api/postUserContent]');
    res.sendStatus(200);
  } catch (err) {
    console.log(err);

    // 2023.08.11, jdk
    // 이후에 error status code로 세부적인 상황 구분
    res.status(404).json({
      error: "An error occurred while /api/postUserContent"
    });
  } finally {
    if (conn) conn.release();
  }
})

app.get('/api/getUsersPostsList', async (req, res) => {

  let conn = null;
  try {

    let QUERY_STR = `SELECT rid, user_name, title, content, posted_time, liked, comments_num, latitude, longitude FROM User_Posts order by posted_time desc;`;

    conn = await new Promise((resolve, reject) => {
      pool.getConnection((err, connection) => {
        if (err) reject(err);
        resolve(connection);
      });
    }).catch((err) => {
      throw err;
    })

    const [rows] = await conn.promise().query(QUERY_STR);

    // 2023.08.04, jdk
    // node.js에도 logger 도입 필요.
    // 또한, log나 error에 API 이름을 직접 드러내지 말고 간접적으로 에러 문구 바꾸기.

    console.log(rows);
    console.log('Successfully fetched the users posts list. [/api/getUsersPostsList]');
    res.status(200).json(rows);
  } catch (err) {
    res.status(404).json({
      error: "An error occurred while /api/getUsersPostsList"
    });
  } finally {
    if (conn) conn.release();
  }
})

// 2023.08.11, jdk
// 유저가 특정 게시글에 좋아요를 눌렀거나 취소했을 때 사용되는 API.
app.post('/api/pressedLikeButton', async (req, res) => {
  let conn = null;

  const likedPostData = req.body;

  const rid = likedPostData.rid;
  const user_name = likedPostData.user_name;
  const isCanceled = likedPostData.isCanceled;

  let added_num = null;
  let QUERY_STR_UPDATE_LIKE_ROW = null;

  // 새롭게 좋아요를 등록하는 경우
  if (isCanceled == false) {
    added_num = 1;
    QUERY_STR_UPDATE_LIKE_ROW = `INSERT INTO User_Posts_Like(rid, user_name) VALUES(${rid}, '${user_name}');`;
  }
  // 좋아요를 취소하는 경우
  else {
    added_num = -1;
    QUERY_STR_UPDATE_LIKE_ROW = `DELETE FROM User_Posts_Like WHERE rid=${rid} and user_name='${user_name}';`;
  }

  // 좋아요 개수 갱신
  const QUERY_STR_UPDATE_LIKED = `UPDATE User_Posts set liked = liked + (${added_num}) where rid = ${rid}`;

  try {
    conn = await new Promise((resolve, reject) => {
      pool.getConnection((err, connection) => {
        if (err) reject(err);
        resolve(connection);
      });
    }).catch((err) => {
      throw err;
    })

    // 2023.08.13, jdk
    // catch를 추가하여 error handling이 필요함.
    await conn.promise().query(QUERY_STR_UPDATE_LIKED);
    await conn.promise().query(QUERY_STR_UPDATE_LIKE_ROW);

    // rows 반환이 필요함?
    // 필요하지 않은 것으로 생각되어, sendStatus로 교체
    // console.log(rows);

    console.log('Successfully update a post liking. [/api/pressedLikeButton]');
    res.sendStatus(200);
  } catch (err) {
    console.error(err);

    res.status(404).json({
      // 2023.08.04, jdk
      error: "An error occurred while /api/getUsersPostsList"
    });
  } finally {
    if (conn) conn.release();
  }
});


app.post('/api/isPressedPostLike', async (req, res) => {
  let conn = null;

  const likedPostData = req.body;

  const rid = likedPostData.rid;
  const user_name = likedPostData.user_name;

  const QUERY_STR = `SELECT 1 FROM User_Posts_Like WHERE rid=${rid} and user_name='${user_name}';`;
  let isPressed = false;

  try {
    conn = await new Promise((resolve, reject) => {
      pool.getConnection((err, connection) => {
        if (err) reject(err);
        resolve(connection);
      });
    }).catch((err) => {
      throw err;
    })

    // 2023.08.13, jdk
    // catch를 추가하여 error handling이 필요함.
    const [rows] = await conn.promise().query(QUERY_STR);

    console.log(rows);

    if (rows[0]['1'] == 1) {
      isPressed = true;
    }

    console.log('rows.affectedRows : ', rows.affectedRows);
    console.log('isPressed : ', isPressed);

    // rows 반환이 필요함?
    // 필요하지 않은 것으로 생각되어, sendStatus로 교체
    // console.log(rows);

    console.log('Successfully applied user\'s like on DB. [/api/pressedLikeButton]');
    res.status(200).json({
      isPressed: isPressed,
    });
  } catch (err) {
    console.error(err);

    res.status(404).json({
      // 2023.08.04, jdk
      error: "An error occurred while /api/getUsersPostsList"
    });
  } finally {
    if (conn) conn.release();
  }
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

