_: {
  #------- hyprland 录屏与截图快捷键脚本--------#
  home.file.".config/hypr/scripts/capture.sh" = {
    source = ./capture.sh;
    executable = true; # 设置可执行权限
  };

  #------------- 录制状态指示 ------------#
  home.file.".config/waybar/scripts/wf-recorder-status.sh" = {
    source = ./wf-recorder-status.sh;
    executable = true;
  };

  #---------壁纸切换脚本--------#
  home.file.".config/wallpaper/script/swww-rofi.sh" = {
    source = ./swww-rofi.sh;
    executable = true;
  };
}
