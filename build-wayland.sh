#
# This build recipe is sourced from the uturn build driver.  It runs
# in / with two variables available:
#
#   build_path - path to where the project should be built
#   repo_path  - path to repo with the revision to build checked out
#
# FIXME: What if a project doesn't support out-of-tree builds?
#

container=base-x86_64
upstream=ssh://git.freedesktop.org/git/wayland/wayland

function build {
    cd $build_path
    $repo_path/autogen.sh --prefix=/usr
    make -j5 check
    make install DESTDIR=$install_path
}
