

container=base-x86_64
packages="wayland mesa cairo weston"

function build_walyand {
    cd $build_path
    $repo_path/autogen.sh --prefix=/usr --enable-egl --enable-glesv2
    make -j5
    make install DESTDIR=$install_path
}

function build_mesa {
    cd $build_path
    $repo_path/autogen.sh --prefix=/usr --with-egl-platforms=wayland,drm,x11 --with-dri-drivers=i965 --disable-static --with-gallium-drivers= --enable-gles2 --disable-gallium-egl --disable-dri3
    make -j5
    make install DESTDIR=$install_path
}

function build_cairo {
    cd $build_path
    $repo_path/autogen.sh --prefix=/usr --enable-egl --enable-glesv2
    make -j5
    make install DESTDIR=$install_path
}

function build_weston {
    cd $build_path
    $repo_path/autogen.sh --prefix=/usr
    make -j5
}
