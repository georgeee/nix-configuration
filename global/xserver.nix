# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
   sysPkgs = with pkgs; [
   ];
   hsPkgs  = with pkgs.haskellPackages; [
     xmonad xmonad-contrib taffybar
   ];
in
{
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
        default = "none";
        xterm.enable = false;
      };
      monitorSection = ''
          DisplaySize 487.2 273.6
        '';
      windowManager = {
        default = "xmonad";
        xmonad = {
          enable                 = true;
          enableContribAndExtras = true;
        };
      };
   };
   environment.systemPackages = builtins.concatLists [ sysPkgs hsPkgs ];
}

