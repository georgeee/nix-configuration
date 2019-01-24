# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
   sysPkgs = with pkgs; [
     wget git julia ghc killall

     tmux htop mosh acpi curl moc
     unrar unzip nettools gnupg tcpdump strace traceroute openssl
     gcc
     # telegram-desktop
     ffmpeg pulseaudioFull

     
   ];
   hsPkgs = with pkgs.haskellPackages; [
     stylish-haskell
     stack
   ];
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./vim.nix
      ./xserver.nix
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
