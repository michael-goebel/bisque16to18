
this_path=$(pwd)/$(dirname "$0")
echo ${this_path}

start=6


packages="
python=2.7.15~rc1-1
python-dev=2.7.15~rc1-1
python-virtualenv=15.1.0+ds-1.1
python-pip=9.0.1-2.3~ubuntu1.18.04.1
python-paver=1.2.1-1.1
libxml2-dev=2.9.4+dfsg1-6.1ubuntu1.3
libxslt1-dev=1.1.29-5ubuntu0.2
libhdf5-dev=1.10.0-patch1+docs-4
mercurial=4.5.3-1ubuntu2.1
git=1:2.17.1-1ubuntu0.6
cmake=3.10.2-1ubuntu2.18.04.1
pkg-config=0.29.1-0ubuntu2
graphviz=2.40.1-2
libgraphviz-dev=2.40.1-2
postgresql=10+190ubuntu0.1
postgresql-client=10+190ubuntu0.1
libsqlite3-dev=3.22.0-1ubuntu0.3
libmysqlclient-dev=5.7.29-0ubuntu0.18.04.1
openslide-tools=3.4.1+dfsg-2
python-openslide=1.1.1-2ubuntu4
libopenslide-dev=3.4.1+dfsg-2
libopenslide0=3.4.1+dfsg-2
libpq-dev=10.12-0ubuntu0.18.04.1
libfftw3-dev=3.3.7-1
libbz2-dev=1.0.6-8.1ubuntu0.2
liblcms2-dev=2.9-1ubuntu0.1
zlib1g-dev=1:1.2.11.dfsg-0ubuntu2
libtiff-dev=4.0.9-5ubuntu0.3
libpng-dev=1.6.34-1ubuntu0.18.04.2
libjpeg62=1:6b2-3
liborc-0.4-0=1:0.4.28-1
liborc-0.4-dev=1:0.4.28-1
qt5-default=5.9.5+dfsg-0ubuntu2.5
qt5-qmake=5.9.5+dfsg-0ubuntu2.5
libtheora0=1.1.1+dfsg.1-14
libtheora-dev=1.1.1+dfsg.1-14
liblzma5=5.2.2-1.3
liblzma-dev=5.2.2-1.3
libbz2-1.0=1.0.6-8.1ubuntu0.2
libbz2-dev=1.0.6-8.1ubuntu0.2
libxvidcore4=2:1.3.5-1
libxvidcore-dev=2:1.3.5-1
libgdcm2.8=2.8.4-1build2
"


bash_appends="
# Added automatically by BisQue installer
export PATH=/usr/local/bin:\$PATH
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
export VIRTUALENVWRAPPER_VIRTUALENV=/usr/bin/virtualenv
source /usr/local/bin/virtualenvwrapper.sh
"





case $start in

1)
	# install system packages
	sudo apt-get install -y ${packages} ;&

2)
	# build openjpeg
	git clone https://github.com/uclouvain/openjpeg
	cd openjpeg && mkdir build && cd build
	cmake .. -DCMAKE_BUILD_TYPE=Release
	sudo make -j4 install && sudo ldconfig && cd ../.. ;&

3)
	# build liboil (required by schroedinger)
	wget https://liboil.freedesktop.org/download/liboil-0.3.13.tar.gz
	tar -xvzf liboil-0.3.13.tar.gz
	cd liboil-0.3.13/ && mkdir build && cd build/ && ../configure
	make && sudo make install && cd ../.. ;&

4)
	# build schroedinger
	wget https://launchpad.net/schroedinger/trunk/1.0.0/+download/schroedinger-1.0.0.tar.gz
	tar -xvzf schroedinger-1.0.0.tar.gz && cd schroedinger-1.0.0/
	mkdir build && cd build/ && ../configure && make
	sudo make install && cd ../.. ;&

5)
	# build imgcnv
	#hg clone --insecure http://biodev.ece.ucsb.edu/hg/imgcnv && cd imgcnv
	#scp mike@128.111.185.28:~/fall_2019/build_bisque4/imgcnv/ubuntu1804.sh .
	cp $(dirname "$0")/ubuntu1804.sh .
	bash ubuntu1804.sh && make -j4 && sudo make install && cd ../
	sudo ln -s /usr/lib/libimgcnv.so.2 /usr/lib/libimgcnv.so && sudo ldconfig ;&

6)
	#echo ${bash_appends}
	# create virtualenv
	#sudo pip install virtualenvwrapper
	#grep -Fxq "Added automatically by BisQue installer" ~/.bashrc
	#grep BisQue ~/.bashrc	
	#grep "${bash_appends}" ~/.bashrc
	first_line=$(echo "${bash_appends}" | head -n 2 | tail -n 1)
	echo ${first_line}


	if grep -Fxq "${first_line}" ~/.bashrc
	then
		echo "bashrc already modified"
	else
		echo "${bash_appends}" >> ~/.bashrc
	fi
	tail ~/.bashrc


	#echo -e 'export PATH=/usr/local/bin:$PATH' >> ~/.bashrc
	#echo -e 'export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python' >> ~/.bashrc
	#echo -e 'export VIRTUALENVWRAPPER_VIRTUALENV=/usr/bin/virtualenv' >> ~/.bashrc
	#echo -e 'source /usr/local/bin/virtualenvwrapper.sh' >> ~/.bashrc
	source ~/.bashrc
	mkvirtualenv -p /usr/bin/python2 bqdev ;&


7)	
	# clone bisque and pip install (there are problems with the biodev index, so reinstall some packages)
	git clone https://github.com/UCSB-VRL/bisque.git && cd bisque-stable
	pip install -i https://biodev.ece.ucsb.edu/py/bisque/xenial/+simple/ -r requirements.txt
	pip install --force-reinstall lxml==3.7.3 orderedset==2.0.1 tables==3.4.2 ;&

8)
	paver setup
	bq-admin setup ;&

esac


