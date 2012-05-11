#build dependencies for cview that are not part of GnuStep MinGW downloads
CMAKE_MINIMUM_REQUIRED(VERSION 2.8.0)

SET(EXTRA_PATHS C:/GNUStep/msys/1.0/bin)
FIND_PROGRAM(URL_GRAB NAMES wget curl PATHS ${EXTRA_PATHS})
FIND_PROGRAM(UNZIP NAMES unzip PATHS ${EXTRA_PATHS})
FIND_PROGRAM(TAR NAMES tar PATHS ${EXTRA_PATHS})
FIND_PROGRAM(RSYNC NAMES rsync PATHS ${EXTRA_PATHS})
FILE(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/libs ${CMAKE_CURRENT_BINARY_DIR}/include  ${CMAKE_CURRENT_BINARY_DIR}/include/FTGL ${CMAKE_CURRENT_BINARY_DIR}/libs/pkgconfig)

##########################
#  freeglut
##########################
SET(FREEGLUT_VERSION 2.8.0-1.mp)
SET(FREEGLUT_ZIP "freeglut-MinGW-${FREEGLUT_VERSION}.zip")
SET(FREEGLUT_DOWNLOAD_URL "http://files.transmissionzero.co.uk/software/development/GLUT/${FREEGLUT_ZIP}")
ADD_CUSTOM_COMMAND(OUTPUT ${FREEGLUT_ZIP} COMMAND ${URL_GRAB} ${FREEGLUT_DOWNLOAD_URL})
ADD_CUSTOM_COMMAND(OUTPUT "freeglut/lib" COMMAND ${UNZIP} -x ${FREEGLUT_ZIP} DEPENDS ${FREEGLUT_ZIP})
ADD_CUSTOM_COMMAND(OUTPUT "libs/libfreeglut.a" COMMAND cp "freeglut/lib/*" "libs" COMMAND cp -a freeglut/include/* include DEPENDS "freeglut/lib")
#ADD_CUSTOM_COMMAND(OUTPUT "libs/libfreeglut.a" COMMAND cp "freeglut/bin/freeglut.dll" "freeglut/lib/*" "libs" COMMAND cp -a freeglut/include/* include DEPENDS "freeglut/lib")
ADD_CUSTOM_TARGET(freeglut DEPENDS "libs/libfreeglut.a" )


##########################
# AntTweakBar
##########################
SET(ATB_VERSION 114)
SET(ATB_ZIP "AntTweakBar_${ATB_VERSION}.zip")
SET(ATB_DOWNLOAD_URL "http://www.antisphere.com/Tools/AntTweakBar/${ATB_ZIP}")
ADD_CUSTOM_COMMAND(OUTPUT ${ATB_ZIP} COMMAND ${URL_GRAB} ${ATB_DOWNLOAD_URL})
ADD_CUSTOM_COMMAND(OUTPUT "AntTweakBar/lib" COMMAND ${UNZIP} -x ${ATB_ZIP} DEPENDS ${ATB_ZIP})
ADD_CUSTOM_COMMAND(OUTPUT "libs/AntTweakBar.dll" COMMAND cp "AntTweakBar/lib/*.dll" "libs" COMMAND cp -a AntTweakBar/include/* include DEPENDS "AntTweakBar/lib")
ADD_CUSTOM_TARGET(anttweakbar DEPENDS "libs/AntTweakBar.dll" )


##########################
# ImageMagick
##########################
SET(IM_VERSION 6.5.7)
SET(IM_ZIP "ImageMagick-${IM_VERSION}.tar.gz")
SET(IM_DOWNLOAD_URL "http://www.emsl.pnl.gov/msc-releases/cview-deps/${IM_ZIP}")
ADD_CUSTOM_COMMAND(OUTPUT ${IM_ZIP} COMMAND ${URL_GRAB} -O ${IM_ZIP} ${IM_DOWNLOAD_URL})
ADD_CUSTOM_COMMAND(OUTPUT "ImageMagick-${IM_VERSION}/lib" COMMAND ${TAR} -xmf ${IM_ZIP} DEPENDS ${IM_ZIP})
ADD_CUSTOM_COMMAND(OUTPUT "libs/libMagickWand.a" COMMAND cp -r "ImageMagick-${IM_VERSION}/lib/*" "libs" COMMAND ${RSYNC} -rlpgoD ImageMagick-${IM_VERSION}/include/* include DEPENDS "ImageMagick-${IM_VERSION}/lib")
ADD_CUSTOM_TARGET(imagemagick DEPENDS "libs/libMagickWand.a" )
  

##########################
# freetype2
##########################
SET(FT_VERSION 2.3.11)
SET(FT_ZIP "freetype-${FT_VERSION}.tar.gz")
SET(FT_DOWNLOAD_URL "http://download.savannah.gnu.org/releases/freetype/${FT_ZIP}")
ADD_CUSTOM_COMMAND(OUTPUT ${FT_ZIP} COMMAND ${URL_GRAB} -O ${FT_ZIP} ${FT_DOWNLOAD_URL})
ADD_CUSTOM_COMMAND(OUTPUT "freetype-${FT_VERSION}/configure" COMMAND ${TAR} -xmf ${FT_ZIP} DEPENDS ${FT_ZIP})
ADD_CUSTOM_COMMAND(OUTPUT "freetype-${FT_VERSION}/objs/libfreetype.la" COMMAND ./configure COMMAND make WORKING_DIRECTORY "freetype-${FT_VERSION}" DEPENDS "freetype-${FT_VERSION}/configure")
ADD_CUSTOM_COMMAND(OUTPUT "libs/libfreetype.a" 
					COMMAND cp -r "freetype-${FT_VERSION}/objs/.libs/lib*" "libs" 
					COMMAND ${RSYNC} -rlpgoD freetype-${FT_VERSION}/include/* include 
					COMMAND cp "freetype-${FT_VERSION}/builds/unix/freetype2.pc" libs/pkgconfig 
					DEPENDS "freetype-${FT_VERSION}/objs/libfreetype.la")
ADD_CUSTOM_TARGET(freetype2 DEPENDS "libs/libfreetype.a" )
 

##########################
# ftgl
# this is quite messy, wish we could run confiugre/make properly...
##########################
SET(FTGL_VERSION 2.1.3-rc5)
STRING(REPLACE - ~ FTGL_TVERSION ${FTGL_VERSION})
SET(FTGL_ZIP "ftgl-${FTGL_VERSION}.tar.gz")
SET(FTGL_DOWNLOAD_URL "http://downloads.sourceforge.net/project/ftgl/FTGL%20Source/${FTGL_TVERSION}/${FTGL_ZIP}")
ADD_CUSTOM_COMMAND(OUTPUT ${FTGL_ZIP} COMMAND ${URL_GRAB} -O ${FTGL_ZIP} ${FTGL_DOWNLOAD_URL} )
ADD_CUSTOM_COMMAND(OUTPUT "ftgl-${FTGL_TVERSION}/src/FTGL/ftgl.h" 
					COMMAND ${TAR} -xmf ${FTGL_ZIP} 
					COMMAND patch -p2 -d  "ftgl-${FTGL_TVERSION}/src/" < ${CMAKE_CURRENT_SOURCE_DIR}/ftgl.patch  
					DEPENDS ${FTGL_ZIP})
ADD_CUSTOM_COMMAND(OUTPUT "ftgl-${FTGL_TVERSION}/lib/ftgl.dll" COMMAND ./makeftgl4mingw WORKING_DIRECTORY "ftgl-${FTGL_TVERSION}/src" DEPENDS "ftgl-${FTGL_TVERSION}/src/FTGL/ftgl.h")
ADD_CUSTOM_COMMAND(OUTPUT "libs/ftgl.dll" 
					COMMAND cp -r "ftgl-${FTGL_TVERSION}/src/lib/*" libs 
					COMMAND ${RSYNC} -rlpgoD ftgl-${FTGL_TVERSION}/src/FTGL/ include/FTGL/ 
					COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/ftgl.pc libs/pkgconfig 
					DEPENDS "ftgl-${FTGL_TVERSION}/lib/ftgl.dll")
ADD_CUSTOM_TARGET(ftgl-lib DEPENDS freetype2 "libs/ftgl.dll" )



SET(ENV{PKG_CONFIG_PATH} ${CMAKE_CURRENT_BINARY_DIR}/libs/pkgconfig)
ADD_CUSTOM_TARGET(mingw-libs DEPENDS freeglut anttweakbar imagemagick freetype2 ftgl-lib)
