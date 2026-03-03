import { preferences } from '@kit.ArkData';
import { UIAbility } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';

export { MyTitleBar } from '../components/MyTitleBar';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @State toggle: boolean = false;
  @State count: number = 0;

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

          router.pushUrl({url: 'pages/second', params:'1'}).then(()=>{
            console.info(`Succeeded in jumping to the second page.`)
          }).catch((err: BusinessError)=>{
            console.error(`Failed to jump to the second page. Code is ${err.code}, message is ${err.message}`)
          })
        })
        Text(`${this.count}`)
        Button(){
          Text('+')
            .fontColor('#FFF').fontSize(15)
        }
        .type(ButtonType.Circle)
        .onClick(()=>{
          this.count++;
        })
        .backgroundColor('#ff466746')
        .height(20)
        .width(20)
      }
      Button(){
        Text('Save')
      }
      .type(ButtonType.ROUNDED_RECTANGLE)
      .onClick(()=>{
        let isGskvSupported = preferences.isStorageTypeSupported(preferences.StorageType.GSKV);
        console.info("Is gskv supported on this platform: " + isGskvSupported);
      })
      .width('100%')
    }
    .height('100%')
  }
}


