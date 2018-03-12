#!/bin/bash
kernel_dir=$PWD
export CONFIG_FILE="z2_plus_defconfig"
export ARCH=arm64
export SUBARCH=arm64
export LOCALVERSION="-R2_0.02"
export KBUILD_BUILD_USER="ST12"
export KBUILD_BUILD_HOST="BLR"
export COMPILER_NAME="DTC-7.0"
red=$(tput setaf 1) # red
grn=$(tput setaf 2) # green
cya=$(tput setaf 6) # cyan

export OPT_FLAGS="-O3 -pipe -fvectorize \
				-fslp-vectorize -freroll-loops -funroll-loops"

export ARCH_FLAGS="-mtune=kryo+fp+simd \
				-mhvx-double -mhvx -marm"

export POLLY_FLAGS="-mllvm -polly \
				-mllvm -polly-run-dce \
				-mllvm -polly-run-inliner \
				-mllvm -polly-opt-fusion=max \
				-mllvm -polly-ast-use-context \
				-mllvm -polly-detect-keep-going \
				-mllvm -polly-vectorizer=stripmine"

export CLANG_TRIPLE="aarch64-linux-gnu-"
export CROSS_COMPILE="${HOME}/build/z2/gcc-8/bin/aarch64-linux-gnu-"
export CLANG_TCHAIN="${HOME}/build/z2/dtc-7.0-tmp/out/7.0/bin/clang"
export objdir="${kernel_dir}/out"
export builddir="${kernel_dir}/build"
cd $kernel_dir
make_a_fucking_defconfig() 
{
	# I FUCKING HATE YOU ALL
	rm -rf ${objdir}/arch/arm64/boot/dts/qcom/
	echo -e ${grn} "############# Generating Defconfig ##############"
	echo -e ${cya}  "";
	make -s ARCH="arm64" O=$objdir $CONFIG_FILE -j8
}
compile() 
{
	echo -e ${grn} "############### Compiling kernel ################"
	make -s CC="${CLANG_TCHAIN}" O=$objdir -j8 \
	OPT_FLAGS="${OPT_FLAGS} ${ARCH_FLAGS} ${POLLY_FLAGS}" \
	Image.gz-dtb
	echo -e ${cya}  "";
}
ramdisk() 
{
	cd ${objdir}
	COMPILED_IMAGE=arch/arm64/boot/Image.gz-dtb
	if [[ -f ${COMPILED_IMAGE} ]]; then
		mv -f ${COMPILED_IMAGE} $builddir/Image.gz-dtb
		echo -e ${grn} "#################################################"
		echo -e ${grn} "############### Build competed! #################"
		echo -e ${grn} "#################################################"
	else
		echo -e ${red} "#################################################"
		echo -e ${red} "# Build fuckedup, check warnings/errors faggot! #"
		echo -e ${red} "#################################################"
	fi
	echo -e ${cya}  "";
}
make_a_fucking_defconfig
compile 
ramdisk
cd ${kernel_dir}