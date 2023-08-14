import nodemailer from "nodemailer";
import { createRequire } from "module";
const require = createRequire(import.meta.url);
const db_config = require("./cfg/emailconfig.json");


export async function sendEmail(email, subject, content) {
  const smtpTransport = nodemailer.createTransport({
    service: "Gmail",   //사용하는 이메일 서비스
    auth: db_config     //계정 정보, 앱 비밀번호 
  });

  let emailOptions = {
    from: "whdgus120212@gmail.com",
    to: email,          //이메일을 받는 주소
    subject: subject,   //이메일 제목
    html: content,      //이메일 내용
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
