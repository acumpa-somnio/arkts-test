import { BusinessError } from '@kit.BasicServicesKit';


/**
 * Utility class for string-related operations
 */
export class StringUtils {
  /**
   * Gets a string value from a resource
   * @param res Resource reference
   * @returns Promise that resolves to the string value
   */
  static getStringFromResource(context: Context, res: Resource): string {
    try {
      let systemResourceManager = context.resourceManager;
      return systemResourceManager.getStringSync(res.id);
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to load string resource: ${businessError.code}, message: ${businessError.message}`);
      return '';
    }
  }
}