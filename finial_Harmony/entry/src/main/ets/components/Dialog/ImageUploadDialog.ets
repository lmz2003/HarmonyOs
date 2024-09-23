import picker from '@ohos.file.picker';
import { checkPermissions, applyPermission, copyFileToCache, getToken } from '../../utils/index'
import { request } from '@kit.BasicServicesKit';
import { Permissions } from '@ohos.abilityAccessCtrl';
import camera from '@ohos.multimedia.camera';
import camerapicker from '@ohos.multimedia.cameraPicker';
import { BusinessError } from '@ohos.base';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import {Data} from '../../pages/LoginPageTablet';
@Extend(Text)
function custText() {
  .width('100%')
  .height('48')
  .fontColor('#39364D')
  .textAlign(TextAlign.Center)
}
@Component
@CustomDialog
export default struct ImageUploadDialog {
  @Link data: object
  @Link imageHide: Visibility
  @Link imageCh: string
  @Link isshowOriginalImage: boolean
  @Link isGetpath: boolean
  @Link xy_data : Data[]
  @Link dialogController_loading: CustomDialogController | null
  @Link CanIGetImage : boolean
  dialogController: CustomDialogController
  uploadURL: string =
    'https://infer-modelarts-cn-southwest-2.myhuaweicloud.com/v1/infers/6a69325f-bced-430b-8369-1e2468fbd6a2'; //上传接口地址
 context = getContext(this) as common.UIAbilityContext; //UIAbilityContext

  //检查权限
  async checkAppPermission(): Promise<boolean> {
    try {
      const READ_MEDIA_PERMISSION: Permissions = 'ohos.permission.READ_MEDIA' //媒体读取权限
      const WRITE_MEDIA_PERMISSION: Permissions = 'ohos.permission.WRITE_MEDIA' //媒体写入权限
      const WRITE_IMAGEVIDEO_PERMISSION:Permissions = 'ohos.permission.WRITE_IMAGEVIDEO' //图库写入权限
      let permissionList: Permissions[] = []; //需要申请选项列表
      let readPermission = await checkPermissions(READ_MEDIA_PERMISSION) //检查是否有媒体读取权限
      !readPermission && permissionList.push(READ_MEDIA_PERMISSION)
      let writePermission = await checkPermissions(WRITE_MEDIA_PERMISSION) //检查是否有媒体写入权限
      !writePermission && permissionList.push(WRITE_MEDIA_PERMISSION)
      let Permission = await checkPermissions(WRITE_IMAGEVIDEO_PERMISSION) //检查是否有图库写入权限
      !Permission && permissionList.push(WRITE_IMAGEVIDEO_PERMISSION)
      if (permissionList.length) {
        //申请权限
        let res: boolean = await applyPermission(this.context, permissionList)
        if (!res) { //用户未同意授权
          AlertDialog.show({
            title: "提示",
            message: "无权限读写用户外部存储中的媒体文件信息，请前往系统设置开启",
            alignment: DialogAlignment.Center,
            secondaryButton: {
              value: '关闭',
              action: () => {
              }
            }
          })
        }
        return res
      }
      return true
    } catch (e) {
      return Promise.reject(e)
    }
  }



  build() {
    Column() {
      //拍照
      Text('拍照').custText().onClick(async () => {
        //检查是否有读写外部媒体权限
        let res: boolean = await this.checkAppPermission()
        //无权限返回
        if (!res) {
          return
        }
        try {
          let pickerProfile: camerapicker.PickerProfile = {
            cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
          };
          let pickerResult: camerapicker.PickerResult = await camerapicker.pick(this.context,
            [camerapicker.PickerMediaType.PHOTO, camerapicker.PickerMediaType.PHOTO], pickerProfile);
          if (pickerResult?.resultUri) {
            //关闭弹窗
            this.dialogController.close()
            //复制图片到缓存目录（缓存目录才有读写权限）
            let filePath = await copyFileToCache(pickerResult.resultUri, this.context)
            if (filePath) {
              this.xy_data = [];
              this.isshowOriginalImage = true;
              this.isGetpath = true;
            }
          }
        } catch (error) {
          let err = error as BusinessError;
          console.error(`the pick call failed. error code: ${err.code}`);
        }

      })
      Divider().color('#F7F9FA').width('100%').strokeWidth(1)
      //从手机相册选择
      Text('从手机相册选择').custText().onClick(async () => {
        //检查是否有读写外部媒体权限
        let res: boolean = await this.checkAppPermission()
        //无权限返回
        if (!res) {
          return
        }
        //关闭弹窗
        this.dialogController.close()
        //从相册选择
        let PhotoSelectOptions = new picker.PhotoSelectOptions();
        PhotoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
        PhotoSelectOptions.maxSelectNumber = 1;
        let photoPicker = new picker.PhotoViewPicker();
        photoPicker.select(PhotoSelectOptions).then(async (PhotoSelectResult) => {
          if (PhotoSelectResult.photoUris.length) {
            // 传递信息
            this.imageCh = PhotoSelectResult.photoUris[0];
            console.log(this.imageCh, "这是路径")
            this.imageHide = Visibility.Visible;
            //直接传入当前图片
            console.log('Context:', JSON.stringify(this.context));
            let filePath = await copyFileToCache(this.imageCh, this.context)
            console.log(filePath, "这是filepath")
            if (filePath) {
              this.isshowOriginalImage = true;
              this.isGetpath = true;
              this.xy_data = [];
            }
          }
        })

      })

      Button('取消', { type: ButtonType.Capsule })
        .backgroundColor('#F7F7F7')
        .fontSize('16fp')
        .fontColor('#333333')
        .width('100%')
        .margin({ top: '30' })
        .onClick(() => {
          this.dialogController.close()
        })
    }
    .width('100%')
    .padding({
      left: '16',
      top: '11',
      right: '16',
      bottom: '16'
    })
    .backgroundColor(Color.White)
    .borderRadius({
      topLeft: '24',
      topRight: '24'
    })
  }
}

function fileContent(path: string) {
  throw new Error('Function not implemented.');
}
