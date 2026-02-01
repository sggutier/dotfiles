# NAS configuration module with ZFS, Samba, and NFS
{ config, pkgs, lib, ... }:

let
  cfg = config.modules.nas;
in
{
  options.modules.nas = {
    enable = lib.mkEnableOption "NAS functionality with ZFS storage";

    poolName = lib.mkOption {
      type = lib.types.str;
      default = "tank";
      description = "Name of the ZFS storage pool";
    };

    datasets = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          mountpoint = lib.mkOption {
            type = lib.types.str;
            description = "Where to mount this dataset";
          };
          share = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to export this dataset via Samba/NFS";
          };
        };
      });
      default = {
        share = {
          mountpoint = "/tank/share";
          share = true;
        };
      };
      description = "ZFS datasets to mount declaratively";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "nas";
      description = "User that owns the NAS shares";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "nas";
      description = "Group that owns the NAS shares";
    };

    samba = {
      enable = lib.mkEnableOption "Samba/SMB file sharing";

      credentialsFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = ''
          Path to a file containing Samba credentials in smbpasswd format.
          Generate with: pdbedit -L -w > /path/to/credentials
          If null, you must run 'smbpasswd -a <user>' manually after first boot.
        '';
      };

      extraShares = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
        default = {};
        description = "Additional Samba shares beyond the dataset shares";
      };
    };

    nfs = {
      enable = lib.mkEnableOption "NFS file sharing";

      extraExports = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Additional NFS exports";
      };

      allowedNetworks = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "192.168.1.0/24" ];
        description = "Networks allowed to access NFS shares";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # ZFS support
    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs.forceImportRoot = false;
    boot.zfs.extraPools = [ cfg.poolName ];

    services.zfs.autoScrub.enable = true;
    services.zfs.autoSnapshot = {
      enable = true;
      frequent = 4;
      hourly = 24;
      daily = 7;
      weekly = 4;
      monthly = 12;
    };

    # ZFS requires a host ID
    networking.hostId = lib.mkDefault (builtins.substring 0 8
      (builtins.hashString "md5" config.networking.hostName));

    # Let ZFS handle mounting natively via dataset mountpoint property
    # The pool is imported via boot.zfs.extraPools, and datasets mount automatically
    # based on their 'mountpoint' property (set with: zfs set mountpoint=/path pool/dataset)

    # Create NAS group and user
    users.groups.${cfg.group} = {};
    users.users.${cfg.user} = lib.mkIf (cfg.user != "root") {
      isSystemUser = true;
      group = cfg.group;
      description = "NAS service user";
    };

    # Declarative ownership and permissions via tmpfiles
    systemd.tmpfiles.rules = lib.concatLists (lib.mapAttrsToList (name: dataset:
      lib.optional dataset.share
        "d ${dataset.mountpoint} 0775 ${cfg.user} ${cfg.group} -"
    ) cfg.datasets);

    # Samba configuration
    services.samba = lib.mkIf cfg.samba.enable {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = config.networking.hostName;
          "netbios name" = config.networking.hostName;
          "security" = "user";
          "map to guest" = "never";
          "min protocol" = "SMB2";
          # Performance tuning for ZFS
          "socket options" = "TCP_NODELAY IPTOS_LOWDELAY";
          "use sendfile" = "yes";
          "aio read size" = "16384";
          "aio write size" = "16384";
          # Disable printer sharing
          "load printers" = "no";
          "printing" = "bsd";
          "printcap name" = "/dev/null";
          "disable spoolss" = "yes";
        };
      } // (lib.mapAttrs' (name: dataset: {
        name = name;
        value = lib.mkIf dataset.share {
          path = dataset.mountpoint;
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "valid users" = "@${cfg.group}";
          "force group" = cfg.group;
          "create mask" = "0664";
          "directory mask" = "0775";
        };
      }) cfg.datasets) // cfg.samba.extraShares;
    };

    # Import Samba credentials if provided
    systemd.services.samba-credentials = lib.mkIf (cfg.samba.enable && cfg.samba.credentialsFile != null) {
      description = "Import Samba credentials";
      wantedBy = [ "samba-smbd.service" ];
      before = [ "samba-smbd.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.samba}/bin/pdbedit -i smbpasswd:${cfg.samba.credentialsFile}";
        RemainAfterExit = true;
      };
    };

    services.samba-wsdd = lib.mkIf cfg.samba.enable {
      enable = true;
      openFirewall = true;
    };

    # Avahi for macOS/Linux discovery (Bonjour/mDNS)
    services.avahi = lib.mkIf cfg.samba.enable {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
      extraServiceFiles.smb = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
        </service-group>
      '';
    };

    # NFS configuration
    services.nfs.server = lib.mkIf cfg.nfs.enable {
      enable = true;
      exports = lib.concatStringsSep "\n" (
        (lib.concatLists (lib.mapAttrsToList (name: dataset:
          lib.optional dataset.share
            "${dataset.mountpoint} ${lib.concatMapStringsSep " "
              (net: "${net}(rw,sync,no_subtree_check,all_squash,anonuid=${toString config.users.users.${cfg.user}.uid},anongid=${toString config.users.groups.${cfg.group}.gid})")
              cfg.nfs.allowedNetworks}"
        ) cfg.datasets))
        ++ [ cfg.nfs.extraExports ]
      );
    };

    networking.firewall = lib.mkIf cfg.nfs.enable {
      allowedTCPPorts = [ 2049 ];
      allowedUDPPorts = [ 2049 ];
    };

    environment.systemPackages = with pkgs; [
      zfs
      smartmontools
      hdparm
      lsof
      iotop
      ncdu
    ];
  };
}
