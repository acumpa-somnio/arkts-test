import httpGet from '../common/utils/HttpUtil';
import CommonConstant from '../common/constant/CommonConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Spell } from '../models/spell';
import { HashMap, JSON } from '@kit.ArkTS';

const webSrc: ResourceStr = CommonConstant.SERVER;
const DOMAIN = 0x0000;
const TAG = 'WebPage';
const FORMAT = '%{public}s';

@Entry
@Component
struct spellDetail {
  @State params: Map<string,string> = this.getUIContext().getRouter().getParams() as Map<string,string>
  @State spell: Spell|null = Spell.empty();



  build(){

    Column(){
      Text(
        this.spell?.name
      )
      Text(
        this.spell?.incantation
      )
      Text(
        this.spell?.effect
      )
      Text(
        this.spell?.type
      )
      Text(
        this.spell?.light
      )
      Text(
        this.spell?.creator
      )

    }

  }

  async aboutToAppear(){
    await this.onRequest();
  }


  async onRequest() {
    try {
      let result = await httpGet(`${this.getResourceString(webSrc as Resource)}/${this.params["id"]}`);
      let resultString : string = result?.result.toString()??'{}';
      let jsonObject = JSON.parse(resultString);
      try{
          let newSpell:Spell|null = Spell.fromJson(jsonObject!);
          this.spell = newSpell;
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