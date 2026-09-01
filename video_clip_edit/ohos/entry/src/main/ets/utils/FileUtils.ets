import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileUri } from '@kit.CoreFileKit';
import { LogUtil } from '.';
import { image } from '@kit.ImageKit';
import { componentSnapshot } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';

const TAG = "FileUtils";

const dir = "uploadCache"

export class FileUtils {
  //在应用缓存目录中的文件夹uploadCache中copy相册图片，并返回缓存目录的文件路径
  static getPathFromUri(context: common.Context | null, uri: string, defExtension?: string) {
    Log.i(TAG, "getPathFromUri : " + uri);
    let inputFile: fs.File;
    try {
      inputFile = fs.openSync(uri);
    } catch (err) {
      Log.e(TAG, "open uri file failed err:" + err)
      return null;
    }
    if (inputFile == null) {
      return null;
    }
    if (!context) {
      return
    }
    {
      const targetDirectoryPath = FileUtils.getUploadCacheDir(context)

      const inputFilePath = uri.substring(uri.lastIndexOf("/") + 1);
      const inputFilePathSplits = inputFilePath.split(".");
      Log.i(TAG, "getPathFromUri inputFilePath: " + inputFilePath);
      const outputFileName = inputFilePathSplits[0];
      let extension: string;
      if (inputFilePathSplits.length > 1) {
        // 取原路径的后缀
        extension = "." + inputFilePathSplits[inputFilePathSplits.length - 1];
      } else {
        if (defExtension) {
          extension = defExtension;
        } else {
          extension = ".jpg";
        }
      }
      const outputFilePath = targetDirectoryPath + "/" + outputFileName + extension;
      const outputFile = fs.openSync(outputFilePath, fs.OpenMode.CREATE);
      try {
        Log.i(TAG, "copyFileSync inputFile fd:" + inputFile.fd + " outputFile fd:" + outputFile.fd);
        fs.copyFileSync(inputFile.fd, outputFilePath);
      } catch (err) {
        Log.e(TAG, "copyFileSync failed err:" + err);
        return null;
      } finally {
        fs.closeSync(inputFile);
        fs.closeSync(outputFile);
      }
      return outputFilePath;
    }
  }

  static clearCache(context: common.Context) {
    try {
      const cacheDirPath = FileUtils.getUploadCacheDir(context)
      const isHaveCatch = fs.accessSync(cacheDirPath)
      if (isHaveCatch) {
        fs.rmdirSync(cacheDirPath)
      }
    } catch (err) {
      Log.e(TAG, "clearCache cacheDir failed err:" + err)
    }

    try {
      const filesDirPath = FileUtils.getUploadFilesDir(context)
      const isHaveFiles = fs.accessSync(filesDirPath)
      if (isHaveFiles) {
        fs.rmdirSync(filesDirPath)
      }
    } catch (err) {
      Log.e(TAG, "clearCache filesDir failed err:" + err)
    }
  }

  static async saveToAlbum(srcFileUri: string, type: 'image' | 'video') {
    try {
      let context = getContext();
      let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      let srcFileUris: Array<string> = [
        fileUri.getUriFromPath(srcFileUri)
      ];
      const fullName = srcFileUri.split('/').pop() || '';

      const lastDotIndex = fullName.lastIndexOf('.');

      const name = fullName.substring(0, lastDotIndex);
      const extension = fullName.substring(lastDotIndex + 1);

      let photoCreationConfigs: Array<photoAccessHelper.PhotoCreationConfig> = [
        {
          title: name,
          fileNameExtension: extension,
          photoType: type == 'image' ? photoAccessHelper.PhotoType.IMAGE : photoAccessHelper.PhotoType.VIDEO,
          subtype: photoAccessHelper.PhotoSubtype.DEFAULT,
        }
      ];
      let desFileUris: Array<string> = await phAccessHelper.showAssetsCreationDialog(srcFileUris, photoCreationConfigs);
      let desFile: fs.File = await fs.open(desFileUris[0], fs.OpenMode.WRITE_ONLY);
      let srcFile: fs.File = await fs.open(srcFileUri, fs.OpenMode.READ_ONLY);
      await fs.copyFile(srcFile.fd, desFile.fd);
      fs.closeSync(srcFile);
      fs.closeSync(desFile);
      LogUtil.info(TAG, 'create asset by dialog successfully');
      return true
    } catch (err) {
      LogUtil.error(TAG, `failed to create asset by dialog successfully errCode is: ${err.code}, ${err.message}`);
      return false
    }
  }


  //截图保存到相册
  static async screenshot(imageId: string, context: Context) {
    const filePath = await FileUtils.getFilePath(imageId, context)

    try {
      //获取完整路径
      const uri = fileUri.getUriFromPath(filePath)
      //根据路径在相册创建一个文件
      const assetChangeRequest = photoAccessHelper.MediaAssetChangeRequest.createImageAssetRequest(context, uri)
      //拿到phAccessHelper
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context)
      //将文件提交到相册
      await phAccessHelper.applyChanges(assetChangeRequest)

      return true

    } catch (err) {
      LogUtil.error(TAG, JSON.stringify(err))
      return false
    }
  }

  static async getFilePath(imageId: string, context: Context) {
    //拿到文件.PixelMap对象
    const share = await componentSnapshot.get(imageId)
    const packer = image.createImagePacker()
    //转为二进制
    const arrayBuffer = await packer.packing(share, { format: 'image/png', quality: 100 })
    //拿到缓存路径+随机文件名
    const targetDirectoryPath = FileUtils.getUploadCacheDir(context)
    const filePath = targetDirectoryPath + '/' + Date.now() + '.png'
    //打开文件
    const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE)
    fs.writeSync(file.fd, arrayBuffer)
    fs.closeSync(file.fd)
    return filePath
  }

  static getUploadCacheDir(context: Context) {
    const targetDirectoryPath = context.cacheDir + "/" + dir;
    const isHave = fs.accessSync(targetDirectoryPath)
    if (!isHave) {
      fs.mkdirSync(targetDirectoryPath);
    }
    return targetDirectoryPath
  }

  static getUploadFilesDir(context: Context) {
    const targetDirectoryPath = context.filesDir + "/" + dir;
    const isHave = fs.accessSync(targetDirectoryPath)
    if (!isHave) {
      fs.mkdirSync(targetDirectoryPath);
    }
    return targetDirectoryPath
  }

  static async getAudioDuration(path: string) {
    let duration = 0
    if (canIUse("SystemCapability.Multimedia.Media.AVMetadataExtractor")) {
      let avMetadataExtractor = await media.createAVMetadataExtractor();
      avMetadataExtractor.fdSrc = fs.openSync(path, fs.OpenMode.READ_ONLY);
      let metadata = await avMetadataExtractor.fetchMetadata();
      duration = Number(metadata.duration || "0")
      console.log('xxxx 获取到音频的时长', duration)
      avMetadataExtractor.release();
    }
    return duration
  }
}