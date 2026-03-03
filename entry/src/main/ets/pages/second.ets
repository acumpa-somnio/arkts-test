@Entry
@Component
struct second {
  @State message: string = 'Second page';

  build(){
    Row(){
      Column() {
        Text(this.message)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Button() {
          Text('Back')
            .fontSize(10)
            .fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .margin({
          top: 20
        })
        .backgroundColor('#0D9FFB')
        .width('40%')
        .height('5%')
        .onClick(()=>{
          let uiContext: UIContext = this.getUIContext();
          let router = uiContext.getRouter();

          try {
            router.back();
          } catch (err){
            console.error(`Failed to return to the first page. Code is ${err.code}, message is ${err.message}`)
          }

        })
      }
      .width('100%')
    }
    .height('100%')
  }
}