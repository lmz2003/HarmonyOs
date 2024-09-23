import ImageUploadDialog from '../components/Dialog/ImageUploadDialog'
import { promptAction, router, window } from '@kit.ArkUI'
import { image } from '@kit.ImageKit';
import { Data } from './LoginPageTablet';
import { loading } from '../components/Dialog/loading';
import { imageHelper } from './ImagePreviewPhone';
import { common } from '@kit.AbilityKit';
import { copyFileToCache, getToken } from '../utils';
import { BusinessError, request } from '@kit.BasicServicesKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer, util } from '@kit.ArkTS';
import { Base64 } from '@ohos/base64';
import { http } from '@kit.NetworkKit';
import { deviceInfo } from '@kit.BasicServicesKit';

// 定义接口以描述 JSON 数据的结构
interface GeneratedTypeLiteralInterface_1 {
  connection: string;
  contentLength: string;
  contentType: string;
  date: string;
  server: string;
  setCookie: string;
  xModelartsLatency: string;
  xModelartsServiceVersion: string;
  xModelartsTraceId: string;
  xRequestId: string;
}

interface GeneratedTypeLiteralInterface_2 {
  detection_classes?: string[];
  detection_boxes?: [
    number,
    number,
    number,
    number
  ][];
  detection_scores?: number[];
}

interface DetectionResponse {
  headers: GeneratedTypeLiteralInterface_1;
  body: GeneratedTypeLiteralInterface_2;
}

class GeneratedTypeLiteralInterface_1Imp implements GeneratedTypeLiteralInterface_1 {
  connection: string;
  contentLength: string;
  contentType: string;
  date: string;
  server: string;
  setCookie: string;
  xModelartsLatency: string;
  xModelartsServiceVersion: string;
  xModelartsTraceId: string;
  xRequestId: string;

  constructor(connection: string, contentLength: string, contentType: string, date: string, server: string,
    setCookie: string, xModelartsLatency: string, xModelartsServiceVersion: string, xModelartsTraceId: string,
    xRequestId: string) {
    this.connection = connection;
    this.contentLength = contentLength;
    this.contentType = contentType;
    this.date = date;
    this.server = server;
    this.setCookie = setCookie;
    this.xModelartsLatency = xModelartsLatency;
    this.xModelartsServiceVersion = xModelartsServiceVersion;
    this.xModelartsTraceId = xModelartsTraceId;
    this.xRequestId = xRequestId;
  }
}

@Observed
class GeneratedTypeLiteralInterface_2Imp implements GeneratedTypeLiteralInterface_2 {
  detection_classes?: string[];
  detection_boxes?: [number, number, number, number][];
  detection_scores?: number[];

  constructor(detection_classes?: string[], detection_boxes?: [number, number, number, number][],
    detection_scores?: number[]) {
    this.detection_classes = detection_classes;
    this.detection_boxes = detection_boxes;
    this.detection_scores = detection_scores;
  }
}

class DetectionResponseImp implements DetectionResponse {
  headers: GeneratedTypeLiteralInterface_1Imp;
  body: GeneratedTypeLiteralInterface_2Imp;

  constructor(headers: GeneratedTypeLiteralInterface_1Imp, body: GeneratedTypeLiteralInterface_2Imp) {
    this.headers = headers;
    this.body = body;
  }
}

let pageOrientations: Record<string, window.Orientation> = {
  "Logon": window.Orientation.PORTRAIT,
  "Detail": window.Orientation.LANDSCAPE,
  "Page2": window.Orientation.PORTRAIT_INVERTED,
  "Page3": window.Orientation.LANDSCAPE_INVERTED,
}

function CalDegree(x: number, y: number, z: number): number {
  const radToDeg = 180 / Math.PI;
  let degree = Math.atan2(y, x) * radToDeg;
  if (degree < 0) {
    degree += 360;
  }
  return degree;
}

@Entry
@Component
struct Index {
  imageURL: string = '';
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  @State imagePa: string = ""
  @State imageHide: Visibility = Visibility.Hidden
  @State showOriginalImage: boolean = false; // 是否展示原始图片
  isGetData: boolean = false;
  Detect: boolean = false;
  @State Getpath: boolean = false;
  @State data: object = new Object
  @State datas: Data[] = [];
  @State CanIGetImage: boolean = false;
  @State imageFinal: PixelMap | null = null;
  @State imageIn: image.ImageInfo | null = null
  @State dialogController_loading: CustomDialogController | null = new CustomDialogController({
    builder: loading(),
    alignment: DialogAlignment.Center,
    offset: ({ dx: 0, dy: 0 }),
    autoCancel: false,
    customStyle: true
  })
  @State resultData: GeneratedTypeLiteralInterface_2Imp = new GeneratedTypeLiteralInterface_2Imp()
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: ImageUploadDialog({
      data: this.data,
      imageHide: this.imageHide,
      imageCh: this.imagePa,
      isshowOriginalImage: this.showOriginalImage,
      isGetpath: this.Getpath,
      uploadURL: 'https://infer-modelarts-cn-southwest-2.myhuaweicloud.com/v1/infers/b7df3ed9-ede3-4ddf-b353-ee35ec9a9565', //上传地址
      xy_data: this.datas,
      dialogController_loading: this.dialogController_loading,
      CanIGetImage: this.CanIGetImage
    }),
    alignment: DialogAlignment.Bottom, //弹窗居于底部
    customStyle: true, //自定义样式
  }) //选择上传类型弹窗控制器
  context1 = getContext(this) as common.UIAbilityContext; //UIAbilityContext
  @State ODID: string = ''

  aboutToAppear(): void {
    this.ODID = deviceInfo.ODID;
  }

  stringToUint8Array(str: string) {
    let arr = new Uint8Array(str.length);
    for (let i = 0, j = str.length; i < j; ++i) {
      arr[i] = str.charCodeAt(i);
    }
    return arr;
  }

  async getArrayBuffer(pixelMap: PixelMap): Promise<ArrayBuffer> {
    //创建打包设置
    const imagePackerApi: image.ImagePacker = image.createImagePacker();
    let packOpts: image.PackingOption = { format: "image/png", quality: 98 };
    return await imagePackerApi.packing(pixelMap, packOpts)
  }

  async computeHmacSha1(message: string, secretKey: string): Promise<Uint8Array> {
    try {
      // 创建 HMAC-SHA1 实例
      let macAlgName = 'SHA1'; // 或其他适合的名字，具体取决于 cryptoFramework 的 API
      let mac = cryptoFramework.createMac(macAlgName);
      // 将密钥和消息转换为字节流
      let textEncoder: util.TextEncoder = new util.TextEncoder('utf-8');
      let keyBytes: Uint8Array = textEncoder.encodeInto(secretKey);
      let messageBytes: Uint8Array = textEncoder.encodeInto(message);
      // 创建密钥 blob
      let keyBlob: cryptoFramework.DataBlob = { data: keyBytes };
      let symKeyGenerator = cryptoFramework.createSymKeyGenerator('HMAC');
      // 转换密钥
      const symKey = await symKeyGenerator.convertKey(keyBlob);
      // 初始化 MAC 对象
      await mac.init(symKey);
      // 更新数据
      await mac.update({ data: messageBytes });
      // 获取最终的 MAC 输出
      let macOutput: cryptoFramework.DataBlob = await mac.doFinal();
      // 将 MAC 输出转换为十六进制字符串
      let result = macOutput.data;
      const res = buffer.from(macOutput.data).toString('hex');
      console.log('Hmac—:' + res);
      return result;
    } catch (err) {
      console.error('Error:', err);
      return err;
    }
  }

  async saveToYun(Http_Verb: string, bucketName: string, image: ArrayBuffer) {
    const ContentMD5 = "";
    const ContentType = "application/octet-stream";
    const baseUrl: string = 'http://history-image.obs.cn-southwest-2.myhuaweicloud.com';
    const accessKeyId = '6LONLGGS8X0WJABM8ABW';
    const secretKey = 'E2ODKlOXpSwdPkPFYL1m0uuD9NDonxRLd19kZaXw';
    let date = new Date();
    let dateString = date.toUTCString()
    console.log(dateString)
    let imageName: string = date.getTime() + ".jpg";
    let resourceName: string = "/" + bucketName + "/image/" + imageName;
    const stringToSign: string =
      Http_Verb + "\n" + ContentMD5 + "\n" + ContentType + "\n" + dateString + "\n" + resourceName;
    console.log("stringToSign:", stringToSign);
    console.log('HmacSHA1处理');
    let a: Uint8Array = await this.computeHmacSha1(stringToSign, secretKey);
    console.log("HmacSHA1编码" + a.toString());
    let Signature: string = Base64.encodeToString(a);
    console.info("base64  encode:" + Signature);
    console.log('BASE64编码' + Signature)
    let Authorization: string = "OBS " + accessKeyId + ":" + Signature;
    console.log(Authorization)
    // 签名设置完毕,可以进行数据的传输了
    console.log(baseUrl + "/image/" + imageName)
    this.imageURL = baseUrl + "/image/" + imageName;
    let httpRequest: http.HttpRequest = http.createHttp();
    httpRequest.request(
      baseUrl + "/image/" + imageName
      , {
      method: http.RequestMethod.PUT,
      header: {
        "Content-Type": "application/octet-stream",
        "Authorization": Authorization,
        "Date": dateString
      },
      extraData: image,
      readTimeout: 30000,
      connectTimeout: 30000
    }
      , (err: BusinessError, data: http.HttpResponse) => {
      if (!err) {
        if (data.responseCode === 200) {
          console.log('保存成功');
          //保存成功关闭弹窗
          console.log(this.imageURL)
        } else {
          console.log("错误码" + data.responseCode + "错误信息" + data.result)
        }
      } else {
        console.log("错误信息" + err.message + "\n" + "错误码" + err.code)
      }
    }
    )
  }

  async addRecordToDatabase(description: string, url: string, device: string, deviceCode: string) {
    let httpRequest = http.createHttp();

    httpRequest.on('headersReceive', (header) => {
      console.info('header: ' + JSON.stringify(header));
    });

    httpRequest.request(
      `http://ngrokthree.sv6.tunnelfrp.com/har`, // 将此替换为你实际的API URL
      {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify({
          description: description,
          url: url,
          device: device,
          deviceCode: deviceCode
        }),
        expectDataType: http.HttpDataType.STRING,
        usingCache: false,
        connectTimeout: 60000,
        readTimeout: 60000,
      },
      (err: BusinessError, data: http.HttpResponse) => {
        if (!err) {
          console.info('Data added successfully!');
          console.info('Result:' + JSON.stringify(data.result));
          console.info('Response Code:' + JSON.stringify(data.responseCode));
        } else {
          console.error('Error adding data: ' + JSON.stringify(err));
        }

        httpRequest.off('headersReceive');
        httpRequest.destroy();
      }
    );
  }

  //开始上传图片 path：图片路径后缀（图片名称）
  async uploadImage(path: string) {
    let token: string = await getToken(); //获取到token
    let result = token.replace(/[\r\n\s]+/g, ""); //对 token 进行处理，去除其中的换行符、回车符和空格等多余的字符
    let filePath = await copyFileToCache(path, this.context1)
    let uri = `internal://cache/${filePath}` //上传图片全路径
    //这个是cache中存储的路径
    console.log(`${result}`)
    console.log(`${uri}`, "图片url")
    let uploadConfig: request.UploadConfig = {
      //上传的路径
      url: 'https://infer-modelarts-cn-southwest-2.myhuaweicloud.com/v1/infers/426e9296-0ccb-4303-8bb9-e16a38803b6c',
      header: {
        'Content-Type': 'multipart/form-data',
        'x-auth-token': result
      },
      method: "POST",
      files: [{
        filename: "images",
        name: "images",
        uri,
        type: "png"
      }], //类型
      data: []
    };

    try {
      //传输文件
      promptAction.showToast({
        message: '正在检测，请稍等'//弹窗内容
      });
      this.dialogController_loading?.open()
      this.isGetData = false;
      console.log('Context1:', JSON.stringify(this.context1));
      let uploadTask: request.UploadTask = await request.uploadFile(this.context1, uploadConfig);
      let headerCallback = (headers: object) => {
        this.isGetData = true;
        this.data = headers
        console.log("检测完成")
        promptAction.showToast({
          message: '检测完成'//弹窗内容
        });
        this.Detect = true;
        this.CanIGetImage = true;
        this.dialogController_loading?.close()
        // console.info("upOnHeader headers:" + JSON.stringify(headers));
      };
      uploadTask.on('headerReceive', headerCallback);
      // 获得了数据和字符串
    } catch (e) {
      console.log(JSON.stringify(e), '请求错误')
    }


  }

  build() {
    Row({ space: 5 }) {
      //Canvas()
      Column({ space: 20 }) {
        Text("图片").fontSize(20)
          .margin({ top: 10 })

        Divider().strokeWidth(1)
          .color(Color.Gray)
          .width('100%')


        Canvas(this.context)
          .width('100%')
          .height('90%')

          .onReady(() => {
          })
          .onClick(() => {
            this.imageIn = this.imageFinal?.getImageInfoSync() as image.ImageInfo;
            let size: image.Size = this.imageIn.size;
            console.log("高度：" + size.height);
            console.log("宽度：" + size.width);
            let arr: ArrayBuffer = new ArrayBuffer(size.height * size.width * 4);
            //数组缓存区
            this.imageFinal?.readPixelsToBuffer(arr);
            let result = Array.from(new Uint8Array(arr))
            console.log("字节长度：" + arr.byteLength.toString());
            //跳转到界面
            router.pushUrl({ url: 'pages/ImagePreviewTablet', params: new imageHelper(result, size) });
          })
          .enabled(this.CanIGetImage)
      }
      .width('50%')
      .height('100%')
      .borderColor(Color.Gray)
      .borderWidth(1)
      .borderRadius(10)
      .margin({left:10})

      Column({ space: 20 }) {
        Text("检测结果").fontSize(20)
          .fontWeight(25)
          .margin({ top: 10 })
        Divider().strokeWidth(1)
          .color(Color.Gray)
          .width('100%')

        Row({ space: 70 }) {
          Text("种类").fontSize(15).fontWeight(15)
          Text("   坐标").fontSize(15).fontWeight(15)
          Text("   置信度").fontSize(15).fontWeight(15)
        }
        Divider().strokeWidth(1)
          .color(Color.Gray)
          .width('100%')
        Row() {
          List({ space: 10 }) {

            ForEach(this.datas, (item: Data) => {
              ListItem() {

                Row({ space: 40 }) {
                  Text(item.errorType).fontSize("13vp").width('25%')
                  Text(item.x_pre.toFixed(2) + "\t" + "\t" + item.x_post.toFixed(2) + "\n" + item.y_pre.toFixed(2) +
                    "\t" + "\t" + item.y_post.toFixed(2)).fontSize("13vp").width('30%')
                  Text(item.score.toFixed(2)).fontSize("13vp").width('20%')
                }.margin({ left: 30 })
              }
            })
          }
        }

      }
      .height('100%')
      .width('30%')
      .borderColor(Color.Gray)
      .borderWidth(1)
      .borderRadius(10)
      .alignItems(HorizontalAlign.Center)


      Column({ space: 10 }) {
        Button('添加图片').onClick(async () => {
          await new Promise<void>((resolve) => {
            this.dialogController?.open();
            const checkFilePathUpdate = () => {
              if (this.showOriginalImage) {
                this.dialogController?.close();
                resolve(); // 等待图片路径更新完成后，继续执行
              } else {
                setTimeout(checkFilePathUpdate, 100); // 每隔100毫秒检查一次
              }
            };
            checkFilePathUpdate();
          });
          if (this.showOriginalImage) {
            this.showOriginalImage = false; // 切换为展示原始图片
            let imageBitMap: ImageBitmap = new ImageBitmap(this.imagePa);
            let canvasWidth = this.context.width; // 画布宽度
            let canvasHeight = this.context.height; // 画布高度
            let scaleRatio = canvasWidth / imageBitMap.width; // 计算缩放比例
            let scaledHeight = imageBitMap.height * scaleRatio; // 计算缩放后的高度
            let topMargin = (canvasHeight - scaledHeight) / 2;
            // 计算水平居中的 leftMargin
            let leftMargin = (canvasWidth - imageBitMap.width * scaleRatio) / 2;

            // 清除Canvas，并绘制原始图片居中显示
            this.context.clearRect(0, 0, canvasWidth, this.context.height);
            this.context.drawImage(imageBitMap, 0, 0, imageBitMap.width, imageBitMap.height, leftMargin, topMargin,
              imageBitMap.width * scaleRatio, scaledHeight);
          } else {
            console.log("No image found for detection.");
          }
        })
          .backgroundColor('#ffd6091b')


        Button('检测图片').onClick(async () => {
          if (this.Getpath) {
            // 如果被刷新，那么就获得图片信息
            await this.uploadImage(this.imagePa)
            await new Promise<void>((resolve) => {
              const checkFilePathUpdate = () => {
                if (this.isGetData) {
                  resolve(); // 等待图片路径更新完成后，继续执行
                } else {
                  setTimeout(checkFilePathUpdate, 100); // 每隔100毫秒检查一次
                }
              };
              checkFilePathUpdate();
            });
            if (this.isGetData && this.Detect == true) {
              //获取图片信息
              let imageBitMap: ImageBitmap = new ImageBitmap(this.imagePa);
              console.log("width", imageBitMap.width)
              console.log("height", imageBitMap.height)
              let canvasWidth = this.context.width; // 画布宽度
              let canvasHeight = this.context.height; // 画布高度

              // 确定缩放比例：保持图片宽度与画布宽度相同
              let scaleRatio = canvasWidth / imageBitMap.width;
              let scaledHeight = imageBitMap.height * scaleRatio;
              // 计算水平居中的 leftMargin
              let leftMargin = (canvasWidth - imageBitMap.width * scaleRatio) / 2;
              let topMargin = (canvasHeight - scaledHeight) / 2;
              this.context.reset();
              // 创建imageBitMap
              // 1vp = 0.4444444px
              // 在画布上绘制图片，保持图片宽度与画布宽度相同，并且设置顶部间距
              this.context.drawImage(imageBitMap, 0, 0, imageBitMap.width, imageBitMap.height, leftMargin, topMargin,
                canvasWidth,
                scaledHeight);
              // 可以进行画作了
              //获取数据
              if (this.resultData.detection_boxes) {
                this.resultData.detection_boxes = [];
              }
              let str = JSON.stringify(this.data);
              console.log(str)
              // 删除所有的 \ 字符
              let noBackslashesStr = str.replace(/\\/g, '');
              // 在每个 " 字符前插入一个 \
              let modifiedStr = noBackslashesStr.replace(/"/g, '\\"');
              let noSpacesStr = modifiedStr.replace(/\s+/g, '');
              let index = noSpacesStr.indexOf("body")
              let substring = noSpacesStr.substring(index + 9, noSpacesStr.length - 3);
              let re: string = substring.replace(/\.0/g, '');
              let ree = re.replace(/\\/g, '');
              console.log(index.toString(), "body的索引")
              console.log(ree)
              this.resultData = JSON.parse(ree)
              if (this.resultData.detection_classes != undefined && this.resultData.detection_boxes != undefined &&
                this.resultData.detection_scores != undefined) {
                //循环渲染
                let num = this.resultData.detection_classes.length;

                for (let i = 0; i < num; i++) {
                  let nums: number[] = this.resultData.detection_boxes[i];
                  let className = this.resultData.detection_classes[i];
                  let score = this.resultData.detection_scores[i];
                  // 根据缩放比例调整检测框的坐标
                  let x = nums[1] * scaleRatio;
                  let y = nums[0] * scaleRatio;
                  let width = (nums[3] - nums[1]) * scaleRatio;
                  let height = (nums[2] - nums[0]) * scaleRatio;
                  this.datas[i] = new Data(className, x, x + width, y, y + width, score);
                  if (className === "Mouse_bite") {
                    this.context.strokeStyle = '#FFFF00'
                  } else if (className === "Open_curcuit") {
                    this.context.strokeStyle = '#EE82EE'
                  } else if (className === "Short") {
                    this.context.strokeStyle = 'red'
                  } else if (className === "Spur") {
                    this.context.strokeStyle = '#3333FF'
                  } else if (className === "Spurious_copper") {
                    this.context.strokeStyle = 'black'
                  }

                  this.context.rect(x * 0.444444444 + leftMargin, y * 0.444444444 + topMargin, width * 0.444444444,
                    height * 0.444444444)
                  // 绘制文本标签
                  this.context.font = '16px Arial'; // 设置字体大小和字体
                  this.context.fillStyle = 'red'; // 设置文本颜色
                  this.context.textBaseline = 'top'; // 设置文本的基线位置
                  this.context.fillText(`${className} (${score.toFixed(2)})`, x * 0.444444444 + leftMargin,
                    y * 0.444444444 + topMargin - 10); // 绘制文本，-5 是为了将文本放在矩形框上方
                  this.context.stroke()
                }
                this.imageFinal =
                  this.context.getPixelMap(leftMargin, topMargin, canvasWidth, imageBitMap.height * scaleRatio);
                console.log(this.imageFinal.getBytesNumberPerRow().toString())
              }
              this.showOriginalImage = false;
              this.Detect = false;
              let arr: ArrayBuffer = new ArrayBuffer(1)
              //result 是最终获取到的数据
              if (this.imageFinal != null) {
                arr = await this.getArrayBuffer(this.imageFinal);
              }
              let description: string = JSON.stringify(this.resultData);
              let device: string = deviceInfo.deviceType;
              let deviceCode: string = this.ODID;

              //下面是上传到云端
              this.saveToYun(http.RequestMethod.PUT, "history-image", arr)
              //下面是上传至数据库
              await new Promise<void>((resolve) => {
                const checkFilePathUpdate = () => {
                  if (this.imageURL) {
                    resolve(); // 等待图片路径更新完成后，继续执行
                  } else {
                    setTimeout(checkFilePathUpdate, 100); // 每隔100毫秒检查一次
                  }
                };
                checkFilePathUpdate();
              });
              console.log('数据库图片url',this.imageURL);
              this.addRecordToDatabase(description, this.imageURL, device, deviceCode);
              ree = "";
              //result 是最终获取到的数据
            } else if (this.isGetData == false) {
              //console.log("检测还未完成，请稍等")
              promptAction.showToast({
                message: '检测还未完成，请稍等'//弹窗内容
              });
            } else if (this.isGetData == true && this.Detect == false) {
              //console.log("检测还未完成，请稍等")
              promptAction.showToast({
                message: '检测已完成'//弹窗内容
              });
            }
          } else {
            promptAction.showToast({
              message: '请上传图片'//弹窗内容
            });
          }
        })
          .backgroundColor('#ffd6091b')

        Text('历史记录')
          .onClick(async () => {
            try {
              router.pushUrl({ url: 'pages/HistoryPageTablet' }); // 跳转到新页面
            } catch (error) {
              console.error('Error fetching history data:', error);
            }
          })
          .margin({ top: "100%", left: '25%' })
          .width("33%")
          .fontSize(15)
          .fontColor(Color.Gray)
          .decoration({ type: TextDecorationType.Underline, color: Color.Gray });
      }
      .height('100%')
      .width('20%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({ top: "26%" })
    }.width('100%')


  }
}