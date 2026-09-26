# Патч mako 1.11.0: устраняет permanent render freeze после "no buffer available"
# https://github.com/emersion/mako/issues/655
#
# При возврате из suspend композитор ещё держит оба SHM-буфера поверхности,
# send_frame() делал ранний return без нового frame callback, surface->dirty
# оставался true и рендер уведомлений замирал навсегда (D-Bus при этом жив).
# Патч просит новый frame callback и повторяет отрисовку на следующем кадре.
{ ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      mako = prev.mako.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          ../../pkgs/mako/0001-retry-frame-on-no-buffer.patch
        ];
      });
    })
  ];
}