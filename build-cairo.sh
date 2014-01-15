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
    $repo_path/autogen.sh --prefix=/usr --enable-egl --enable-glesv2
    make -j5
    make install DESTDIR=$install_path
}
