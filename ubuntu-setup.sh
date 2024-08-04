#!/bin/bash
#
# Script to set up an Ubuntu 22.04+ server
# (with minimum 64GB RAM, 32 threads CPU) for android ROM compiling
#
# Sudo access is mandatory to run this script
#
# IMPORTANT NOTICE: This script sets my personal git config, update
# it with your details before you run this script!
#
# Usage:
#	./ubuntu-setup.sh
#

# Go to home dir
orig_dir=$(pwd)
cd $HOME

echo -e "Installing and updating APT packages...\n"
sudo apt update -qq
sudo apt full-upgrade -y -qq
sudo apt install -y -qq bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs \
                        gnupg gperf imagemagick lib32readline-dev lib32z1-dev libelf-dev liblz4-tool \
                        libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool \
                        squashfs-tools xsltproc zip zlib1g-dev lib32ncurses5-dev libncurses5 libncurses5-dev \
                        zram-config

sudo apt autoremove -y -qq
sudo apt purge snapd -y -qq
echo -e "\nDone."

echo -e "\nInstalling git-repo..."
wget -q https://storage.googleapis.com/git-repo-downloads/repo
chmod a+x repo
sudo install repo /usr/local/bin/repo
rm repo
echo -e "Done."

if [[ $SHELL = *zsh* ]]; then
sh_rc=".zshrc"
else
sh_rc=".bashrc"
fi

echo -e "\nSetting up shell environment..."

cat <<'EOF' >> $sh_rc

# Super-fast repo sync
repofastsync() { time schedtool -B -e ionice -n 0 `which repo` sync -c --force-sync --optimized-fetch --no-tags --no-clone-bundle --retry-fetches=5 -j$(nproc --all) "$@"; }

# List lib dependencies of any lib/bin
list_blob_deps() { readelf -d $1 | grep "\(NEEDED\)" | sed -r "s/.*\[(.*)\]/\1/"; }
alias deps="list_blob_deps"

export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache

#### FILL IN PIXELDRAIN API KEY ####
PD_API_KEY=435e9784-bb04-4c07-9ada-755fafdc9924
####################################
function pdup() {
    [ -z "$1" ] && echo "Error: File not specified!" && return
    ID=$(curl --progress-bar -T "$1" -u :$PD_API_KEY https://pixeldrain.com/api/file/ | cat | grep -Po '(?<="id":")[^"]*')
    echo -e "\nhttps://pixeldrain.com/u/$ID"
}

EOF
echo -e "Done."

# Increase maximum ccache size
mkdir .ccache
ccache -M 50G

# Setup zram
echo -e "\nSetting up zram..."
zram_config="/usr/bin/init-zram-swapping"
cp $zram_config.bak

# Set the compression algorithm to zstd
sed -i '/# initialize the devices/a \
echo "zstd" > /sys/block/zram0/comp_algorithm\n\
' $zram_config

# Optimization of zram configuration parameters
sed -i '/# initialize the devices/i \
sysctl vm.page-cluster=0\n\
sysctl vm.swappiness=100\n\
' $zram_config

echo "Done."

###
### IMPORTANT !!! REPLACE WITH YOUR PERSONAL DETAILS IF NECESSARY
###
# Configure git
echo -e "\nSetting up Git..."
git config --global user.name "chaptsand"
git config --global user.email "chaptsand@gmail.com"
git config --global push.autoSetupRemote true
echo "Done."

# Done!
echo -e "\nALL DONE. Now sync sauces & start baking!"
echo -e "Please relogin or run \`source ~/$sh_rc && source ~/.profile\` for environment changes to take effect."

# Go back to original dir
cd "$orig_dir"
