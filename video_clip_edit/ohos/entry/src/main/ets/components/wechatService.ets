import { promptAction } from '@kit.ArkUI'
import { FileUtils } from '../utils'

@Component
export struct wechatService {
  @StorageProp("safeBottom") safeBottom: number = 0
  qrCodeString: string =
    "https://work.weixin.qq.com/ca/cawcde8fa16c09a99f?refkey=AQEAkRWZwhM2WXPCHfEOj-9RrBPW4AlNH9620gzvV83dY9PkkrdvhbjjIOrx9pzMyBrP"
  imageId: string = "bindSheetServiceImage"

  async saveImage(result: SaveButtonOnClickResult) {
    let isSave: boolean = false
    if (result === SaveButtonOnClickResult.SUCCESS) {
      //点击按钮后，授权成功直接保存到相册
      isSave = await FileUtils.screenshot(this.imageId, getContext(this))
    } else {
      //授权失败，走弹窗授权逻辑
      const filePath = await FileUtils.getFilePath(this.imageId, getContext(this))
      isSave = await FileUtils.saveToAlbum(filePath, 'image')
    }

    if (isSave) {
      promptAction.showToast({ message: '保存成功' })
    }
  }

  build() {
    Column() {
      Column({ space: 20 }) {
        Image($r('app.media.ic_launcher'))
          .width(60)
          .aspectRatio(1)
          .borderRadius(5)

        Text('添加我的企业微信与我联系吧')
          .width('100%')
          .textAlign(TextAlign.Center)

        Column({ space: 15 }) {

          Text('请用微信手机端扫码加好友')
            .width('100%')
            .textAlign(TextAlign.Center)
          Stack() {
            QRCode(this.qrCodeString)
              .width('100%')
              .backgroundColor('#ffececec')
          }
          .width('100%')
          .aspectRatio(1)
          .padding(15)

        }
        .width('100%')
        .backgroundColor('#ffececec')
        .borderRadius(15)
        .padding({
          left: 30,
          right: 30,
          top: 30,
          bottom: 40
        })
      }
      .padding(18)
      .height(460)
      .backgroundColor(Color.White)
      .id(this.imageId)

      Stack() {
        SaveButton({
          text: SaveDescription.SAVE_IMAGE,
          icon: SaveIconStyle.FULL_FILLED
        })
          .onClick((_event, result) => {
            this.saveImage(result)
          })
      }
      .margin({ bottom: this.safeBottom == 0 ? 30 : this.safeBottom })

    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 35, right: 35 })
  }
}