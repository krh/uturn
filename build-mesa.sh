#
# This build recipe is sourced from the uturn build driver.  It runs
# in / with two variables available:
#
#   build_path   - path to where the project should be build
#   repo_path    - path to repo with the revision to build checked out
#   install_path - path to the install root for the project
#
# FIXME: What if a project doesn't support out-of-tree builds?
#

deps="mesa"
container=base-x86_64

function build {
    cd $build_path
    $repo_path/autogen.sh --prefix=/usr --with-egl-platforms=wayland,drm,x11 --with-dri-drivers=i965 --disable-static --with-gallium-drivers= --enable-gles2 --disable-gallium-egl --disable-dri3
    make -j5
    make install DESTDIR=$install_path
}
