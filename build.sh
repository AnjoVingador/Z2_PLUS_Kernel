#!/bin/bash
kernel_dir=$PWD
export CONFIG_FILE="z2_plus_defconfig"
export ARCH=arm64
export SUBARCH=arm64
export LOCALVERSION="-ARB"
export KBUILD_BUILD_USER="ST12"
export KBUILD_BUILD_HOST="BLR"
NC='\033[0m'
RED='\033[0;31m'
LGR='\033[1;32m'

export OPT_FLAGS="-O3 -pipe -fvectorize -fslp-vectorize"

# export ARCH_FLAGS="-mtune=cortex-a53"

export POLLY_FLAGS="-mllvm -polly \
				-mllvm -polly-run-dce \
				-mllvm -polly-run-inliner \
				-mllvm -polly-opt-fusion=max \
				-mllvm -polly-ast-use-context \
				-mllvm -polly-vectorizer=stripmine"

export WIPPER_POLLY=" \
				-mllvm -polly-parallel \
				-mllvm -polly-delinearize \
				-mllvm -polly-optimizer=isl \
				-mllvm -enable-polly-aligned \
				-mllvm -polly-allow-nonaffine"

OPT_FLAGS="${OPT_FLAGS} ${POLLY_FLAGS} ${WIPPER_POLLY} ${ARCH_FLAGS}"
export CLANG_TRIPLE="aarch64-linux-gnu-"
export CROSS_COMPILE="${HOME}/build/z2/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-"
export CLANG_TCHAIN="${HOME}/build/z2/dtc-7.0-tmp/out/7.0/bin/clang"
export objdir="${kernel_dir}/out"
export builddir="${kernel_dir}/build"
cd $kernel_dir
make_a_fucking_defconfig() 
{
	# I FUCKING HATE YOU ALL
	rm -rf ${objdir}/arch/arm64/boot/dts/qcom/
	echo -e ${LGR} "############# Generating Defconfig ##############${NC}"
	make -s ARCH="arm64" O=$objdir $CONFIG_FILE -j8
}
compile() 
{
	echo -e ${LGR} "############### Compiling kernel ################${NC}"
	make CC="${CLANG_TCHAIN} ${OPT_FLAGS}" O=$objdir -j8 \
	Image.gz-dtb
}
ramdisk() 
{
	cd ${objdir}
	COMPILED_IMAGE=arch/arm64/boot/Image.gz-dtb
	if [[ -f ${COMPILED_IMAGE} ]]; then
		mv -f ${COMPILED_IMAGE} $builddir/Image.gz-dtb
		echo -e ${LGR} "#################################################"
		echo -e ${LGR} "############### Build competed! #################"
		echo -e ${LGR} "#################################################${NC}"
	else
		echo -e ${RED} "#################################################"
		echo -e ${RED} "# Build fuckedup, check warnings/errors faggot! #"
		echo -e ${RED} "#################################################${NC}"
	fi
}
make_a_fucking_defconfig
compile 
ramdisk
cd ${kernel_dir}
