#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/llvm/llvm-project"
__dirname="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL_TEST="clang --version"

fail() {
	echo -e "asdf-llvm: $*"
	exit 1
}

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^llvmorg-//'
}

list_all_versions() {
	list_github_tags
}

llvm_archive_name() {
	local version="$1"
	local os arch

	case "$(uname -s)" in
		Linux) os="Linux" ;;
		Darwin) os="macOS" ;;
		*) fail "Unsupported OS: $(uname -s)" ;;
	esac

	case "$(uname -m)" in
		x86_64|amd64) arch="X64" ;;
		aarch64|arm64) arch="ARM64" ;;
		*) fail "Unsupported arch: $(uname -m)" ;;
	esac

	echo "LLVM-${version}-${os}-${arch}.tar.xz"
}

download_prebuilt_release() {
	local version output_file remote_name url
	version="$1"
	output_file="$2"

	remote_name="$(llvm_archive_name "$version")"
	url="$GH_REPO/releases/download/llvmorg-${version}/${remote_name}"

	echo "* Downloading LLVM prebuilt $remote_name..."
	if ! curl "${curl_opts[@]}" -o "$output_file" -C - "$url"; then
		return 1
	fi
}

download_source_release() {
	local version output_file url
	version="$1"
	output_file="$2"

	url="$GH_REPO/archive/llvmorg-${version}.tar.gz"

	echo "* Downloading LLVM source $version..."
	curl "${curl_opts[@]}" -o "$output_file" -C - "$url" || fail "Could not download $url"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}"
	local bin_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-llvm supports release installs only"
	fi

	(
		mkdir -p "$install_path"
		cd "$ASDF_DOWNLOAD_PATH"

		local archive
		archive="$(llvm_archive_name "$version")"

		if [ -f "$archive" ]; then
			tar -xJf "$archive" -C "$install_path" --strip-components=1 || fail "Could not extract $archive"
			rm -f "$archive"
		else
			# Build from source and install all tools
			cmake -S llvm -B build -G Ninja \
				-DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra' \
				-DLLVM_BUILD_RUNTIME="OFF" \
				-DBUILD_SHARED_LIBS="OFF" \
				-DCMAKE_INSTALL_PREFIX="$install_path" \
				-DCMAKE_BUILD_TYPE=Release
			ninja -C build install
			rm -rf "$ASDF_DOWNLOAD_PATH"
		fi

		# Validate installation
		test -d "$bin_path" || fail "Expected $bin_path to exist after installation."
		if [ -n "${TOOL_TEST:-}" ]; then
			local tool_cmd
			tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
			test -x "$bin_path/$tool_cmd" || fail "Expected $bin_path/$tool_cmd to be executable."
		fi

		echo "llvm $version installation was successful!"
	) || (
		rm -rf "$install_path"
		rm -rf "$ASDF_DOWNLOAD_PATH"
		fail "An error occurred while installing llvm $version."
	)
}
