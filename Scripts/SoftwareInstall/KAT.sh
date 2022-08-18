##python
export PATH=/share/apps/python-3.9.5-shared/bin:$PATH
export LD_LIBRARY_PATH=/share/apps/python-3.9.5-shared/lib:$LD_LIBRARY_PATH


git clone https://github.com/TGAC/KAT.git
cd KAT/
./build_boost.sh 
./autogen.sh 
./configure --prefix /SAN/ugi/StalkieGenomics/software/KAT
