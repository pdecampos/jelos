# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="mupen64plus-sa-video-glide64mk2"
PKG_VERSION="d900f2191575e01eb846a1009be71cbc1b413dba"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/mupen64plus/mupen64plus-video-glide64mk2"
PKG_URL="https://github.com/mupen64plus/mupen64plus-video-glide64mk2/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain boost libpng SDL2 SDL2_net zlib freetype nasm:host mupen64plus-sa-core"
PKG_SHORTDESC="mupen64plus-video-glide64mk2"
PKG_LONGDESC="Mupen64Plus Standalone Glide64 Video Driver"
PKG_TOOLCHAIN="manual"

case ${DEVICE} in
  AMD64|RK3588|S922X)
    PKG_DEPENDS_TARGET="mupen64plus-sa-simplecore"
  ;;
esac

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

make_target() {
  case ${ARCH} in
    arm|aarch64)
      export HOST_CPU=aarch64
      BINUTILS="$(get_build_dir binutils)/.aarch64-libreelec-linux-gnueabi"
      export USE_GLES=1
    ;;
    x86_64)
      export HOST_CPU=x86_64
      export USE_GLES=0
    ;;
  esac
  export APIDIR=${SYSROOT_PREFIX}/usr/local/include/mupen64plus
  export SDL_CFLAGS="-I${SYSROOT_PREFIX}/usr/include/SDL2 -pthread"
  export SDL_LDLIBS="-lSDL2_net -lSDL2"
  export CROSS_COMPILE="${TARGET_PREFIX}"
  export V=1
  export VC=0
  make -C projects/unix clean
  make -C projects/unix all ${PKG_MAKE_OPTS_TARGET}
  cp ${PKG_BUILD}/projects/unix/mupen64plus-video-glide64mk2.so ${PKG_BUILD}/projects/unix/mupen64plus-video-glide64mk2-base.so
  export APIDIR=${SYSROOT_PREFIX}/usr/local/include/simple64
  make -C projects/unix all ${PKG_MAKE_OPTS_TARGET}
  cp ${PKG_BUILD}/projects/unix/mupen64plus-video-glide64mk2.so ${PKG_BUILD}/projects/unix/mupen64plus-video-glide64mk2-simple.so
}

makeinstall_target() {
  UPREFIX=${INSTALL}/usr/local
  ULIBDIR=${UPREFIX}/lib
  USHAREDIR=${UPREFIX}/share/mupen64plus
  UPLUGINDIR=${ULIBDIR}/mupen64plus
  mkdir -p ${UPLUGINDIR}
  cp ${PKG_BUILD}/projects/unix/mupen64plus-video-glide64mk2-base.so ${UPLUGINDIR}/mupen64plus-video-glide64mk2.so
  #${STRIP} ${UPLUGINDIR}/mupen64plus-video-glide64mk2.so
  chmod 0644 ${UPLUGINDIR}/mupen64plus-video-glide64mk2.so
  cp ${PKG_BUILD}/projects/unix/mupen64plus-video-glide64mk2-simple.so ${UPLUGINDIR}
  #${STRIP} ${UPLUGINDIR}/mupen64plus-video-glide64mk2-simple.so
  chmod 0644 ${UPLUGINDIR}/mupen64plus-video-glide64mk2-simple.so
  mkdir -p ${USHAREDIR}
  cp ${PKG_BUILD}/data/Glide64mk2.ini ${USHAREDIR}
  chmod 0644 ${USHAREDIR}/Glide64mk2.ini
}

