import { media } from '@kit.MediaKit'
import { fileIo as fs } from '@kit.CoreFileKit'
import { FileUtils, LogUtil } from '.'

const TAG = "utils"

class AvRecorderManager {
  filePath: string = ''
  fileFd?: fs.File
  recorder?: media.AVRecorder

  //初始化录音器
  async init() {
    if (!this.recorder) {
      this.recorder = await media.createAVRecorder()
    }
  }

  //进入准备就绪状态
  async prepareRecorder() {
    const context = getContext()
    const filesDir = FileUtils.getUploadFilesDir(context)
    this.filePath = `${filesDir}/audio_${Date.now()}.m4a`

    this.fileFd = fs.openSync(this.filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE)

    let avProfile: media.AVRecorderProfile = {
      audioBitrate: 100000,
      audioChannels: 2,
      audioCodec: media.CodecMimeType.AUDIO_AAC,
      audioSampleRate: 48000,
      fileFormat: media.ContainerFormatType.CFT_MPEG_4A,
    }
    let avConfig: media.AVRecorderConfig = {
      audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
      profile: avProfile,
      url: 'fd://' + this.fileFd.fd,
    }
    await this.recorder?.prepare(avConfig)
  }

  //开始录音
  async startRecorder() {
    if (!this.recorder) {
      return
    }
    try {
      await this.prepareRecorder()
      await this.recorder.start()
    } catch (e) {
      LogUtil.error(TAG, "start record error " + JSON.stringify(e))
    }
  }

  //关闭录音
  async endRecorder() {
    if (!this.recorder) {
      return
    }
    try {
      await this.recorder.stop()
    } catch (e) {
      LogUtil.error(TAG, "stop record error " + JSON.stringify(e))
    }
    await fs.close(this.fileFd?.fd)
    const filePath = FileUtils.getPathFromUri(getContext(), this.filePath)
    await this.recorder.reset()
    return filePath
  }

  //释放录音资源
  async release() {
    if (!this.recorder) {
      return
    }
    await this.recorder.stop()
    await this.recorder.release()
    this.filePath = ''
    this.fileFd = undefined
  }
}

export const avRecorderManager = new AvRecorderManager()