import httpGet from '../common/utils/HttpUtil';
import CommonConstant from '../common/constant/CommonConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { JSON } from '@kit.ArkTS';
import { Spell } from '../models/spell';
import { router } from '@kit.ArkUI';

const webSrc: ResourceStr = CommonConstant.SERVER;
const DOMAIN = 0x0000;
const TAG = 'WebPage';
const FORMAT = '%{public}s';

@Entry
@Component
struct spells  {

  @State spells:Array<Spell> = [];

  async aboutToAppear(){
    await this.onRequest();
  }



  build() {
    List(){
      ForEach(this.spells, (item: Spell)=>{
        ListItem(){
          Row(){
            if(item.incantation!=null){
              Text( `${item.incantation} - `).fontSize(10)
            }
            Text(item.name).fontSize(10)
          }.padding({
            bottom:5,
            top:5,
            left:25,
          }
          )
        }.onClick(()=>{
          this.getUIContext().getRouter().pushUrl({
            url: 'pages/spellDetail' ,
            params: {id: item.id }
          }).catch((error:Error) => {
            console.log(Error.toString());
          });
        })
      })
    }
    .width('100%')
    .alignListItem(ListItemAlign.Start)

  }


  async onRequest() {
    try {

      let result = await httpGet(this.getResourceString(webSrc as Resource));
      let resultString : string = result?.result.toString()??'{}';

        let jsonObject = JSON.parse(resultString);
        this.spells = [];
        try{
          (jsonObject as Array<Object>).forEach(element => {
            try{
              let spell:Spell = Spell.fromJson(element);
              console.log(spell.toString());
              this.spells.push(spell);
            }catch(er){}

          });
        }  catch(_){}

    } catch (error) {
      try {
        this.getUIContext().getPromptAction().showToast({ message: $r('app.string.http_response_error') })
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'WebPage', `showToast failed, error code=${err.code}, message=${err.message}`);
      }
    }
  }

  getResourceString(resource: Resource): string {
    let resourceString: string = '';
    try {
      resourceString = this.getUIContext().getHostContext()!.resourceManager.getStringSync(resource.id);
    } catch (err) {
      hilog.error(DOMAIN, TAG, FORMAT, `Failed to getResourceString. Cause code: ${err.code},message: ${err.message}`);
    }
    return resourceString;
  }

}