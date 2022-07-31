# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  sysPkgs = with pkgs; [
    wireguard
    wget git 
    # julia
    ghc killall
    pinentry

    tmux htop mosh acpi curl moc
    unrar unzip nettools gnupg tcpdump strace traceroute openssl
    ntfs3g
    asciinema
    gcc
    # telegram-desktop
    ffmpeg pulseaudioFull
  ];
in
{
  virtualisation.docker.enable = true;

  services.physlock.enable = true;

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./vim.nix
      ./xserver.nix
      # ./rmtp.nix
    ];
  # services.printing.enable = true;
  # services.printing.drivers = [ pkgs.hplipWithPlugin ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = { "vm.swappiness" = 10;};
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
  networking.firewall = {
    allowedTCPPorts = [ 1935 8080 8302 51820 ];
  };
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.0.0.2/24" ];
      listenPort = 51820;
      privateKeyFile = "/keys/wg-private";
      peers = [
        {
          publicKey = "I3IzCClwUkHVXWRmI+smqLC34LDK9jnz8wKY9J/S7iI=";
          allowedIPs = [ # TODO find a less hacky way
            "10.0.0.0/24"
            # "213.24.64.0/24"
            # "146.158.0.0/16"
            # "62.76.205.0/24"
            # # Youtube premuim
            # "216.58.0.0/16"
            # "142.250.0.0/16"
            # "172.217.0.0/16"
            # "209.85.0.0/16"
            # "74.125.0.0/16"
            # "173.194.0.0/16"

            # "0.0.0.0/1"
            # "128.0.0.0/3"
            # "160.0.0.0/8"
            # "161.0.0.0/10"
            # "161.64.0.0/11"
            # "161.96.0.0/16"
            # "161.97.0.0/17"
            # "161.97.128.0/19"
            # "161.97.176.0/21"
            # "161.97.184.0/24"
            # "161.97.184.0/26"
            # "161.97.184.96/27"
            # "161.97.184.65/32"
            # "161.97.184.66/31"
            # "161.97.184.68/30"
            # "161.97.184.72/29"
            # "161.97.184.80/28"
            # "161.97.184.128/25"
            # "161.97.186.0/23"
            # "161.97.188.0/22"
            # "161.97.192.0/18"
            # "161.98.0.0/15"
            # "161.100.0.0/14"
            # "161.104.0.0/13"
            # "161.112.0.0/12"
            # "161.128.0.0/9"
            # "162.0.0.0/7"
            # "164.0.0.0/6"
            # "168.0.0.0/5"
            # "176.0.0.0/4"
            # "192.0.0.0/2"
          ];
          endpoint = "161.97.185.64:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };

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
  time.timeZone = "Europe/Madrid";
  # services.timesyncd.enable = false;

  nixpkgs.config = {
    allowUnfree = true;
    chromium = {
      # enablePepperFlash = true; # Chromium's non-NSAPI alternative to Adobe Flash
      # enablePepperPDF = true;
     };
  };
  nix.trustedUsers = [ "root" "georgeee" ];
  services.logind = {
    lidSwitch = "suspend";
    extraConfig = ''
      HandlePowerKey=hibernate
    '';
  };

  environment.systemPackages = sysPkgs;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

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
  programs.gnupg = {
    agent.enable = true;
    agent.pinentryFlavor = "qt";
  };
  nix.binaryCaches = [
    "https://cache.nixos.org"
    "s3://serokell-private-cache?endpoint=s3.eu-central-1.wasabisys.com&profile=serokell-private-cache"
  ];

  nix.binaryCachePublicKeys = [
      "serokell-1:aIojg2Vxgv7MkzPJoftOO/I8HKX622sT+c0fjnZBLj0="
  ];

  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.07"; # Did you read the comment?
}
