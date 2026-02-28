/// 统一图标入口 - 使用 Solar Icons 圆润风格
/// 替换 Material Icons，提供更可爱、圆润的视觉体验
library;
import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

abstract final class AppIcons {
  AppIcons._();

  // 基础操作
  static const IconData add = SolarIconsBold.addCircle;
  static const IconData addSquare = SolarIconsBold.addSquare;
  static const IconData close = SolarIconsBold.closeCircle;
  static const IconData check = SolarIconsBold.checkCircle;
  static const IconData checkOutline = SolarIconsBold.checkSquare;
  static const IconData inProgress = SolarIconsBold.clockCircle;

  // 文件与文件夹
  static const IconData folder = SolarIconsBold.folder;
  static const IconData folderOpen = SolarIconsBold.folderOpen;

  // 用户与人物
  static const IconData person = SolarIconsBold.userRounded;
  static const IconData people = SolarIconsBold.usersGroupRounded;

  // 媒体与创作
  static const IconData movie = SolarIconsBold.clapperboardPlay;
  static const IconData video = SolarIconsBold.videocamera;
  static const IconData videoLibrary = SolarIconsBold.videoLibrary;
  static const IconData image = SolarIconsBold.gallery;
  static const IconData gallery = SolarIconsBold.gallery;
  static const IconData play = SolarIconsBold.play;
  static const IconData playArrow = SolarIconsBold.play;
  static const IconData music = SolarIconsBold.musicNote;
  static const IconData mic = SolarIconsBold.microphone;

  // 文档与编辑
  static const IconData book = SolarIconsBold.book;
  static const IconData document = SolarIconsBold.document;
  static const IconData edit = SolarIconsBold.pen;
  static const IconData pen = SolarIconsBold.pen;
  static const IconData editOutline = SolarIconsOutline.pen;

  // 操作
  static const IconData save = SolarIconsBold.diskette;
  static const IconData delete = SolarIconsBold.trashBinTrash;
  static const IconData refresh = SolarIconsBold.refresh;
  static const IconData download = SolarIconsBold.download;
  static const IconData upload = SolarIconsBold.upload;
  static const IconData uploadOutline = SolarIconsOutline.upload;

  // 设置与配置
  static const IconData settings = SolarIconsBold.settings;
  static const IconData tune = SolarIconsBold.settingsMinimalistic;
  static const IconData notification = SolarIconsBold.notificationUnread;

  // 导航与箭头
  static const IconData chevronRight = SolarIconsBold.arrowRight;
  static const IconData chevronLeft = SolarIconsBold.arrowLeft;
  static const IconData expandMore = SolarIconsBold.arrowDown;
  static const IconData expandLess = SolarIconsBold.arrowUp;
  static const IconData keyboardArrowUp = SolarIconsBold.arrowUp;
  static const IconData keyboardArrowRight = SolarIconsBold.arrowRight;
  static const IconData keyboardArrowDown = SolarIconsBold.arrowDown;

  // 更多菜单
  static const IconData moreVert = SolarIconsBold.menuDots;
  static const IconData moreHoriz = SolarIconsBold.menuDots;

  // 状态与提示
  static const IconData warning = SolarIconsBold.dangerTriangle;
  static const IconData error = SolarIconsBold.danger;
  static const IconData info = SolarIconsBold.infoCircle;
  static const IconData sync = SolarIconsBold.refresh;
  static const IconData bolt = SolarIconsBold.bolt;
  static const IconData magicStick = SolarIconsBold.magicStick;

  // 其他
  static const IconData lock = SolarIconsBold.lock;
  static const IconData lockOutline = SolarIconsBold.lockKeyhole;
  static const IconData help = SolarIconsBold.infoCircle;
  static const IconData dragHandle = SolarIconsBold.menuDots;
  static const IconData list = SolarIconsBold.list;
  static const IconData tag = SolarIconsBold.tag;
  static const IconData landscape = SolarIconsBold.mapPoint;
  static const IconData category = SolarIconsBold.tag;
  static const IconData palette = SolarIconsBold.palette2;
  static const IconData run = SolarIconsBold.play;
  static const IconData calculator = SolarIconsBold.calculatorMinimalistic;
  static const IconData rocket = SolarIconsBold.rocket2;
  static const IconData unfoldMore = SolarIconsBold.arrowDown;
  static const IconData unfoldLess = SolarIconsBold.arrowUp;
  static const IconData arrowForward = SolarIconsBold.arrowRight;

  // 步骤导航专用
  static const IconData script = SolarIconsBold.book;
  static const IconData assets = SolarIconsBold.userRounded;
  static const IconData storyboard = SolarIconsBold.clapperboardPlay;
  static const IconData config = SolarIconsBold.settingsMinimalistic;
  static const IconData generate = SolarIconsBold.magicStick;
  static const IconData clipEdit = SolarIconsBold.videoLibrary;
  static const IconData movieFilter = SolarIconsBold.clapperboardOpen;

  // AI 相关
  static const IconData autoAwesome = SolarIconsBold.magicStick;
  static const IconData autoFixHigh = SolarIconsBold.magicStick;
  static const IconData autoAwesomeMotion = SolarIconsBold.magicStick;

  // 其他
  static const IconData mergeType = SolarIconsBold.arrowRight;
  static const IconData hourglassEmpty = SolarIconsBold.clockCircle;
  static const IconData brokenImage = SolarIconsBold.gallery;
  static const IconData analytics = SolarIconsBold.chartSquare;
  static const IconData logout = SolarIconsBold.logout;
  static const IconData circleOutline = SolarIconsBold.recordCircle; // 未保存等状态
  static const IconData checkCircleOutline = SolarIconsOutline.checkCircle;
  static const IconData errorOutline = SolarIconsBold.danger;

  // 风格库
  static const IconData brush = SolarIconsBold.palette2;
  static const IconData colorSwatch = SolarIconsBold.palette2;

  // 版本管理
  static const IconData history = SolarIconsBold.history;
  static const IconData gitBranch = SolarIconsBold.arrowRight;
  static const IconData lockUnlocked = SolarIconsOutline.lockKeyhole;

  // 搜索
  static const IconData search = SolarIconsBold.magnifier;

  // 链接
  static const IconData link = SolarIconsBold.linkRound;
  static const IconData linkOff = SolarIconsBold.linkBroken;

  // 引用 & 文本
  static const IconData formatQuote = SolarIconsBold.chatRound;
}
