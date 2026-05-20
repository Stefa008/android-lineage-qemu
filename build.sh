#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
sudo apt update
sudo apt install -y sudo git android-sdk-platform-tools python-is-python3 python3-yaml qemu-utils
sudo apt install -y bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg
sudo apt install -y meson-1.5 glslang-tools python3-mako
git config --global user.name "github-actions[bot]"
git config --global user.email "github-actions[bot]@users.noreply.github.com"
git config --global trailer.changeid.key "Change-Id"
git config --global color.ui true
git lfs install
unset REPO_URL
mkdir -p bin android/lineage
curl https://storage.googleapis.com/git-repo-downloads/repo > bin/repo
chmod a+x bin/repo
export PATH="$(realpath .)/bin:$PATH"
cd android/lineage
export PATH="$(realpath .)/prebuilts/sdk/tools/linux/bin/:$PATH"
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs --no-clone-bundle
repo sync -j 8

# === APPLICAZIONE CONFIGURAZIONE 128 GB ===
find device/ -name "BoardConfig*.mk" -exec sed -i 's/BOARD_SUPER_PARTITION_SIZE := .*/BOARD_SUPER_PARTITION_SIZE := 137438953472/g' {} +
find device/ -name "BoardConfig*.mk" -exec sed -i 's/BOARD_LINEAGE_DYNAMIC_PARTITIONS_SIZE := .*/BOARD_LINEAGE_DYNAMIC_PARTITIONS_SIZE := 137434759168/g' {} +
# ==========================================

sed -i 's/-$(LINEAGE_BUILDTYPE)/-jqssun/g' vendor/lineage/config/version.mk

source build/envsetup.sh
export AB_OTA_UPDATER=false ROOMSERVICE_BRANCHES="lineage-23.1 lineage-23.0"
breakfast virtio_arm64only
echo "CONFIG_RTC_CLASS=y" >> kernel/virt/virtio/arch/arm64/configs/lineageos/virtio.config

breakfast virtio_arm64only userdebug
m recoveryimage
mv out/target/product/virtio_arm64only/recovery.img ../../recovery-userdebug.img
breakfast virtio_arm64only user
m vm-utm-zip otapackage
