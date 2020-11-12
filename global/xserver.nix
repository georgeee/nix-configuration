# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  iconTheme = pkgs.breeze-icons.out;
  themeEnv = ''
        # QT: remove local user overrides (for determinism, causes hard to find bugs)
        rm -f ~/.config/Trolltech.conf
        # GTK3: remove local user overrides (for determinisim, causes hard to find bugs)
        rm -f ~/.config/gtk-3.0/settings.ini
        # GTK3: add breeze theme to search path for themes
        # (currently, we need to use gnome-breeze because the GTK3 version of kde5.breeze is broken)
        export XDG_DATA_DIRS="${pkgs.gnome-breeze}/share:$XDG_DATA_DIRS"
        # GTK3: add /etc/xdg/gtk-3.0 to search path for settings.ini
        # We use /etc/xdg/gtk-3.0/settings.ini to set the icon and theme name for GTK 3
        export XDG_CONFIG_DIRS="/etc/xdg:$XDG_CONFIG_DIRS"
        # GTK2 theme + icon theme
        export GTK2_RC_FILES=${pkgs.writeText "iconrc" ''gtk-icon-theme-name="breeze"''}:${pkgs.breeze-gtk}/share/themes/Breeze/gtk-2.0/gtkrc:$GTK2_RC_FILES
        # SVG loader for pixbuf (needed for GTK svg icon themes)
        export GDK_PIXBUF_MODULE_FILE=$(echo ${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/*/loaders.cache)
        # LS colors
        # TODO uncomment: eval `$ {pkgs.coreutils}/bin/dircolors "$ {./dircolors}"`
        # QT5: convince it to use our preferred style
        export QT_STYLE_OVERRIDE=breeze
        '';
  sysPkgs = with pkgs; [
    nvidia-offload
    #themes
    adapta-gtk-theme
    gnome3.adwaita-icon-theme
    xorg.xcursorthemes
    # gnome-shell-extension-appindicator-32
    # Qt theme
    # breeze-qt5
    # breeze-qt4

    # Icons (Main)
    # iconTheme
    hicolor_icon_theme

    libnotify
    dropbox feh evince
    trayer firefox
    chromium konsole xclip 
    xorg.xbacklight
    vlc networkmanagerapplet
    deadbeef deadbeef-mpris2-plugin deadbeef-with-plugins
    corefonts freefont_ttf terminus_font ubuntu_font_family
    tdesktop
    pcmanfm transmission-gtk
    udiskie
    # polybar
  ];
  hsPkgs  = with pkgs.haskellPackages; [
    xmonad xmonad-contrib
    status-notifier-item
  ];
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec -a "$0" "$@"
      '';
in
{
   # services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];
   imports = [ ./suspend.nix  ];
   services.upower.enable = true;
   services.gnome3.gnome-keyring.enable = true;
   services.batteryNotifier = {
      enable = true;
      notifyCapacity = 15;
   };
   # hardware.nvidia.optimus_prime = {
   #  enable = true;
   #  # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
   #  intelBusId = "PCI:0:2:0";

   #  # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
   #  nvidiaBusId = "PCI:1:0:0";
   # };
   services.xserver = {
      # serverLayoutSection = ''
      #       Option "AllowNVIDIAGPUScreens"
      #           '';
      # displayManager.startx.enable = true;
      enable = true;
      layout = "us,ru";
      xkbOptions = "grp:caps_toggle";
      displayManager.sddm.enable = true;

      # Uncomment to enable nvidia
      videoDrivers = [ "nvidia" ];
      dpi = 192;
      
      # wacom.enable = true;
      monitorSection = ''
          DisplaySize 487.2 273.6
        '';
      # desktopManager.gnome3.enable = true;
      synaptics = {
        enable = true;
        minSpeed = "1.0"; 
        maxSpeed = "2.0";
        tapButtons = true;
        twoFingerScroll = true;
        horizontalScroll = true;
        vertEdgeScroll = true;
        palmDetect = true;
      };
      desktopManager = {
        xterm.enable = false;
      };
      windowManager = {
        xmonad = {
          enable                 = true;
          enableContribAndExtras = true;
        };
      };
      displayManager.defaultSession = "none+xmonad";
      displayManager.sessionCommands = with pkgs; lib.mkAfter ''
        ${xlibs.xsetroot}/bin/xsetroot -cursor_name left_ptr;
        ${haskellPackages.status-notifier-item}/bin/status-notifier-watcher &
        ${coreutils}/bin/sleep 10 && ${dropbox}/bin/dropbox &
        ${coreutils}/bin/sleep 10 && ${networkmanagerapplet}/bin/nm-applet &
        ${feh}/bin/feh --bg-scale ~/.bg.jpg ;
        ${udiskie}/bin/udiskie -t ;
        exec ${haskellPackages.xmonad}/bin/xmonad
                                                               '';
   };
   environment.extraInit = ''
     ${themeEnv}
     # these are the defaults, but some applications are buggy so we set them
     # here anyway
     export XDG_CONFIG_HOME=$HOME/.config
     export XDG_DATA_HOME=$HOME/.local/share
     export XDG_CACHE_HOME=$HOME/.cache
     '';

   # QT4/5 global theme
   environment.etc."xdg/Trolltech.conf" = {
     text = ''
        [Qt]
        style=Breeze
        '';
     mode = "444";
   };
   # GTK3 global theme (widget and icon theme)
   environment.etc."xdg/gtk-3.0/settings.ini" = {
       text = ''
           [Settings]
           gtk-icon-theme-name=breeze
           gtk-theme-name=Breeze-gtk
           '';
       mode = "444";
   };
   environment.systemPackages = builtins.concatLists [ sysPkgs hsPkgs ];
}

