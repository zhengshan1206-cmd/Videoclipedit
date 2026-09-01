import hilog from '@ohos.hilog';

const DOMAIN = 0x7777;

export class LogUtil {
  public static debug(tag: string, msg: string): void {
    hilog.debug(DOMAIN, tag, '%{public}s', msg);
    console.log(`[DEBUG][${tag}] ${msg}`);
  }

  public static info(tag: string, msg: string): void {
    hilog.info(DOMAIN, tag, '%{public}s', msg);
    console.log(`[INFO][${tag}] ${msg}`);
  }

  public static warn(tag: string, msg: string): void {
    hilog.warn(DOMAIN, tag, '%{public}s', msg);
    console.log(`[WARN][${tag}] ${msg}`);
  }

  public static error(tag: string, msg: string): void {
    hilog.error(DOMAIN, tag, '%{public}s', msg);
    console.log(`[ERROR][${tag}] ${msg}`);
  }
}