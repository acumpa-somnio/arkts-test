
@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @State toggle: boolean = false;

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Button() {
          Text('Next')
            .fontSize(10)
            .fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .margin({
          top: 5
        })
        .backgroundColor('#0D9FFB')
        .width('40%')
        .height('5%')
        .onClick(()=>{
          console.info(`Succeeded in clicking the 'Next' button.`);
          let uiContext: UIContext = this.getUIContext()
          let router  = uiContext.getRouter()

          router.pushUrl({url: 'pages/second'}).then(()=>{
            console.info(`Succeeded in jumping to the second page.`)
          }).catch((err: BusinessError)=>{
            console.error(`Failed to jump to the second page. Code is ${err.code}, message is ${err.message}`)
          })
        })
      }
      .width('100%')
    }
    .height('100%')
  }
}