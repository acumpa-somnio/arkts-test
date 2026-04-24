import { abilityAccessCtrl, bundleManager, Permissions } from '@kit.AbilityKit';
import hilog from '@ohos.hilog';
import { BusinessError } from '@kit.BasicServicesKit';
/**
 * Specific domain for permission logs
 */
const PERMISSION_DOMAIN = 0x0001;

/**
 * Tag for permission-related logs
 */
const TAG = 'PermissionUtils';

/**
 * Enumeration for permission states
 */
export enum PermissionStatus {
  GRANTED = 0,
  DENIED = -1,
  ASKING_USER = 1
}


/**
 * Abstract class that defines the contract for permission utilities
 * Follows the MVVM pattern with Strategy pattern for different implementations
 */
export abstract class PermissionUtils {
  private static instance: PermissionUtils;
  
  /**
   * Gets the singleton instance of PermissionUtils
   * Strategy pattern - returns either real or mock implementation based on environment
   * @returns The appropriate PermissionUtils implementation
   */
  public static getInstance(): PermissionUtils {
    if (!PermissionUtils.instance) {
      // Use mock implementation in preview mode, real implementation otherwise
      if (true) {
        PermissionUtils.instance = new PermissionUtilsMock();
        console.log('Using MOCK permission implementation');
      } else {
        PermissionUtils.instance = new PermissionUtilsImpl();
        console.log('Using REAL permission implementation');
      }
    }
    return PermissionUtils.instance;
  }

  /**
   * Force the use of a specific implementation
   * @param implementation The implementation to use
   */
  public static setImplementation(implementation: PermissionUtils): void {
    PermissionUtils.instance = implementation;
    console.log(`Explicitly setting permission implementation to: ${implementation.constructor.name}`);
  }

  /**
   * Checks if a specific permission has been granted, requesting it if needed
   * @param permission The permission to check
   * @param context Application context
   * @returns Whether the permission is granted
   */
  public abstract checkPermissionGrant(permission: Permissions, context: Context): Promise<boolean>;

  /**
   * Checks if a permission is granted without requesting it
   * @param permission The permission to check
   * @returns Whether the permission is granted
   */
  public abstract isPermissionGranted(permission: Permissions): Promise<boolean>;

  /**
   * Checks multiple permissions and returns a map with the results
   * @param permissions List of permissions to check
   * @param context Application context
   * @returns Map of permissions and their states
   */
  public abstract checkMultiplePermissions(permissions: Permissions[], context: Context): Promise<Map<Permissions, boolean>>;


  /**
   * Utility function to log errors in a consistent way
   * @param functionName The name of the function where the error occurred
   * @param error The error that occurred
   */
  protected logError(functionName: string, error: BusinessError | Error): void {
    const err = error as BusinessError;
    hilog.error(PERMISSION_DOMAIN, TAG, 
      `Error in ${functionName}: Code: ${err.code || 'N/A'}, Message: ${err.message}`);
  }
}

/**
 * Real implementation of PermissionUtils that interacts with the system
 */
class PermissionUtilsImpl extends PermissionUtils {
  /**
   * Checks if a specific permission has been granted by the user.
   * If not granted, requests the permission from the user.
   * 
   * @param permission - The permission to check
   * @param context - The application context
   * @returns A promise that resolves to true if the permission is granted, false otherwise
   */
  public async checkPermissionGrant(permission: Permissions, context: Context): Promise<boolean> {
    console.log(`[REAL] Checking permission: ${permission}`);
    
    const tokenId = await this.getAppTokenId();
    if (tokenId === -1) {
      return false;
    }
    
    console.log(`[REAL] Token ID: ${tokenId}`);
    const hasPermission = await this.checkPermissionWithTokenId(tokenId, permission);
    console.log(`[REAL] Has permission: ${hasPermission}`);
    
    if (hasPermission) {
      return true;
    } else {
      const result = await this.requestPermissions(permission, context);
      return result;
    }
  }

  /**
   * Checks if a permission is granted without requesting it from the user.
   * 
   * @param permission - The permission to check
   * @returns A promise that resolves to true if the permission is granted, false otherwise
   */
  public async isPermissionGranted(permission: Permissions): Promise<boolean> {
    console.log(`[REAL] Checking if permission is granted: ${permission}`);
    
    const tokenId = await this.getAppTokenId();
    if (tokenId === -1) {
      return false;
    }

    const hasPermission = await this.checkPermissionWithTokenId(tokenId, permission);
    
    console.log(`[REAL] Permission status for ${permission}: ${hasPermission}`);
    return hasPermission;
  }

  /**
   * Checks multiple permissions and returns a map with the results
   * 
   * @param permissions - List of permissions to check
   * @param context - The application context
   * @returns A map where the keys are the permissions and the values indicate if they are granted
   */
  public async checkMultiplePermissions(permissions: Permissions[], context: Context): Promise<Map<Permissions, boolean>> {
    const results = new Map<Permissions, boolean>();
    
    for (const permission of permissions) {
      results.set(permission, await this.checkPermissionGrant(permission, context));
    }
    
    return results;
  }

  /**
   * Gets the application token ID
   * @returns The token ID or -1 if there is an error
   */
  private async getAppTokenId(): Promise<number> {
    try {
      const bundleInfo: bundleManager.BundleInfo =
        bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      const appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      return appInfo.accessTokenId;
    } catch (error) {
      this.logError('getAppTokenId', error);
      return -1;
    }
  }

  /**
   * Checks a permission using the token ID
   * @param tokenId - The application token ID
   * @param permission - The permission to check
   * @returns true if the permission is granted, false otherwise
   */
  private async checkPermissionWithTokenId(tokenId: number, permission: Permissions): Promise<boolean> {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const requestedPermission = atManager.checkAccessTokenSync(tokenId, permission);
      return requestedPermission === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    } catch (error) {
      this.logError('checkPermissionWithTokenId', error);
      return false;
    }
  }

  /**
   * Requests permissions from the user.
   * 
   * @param permission - The permission to request
   * @param context - The application context
   * @returns A promise that resolves to true if the permission was granted, false otherwise
   */
  private async requestPermissions(permission: Permissions, context: Context): Promise<boolean> {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const result = await atManager.requestPermissionsFromUser(context, [permission]);
      
      // If the result is GRANTED (0), the permission was granted
      if (result.authResults[0] === PermissionStatus.GRANTED) {
        return true;
      }
      
      // If the dialog was shown but the user denied, return false
      if (result.dialogShownResults && result.dialogShownResults[0]) {
        return false;
      }
      
      // If the dialog was not shown, open the permission settings
      return this.openPermissionsSetting(permission, context);
    } catch (err) {
      this.logError('requestPermissions', err);
      return false;
    }
  }

  /**
   * Opens the system permission settings for a specific permission.
   * 
   * @param permission - The permission for which to open the settings
   * @param context - The application context
   * @returns A promise that resolves to true if the permission was granted, false otherwise
   */
  public async openPermissionsSetting(permission: Permissions, context: Context): Promise<boolean> {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const data = await atManager.requestPermissionOnSetting(context, [permission]);
      
      return data[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    } catch (err) {
      this.logError('openPermissionsSetting', err);
      return false;
    }
  }
}

/**
 * Mock implementation of PermissionUtils for testing and development
 */
class PermissionUtilsMock extends PermissionUtils {
  private mockPermissions: Map<Permissions, boolean> = new Map<Permissions, boolean>();
  // By default, grant all permissions in mock mode
  private defaultResponse: boolean = false;

  /**
   * Sets the default response for permission requests
   * @param granted Whether permissions should be granted by default
   */
  public setDefaultResponse(granted: boolean): void {
    this.defaultResponse = granted;
    console.log(`[MOCK] Default permission response set to: ${granted ? 'GRANT' : 'DENY'}`);
  }

  /**
   * Sets a specific permission state
   * @param permission The permission to set
   * @param granted Whether the permission is granted
   */
  public setPermission(permission: Permissions, granted: boolean): void {
    this.mockPermissions.set(permission, granted);
    console.log(`[MOCK] Permission ${permission} explicitly set to ${granted ? 'GRANTED' : 'DENIED'}`);
  }

  /**
   * Toggles a permission state
   * @param permission The permission to toggle
   * @returns The new state of the permission
   */
  public togglePermission(permission: Permissions): boolean {
    const currentValue = this.mockPermissions.get(permission) ?? this.defaultResponse;
    const newValue = !currentValue;
    this.mockPermissions.set(permission, newValue);
    console.log(`[MOCK] Permission ${permission} toggled from ${currentValue} to ${newValue}`);
    return newValue;
  }

  /**
   * Mock implementation for permission check and request
   * @param permission The permission to check
   * @param context Application context (not used in mock)
   */
  public async checkPermissionGrant(permission: Permissions, context: Context): Promise<boolean> {
    console.log(`[MOCK] Checking permission: ${permission}`);
    
    // If we have an explicit setting for this permission, use it
    if (this.mockPermissions.has(permission)) {
      const result = this.mockPermissions.get(permission) as boolean;
      console.log(`[MOCK] Using explicit mock setting: ${result}`);
      return result;
    }
    
    // Otherwise use the default response
    console.log(`[MOCK] Using default response: ${this.defaultResponse}`);
    this.mockPermissions.set(permission, this.defaultResponse); 
    return this.defaultResponse;
  }

  /**
   * Mock implementation for checking permission status
   * @param permission The permission to check
   */
  public async isPermissionGranted(permission: Permissions): Promise<boolean> {
    console.log(`[MOCK] Checking if permission is granted: ${permission}`);
    // If we have an explicit setting for this permission, use it
    if (this.mockPermissions.has(permission)) {
      const result = this.mockPermissions.get(permission) as boolean;
      console.log(`[MOCK] Using explicit mock setting: ${result}`);
      return result;
    }
    
    // Otherwise use the default response
    console.log(`[MOCK] Using default response: ${this.defaultResponse}`);
    return this.defaultResponse;
  }

  /**
   * Mock implementation for checking multiple permissions
   * @param permissions List of permissions to check
   * @param context Application context (not used in mock)
   */
  public async checkMultiplePermissions(permissions: Permissions[], context: Context): Promise<Map<Permissions, boolean>> {
    const results = new Map<Permissions, boolean>();
    
    for (const permission of permissions) {
      results.set(permission, await this.isPermissionGranted(permission));
    }
    
    return results;
  }

  /**
   * Opens the global permission settings panel using requestGlobalSwitch
   * 
   * @param context - The application context
   * @returns A promise that resolves to true if successful
   */

}

// Create convenience for accessing a specific implementation if needed
export const permissionUtilsReal = new PermissionUtilsImpl();
export const permissionUtilsMock = new PermissionUtilsMock();

/**
 * Sets the implementation to use (mock or real)
 * @param useMock Whether to use the mock implementation
 */
export function usePermissionImplementation(useMock: boolean): void {
  if (useMock) {
    PermissionUtils.setImplementation(permissionUtilsMock);
  } else {
    PermissionUtils.setImplementation(permissionUtilsReal);
  }
}

/**
 * Checks if a specific permission has been granted by the user
 * @param permission The permission to check
 * @param context Application context
 * @returns Whether the permission is granted
 */
export async function checkPermissionGrant(permission: Permissions, context: Context): Promise<boolean> {
  return PermissionUtils.getInstance().checkPermissionGrant(permission, context);
}

/**
 * Checks if a permission is granted without requesting it
 * @param permission The permission to check
 * @returns Whether the permission is granted
 */
export async function isPermissionGranted(permission: Permissions): Promise<boolean> {
  return PermissionUtils.getInstance().isPermissionGranted(permission);
}

/**
 * Checks multiple permissions
 * @param permissions List of permissions to check
 * @param context Application context
 * @returns Map of permissions and their states
 */
export async function checkMultiplePermissions(permissions: Permissions[], context: Context): Promise<Map<Permissions, boolean>> {
  return PermissionUtils.getInstance().checkMultiplePermissions(permissions, context);
}


/**
 * Gets the mock implementation to configure it
 * @returns The mock implementation
 */
export function getMockImplementation(): PermissionUtilsMock {
  return permissionUtilsMock;
}

/**
 * Sets the default response for mock permissions
 * @param granted Whether permissions should be granted by default
 */
export function setMockDefaultResponse(granted: boolean): void {
  permissionUtilsMock.setDefaultResponse(granted);
}

/**
 * Sets a specific mock permission
 * @param permission The permission to set
 * @param granted Whether the permission should be granted
 */
export function setMockPermission(permission: Permissions, granted: boolean): void {
  permissionUtilsMock.setPermission(permission, granted);
}

/**
 * Toggles a mock permission
 * @param permission The permission to toggle
 * @returns The new state of the permission
 */
export function toggleMockPermission(permission: Permissions): boolean {
  return permissionUtilsMock.togglePermission(permission);
}