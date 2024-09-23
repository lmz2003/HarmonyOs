import { setToken } from '../utils/index' // 引入 setToken 函数
import { RequestParams, showToast,loginrequest} from '../utils/request'
import { router } from '@kit.ArkUI'
import { http } from '@kit.NetworkKit'
import '@ohos.utils.fastjson.JSONArray';
import '@ohos.utils.fastjson.JSONObject';
import deviceInfo from '@ohos.deviceInfo'

interface GetData{
  "errorType":string,
  "x_pre":number,
  "x_post":number,
  "y_pre":number,
  "y_post":number,
  "score":number
}
export class Data implements GetData {
  errorType: string;
  x_pre: number;
  x_post: number;
  y_pre: number;
  y_post: number;
  score: number;

  constructor(e: string = "", x_pre: number = 0, x_post: number = 0, y_pre: number = 0, y_post: number = 0, score: number = 0) {
    this.errorType = e;
    this.x_pre = x_pre;
    this.x_post = x_post;
    this.y_pre = y_pre;
    this.y_post = y_post;
    this.score = score;
  }
}
interface GeneratedObjectLiteralInterface_2 {
  "name": string;
}

interface GeneratedObjectLiteralInterface_3 {
  "project": GeneratedObjectLiteralInterface_2;
}

interface GeneratedObjectLiteralInterface_1 {
  "name": string;
}

interface GeneratedObjectLiteralInterface_4 {
  "domain": GeneratedObjectLiteralInterface_1;
  "name": string;
  "password": string;
}

interface GeneratedObjectLiteralInterface_5 {
  "user": GeneratedObjectLiteralInterface_4;
}

interface GeneratedObjectLiteralInterface_6 {
  "methods": string[];
  "password": GeneratedObjectLiteralInterface_5;
}

interface GeneratedObjectLiteralInterface_7 {
  "identity": GeneratedObjectLiteralInterface_6;
  "scope": GeneratedObjectLiteralInterface_3;
}

interface GeneratedObjectLiteralInterface_8 {
  "auth": GeneratedObjectLiteralInterface_7;
}


@Entry
@Component
struct Login {
  @State domainname: string = '';
  @State username: string = '';
  @State userPassWord: string = '';
  loginData: GeneratedObjectLiteralInterface_8 = {
    "auth": ({
      "identity": ({
        "methods": ["password"],
        "password": ({
          "user": ({
            "domain": ({ "name": this.domainname } as GeneratedObjectLiteralInterface_1),
            "name": this.username,
            "password": this.userPassWord
          } as GeneratedObjectLiteralInterface_4)
        } as GeneratedObjectLiteralInterface_5)
      } as GeneratedObjectLiteralInterface_6),
      "scope": ({
        "project": ({
          "name": "cn-southwest-2"
        } as GeneratedObjectLiteralInterface_2)
      } as GeneratedObjectLiteralInterface_3)
    } as GeneratedObjectLiteralInterface_7)
  }


  param: RequestParams = {
    url: 'v3/auth/tokens',
    method: http.RequestMethod.POST,
    data: this.loginData,
    headerContentType: 'application/json'
  }
  private loginUser = async () => {
    if (!this.domainname || !this.username || !this.userPassWord) {
      AlertDialog.show({
        title: '温馨提示',
        message: '请输入租户名或用户名或者密码',
        autoCancel: true,
        alignment: DialogAlignment.Center,
        gridCount: 3,
        confirm: {
          value: '确认',
          action: () => {
            console.info('Button-clicking callback');
          }
        },
        cancel: () => {
          console.info('Closed callbacks');
        }
      });
    } else {

      try {
        const response = await loginrequest(this.param);
        if (response.code === 201) {
          if(deviceInfo.deviceType==='phone'){
            router.replaceUrl({ url: 'pages/IndexPhone' });
          }else{
            router.replaceUrl({ url: 'pages/IndexTablet' });
          }
        } else {
          showToast(response.message);
        }
      } catch (error) {
        showToast();
      }
    }
  };
  build() {
  Column(){
    Column() {
      Image($r('app.media.Icon'))
        .width(106)
        .height(106)
        .borderRadius(10)
        .margin({ top: 60, bottom: 10 });

      Text('华为IAM用户登录').fontSize(20).margin({top:5})
      Column({ space: 10 }) {
        TextInput({ text: this.domainname, placeholder: '租户名/原华为云账号' })
          .width('50%')
          .height(40)
          .type(InputType.USER_NAME)
          .onChange((e) => {
            this.domainname = e;
            this.loginData.auth.identity.password.user.domain.name = e;
          });
        TextInput({ text: this.username, placeholder: 'IAM用户名/邮件地址' })
          .width('50%')
          .height(40)
          .type(InputType.USER_NAME)
          .onChange((e) => {
            this.username = e;
            this.loginData.auth.identity.password.user.name = e;
          });
        TextInput({ text: this.userPassWord, placeholder: 'IAM用户密码' })
          .width('50%')
          .height(40)
          .type(InputType.Password)
          .onChange((e) => {
            this.userPassWord = e;
            this.loginData.auth.identity.password.user.password = e;
          });
      }
      .margin({ top: 45 });

      Row() {
        Button('登录', { type: ButtonType.Normal, stateEffect: true })
          .borderRadius(8)
          .backgroundColor(0x317aff)
          .type(ButtonType.Capsule)
          .width('30%')
          .backgroundColor('#ffd6091b')
          .onClick(this.loginUser);
      }
      .margin({ top: 60 });

      Blank();


      Row() {
        Text('我已阅读并同意');
        Text('用户协议').fontColor('#ff649af6')
          .decoration({ type: TextDecorationType.Underline, color: '#ff649af6' });
      }
      .margin({bottom:10})
    }
    .backgroundColor(Color.White)
    .borderRadius(20)
    .width('40%')
    .height('90%')

    .alignItems(HorizontalAlign.Center)

  }.width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .linearGradient({
    // 设置颜色渐变起始角度为顺时针方向45°
    colors: [
      ['rgb(199, 210, 254)', 0.0], // 颜色断点1的颜色和比重，对应组件在180°方向上的起始位置
      ['rgb(254, 202, 202)', 0.5], // 颜色断点2的颜色和比重，对应组件在180°方向上的终点位置
      ['rgb(254, 249, 195)', 1],
    ]
  })

  }
}

