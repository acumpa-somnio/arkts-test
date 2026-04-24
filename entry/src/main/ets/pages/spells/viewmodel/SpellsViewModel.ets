import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import httpGet from '../../../common/utils/HttpUtil'
import CommonConstant, { DOMAIN_NUMBER } from '../../../common/constant/CommonConstants';
import { JSON } from '@kit.ArkTS';
import { Spell } from '../../../models/spell';
import { StringUtils } from '../../../utils/StringUtils';
import { hilog } from '@kit.PerformanceAnalysisKit';

import { notificationManager } from '@kit.NotificationKit';
import { wantAgent, WantAgent } from '@kit.AbilityKit';
import { DateUtils } from '../../../utils/DateUtils';

import { pushService } from '@kit.PushKit';


const DOMAIN = 0x0000;
const TAG = 'WebPage';
const FORMAT = '%{public}s';


export class SpellsViewModel {
  async fetchSpells(context: Context): Promise<Array<Spell>> {

    let spells: Array<Spell> = [];
    try {

      let result = await httpGet(StringUtils.getStringFromResource(context, CommonConstant.SERVER));
      let resultString: string = result?.result.toString() ?? '{}';

      let jsonObject = JSON.parse(resultString);

      try {
        (jsonObject as Array<Object>).forEach(element => {
          try {
            let spell: Spell = Spell.fromJson(element);
            console.log(spell.toString());
            spells.push(spell);
          } catch (er) {
          }

        });
      } catch (_) {
      }

    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'WebPage', `showToast failed, error code=${err.code}, message=${err.message}`);
    }

    return spells;
  }

  static async triggerSimpleNotification(): Promise<void> {
    let notificationRequest: notificationManager.NotificationRequest = {
      id: 1,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT, // Basic notification
        normal: {
          title: '¡GOOOOOOL!',
          //text: '¡Gol de Uruguay!\nMaxi Araújo\n🇺🇾 1 - 0 🇳🇬',
          text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore',
        }
      }
    };
    notificationManager.publish(notificationRequest, (err: BusinessError) => {
      if (err) {
        hilog.error(DOMAIN_NUMBER, TAG,
          `Failed to publish notification. Code is ${err.code}, message is ${err.message}`);
        return;
      }
      hilog.info(DOMAIN_NUMBER, TAG, 'Succeeded in publishing notification.');
    });
  }


  static async triggerNotificationWithAgent(): Promise<void> {
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          deviceId: '',
          bundleName: 'com.somniosoftware.wearabletest',
          abilityName: 'EntryAbility',
          action: '',
          entities: [],
          uri: '',
          parameters: {}
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.CONSTANT_FLAG]
    };

    wantAgent.getWantAgent(wantAgentInfo, (err: BusinessError, data: WantAgent) => {
      if (err) {
        hilog.error(DOMAIN_NUMBER, TAG, `Failed to get want agent. Code is ${err.code}, message is ${err.message}`);
        return;
      }
      hilog.info(DOMAIN_NUMBER, TAG, 'Succeeded in getting want agent.');

      let actionButton: notificationManager.NotificationActionButton = {
        title: 'OK',
        wantAgent: data
      }

      let notificationRequest: notificationManager.NotificationRequest = {
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: 'SmartWord',
            text: 'Your 5 words for today are ready!',
          },
        },
        id: 6,
        wantAgent: data,
        actionButtons: [actionButton],
      }

      notificationManager.publish(notificationRequest, (err: BusinessError) => {
        if (err) {
          hilog.error(DOMAIN_NUMBER, TAG,
            `Failed to publish notification. Code is ${err.code}, message is ${err.message}`);
          return;
        }
        hilog.info(DOMAIN_NUMBER, TAG, 'Succeeded in publishing notification.');
      });
    });
  }

  reminderStatus: string = 'Ready';
  reminderTitle: string = '';
  reminderContent: string = '';
  reminderTime: string = '';
  notificationId: number = 1000;
  reminderId: number = -1;

  private createReminder() {

    const cutoffDate = new Date('2026-03-05T12:00:00-05:00');
    let timeInSenconds = DateUtils.timeDifferenceInSeconds(cutoffDate);

    if (isNaN(timeInSenconds) || timeInSenconds <= 0) {
      hilog.info(DOMAIN_NUMBER, TAG, 'Invalid time input');
      this.reminderStatus = 'Please enter a valid time in seconds.';
      return;
    }

    if (!this.reminderTitle || !this.reminderContent) {
      hilog.info(DOMAIN_NUMBER, TAG, 'Title or content missing');
      this.reminderStatus = 'Please fill in both title and content.';
      return;
    }

    let timerReminder: reminderAgentManager.ReminderRequestTimer = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_TIMER,
      triggerTimeInSeconds: timeInSenconds,
      title: this.reminderTitle,
      content: this.reminderContent,
      notificationId: ++this.notificationId
    };

    hilog.info(DOMAIN_NUMBER, TAG, `Publishing reminder with ID: ${this.notificationId}`);

    reminderAgentManager.publishReminder(timerReminder).then((id: number) => {
      hilog.info(DOMAIN_NUMBER, TAG, `Reminder published successfully with request ID: ${id}`);
      this.reminderId = id;
      this.reminderStatus = `Reminder set.`;
      this.reminderTitle = '';
      this.reminderContent = '';
      this.reminderTime = '';
    }).catch((err: BusinessError) => {
      hilog.info(DOMAIN_NUMBER, TAG, `Failed to publish reminder: ${err.code}, ${err.message}`);
      this.reminderStatus = `Error: ${err.code}, ${err.message}`;
    });
  }

  static async setPushToken() {

    try {
      await pushService.getToken().then((pushToken) => {
        hilog.info(DOMAIN_NUMBER, TAG, pushToken);
      });
    } catch (e) {
      hilog.error(DOMAIN_NUMBER, TAG, e);
    }
  }
}