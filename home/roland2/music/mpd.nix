{config, lib, pkgs, ...}: {
  home.packages = with pkgs; [
    mpc
  ];

  # MPD 启动要求音乐目录已存在
  home.activation.ensureMusicDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "${config.home.homeDirectory}/music"
  '';

  services.mpd.enable = true;
  services.mpd = {
    musicDirectory = "${config.home.homeDirectory}/music";
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "PipeWire Output"
      }

      restore_paused "yes"
      auto_update "yes"
    '';
  };
  programs.ncmpcpp = {
    enable = true;
    mpdMusicDir = "${config.home.homeDirectory}/music";
    settings = {
      lyrics_directory = "${config.home.homeDirectory}/music";
      store_lyrics_in_song_dir = "yes";
    };
  };
}
