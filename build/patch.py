import os
import toml

# Android API level, used to name the NDK clang wrapper (aarch64-linux-android<api>-clang)
android_api = os.environ.get('ANDROID_API_VERSION', '28')

# Patch ZeroTierOne/rustybits/zeroidc/Cargo.toml

# > +ZeroTierOne/rustybits/zeroidc/Cargo.toml
# [dependencies]
# openssl-sys = {version = ">=0.9", features = ["vendored"]}

cargo_toml_path = "ZeroTierOne/rustybits/zeroidc/Cargo.toml"
cargo_toml = toml.load(cargo_toml_path)
cargo_toml['dependencies']['openssl-sys'] = { 'version': ">=0.9", 'features': ["vendored"] }
with open(cargo_toml_path, 'w') as f:
    toml.dump(cargo_toml, f)

# -------------------------------------------------------------------------------------------------------

# Patch ZeroTierOne/rustybits/zeroidc/.cargo/config.toml

# > +ZeroTierOne/rustybits/zeroidc/.cargo/config.toml
# [target.aarch64-unknown-linux-gnu]
# linker = "aarch64-linux-gnu-gcc"
# [target.aarch64-linux-android]
# linker = "aarch64-linux-android<api>-clang"

config_toml_path = "ZeroTierOne/rustybits/zeroidc/.cargo/config.toml"
config_toml = toml.load(config_toml_path)
config_toml['target']['aarch64-unknown-linux-gnu'] = { "linker": "aarch64-linux-gnu-gcc" }
config_toml['target']['aarch64-linux-android'] = { "linker": "aarch64-linux-android%s-clang" % android_api }
with open(config_toml_path, 'w') as f:
    toml.dump(config_toml, f)

# -------------------------------------------------------------------------------------------------------

# Patch ZeroTierOne/osdep/LinuxEthernetTap.cpp

linux_tap_path = 'ZeroTierOne/osdep/LinuxEthernetTap.cpp'

linux_tap_match1 = 'int rc = pthread_setaffinity_np(self, sizeof(cpu_set_t), &cpuset);'
# bionic (NDK) has no pthread_setaffinity_np -> sched_setaffinity + pthread_gettid_np
# glibc (GCC toolchains) has no pthread_gettid_np -> keep upstream pthread_setaffinity_np
linux_tap_replace1 = '\n'.join((
    '#if defined(__ANDROID__)',
    'int rc = sched_setaffinity(pthread_gettid_np(self), sizeof(cpu_set_t), &cpuset);',
    '#else',
    'int rc = pthread_setaffinity_np(self, sizeof(cpu_set_t), &cpuset);',
    '#endif',
))

linux_tap_match2 = '#include <sys/utsname.h>'
linux_tap_replace2 = '#include <sys/utsname.h>\n#include <sched.h>'

with open(linux_tap_path, 'r') as file: 
    data = file.read()
    patch_NDK = data.replace(linux_tap_match1, linux_tap_replace1).replace(linux_tap_match2, linux_tap_replace2)

with open(linux_tap_path, 'w') as file:
    file.write(patch_NDK)

# -------------------------------------------------------------------------------------------------------

# Patch make-linux.mk

make_linux_path = 'ZeroTierOne/make-linux.mk'
with open(make_linux_path, 'r') as file: 
    data = file.read() 
    patch_aarch64 = data.replace(
                        '$(ZT_CARGO_FLAGS)', '$(ZT_CARGO_FLAGS) --target aarch64-unknown-linux-gnu --quiet'
                    ).replace(
                        'rustybits/target/release/libzeroidc.a', 'rustybits/target/aarch64-unknown-linux-gnu/release/libzeroidc.a'
                    )
    patch_arm = data.replace(
                        "$(shell $(CC) -dumpmachine | cut -d '-' -f 1)", 'armhf'
                    ).replace(
                        'override CFLAGS+=-mfloat-abi=hard -march=armv6zk -marm -mfpu=vfp -mno-unaligned-access -mtp=cp15 -mcpu=arm1176jzf-s',
                        'override CFLAGS+=-mfloat-abi=hard -march=armv7-a -marm -mfpu=vfp'
                    ).replace(
                        'override CXXFLAGS+=-mfloat-abi=hard -march=armv6zk -marm -mfpu=vfp -fexceptions -mno-unaligned-access -mtp=cp15 -mcpu=arm1176jzf-s',
                        'override CXXFLAGS+=-mfloat-abi=hard -march=armv7-a -marm -mfpu=vfp -fexceptions'
                    )
    patch_arm_ndk = data.replace(
                        "$(shell $(CC) -dumpmachine | cut -d '-' -f 1)", 'armhf'
                    ).replace(
                        'override CFLAGS+=-mfloat-abi=hard -march=armv6zk -marm -mfpu=vfp -mno-unaligned-access -mtp=cp15 -mcpu=arm1176jzf-s',
                        'override CFLAGS+=-march=armv7-a -marm -mfpu=vfp'
                    ).replace(
                        'override CXXFLAGS+=-mfloat-abi=hard -march=armv6zk -marm -mfpu=vfp -fexceptions -mno-unaligned-access -mtp=cp15 -mcpu=arm1176jzf-s',
                        'override CXXFLAGS+=-march=armv7-a -marm -mfpu=vfp -fexceptions'
                    )
    # NDK + SSO(zeroidc): cargo builds for Android. rustc packs native static libs into a
    # staticlib by default (link modifier +bundle), so the vendored OpenSSL (libssl.a /
    # libcrypto.a) is already inside libzeroidc.a -- and Android has no libssl/libcrypto
    # to link against anyway, so dropping -lssl -lcrypto is required here.
    patch_ndk_sso = data.replace(
                        '$(ZT_CARGO_FLAGS)', '$(ZT_CARGO_FLAGS) --target aarch64-linux-android --quiet'
                    ).replace(
                        'rustybits/target/debug/libzeroidc.a', 'rustybits/target/aarch64-linux-android/debug/libzeroidc.a'
                    ).replace(
                        'rustybits/target/release/libzeroidc.a', 'rustybits/target/aarch64-linux-android/release/libzeroidc.a'
                    ).replace(
                        'libzeroidc.a -ldl -lssl -lcrypto', 'libzeroidc.a -ldl'
                    )
    
with open(make_linux_path + '.aarch64', 'w') as file:
    file.write(patch_aarch64)
with open(make_linux_path + '.arm', 'w') as file:
    file.write(patch_arm)
with open(make_linux_path + '.ndk.sso', 'w') as file:
    file.write(patch_ndk_sso)
with open(make_linux_path + '.arm.ndk', 'w') as file:
    file.write(patch_arm_ndk)

# Patch ZeroTierOne/osdep/OSUtils.cpp

osutil_path = 'ZeroTierOne/osdep/OSUtils.cpp'
with open(osutil_path, 'r') as file: 
    data = file.read().replace('/var/lib/zerotier-one', '/data/adb/zerotier/home')
with open(osutil_path, 'w') as file:
    file.write(data)