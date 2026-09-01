enum API {
  //App
  getNewVersion('/v1/version'),
  allAiPictures('QiumiImage/allpictures'),

  commonNotice('common/notice'),

  ///民间故事文案生成
  folkStoryAutoGenerate('folkStory/getNovelInfo'),

  folkStoryThemeAutoGenerate('folkStory/generateNovelPrompt'),

  ///画面风格
  pictureStyle('folkStory/getImgStyle'),

  ///视频比例
  videoRatio('folkStory/getImgScale'),

  ///字幕设置
  captionsConfig('folkStory/getSubtitleConfig'),

  ///生成民间故事
  createFolkStory('FolkStory/saveBaseInfo'),

  getCaptionsSettingImg('folkStory/getSubtitleInfo'),

  getFolkStoryTextFieldSetting('folkStory/getFolkStoryConfig');

  const API(this.path);

  final String path;
}
