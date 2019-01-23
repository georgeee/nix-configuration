# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
   sysPkgs = with pkgs; [
     wget git julia ghc

     tmux htop mosh acpi curl
     unrar unzip nettools gnupg tcpdump strace traceroute openssl
     gcc chromium
     
     vlc ffmpeg konsole xclip pulseaudioFull

     corefonts freefont_ttf terminus_font ubuntu_font_family
     
   ];
   hsPkgs  = with pkgs.haskellPackages; [
     stylish-haskell     
   ];
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./vim.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "georgeee-laptop-1"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
   i18n = {
     consoleFont = "Lat2-Terminus16";
     consoleKeyMap = "us";
     defaultLocale = "en_US.UTF-8";
   };

  # Set your time zone.
   time.timeZone = "Europe/Moscow";

   nixpkgs.config = {
     allowUnfree = true;
     chromium = {
       # enablePepperFlash = true; # Chromium's non-NSAPI alternative to Adobe Flash
       # enablePepperPDF = true;
      };
   };

   environment.systemPackages = builtins.concatLists [ sysPkgs hsPkgs ];

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
   sound.enable = true;
   hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
   services.xserver = {
      enable = true;
      layout = "us,ru";
      xkbOptions = "grp:caps_toggle";
      displayManager.slim = {
        enable = true;
        autoLogin = false;
        defaultUser = "georgeee";
        theme = pkgs.fetchurl {
          url    = "https://github.com/jagajaga/nixos-slim-theme/archive/Final.tar.gz";
          sha256 = "4cab5987a7f1ad3cc463780d9f1ee3fbf43603105e6a6e538e4c2147bde3ee6b";
        };
      };
      libinput = {
        enable = true;
        #clickMethod = "clickfinger";
        tapping = true;
      };
      synaptics.enable = false;
      # synaptics = {
      #   enable = true;
      #   minSpeed = "1.0"; 
      #   maxSpeed = "2.0";
      #   tapButtons = true;
      #   twoFingerScroll = true;
      #   horizontalScroll = true;
      #   vertEdgeScroll = true;
      #   palmDetect = true;
      # };
      # windowManager.xmonad.enable = true;
      # windowManager.default = "xmonad";
      desktopManager.gnome3.enable = true;
      desktopManager.default = "gnome3";
      monitorSection = ''
        DisplaySize 487.2 273.6
      '';
   };


  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.georgeee = {
     isNormalUser = true;
     uid = 1000;
   };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?

}
