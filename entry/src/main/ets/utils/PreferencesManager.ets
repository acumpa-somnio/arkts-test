import { UIAbility } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { APP_PREFERENCES_NAME } from '../common/constant/CommonConstants'

export class PreferencesManager {
  private static instance: PreferencesManager | null = null;
  private _preferences: preferences.Preferences | null = null;

  private static readonly defaultPreferences: Map<string, string | number | boolean> = new Map([
    ['', ''] as [string, string | number | boolean],
    ['', ''] as [string, string | number | boolean],
    ['', ''] as [string, string | number | boolean],
  ]) as Map<string, string | number | boolean>;

  private constructor() {
  }

  public static getInstance(): PreferencesManager {
    if (!PreferencesManager.instance) {
      PreferencesManager.instance = new PreferencesManager();
    }
    return PreferencesManager.instance;
  }

  public async initPreferences(uiAbility: UIAbility): Promise<void> {
    try {
      const options: preferences.Options = {
        name: APP_PREFERENCES_NAME,
      };
      this._preferences = await preferences.getPreferences(uiAbility.context, options);
      await this.applyDefaultPreferences();
    } catch (error) {
      console.error('Error initializing prefs: ', error);
    }
  }

  private async applyDefaultPreferences(): Promise<void> {
    if (!this._preferences) {
      throw new Error('Preferences not initialized');
    }
    let needsFlush = false;
    for (const entry of PreferencesManager.defaultPreferences) {
      try {
        const key = entry[0];
        const defaultValue = entry[1];

        const hasKey = await this._preferences.has(key);
        if (!hasKey) {
          await this._preferences.put(key, defaultValue);
          needsFlush = true;
        }
      } catch (error) {
        console.error(`Error applying default for ${entry[0]}: `, error);
      }
    }

    if (needsFlush) {
      await this._preferences.flush();
    }
  }

  public async savePreference(key: string, value: string | number | boolean): Promise<void> {
    if (!this._preferences) {
      throw new Error('Preferences not initialized');
    }
    await this._preferences.put(key, value);
    await this._preferences.flush();
  }

  public async getPreference<T extends string | number | boolean>(key: string,
    defaultValue?: T): Promise<T> {
    if (!this._preferences) {
      throw new Error('Preferences not initialized');
    }
    return (await this._preferences.get(key, defaultValue as T)) as T;
  }

  public async hasPreference(key: string): Promise<boolean> {
    if (!this._preferences) {
      throw new Error('Preferences not initialized');
    }
    return await this._preferences.has(key);
  }
}