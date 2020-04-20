# This file makes changes to several files to compile on Ubuntu 18.04.4 LTS.
# All changes are done using replace and instert functions defined near the top.
# The functions use vi in command line mode (ex).
# Run the following commands:
#
#    bash ubuntu1804.sh
#    make full -j4
#    sudo make install
#



TAB=$'\t'
NEWLINE=$'\n'
replace () { ex -s -c "${line_num}d" -c "${line_num}i|${new_line}" -c x ${file}; }
insert () { ex -s -c "${line_num}i|${new_line}${NEWLINE}" -c x ${file}; }


# This script copies the original makefile into a backup called "old_makefile".
# This is a check in the case that this script is run multiple times. If it has not been copied, do so.
if [ -f 'old_makefile' ];
then
    cp 'old_makefile' 'Makefile'
else
    cp 'Makefile' 'old_makefile'
fi


# Put paranethesis around variables
file='Makefile'
old_line='PKG_CONFIG_PATH=$LIBVPX/vpx.pc:$LIBX264/x264.pc:$LIBX265/build/linux/x265.pc'
new_line='PKG_CONFIG_PATH=$(PWD)/$(LIBVPX)/:$(PWD)/$(LIBX264)/:$(PWD)/$(LIBX265)/build/linux/'
line_num=15
replace

# change .sh to .pl, .sh file does not exist but .pl does
file='Makefile'
old_line=${TAB}'(cd $(LIBVPX); chmod -f u+x build/make/rtcd.sh)'
new_line=${TAB}'(cd $(LIBVPX); chmod -f u+x build/make/rtcd.pl)'
line_num=65
replace

# change c++ standard to 98
file='Makefile'
old_line=${TAB}'(cd $(LIBX265)/build/linux; cmake -G "Unix Makefiles" ../../source -DCMAKE_CXX_FLAGS=-fPIC -DCMAKE_C_FLAGS=-fPIC )'
new_line=${TAB}'(cd $(LIBX265)/build/linux; cmake -G "Unix Makefiles" ../../source -DCMAKE_CXX_FLAGS="-fPIC -std=c++98" -DCMAKE_C_FLAGS=-fPIC )'
line_num=88
replace

# copy all x265 library files (.pc, etc) not just .a
file='Makefile'
old_line=${TAB}'(cp $(LIBX265)/build/linux/libx265.a $(LIBS)/)'
new_line=${TAB}'(cp $(LIBX265)/build/linux/*265* $(LIBS)/)'
line_num=90
replace

# added line to modify permissions on shell file
file='Makefile'
new_line=${TAB}'(cd $(LIBJPEGTURBO); chmod -f u+x simd/nasm_lt.sh)'
line_num=98
insert

# change enable-pic to with-pic
file='Makefile'
old_line=${TAB}'(cd $(LIBJPEGTURBO); ./configure --enable-pic --enable-static --enable-shared=no )'
new_line=${TAB}'(cd $(LIBJPEGTURBO); ./configure --with-pic --enable-static --enable-shared=no )'
line_num=99
replace

# export pkg-config path
file='Makefile'
old_line=${TAB}'(cd $(FFMPEG)/ffmpeg-obj; ../ffmpeg/configure \'
new_line=${TAB}'(export PKG_CONFIG_PATH=$(PKG_CONFIG_PATH); cd $(FFMPEG)/ffmpeg-obj; ../ffmpeg/configure \'
line_num=117
replace

# stdbool.h not imported
file='libsrc/libx265/source/x265.h'
old_line=' '
new_line='#include <stdbool.h>'
line_num=26
replace

# export PKG_CONFIG_PATH
file='Makefile'
old_line=${TAB}'(cd $(FFMPEG)/ffmpeg-obj; ../ffmpeg/configure \'
new_line=${TAB}'(cd $(FFMPEG)/ffmpeg-obj; export PKG_CONFIG_PATH=$(PKG_CONFIG_PATH); ../ffmpeg/configure \'
line_num=117
replace

# The next four changes add the x265 build path to ffmpeg search path
file='Makefile'
old_line=${TAB}${TAB}'--extra-cflags="-fPIC -I../../libvpx -I../../libx264 -I../../libx265/source" \'
new_line=${TAB}${TAB}'--extra-cflags="-fPIC -I../../libvpx -I../../libx264 -I../../libx265/source -I../../libx265/build/linux" \'
line_num=120
replace

file='Makefile'
old_line=${TAB}${TAB}'--extra-cxxflags="-fPIC -I../../libvpx -I../../libx264 -I../../libx265/source" \'
new_line=${TAB}${TAB}'--extra-cxxflags="-fPIC -I../../libvpx -I../../libx264 -I../../libx265/source -I../../libx265/build/linux" \'
line_num=121
replace

# Error between perl versions 2.25 and 2.26, the first brace needed to be escaped
file='libsrc/ffmpeg/ffmpeg/doc/texi2pod.pl'
old_line=${TAB}'s/\@anchor{(?:[^\}]*)\}//g;'
new_line=${TAB}'s/\@anchor\{(?:[^\}]*)\}//g;'
line_num=387
replace

# The next four lines add libraries to the end of the include paths on command line
file='src/imgcnv.pro'
old_line='    LIBS += -lpthread -lxvidcore -lopenjpeg -lschroedinger-1.0 -ltheora -ltheoraenc -ltheoradec'
new_line='    LIBS += -lpthread -lxvidcore -lopenjp2 -lschroedinger-1.0 -ltheora -ltheoraenc -ltheoradec -llzma -lfftw3 -lbz2 -ldl'
line_num=279
replace

file='src/imgcnv.pro'
old_line='  }'
new_line='    LIBS += -lpthread -lxvidcore -lopenjp2 -lschroedinger-1.0 -ltheora -ltheoraenc -ltheoradec -llzma -lfftw3 -lbz2 -ldl }'
line_num=319
replace

file='src_dylib/libimgcnv.pro'
old_line='    LIBS += -lpthread -lxvidcore -lopenjpeg -lschroedinger-1.0 -ltheora -ltheoraenc -ltheoradec'
new_line='    LIBS += -lpthread -lxvidcore -lopenjp2 -lschroedinger-1.0 -ltheora -ltheoraenc -ltheoradec -llzma -lfftw3 -lbz2 -ldl'
line_num=280
replace

file='src_dylib/libimgcnv.pro'
old_line='  }'
new_line='    LIBS += -lpthread -lxvidcore -lopenjp2 -lschroedinger-1.0 -ltheora -ltheoraenc -ltheoradec -llzma -lfftw3 -lbz2 -ldl }'
line_num=320
replace

