import { vibrator } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { resourceManager } from '@kit.LocalizationKit';

/**
 * Enum for predefined vibration types
 */
enum VibrationPreset {
  SOFT = 'haptic.effect.soft',
  MEDIUM = 'haptic.effect.medium',
  HARD = 'haptic.effect.hard',
  BUTTON_PRESS = 'haptic.clock.timer',
  NOTIFICATION = 'haptic.clock.alarm'
}

/**
 * Enum for comprehensive vibration usage contexts
 * Provides type safety and prevents arbitrary string inputs
 */
export enum VibrationUsage {
  UNKNOWN = 'unknown',
  ALARM = 'alarm',
  RING = 'ring',
  NOTIFICATION = 'notification',
  COMMUNICATION = 'communication',
  TOUCH = 'touch',
  MEDIA = 'media',
  PHYSICAL_FEEDBACK = 'physicalFeedback',
  SIMULATE_REALITY = 'simulateReality'
}
/**
 * Interface for vibration options
 */
interface VibrationOptions {
  count?: number;
  intensity?: number;
}

/**
 * Configuration interface for custom vibration patterns
 */
interface CustomVibrationConfig {
  fileName: string;
  usage?: VibrationUsage;
}

class VibrationManager {
  /**
   * Check if a specific vibration effect is supported
   * @param effectId - The preset effect to check
   * @returns Promise resolving to boolean indicating support
   */
  static async isSupportedEffect(effectId: string): Promise<boolean> {
    return new Promise((resolve, reject) => {
      try {
        vibrator.isSupportEffect(effectId, (err: BusinessError, state: boolean) => {
          if (err) {
            reject(err);
          } else {
            resolve(state);
          }
        });
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * Trigger a preset vibration effect
   * @param effect - Preset vibration effect
   * @param usage - Context of vibration
   * @param options - Additional vibration options
   */
  static async triggerPresetVibration(
    effect: VibrationPreset,
    usage: VibrationUsage = VibrationUsage.UNKNOWN,
    options: VibrationOptions = {}
  ): Promise<void> {
    return new Promise((resolve, reject) => {
      const checkAndTriggerVibration = async () => {
        try {
          // Verify effect support first
          const isSupported = await VibrationManager.isSupportedEffect(effect);

          if (!isSupported) {
            reject(new Error(`Vibration effect ${effect} not supported`));
            return;
          }

          vibrator.startVibration({
            type: 'preset',
            effectId: effect,
            count: options.count ?? 1,
            intensity: options.intensity ?? 50
          }, {
            usage: usage
          }, (error: BusinessError) => {
            if (error) {
              reject(error);
            } else {
              resolve();
            }
          });
        } catch (err) {
          reject(err);
        }
      };

      checkAndTriggerVibration();
    });
  }

  /**
   * Trigger a time-based vibration
   * @param duration - Vibration duration in milliseconds
   * @param usage - Context of vibration
   */
  static async triggerTimedVibration(
    duration: number,
    usage: VibrationUsage = VibrationUsage.UNKNOWN
  ): Promise<void> {
    return new Promise((resolve, reject) => {
      try {
        vibrator.startVibration({
          type: 'time',
          duration: duration
        }, {
          usage: usage
        }, (error: BusinessError) => {
          if (error) {
            reject(error);
          } else {
            resolve();
          }
        });
      } catch (err) {
        reject(err);
      }
    });
  }

  /**
   * Trigger a custom vibration from a configuration file
   * @param config - Custom vibration configuration
   */
  static async triggerCustomVibration(
    config: CustomVibrationConfig
  ): Promise<void> {
    return new Promise((resolve, reject) => {
      try {
        // Get file descriptor for the custom vibration config
        let rawFd: resourceManager.RawFileDescriptor =
          getContext().resourceManager.getRawFdSync(config.fileName);

        vibrator.startVibration({
          type: "file",
          hapticFd: {
            fd: rawFd.fd,
            offset: rawFd.offset,
            length: rawFd.length
          }
        }, {
          usage: config.usage ?? VibrationUsage.UNKNOWN
        }, (error: BusinessError) => {
          // Close file descriptor
          getContext().resourceManager.closeRawFdSync(config.fileName);

          if (error) {
            reject(error);
          } else {
            resolve();
          }
        });
      } catch (err) {
        reject(err);
      }
    });
  }

  /**
   * Stop all ongoing vibrations
   */
  static async stopVibration(): Promise<void> {
    return new Promise((resolve, reject) => {
      try {
        vibrator.stopVibration((error: BusinessError) => {
          if (error) {
            reject(error);
          } else {
            resolve();
          }
        });
      } catch (err) {
        reject(err);
      }
    });
  }
}

export {
  VibrationManager,
  VibrationPreset
};