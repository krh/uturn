arch=i686
basearch=i386
release=20
name=base-$arch
repo=fedora

_mesa_rpms="mesa-libEGL-devel mesa-libGLES-devel libwayland-egl-devel mesa-libgbm-devel"

rpms="systemd passwd yum fedora-release vim-minimal sudo file \
    openssh-clients time findutils xz which libpng-devel pixman-devel \
    freetype-devel fontconfig-devel \
    libtool automake autoconf git make \
    libffi-devel expat-devel doxygen diffutils \
    libXcursor-devel systemd-devel libxml2-python bison flex \
    libdrm-devel gcc-c++ gettext \
    mtdev-devel libxkbcommon-devel libjpeg-turbo-devel pam-devel \
    libX11-devel libXext-devel libXdamage-devel libXfixes-devel libxcb-devel"
