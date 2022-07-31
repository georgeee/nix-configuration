{ pkgs, ... }:

let
  nginxWithModules = modules: pkgs.nginx.override { inherit modules; };
  nginxWithRTMP = with pkgs.nginxModules; nginxWithModules [ rtmp ];
in {
  config = {
    systemd.services.nginx.serviceConfig.ReadWritePaths = [ "/streaming" ];
    systemd.services.nginx.preStart = ''
      mkdir -p /streaming/{hls,dash}
    '';
    services.nginx = {
      enable = true;
      package = nginxWithRTMP;
      appendConfig = ''
        rtmp {
          server {
            listen 1935;
            chunk_size 10000;
            application live {
              live on;
              record off;
              hls on;
              hls_path /streaming/hls;
              # hls_fragment 3;
              # hls_playlist_length 10;
              dash on;
              dash_path /streaming/dash;
            }
          }
        }
      '';
      appendHttpConfig = ''
        server {
          listen 8080;
          location / {
            root /www;
          }
          location /stat {
            rtmp_stat all;
          }
          location /hls {
            types {
              application/vnd.apple.mpegurl m3u8;
              video/mp2t ts;
            }
            root /streaming;
            add_header Cache-Control no-cache;
            add_header Access-Control-Allow-Origin *;
          }
          location /dash {
            root /streaming;
            add_header Cache-Control no-cache;
            add_header Access-Control-Allow-Origin *;
          }
        }
      '';
    };
  };
}
