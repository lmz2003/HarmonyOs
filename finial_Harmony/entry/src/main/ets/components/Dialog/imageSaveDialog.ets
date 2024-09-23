import { common } from '@kit.AbilityKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';

@Extend(Text)
function custText() {
  .width('100%')
  .height('48')
  .fontColor('#39364D')
  .textAlign(TextAlign.Center)
}
@CustomDialog
export default struct ImageSaveDialog{
  @Link isSave:boolean
  @State description:string = ''
  private pixelMap: PixelMap|null = null
  dialogController: CustomDialogController
  dialogDescriptionController:CustomDialogController|null = null
  // 打包ArrayBuffer
  async getArrayBuffer(pixelMap:PixelMap): Promise<ArrayBuffer>{
    //创建打包设置
    const imagePackerApi: image.ImagePacker = image.createImagePacker();
    let packOpts: image.PackingOption = { format: "image/png", quality: 98 };
    return await imagePackerApi.packing(pixelMap, packOpts)
  }
  // 保存图片
  async saveImage(buffer: ArrayBuffer | string): Promise<boolean> {
    try{
      let context = getContext(this) as common.UIAbilityContext;
      let helper = photoAccessHelper.getPhotoAccessHelper(context);
      let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png');
      console.log("获得uri"+uri)
      let file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      await fs.write(file.fd, buffer);
      await fs.close(file.fd);
      return true;
    }catch (e){
      console.log('发生错误'+e);
      return false;
    }
  }
  build() {
    Column(){
      Text('保存图片到图库').custText().onClick(async ()=>{
        if(this.pixelMap){
          let buff:ArrayBuffer = await this.getArrayBuffer(this.pixelMap);
          console.log("获得缓冲区"+buff.byteLength);
          this.isSave = await this.saveImage(buff);
          console.log("存入"+this.isSave);
        }
        if(this.isSave){
          promptAction.showToast({
            message: '保存图片成功'//弹窗内容
          });
          this.isSave = false;
        }
        this.dialogController.close()
      })
      Divider().color('#F7F9FA').width('100%').strokeWidth(4)
      Text('取消').custText().onClick(()=>{
        this.dialogController.close()
      })
    }.backgroundColor(Color.White).border({radius:'20vp'}).width('85%')
  }
}