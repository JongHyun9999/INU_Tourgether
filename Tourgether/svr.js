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

// import { sendEmail } from './sendemail.js';
// ==================================================
const nodemailer = require("nodemailer");
const emailconfig = require("./cfg/emailconfig.json");
async function sendEmail(email, subject, content) {
  const smtpTransport = nodemailer.createTransport({
    service: "Gmail",   //사용하는 이메일 서비스
    host: 'smtp.gmail.com',
    secure: true,
    auth: emailconfig     //계정 정보, 앱 비밀번호 
  });

  let emailOptions = {
    from: "premieravengers@gmail.com",
    to: email,          //이메일을 받는 주소
    subject: subject,   //이메일 제목
    html: `<h1>이메일 인증</h1>
            <div>
              아래 버튼을 눌러 인증을 완료해주세요.
              <a href='http://localhost:3000/api/processVerify/${email}'>이메일 인증하기</a>
            </div>`,    //이메일 내용
    text: 'Tourgather 앱을 이용해주셔서 감사합니다! \n인증을 완료하기 위해 아래 버튼을 눌러주세요.'
  };

  return new Promise((resolve, reject) => {
    smtpTransport.sendMail(emailOptions, (err, response) => {
      if (err) {
        console.log(err);
        reject(err);
      } else {
        console.log(response);
        resolve(response);
      }
      smtpTransport.close();
    });
  });
}

const dict_isverified = {};
// ============================================


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
app.post('/postMessageData', async (req, res) => {
  const userId = req.body.author
  const textContent = req.body.content
  const latitude = req.body.latitude
  const longitude = req.body.longitude

  let conn = null;
  try {
    let QUERY_STR = null;
    if (req.body.image === null) {
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
        }
      });
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

// 2023.07.29, jdk
// postUserContent : 유저가 작성한 쪽지 게시글을 DB에 업로드 하는 API.
// 이후에는 /api router를 만들어서 기능을 분리하도록 한다.
app.post('/api/postUserContent', async (req, res) => {
  const postData = req.body;
  console.log('postData : ', postData);

  const user_id = postData.user_id;
  const title = postData.title;
  const content = postData.content;
  let posted_time = new Date(postData.posted_time);
  posted_time = posted_time.toISOString().slice(0, 19).replace('T', ' ');

  const latitude = postData.latitude;
  const longitude = postData.longitude;

  console.log(user_id);
  console.log(title);
  console.log(content);
  console.log(posted_time);
  console.log(latitude);
  console.log(longitude);

  let conn = null;
  try {

    let QUERY_STR = `INSERT INTO User_Posts(user_id, title, content, posted_time, latitude, longitude) \ 
                        VALUES('${user_id}', '${title}', '${content}', '${posted_time}', '${latitude}', '${longitude}');`;

    conn = await new Promise((resolve, reject) => {
      pool.getConnection((err, connection) => {
        if (err) reject(err);
        resolve(connection);
      });
    }).catch((err) => {
      console.log("?");
      throw err;
    })

    const [rows] = await conn.promise().query(QUERY_STR);
    console.log('Successfully uploaded the content on DB. [/api/postUserContent]');
    res.status(200).json(rows);
  } catch (err) {
    console.log(err);

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

    let QUERY_STR = `SELECT user_id, title, content, posted_time, liked, latitude, longitude FROM User_Posts order by posted_time desc;`;

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
      // 2023.08.04, jdk
      error: "An error occurred while /api/getUsersPostsList"
    });
  } finally {
    if (conn) conn.release();
  }
})

app.post('/api/postSignin', async (req, res) => {
  console.log('/api/postSignin 호출됨');
  let conn = null;
  try {

    let QUERY_STR = `SELECT user_email, user_password from User_Info where user_email = '${req.body.email}' and user_password = '${req.body.password}';`;
    conn = await new Promise((resolve, reject) => {
      pool.getConnection((err, connection) => {
        if (err) reject(err);
        resolve(connection);
      });
    }).catch((err) => {
      throw err;
    })
    const [rows] = await conn.promise().query(QUERY_STR);

    console.log(rows[0]);
    console.log('Successfully fetched the users posts list. [/api/postSignin]');
    if (rows[0]) res.status(200).json(true);
    else res.status(404).json(false);
  } catch (err) {
    res.status(404).json({
      error: "An error occurred while /api/postSignin"
    });
  } finally {
    if (conn) conn.release();
  }
})

// 입력한 이메일로 인증메일 전송
app.post('/api/postSignup', async (req, res) => {
  console.log('/api/postSignup 호출됨');
  let conn = null;
  try {
    await sendEmail(req.body.email, 'Tourgather 인증메일입니다.', '0352');

    let QUERY_STR = `insert into User_SignUp(user_email, isVerified) values('${req.body.email}', 'N');`;
    conn = await new Promise((resolve, reject) => {
      pool.getConnection((err, connection) => {
        if (err) reject(err);
        resolve(connection);
      });
    }).catch((err) => {
      throw err;
    })

    const [rows] = await conn.promise().query(QUERY_STR);

    console.log(rows)
    console.log('Successfully fetched the users posts list. [/api/postSignup]');
    if (rows[0]) res.status(200).json(true);
    else res.status(404).json(false);
  } catch (err) {
    res.status(404).json({
      error: "An error occurred while /api/postSignup"
    });
  } finally {
    if (conn) conn.release();
  }
})

// 사용자의 인증 버튼 처리
app.get('/api/processVerify/:user_email', async (req, res) => {
  console.log('/api/processVerify 호출됨');
  let conn = null;
  try {
    // dict_isverified[`${req.params.user_email}`] = true;
    let QUERY_STR = `update User_SignUp set isVerified = 'Y' where user_email = '${req.params.user_email}';`;
    conn = await new Promise((resolve, reject) => {
      pool.getConnection((err, connection) => {
        if (err) reject(err);
        resolve(connection);
      });
    }).catch((err) => {
      throw err;
    })

    const [rows] = await conn.promise().query(QUERY_STR);

    console.log('Successfully fetched the users posts list. [/api/processVerify]');
    if (rows[0]) res.status(200).json(true);
    else res.status(404).json(true);
  } catch (err) {
    res.status(404).json({
      error: "An error occurred while /api/processVerify"
    });
  } finally {
    if (conn) conn.release();
  }
})

// 인증 다음 단계 버튼 누를시
app.post('/api/emailVerify/', async (req, res) => {
  console.log('/api/emailVerify 호출됨');
  let conn = null;
  try {
    console.log(req.body.email + ' 이메일 인증 확인 시작');
    let QUERY_STR = `select isVerified from User_SignUp where user_email = '${req.body.email}';`;
    conn = await new Promise((resolve, reject) => {
      pool.getConnection((err, connection) => {
        if (err) reject(err);
        resolve(connection);
      });
    }).catch((err) => {
      throw err;
    })

    const [rows] = await conn.promise().query(QUERY_STR);

    console.log('Successfully fetched the users posts list. [/api/emailVerify]');
    if (rows[0].isVerified === 'Y') {
      console.log('메일 인증 완료. 다음 단계로 넘어감.');
      res.status(200).json(true);
    }
    else {
      console.log('메일 인증 오류.');
      res.status(404).json(true);
    }
  } catch (err) {
    res.status(404).json({
      error: "An error occurred while /api/emailVerify"
    });
  } finally {
    if (conn) conn.release();
  }
})

// 유저 등록
app.post('/api/addUser', async (req, res) => {
  console.log('/api/addUser 호출됨');
  let conn = null;
  try {

    let QUERY_STR = `insert into User_Info(user_id, user_name, user_email, user_password, user_major) 
      values('${req.body.uid}', '${req.body.name}', '${req.body.email}', '${req.body.password}', '임베테스트')`;

    conn = await new Promise((resolve, reject) => {
      pool.getConnection((err, connection) => {
        if (err) reject(err);
        resolve(connection);
      });
    }).catch((err) => {
      throw err;
    })

    const [rows] = await conn.promise().query(QUERY_STR);

    console.log(rows);
    console.log('Successfully fetched the users posts list. [/api/addUser]');
    if (rows[0]) res.status(200).json(true);
    else res.status(404).json(false);
  } catch (err) {
    res.status(404).json({
      error: "An error occurred while /api/addUser"
    });
  } finally {
    if (conn) conn.release();
  }
})


app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
