# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  hie-nix = pkgs.fetchFromGitHub {
    owner = "wizzup";
    repo = "hie-nix";
    rev = "279a9bb8baad82ea20f18056420b58ce763ee4ad";
    sha256 = "1j6763lzgif3wrz28gjsqp201r75rlf7gc3sjhcfa1ix74z0a6ds";
  };
  sysPkgs = with pkgs; [
    wget git 
    # julia
    ghc killall

    tmux htop mosh acpi curl moc
    unrar unzip nettools gnupg tcpdump strace traceroute openssl
    ntfs3g
    asciinema
    gcc
    # telegram-desktop
    ffmpeg pulseaudioFull

    # (import hie-nix { }).ghc-mod84
  ];
  hsPkgs = with pkgs.haskellPackages; [
    stylish-haskell
    stack
    hlint
  ];
in
{
  virtualisation.docker.enable = false;

  services.physlock.enable = true;

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./vim.nix
      ./xserver.nix
    ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  systemd.services.createDirs = {
    description = "Create directories";
    path = [ pkgs.bash ];
    wantedBy = [ "default.target" ];
    script = ''
      /usr/bin/env bash -c 'mkdir -p /run/{postgresql,mount/passport,mount/usb} && chmod 777 /run/{postgresql,mount/passport,mount/usb} && chmod 777 /sys/class/backlight/intel_backlight/brightness'
      '';
  };

  networking.hostName = "georgeee-laptop-1"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 8080 5560 5561 ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };
  console.keyMap = "us";
  console.font = "Lat2-Terminus16";

  # Set your time zone.
  time.timeZone = "Europe/Moscow";
  # services.timesyncd.enable = false;

  nixpkgs.config = {
    allowUnfree = true;
    chromium = {
      # enablePepperFlash = true; # Chromium's non-NSAPI alternative to Adobe Flash
      # enablePepperPDF = true;
     };
  };
  services.logind.extraConfig = ''
      HandleLidSwitch=hybrid-sleep
      HandlePowerKey=hibernate
    '';

  environment.systemPackages = builtins.concatLists [ sysPkgs hsPkgs ];

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.openvpn.servers.pia = {
    config = builtins.readFile "/keys/pia/US Silicon Valley.ovpn";
    updateResolvConf = true;
    autoStart = false;
  };
  services.udisks2.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.georgeee = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wireshark" "docker" "networkmanager" "wheel" "adm" ];
  };
  
  #nixpkgs.config.packageOverrides = pkgs: {
  #  haskell = pkgs.haskell // {
  #    packages = pkgs.haskell.packages // {
  #      ghc802 = pkgs.haskell.packages.ghc802.override {
  #        overrides = self: super: {
  #          cabal-helper = pkgs.haskell.lib.doJailbreak (super.cabal-helper);
  #        };
  #      };
  #    };
  #  };
  #};

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.07"; # Did you read the comment?
}
