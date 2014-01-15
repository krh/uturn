#
# This build recipe is sourced from the uturn build driver.  It runs
# in / with two variables available:
#
#   build_path - path to where the project should be build
#   repo_path  - path to repo with the revision to build checked out
#
# FIXME: What if a project doesn't support out-of-tree builds?
#

deps="wayland cairo mesa"
container=base-x86_64
upstream=ssh://git.freedesktop.org/git/wayland/weston

function build {
    cd $build_path
    $repo_path/autogen.sh --prefix=/usr
    make -j5
}
