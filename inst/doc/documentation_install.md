# SUNFLO installation instructions (Linux Ubuntu 14.04 LTS)

## Install VLE+RECORD

### simulation platform
```
# download VLE
git clone https://github.com/vle-forge/vle.git
cd vle/
git checkout -b v1.1.2 v1.1.2

# install the dependencies
sudo apt-get install cmake g++ libgtkmm-2.4-dev libglademm-2.4-dev \
  libgtksourceview2.0-dev libboost1.55-dev libboost-serialization1.55-dev \
  libboost-date-time1.55-dev libboost-filesystem1.55-dev \
  libboost-test1.55-dev libboost-regex1.55-dev \
  libboost-program-options1.55-dev libboost-thread1.55-dev \
  libboost-chrono1.55-dev libarchive-dev libqt4-dev

# build vle
cd vle
mkdir build
cd build

cmake -DWITH_GTKSOURCEVIEW=ON -DWITH_GTK=ON -DWITH_CAIRO=ON -DWITH_MPI=OFF \
      -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo              \
      -DCMAKE_INSTALL_PREFIX=/usr ..
      
make -j 4
cpack -G DEB
sudo  dpkg -i vle-1.1-Linux-i686.deb
```

### simulation and system packages
```
echo 'vle.remote.url=http://www.vle-project.org/pub/1.1,http://recordb.toulouse.inra.fr/distributions/1.1' >> ~/.vle/vle.conf
vle -R update
vle --remote update
vle --remote install vle.extension.difference-equation
vle --remote install vle.output
vle --remote install meteo
```

### R interface package
```
# download RVLE
git clone https://github.com/vle-forge/rvle.git
cd rvle/
git checkout -b v1.1.2 v1.1.2
cd ..
R CMD INSTALL rvle
```


## Install sunflo model
```
git clone http://mulcyber.toulouse.inra.fr/anonscm/git/sunrise/sunrise.git sunflo
cd sunflo
git checkout -b v1.3 v1.3
vle -P commun configure build install
vle -P sunflo configure build install
vle -P sunflo_itk configure build install
vle -P sunflo_bio configure build install
vle -P sunflo_diag configure build install
vle -P sunflo_climat configure build install
```

## Install rsunflo R package
```
# install.packages("devtools")
devtools::install_github("picasa/rsunflo")
```