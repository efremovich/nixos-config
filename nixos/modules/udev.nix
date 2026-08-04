{ pkgs, ... }:
{
  # Группа для USB-доступа (используется в users.extraGroups)
  users.groups.plugdev = { };

  services.udev.packages = with pkgs; [ platformio-core.udev ];

  services.udev.extraRules = ''
    # XMOS xTAG / xCORE USB (VID 0x20B1); доступ через группу и uaccess
    SUBSYSTEM=="usb", ATTR{idVendor}=="20b1", GROUP="plugdev", TAG+="uaccess"
    SUBSYSTEM=="usb_device", ATTR{idVendor}=="20b1", GROUP="plugdev", TAG+="uaccess"
    KERNEL=="ttyUSB*", ATTRS{idVendor}=="20b1", GROUP="dialout", TAG+="uaccess"
    KERNEL=="ttyACM*", ATTRS{idVendor}=="20b1", GROUP="dialout", TAG+="uaccess"
  '';
}
