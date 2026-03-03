import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { util } from '@kit.ArkTS';

let dataPreferences: preferences.Preferences | null = null;

class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    let options: preferences.Options = { name: 'myStorage' , storageType: preferences.StorageType.GSKV };
    dataPreferences = preferences.getPreferencesSync(this.context, options);
  }

  setValue(key: string, value: object){
    if(dataPreferences?.hasSync(key)){
      console.info(`The key '${key}' is contained.`);
    } else {
      console.info(`The key '${key}' is not contained.`)
    }
    dataPreferences?.putSync(key, value);
  }

  deleteValue(key: string){
   dataPreferences?.deleteSync(key);
  }

}

