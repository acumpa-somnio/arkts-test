@Component
export struct MyTitleBar{

  build(){
    Row(){
      Text($r('app.string.title_label'))
        .id('library')
        .fontFamily('HarmoneyHeiTi')
        .fontWeight(FontWeight.Bold)
        .fontSize(32)
        .fontColor($r('app.color.start_window_background'))
    }
  }
}