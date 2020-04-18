
this_path=$(pwd)/$(dirname "$0")

verbose=false
start=1

while getopts ":vs:" opt; do
	case ${opt} in
		v ) verbose=true;;
		s ) start=$OPTARG;;
                \? ) echo "Invalid opetion: $OPTARG" 1>&2; exit 0;;
		h )
			echo "Usage"
			echo "    -h                Display this message"
			echo "    -v                Print outputs when building packages"
			echo "    -s [n]            Skip to step number [n]"
			exit 0;;
	esac
done	

if [ ${verbose} == "true" ]; then out=/dev/stdout; else out=/dev/null; fi

step_prefix='\n\n\n\n'

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

bashrc_appends="
# Added automatically by BisQue installer
export PATH=/usr/local/bin:\$PATH
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
export VIRTUALENVWRAPPER_VIRTUALENV=/usr/bin/virtualenv
source /usr/local/bin/virtualenvwrapper.sh
"



case $start in

1)
	echo -e ${step_prefix}"STEP 1, install system packages"
	sudo apt-get install -y ${packages};&

2)
	echo -e ${step_prefix}"STEP 2, install openjpeg"
	if [ ! -d openjpeg ]; then git clone https://github.com/uclouvain/openjpeg; fi
	cd openjpeg && mkdir -p build && cd build
	cmake .. -DCMAKE_BUILD_TYPE=Release > ${out}
	sudo make install > ${out} && sudo ldconfig && cd ../.. ;&

3)
	echo -e ${step_prefix}"STEP 3, install liboil (requirement of schroedinger)"
	wget -nc https://liboil.freedesktop.org/download/liboil-0.3.13.tar.gz
	tar --skip-old-files -xzf liboil-0.3.13.tar.gz
	cd liboil-0.3.13/ && mkdir -p build && cd build/ && ../configure > ${out}
	make > ${out} && sudo make install > ${out} && cd ../.. ;&

4)
	echo -e ${step_prefix}"STEP 4, install schroedinger"
	wget -nc https://launchpad.net/schroedinger/trunk/1.0.0/+download/schroedinger-1.0.0.tar.gz
	tar --skip-old-files -xzf schroedinger-1.0.0.tar.gz
	cd schroedinger-1.0.0/ && mkdir -p build && cd build/ && ../configure > ${out}
	make > ${out} && sudo make install > ${out} && cd ../.. ;&

5)
	echo -e ${step_prefix}"STEP 5, install imgcnv"
	if [ ! -d imgcnv ]; then hg clone --insecure http://biodev.ece.ucsb.edu/hg/imgcnv; fi
	cd imgcnv && cp $(dirname "$0")/ubuntu1804.sh .
	bash ubuntu1804.sh && make -j4 > ${out} && sudo make install > ${out} && cd ../
	sudo ln -s /usr/lib/libimgcnv.so.2 /usr/lib/libimgcnv.so && sudo ldconfig ;&

6)
	echo -e ${step_prefix}"STEP 6, set up virtualenv"
	first_line=$(echo "${bashrc_appends}" | head -n 2 | tail -n 1)
	if grep -Fxq "${first_line}" ~/.bashrc
	then echo "bashrc already modified"
	else echo "${bashrc_appends}" >> ~/.bashrc
	fi
	source /usr/local/bin/virtualenvwrapper.sh
	source ~/.bashrc
	mkvirtualenv -p /usr/bin/python2 bqdev ;&

7)	
	echo -e ${step_prefix}"STEP 7, clone BisQue and install pip packages"
	if [ ! -d bisque-stable ]; then git clone https://github.com/UCSB-VRL/bisque.git; fi
	cd bisque-stable
	source /usr/local/bin/virtualenvwrapper.sh && workon bqdev
	pip install -i https://biodev.ece.ucsb.edu/py/bisque/xenial/+simple/ -r requirements.txt
	pip install --force-reinstall lxml==3.7.3 orderedset==2.0.1 tables==3.4.2
	wget -nc https://raw.githubusercontent.com/python/cpython/b1d867f14965e2369d31a3fcdab5bca34b4d81b4/Lib/cgi.py
	sudo rm /usr/lib/python2.7/cgi.py && sudo mv cgi.py /usr/lib/python2.7 ;&


8)
	echo -e ${step_prefix}"STEP 8, setup BisQue"
	paver setup
	bq-admin setup ;&
	
esac


echo "

Installation script has finished. If successful, run:

    workon bqdev
    cd bisque-stable
    bq-admin server start

Then open a browser to the address:

    localhost:8080

"



