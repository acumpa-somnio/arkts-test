
export const APP_PREFERENCES_NAME = "MyPreferences";
export const DOMAIN_NUMBER: number = 0xFF00;

export default class CommonConstant {
  static readonly SERVER: Resource = $r('app.string.server_address');

  static readonly SUCCESS_CODE: number = 200;
  static readonly READ_TIMEOUT: number = 50000;
  static readonly CONNECT_TIMEOUT: number = 50000;
}