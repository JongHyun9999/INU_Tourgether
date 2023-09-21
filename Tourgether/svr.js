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
const crypto = require('crypto-js');

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
    text: `Tourgather 앱을 이용해주셔서 감사합니다! \n인증을 완료하기 위해 아래 4자리 숫자를 입력해주세요. \n${content}`
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

// ============================================

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

    let QUERY_STR = `INSERT INTO User_Posts(user_name, title, content, posted_time, gps) \ 
                        VALUES('${user_name}', '${title}', '${content}', '${posted_time}', Point(${latitude}, ${longitude}));`;

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

    let QUERY_STR = `SELECT rid, user_name, title, content, posted_time, liked, comments_num, gps FROM User_Posts order by posted_time desc;`;

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

app.post('/api/getUserComments', async (req, res) => {

  console.log('/api/getUserComments is executed...');

  const body = req.body;
  const rid = body['rid'];

  let conn = null;
  try {

    // 2023.09.06, jdk
    // rid를 가져올 필요는 없기 때문에 rid 가져오는 건 나중에 수정하기.
    const QUERY_STR = `SELECT rid, comment_idx, content, user_name, liked_num 
    from User_Comments where rid='${rid}'`;

    conn = await new Promise((resolve, reject) => {
      pool.getConnection((err, connection) => {
        if (err) reject(err);
        resolve(connection);
      });
    }).catch((err) => {
      throw err;
    })

    const [rows] = await conn.promise().query(QUERY_STR);
    console.log("rows : ", rows);

    // 2023.08.04, jdk
    // node.js에도 logger 도입 필요.
    // 또한, log나 error에 API 이름을 직접 드러내지 말고 간접적으로 에러 문구 바꾸기.

    console.log('Successfully fetched the users posts list. [/api/getUserComments]');
    res.status(200).json(rows);
  } catch (err) {
    res.status(404).json({
      error: "An error occurred while /api/getUserComments"
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
  const isPressed = likedPostData.isPressed;

  let added_num = null;
  let QUERY_STR_UPDATE_LIKE_ROW = null;

  // 새롭게 좋아요를 등록하는 경우
  if (isPressed == true) {
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

    let post_succeeded = false;
    let like_succeeded = false;

    // 2023.08.13, jdk
    // catch를 추가하여 error handling이 필요함.
    const [post_result] = await conn.promise().query(QUERY_STR_UPDATE_LIKED);

    // 2023.09.12, jdk
    // 좋아요 입력이 성공한 경우에만 좋아요 수를 늘리도록 변경.

    if (post_result.affectedRows > 0) {
      post_succeeded = true;
      const [like_result] = await conn.promise().query(QUERY_STR_UPDATE_LIKE_ROW);

      if (like_result.affectedRows > 0) {
        like_succeeded = true;
      }
    }

    // 2023.09.12, jdk
    // succeeded boolean 변수를 참조하여 결과를 확인,
    // 이후에 결과에 따라 response를 다르게 설정한다.
    console.log('Successfully update a post liking. [/api/pressedLikeButton]');

    if (post_succeeded && like_succeeded) {
      res.sendStatus(200);
    }
    else {
      throw Error();
    }
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


app.post('/api/isLikeButtonPressed', async (req, res) => {
  let conn = null;

  const likedPostData = req.body;

  const rid = likedPostData.rid;
  const user_name = likedPostData.user_name;

  const QUERY_STR = `SELECT EXISTS (
    SELECT 1
    FROM User_Posts_Like
    WHERE rid = ${rid} AND user_name = '${user_name}'
    ) AS row_exists;`;
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

    console.log(rows[0]);

    // 2023.08.14, jdk
    // 1이라는 이름 바꾸기. => pressedLike
    if (rows[0].row_exists == 1) {
      isPressed = true;
    }

    // rows 반환이 필요함?
    // 필요하지 않은 것으로 생각되어, sendStatus로 교체
    // console.log(rows);

    console.log('Successfully checked the pressed state of the like button. [/api/isPressedLikeButton]');
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

app.post('/api/postSignin', async (req, res) => {
  console.log('/api/postSignin 호출됨');
  const hash_password = crypto.SHA256(req.body.password).toString();
  console.log(hash_password);

  let conn = null;
  try {

    let QUERY_STR = `SELECT user_email, user_password from User_Info where user_email = '${req.body.email}' and user_password = '${hash_password}';`;
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
  let otp_code = '';
  for (let i = 0; i < 4; i++) {
    otp_code += Math.floor(Math.random() * 10);
  }
  otp_code = otp_code.toString();
  console.log('발송한 인증코드 : ', otp_code);

  let conn = null;
  try {
    await sendEmail(req.body.email, 'Tourgather 인증메일입니다.', otp_code);

    let QUERY_STR = `delete from User_Signup where user_email = '${req.body.email}';`;
    console.log(QUERY_STR);
    conn = await new Promise((resolve, reject) => {
      pool.getConnection((err, connection) => {
        if (err) reject(err);
        resolve(connection);
      });
    }).catch((err) => {
      throw err;
    })
    const [rows2] = await conn.promise().query(QUERY_STR);

    QUERY_STR = `insert into User_Signup(user_email, otp_code) values('${req.body.email}', '${otp_code}');`;
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

    let QUERY_STR = `update User_Signup set isVerified = 'Y' where user_email = '${req.params.user_email}';`;
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
  // 인증번호가 일치한지 확인하고, 일치한다면 회원가입 테이블에서 해당 유저의 인증정보를 지워버린다.

  console.log('/api/emailVerify 호출됨');
  console.log('받은 인증코드 : ', req.body.otp_code);
  let conn = null;
  try {
    console.log(req.body.email + ' 이메일 인증 확인 시작');
    // let QUERY_STR = `select isVerified from User_Signup where user_email = '${req.body.email}' and otp_code = '${req.body.otp_code}';`;
    let QUERY_STR = `select user_email from User_Signup where user_email = '${req.body.email}' and otp_code = '${req.body.otp_code}';`;
    conn = await new Promise((resolve, reject) => {
      pool.getConnection((err, connection) => {
        if (err) reject(err);
        resolve(connection);
      });
    }).catch((err) => {
      throw err;
    })
    const [rows1] = await conn.promise().query(QUERY_STR);

    let result;
    console.log(rows1[0])
    if (rows1[0] !== undefined) {
      console.log('지우기 시작')
      QUERY_STR = `delete from User_Signup where user_email = '${req.body.email}';`;
      console.log(QUERY_STR);
      conn = await new Promise((resolve, reject) => {
        pool.getConnection((err, connection) => {
          if (err) reject(err);
          resolve(connection);
        });
      }).catch((err) => {
        throw err;
      })
      const [rows2] = await conn.promise().query(QUERY_STR);
      result = rows2;
    }

    console.log('Successfully fetched the users posts list. [/api/emailVerify]');
    if (result.affectedRows) {
      console.log('메일 인증 완료. 다음 단계로 넘어감.');
      res.status(200).json(true);
    }
    else {
      console.log('메일 인증 오류.');
      res.status(404).json(false);
    }
  } catch (err) {
    res.status(404).json({
      error: "An error occurred while /api/emailVerify"
    });
  } finally {
    if (conn) conn.release();
  }
})

// 닉네임 중복 검사
app.post('/api/checkDupName', async (req, res) => {
  console.log('/api/checkDupName 호출됨');

  let conn = null;
  try {
    let QUERY_STR = `select user_name from User_Info where user_name = '${req.body.name}';`;
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
    console.log('Successfully fetched the users posts list. [/api/checkDupName]');
    if (rows[0]) res.status(200).json(true);
    else res.status(404).json(false);
  } catch (err) {
    console.log(err);
    res.status(404).json({
      error: "An error occurred while /api/checkDupName"
    });
  } finally {
    if (conn) conn.release();
  }
})

// 유저 등록
app.post('/api/addUser', async (req, res) => {
  console.log('/api/addUser 호출됨');
  const hash_password = crypto.SHA256(req.body.password).toString();
  console.log(hash_password);
  let conn = null;
  try {

    let QUERY_STR = `insert into User_Info(user_id, user_name, user_email, user_password, user_major) 
      values('${req.body.uid}', '${req.body.name}', '${req.body.email}', '${hash_password}', '${req.body.major}')`;

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
    console.log(err);
    res.status(404).json({
      error: "An error occurred while /api/addUser"
    });
  } finally {
    if (conn) conn.release();
  }
})

// 2023.07.25, jdk /get API
app.get('/getUserInfo', (req, res) => {

  pool.getConnection((err, conn) => {
    if (err) {
      res.statusMessage(404).send('Database Connection error')
    }
    // console.log(req)

    let query = `select * from User_Info WHERE user_email = '${req.headers.user_email}'`;
    console.log(query)
    conn.query(query, (err, response, fields) => {

      if (err) {
        console.log('failed to get a connection from DB');
        console.log(err);
        return;
      }

      console.log("DB query succesfully");
      console.log(response)
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

app.post('/update_user_map_visibility_status', async (req, res) => {
  console.log('check');
  const user_num = req.body.user_num;
  const user_map_visibility_status = parseInt(req.body.user_map_visibility_status);

  console.log(`user_num : ${user_num}`);
  console.log(`user_map_visibility_status : ${user_map_visibility_status}`);

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
    if (req.body.user_num) {
      QUERY_STR = `UPDATE User_Info SET user_map_visibility_status = '${user_map_visibility_status}' WHERE user_num = '${user_num}';`
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
      error: "An error occurred while update_user_map_visibility_status"
    });
  } finally {
    if (conn) conn.release();
  }
})

app.post('/api/postGetMessage', async (req, res) => {
  console.log('/api/postGetMessage 호출됨');
  let conn = null;
  console.log(req.body.last_rid)
  try {
    let QUERY_STR = `SELECT rid, user_name, title, content, posted_time, liked, comments_num, gps FROM User_Posts WHERE rid > '${req.body.last_rid}';`;
    if (req.body.last_date === '1986-01-01 00:00:00') {
      console.log('첫 호출')
      QUERY_STR = `SELECT rid, user_name, title, content, posted_time, liked, comments_num, gps FROM User_Posts;`;
    }

    conn = await new Promise((resolve, reject) => {
      pool.getConnection((err, connection) => {
        if (err) reject(err);
        resolve(connection);
      });
    }).catch((err) => {
      throw err;
    })

    let [rows] = await conn.promise().query(QUERY_STR);
    
    


    console.log(rows);
    console.log('Successfully fetched the users posts list. [/api/postGetMessage]');
    res.status(200).json(rows);
    // else res.status(404).json(null);
  } catch (err) {
    console.log(err);
    res.status(404).json({
      error: "An error occurred while /api/postGetMessage"
    });
  } finally {
    if (conn) conn.release();
  }
})

// 유저 등록
app.post('/api/postUserComment', async (req, res) => {

  const body = req.body;
  const rid = body['rid'];
  const user_name = body['user_name'];
  const content = body['content'];
  const liked_num = body['liked_num'];

  const QUERY_STR_POST_COMMENT = `insert into User_Comments(rid, user_name, content, liked_num)
    values(${rid}, '${user_name}', '${content}', ${liked_num})`;

  const QUERY_STR_ADD_CNT = `UPDATE User_Posts set comments_num = comments_num + 1 where rid = ${rid}`;

  let conn = null;
  try {
    conn = await new Promise((resolve, reject) => {
      pool.getConnection((err, connection) => {
        if (err) reject(err);
        resolve(connection);
      });
    }).catch((err) => {
      throw err;
    })

    let post_succeeded = false;
    let cnt_add_succeeded = false;
    let comment_idx = null;

    const [comment_post_result] = await conn.promise().query(QUERY_STR_POST_COMMENT);
    console.log("comment_post_result : ", comment_post_result);

    // 2023.09.12, jdk
    // 댓글이 DB 상에 성공적으로 저장된 경우
    if (comment_post_result.affectedRows > 0) {
      post_succeeded = true;

      const [cnt_add_result] = await conn.promise().query(QUERY_STR_ADD_CNT);

      // 2023.09.12, jdk
      // 댓글 개수 증가가 반영된 경우
      if (cnt_add_result.affectedRows > 0) {
        cnt_add_succeeded = true;
      }
    }

    // 2023.09.12, jdk
    // post, cnt_add boolean을 이용해서 추후에 error message handling code 추가.
    console.log('Successfully posted user comment [/api/postUserComment]');
    if (post_succeeded && cnt_add_succeeded) {
      console.log('not executed??');
      res.status(200).send();
    }
    else {
      res.status(404).send();
    }
  } catch (err) {
    console.log(err);
    res.status(404).json({
      error: "An error occurred while /api/postUserComment"
    });
  } finally {
    if (conn) conn.release();
  }
})

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

