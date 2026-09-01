import { webview } from '@kit.ArkWeb';

@Entry
@Component
export struct WebPage {
  @State currentTitle: string = ""
  @State progressValue: number = 0;
  @State showLoading: boolean = false
  controller: webview.WebviewController = new webview.WebviewController()
  url: string = ''

  aboutToAppear(): void {
    const params = this.getUIContext().getRouter().getParams() as object
    this.url = params['url'] as string
  }

  build() {
    Column() {
      RelativeContainer() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .height('100%')
          .aspectRatio(1)
          .onClick(() => {
            this.getUIContext().getRouter().back()
          })

        Text(this.currentTitle)
          .fontSize(16)
          .height('100%')
          .fontWeight(FontWeight.Medium)
          .alignRules({
            center: { anchor: "__container__", align: VerticalAlign.Center },
            middle: { anchor: "__container__", align: HorizontalAlign.Center }
          })

      }
      .height(40)
      .width('100%')
      .padding({
        left: 10,
        right: 10,
        top: 5,
        bottom: 5
      })

      // 加载进度
      if (this.showLoading) {
        Progress({
          type: ProgressType.Linear,
          value: this.progressValue
        })
          .style({
            strokeWidth: 2
          })
          .color(Color.Red)
          .width("100%")
      }

      Web({
        src: this.url,
        controller: this.controller
      })
        .onTitleReceive((event) => {
          this.currentTitle = event.title
        })
        .onProgressChange((event) => {
          this.progressValue = event.newProgress
          if (this.progressValue === 100) {
            this.showLoading = false
            this.progressValue = 0;
          }
        })
        .onPageBegin(() => {
          this.showLoading = true
        })
        .onPageEnd(() => {
          this.controller.runJavaScript("changeColor()")
        })
        .layoutWeight(1)
    }

  }
}



