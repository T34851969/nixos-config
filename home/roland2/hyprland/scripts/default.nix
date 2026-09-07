_: {
  #------- hyprland 录屏与截图快捷键脚本--------#
  home.file.".config/hypr/scripts/capture.sh" = {
    source = ./capture.sh;
    executable = true; # 设置可执行权限
  };

  #---------壁纸切换脚本--------#
  home.file.".config/wallpaper/script/swww-rofi.sh" = {
    source = ./swww-rofi.sh;
    executable = true;
  };
}
