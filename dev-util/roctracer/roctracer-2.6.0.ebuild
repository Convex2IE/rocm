# Copyright
#

EAPI=6

DESCRIPTION=""
HOMEPAGE="https://github.com/ROCmSoftwarePlatform/roctracer.git"
SRC_URI="https://github.com/ROCm-Developer-Tools/roctracer/archive/roc-2.6.0.tar.gz -> rocm-tracer-${PV}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug"

RDEPEND="dev-libs/rocr-runtime
	 sys-devel/llvm-roc"
DEPEND="dev-util/cmake
	dev-lang/python:2.7
	${RDPEND}"

#PATCHES=(
#        "${FILESDIR}/python.patch"
#)

src_unpack() {
	unpack ${A}
	mv roctracer-roc-2.6.0 roctracer-${PV}

	git clone https://github.com/ROCmSoftwarePlatform/hsa-class.git ${S}/test/hsa
	cd ${S}/test/hsa
	git fetch origin && git checkout 7defb6d;
}

src_prepare() {
	eapply "${FILESDIR}/python.patch"

#	sed -e "s:set ( CMAKE_INSTALL_PREFIX \${CMAKE_INSTALL_PREFIX}/\${ROCTRACER_NAME} ):#set ( CMAKE_INSTALL_PREFIX \${CMAKE_INSTALL_PREFIX}/\${ROCTRACER_NAME} ):" -i ${S}/CMakeLists.txt
#	sed -e "s:install ( TARGETS \${ROCTRACER_TARGET} LIBRARY DESTINATION lib ):install ( TARGETS ${ROCTRACER_TARGET} LIBRARY DESTINATION lib64 ):" -i ${S}/CMakeLists.txt
	sed -e "s:execute_process ( COMMAND sh -xc \"if:#execute_process ( COMMAND sh -xc \"if:" -i ${S}/test/CMakeLists.txt

	sed -e "s:GFXIP=\$(:GFXIP=gfx803 #\$:" -i ${S}/test/hsa/script/build_kernel.sh
	sed -e "s:/opt/rocm/opencl/bin/x86_64/clang:/usr/lib/llvm/roc-2.6.0/bin/clang:"  -i ${S}/test/hsa/script/build_kernel.sh
	sed -e "s:/opt/rocm/opencl/include/opencl-c.h:/usr/lib/llvm/roc-2.6.0/lib/clang/9.0.0/include/opencl-c.h:" -i ${S}/test/hsa/script/build_kernel.sh
	sed -e "s:/opt/rocm/opencl/lib/x86_64/bitcode/opencl.amdgcn.bc:/usr/lib/opencl.amdgcn.bc:" -i ${S}/test/hsa/script/build_kernel.sh
	sed -e "s:/opt/rocm/opencl/lib/x86_64/bitcode/ockl.amdgcn.bc:/usr/lib/ockl.amdgcn.bc:" -i ${S}/test/hsa/script/build_kernel.sh

	eapply_user
}

src_configure() {
	mkdir -p "${WORKDIR}/build/"
	cd "${WORKDIR}/build/"

	export CMAKE_PREFIX_PATH=/usr/include/hsa:/usr/lib/

	if use debug; then
		export CMAKE_BUILD_TYPE=debug
#		export CMAKE_DEBUG_TRACE=1
#		export CMAKE_LD_AQLPROFILE=1
	fi

	cmake -DCMAKE_INSTALL_PREFIX="${EPREFIX}/opt/rocm"  ${S}
}

src_compile() {
	cd "${WORKDIR}/build/"
	make
}

src_install() {
	cd "${WORKDIR}/build/"
	emake DESTDIR="${D}" install
}
