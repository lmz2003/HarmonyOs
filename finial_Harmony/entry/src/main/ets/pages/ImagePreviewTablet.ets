import { router } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { display } from '@kit.ArkUI';
import ImageSaveDialog from '../components/Dialog/imageSaveDialog';


export class imageHelper {
  arr: number[]
  size: image.Size

  constructor(arr: number[], size: image.Size) {
    this.arr = arr;
    this.size = size;
  }
}

@Entry
@Component
struct ImagePreview {
  @State image: PixelMap | null = null
  @State sca: number = 1
  @State angle: string = '0deg'
  @State tranX: number = 0
  @State tranY: number = 0
  @State count: number = 0
  @State isSave: boolean = false
  private isTouchTwice: boolean = false
  private ScaleNum: number = 80
  private screenWid: number = 0
  private screenHei: number = 0
  private bottommargin: number = 0
  private X: number = 568.88888832
  private Y: number = 104.44444444444444
  dialogController: CustomDialogController | null = null

  aboutToAppear(): void {
    let dis: display.Display = display.getDefaultDisplaySync();
    this.screenWid = dis.width * 0.444444444
    this.screenHei = dis.height * 0.444444444
    console.log("屏幕宽度" + this.screenWid)
    console.log("屏幕高度" + this.screenHei)

    let temp = router.getParams() as imageHelper;
    this.bottommargin = (this.screenHei - temp.size.height * 0.444444444) / 2
    console.log("字节长度：(预览页面)" + temp.arr.length.toString());
    console.log("高度：" + temp.size.height + "宽度：" + temp.size.width);
    let a: image.InitializationOptions =
      { "size": temp.size, "srcPixelFormat": image.PixelMapFormat.RGBA_8888, editable: true };
    image.createPixelMap(new Uint8Array(temp.arr).buffer, a).then((pixelMap: image.PixelMap) => {
      console.info('Succeeded in creating pixelmap.');
      //pixelMap.rotateSync(90);
      // 显示图片，并且创建弹窗
      this.image = pixelMap;
      // console.log(this.image.getPixelBytesNumber().toString());
    }).catch((error: BusinessError) => {
      console.error(`Failed to create pixelmap. code is ${error.code}, message is ${error.message}`);
    })

  }

  build() {
    Column() {
      Row({ space: 5 }) {
        Image($r("app.media.return")).onClick(() => {
          router.back()
        }).height('40vp').width('40vp')
        Image($r('app.media.rotateleft')).onClick(() => {
          if (this.angle === '0deg') {
            this.angle = '270deg';
          } else if (this.angle === '90deg') {
            this.angle = '0deg';
          } else if (this.angle === '180deg') {
            this.angle = '90deg';
          } else if (this.angle === '270deg') {
            this.angle = '180deg';
          }
        }).height('40vp').width('40vp')
        Image($r("app.media.rotateright")).onClick(() => {
          if (this.angle === '0deg') {
            this.angle = '90deg';
          } else if (this.angle === '90deg') {
            this.angle = '180deg';
          } else if (this.angle === '180deg') {
            this.angle = '270deg';
          } else if (this.angle === '270deg') {
            this.angle = '0deg';
          }
        }).height('40vp').width('40vp')
      }.height('10%').width('100%')

      Image(this.image)
        .objectFit(ImageFit.Contain)
        .margin({ bottom: this.bottommargin })
        .gesture(
          TapGesture({ "count": 2 })
            .onAction((event: GestureEvent) => {
              if (event) {
                console.log("被双击")
                if (this.isTouchTwice) {
                  this.sca = 1;
                  //this.image?.scaleSync(0.45,0.45);
                  this.tranX = 0
                  this.tranY = 0
                } else {
                  this.sca = 2.5;
                  //this.image?.scaleSync(1/0.45,1/0.45);
                  console.log('记录点击的地方')
                  console.log("x:" + event.fingerList[0].globalX.toString() + "y:"
                    + event.fingerList[0].globalY.toString());
                  this.tranX = this.screenWid/2 - ((event.fingerList[0].globalX -this.X) * this.sca + this.X) ;
                  this.tranY = this.screenHei/2 - ((event.fingerList[0].globalY -this.Y) * this.sca + this.Y);

                }
                this.isTouchTwice = !this.isTouchTwice;
              }
            })
        )
        .rotate({
          angle: this.angle
        })
        .translate({ x: this.tranX, y: this.tranY })
        .width('auto')
        .height(`${this.sca * this.ScaleNum}%`)
        .gesture(
          //长按
          LongPressGesture()
            .onAction((event: GestureEvent) => {
              if (event) {
                this.count++;
                console.log(this.count.toString())
              }
              this.dialogController = new CustomDialogController({
                builder: ImageSaveDialog({
                  isSave: this.isSave,
                  pixelMap: this.image
                }),
                alignment: DialogAlignment.Bottom, //弹窗居于底部
                offset: { dx: '0', dy: '-10vp' },
                customStyle: true, //自定义样式
              })
              this.dialogController?.open() // 开启弹窗
            }
            )
        )
    }.width('100%').height('100%')
  }
}