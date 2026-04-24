export class DateUtils {
  static getCurrentTimestamp(): string {
    const now = new Date();

    const year = now.getFullYear();
    const month = (now.getMonth() + 1).toString().padStart(2, '0'); // months are 0-indexed
    const day = now.getDate().toString().padStart(2, '0');
    const hours = now.getHours().toString().padStart(2, '0');
    const minutes = now.getMinutes().toString().padStart(2, '0');
    const seconds = now.getSeconds().toString().padStart(2, '0');

    const isoDate = `${year}-${month}-${day}T${hours}:${minutes}:${seconds}`;

    const tzOffset = now.getTimezoneOffset();
    const tzOffsetHours = Math.abs(Math.floor(tzOffset / 60)).toString().padStart(2, '0');
    const tzOffsetMinutes = Math.abs(tzOffset % 60).toString().padStart(2, '0');

    const tzSign = tzOffset <= 0 ? '+' : '-';
    const tzString = `${tzSign}${tzOffsetHours}:${tzOffsetMinutes}`;

    return `${isoDate}${tzString}`;
  }

  static timeDifferenceInSeconds(targetDate: Date): number {
    const now = new Date();
    const differenceInMilliseconds = targetDate.getTime() - now.getTime();
    return Math.round(differenceInMilliseconds / 1000);
  }
}