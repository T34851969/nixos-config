{
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./modules
  ];

  nix.settings.trusted-users = ["root" "roland2"];
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];

  environment.systemPackages = with pkgs; [
    pulseaudio
    pciutils # lspci
    ffmpeg
    libva
    libva-utils
    power-profiles-daemon
    neovim
    git
    curl
    wget
    bluez
    cachix
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    TERMINAL = "kitty";
    # GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    QT5_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  programs.steam.enable = true;
  programs.steam.fontPackages = with pkgs; [source-han-sans];
  programs.zsh.enable = true;
  users.users.roland2 = {
    description = "Roland2";
    isNormalUser = true;
    home = "/home/roland2";
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
    # 初始密码 123（SHA-512 crypt），部署后可用 passwd 更改
    hashedPassword = "$6$RWOHg/f2qRyYgO8I$vNsH4KUKwG5otBmHVrCOblyu.PPB7rB6UCT.xxn1D1nFg7YJOoDjKqSWx4uSHM7pUCV/XKWp760wz81fvG8Md/";
    extraGroups = ["wheel" "networkmanager" "audio" "input" "video"];
  };
  security.sudo.wheelNeedsPassword = false; # sudo组是否需要密码

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Low-power CPUs use the kernel parameters below to avoid crashes
  boot.kernelParams = ["ahci.mobile_lpm_policy=1"];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
  services.timesyncd.enable = true;

  # U盘自动加载
  services.udisks2.enable = true;

  # networking
  networking.hostName = "lcars-celeron";
  networking.networkmanager.enable = true;
  # 防火墙：默认拒绝入站，仅放行局域网段 192.168.10.0/24 与 Tailscale 的全部流量
  networking.nftables.enable = true; # 防火墙使用 nftables 后端
  networking.firewall = {
    enable = true;
    trustedInterfaces = ["tailscale0"]; # Tailscale 接口全放行
    checkReversePath = "loose"; # strict rpfilter 会丢弃 Tailscale 的包
    allowedUDPPorts = [41641]; # Tailscale 直连（WireGuard 传输端口）
    extraInputRules = ''
      ip saddr 192.168.10.0/24 accept
    '';
  };

  services.tailscale.enable = true; # 首次部署后执行 `sudo tailscale up` 登录

  # Configure network proxy if necessary
  # 系统级代理设置：依赖本机 clash-verge 运行。
  # 新机器首次部署、clash 订阅配置并验证可用后再取消注释，否则系统服务会因代理不可用而失败
  # networking.proxy = {
  #   default = "http://127.0.0.1:7897";
  #   httpProxy = "http://127.0.0.1:7897";
  #   httpsProxy = "http://127.0.0.1:7897";
  #   noProxy = "localhost,127.0.0.1,::1,*.local";
  # };

  # 禁用所有形式的睡眠和休眠
  systemd.sleep.extraConfig = ''
    AllowSuspend=yes         # 如果只想禁用休眠，可以保持 Suspend 启用
    AllowHibernation=no      # 禁用休眠 (Hibernate)
    AllowHybridSleep=no      # 禁用混合睡眠 (Hybrid Sleep)
    AllowSuspendThenHibernate=no # 禁用先睡眠后休眠
  '';

  # timezone and local
  time.timeZone = "Asia/Shanghai";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_CTYPE = "zh_CN.UTF-8";
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkDefault "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji

    dejavu_fonts

    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  fonts = {
    enableDefaultPackages = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["Noto Sans" "Noto Sans CJK SC"];
        sansSerif = ["Noto Serif" "Noto Serif CJK SC"];
        monospace = ["Fira Code"];
      };
    };
  };

  programs.xwayland.enable = true;

  # Niri
  programs.niri.enable = true;

  # Hyprland
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;

  # services.displayManager.sddm.enable = true;
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # Enable sound.
  services.pulseaudio.enable = false;
  # OR
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  hardware = {
    enableAllFirmware = true; # 自动安装所有固件
    cpu.intel.updateMicrocode = true; # Intel CPU
    # cpu.amd.updateMicrocode = true; # AMD CPU
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
      intel-vaapi-driver
    ];
  };
  # 全新机器安装，设为当前发行版；stateVersion 只应在首次安装时设定，已有系统请勿改动
  system.stateVersion = "25.11";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

}
