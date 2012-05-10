#build dependencies for cview that are not part of GnuStep MinGW downloads
CMAKE_MINIMUM_REQUIRED(VERSION 2.4.5)

SET(EXTRA_PATHS C:/GNUStep/msys/1.0/bin)
FIND_PROGRAM(URL_GRAB NAMES wget curl PATHS ${EXTRA_PATHS})
FIND_PROGRAM(UNZIP NAMES unzip PATHS ${EXTRA_PATHS})
FIND_PROGRAM(TAR NAMES tar PATHS ${EXTRA_PATHS})
FILE(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/libs ${CMAKE_CURRENT_BINARY_DIR}/include)

##########################
#  freeglut
##########################
SET(FREEGLUT_VERSION 2.8.0-1.mp)
SET(FREEGLUT_ZIP "freeglut-MinGW-${FREEGLUT_VERSION}.zip")
SET(FREEGLUT_DOWNLOAD_URL "http://files.transmissionzero.co.uk/software/development/GLUT/${FREEGLUT_ZIP}")
ADD_CUSTOM_COMMAND(OUTPUT ${FREEGLUT_ZIP} COMMAND ${URL_GRAB} ${FREEGLUT_DOWNLOAD_URL})
ADD_CUSTOM_COMMAND(OUTPUT "freeglut/bin" COMMAND ${UNZIP} -x ${FREEGLUT_ZIP} DEPENDS ${FREEGLUT_ZIP})
ADD_CUSTOM_COMMAND(OUTPUT "libs/freeglut.dll" COMMAND cp "freeglut/bin/freeglut.dll" "libs" COMMAND cp -a freeglut/include/* include DEPENDS "freeglut/bin")
ADD_CUSTOM_TARGET(freeglut ALL DEPENDS "libs/freeglut.dll" )


##########################
# AntTweakBar
##########################
SET(ATB_VERSION 114)
SET(ATB_ZIP "AntTweakBar_${ATB_VERSION}.zip")
SET(ATB_DOWNLOAD_URL "http://www.antisphere.com/Tools/AntTweakBar/${ATB_ZIP}")
ADD_CUSTOM_COMMAND(OUTPUT ${ATB_ZIP} COMMAND ${URL_GRAB} ${ATB_DOWNLOAD_URL})
ADD_CUSTOM_COMMAND(OUTPUT "AntTweakBar/lib" COMMAND ${UNZIP} -x ${ATB_ZIP} DEPENDS ${ATB_ZIP})
ADD_CUSTOM_COMMAND(OUTPUT "libs/AntTweakBar.dll" COMMAND cp "AntTweakBar/lib/*.dll" "libs" COMMAND cp -a AntTweakBar/include/* include DEPENDS "AntTweakBar/lib")
ADD_CUSTOM_TARGET(anttweakbar ALL DEPENDS "libs/AntTweakBar.dll" )


##########################
# ImageMagick
##########################
SET(IM_VERSION 6.5.7)
SET(IM_ZIP "ImageMagick-${IM_VERSION}.tar.gz")
SET(IM_DOWNLOAD_URL "${IM_ZIP}")
SET(IM_DOWNLOAD_URL "https://svn.pnl.gov/esp/browser/cview/branches/win32/sources/ImageMagick-6.5.7.tar.gz?format=raw")
ADD_CUSTOM_COMMAND(OUTPUT ${IM_ZIP} COMMAND ${URL_GRAB} -O ${IM_ZIP} ${IM_DOWNLOAD_URL})
ADD_CUSTOM_COMMAND(OUTPUT "ImageMagick-${IM_VERSION}/lib" COMMAND ${TAR} -xf ${IM_ZIP} DEPENDS ${IM_ZIP})
ADD_CUSTOM_COMMAND(OUTPUT "libs/libMagickWand.a" COMMAND cp -r "ImageMagick-${IM_VERSION}/lib/*" "libs" COMMAND cp -a ImageMagick-${IM_VERSION}/include/* include DEPENDS "ImageMagick-${IM_VERSION}/lib")
ADD_CUSTOM_TARGET(imagemagick ALL DEPENDS "libs/libMagickWand.a" )

