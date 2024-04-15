#####################
# xray Customization
#####################

SKIPUNZIP=1
ASH_STANDALONE=1
module_path="/data/adb/xray"

VKSEL=chooseport

installCore() {
    case "$1" in
    xray)
        sed -i 's/coreType: .*/coreType: xray/g' ${module_path}/xrayhelper.yml
        sed -i 's/corePath: .*/corePath: \/data\/adb\/xray\/bin\/xray/g' ${module_path}/xrayhelper.yml
        sed -i 's/coreConfig: .*/coreConfig: \/data\/adb\/xray\/confs\//g' ${module_path}/xrayhelper.yml
        ui_print "- Release geodata asset"
        mkdir -p ${module_path}/etc/data
        unzip -j -o "${ZIPFILE}" 'xray/etc/data/*' -d ${module_path}/data >&2
        ui_print "- Release Core"
        unzip -j -o "${ZIPFILE}" "xray/bin/${ARCH}/xray" -d ${module_path}/bin >&2
        ;;
    esac
}

installModule() {
    ui_print "- Install xrayhelper"
    mkdir -p ${module_path}/bin
    unzip -j -o "${ZIPFILE}" "xray/bin/${ARCH}/xrayhelper" -d ${module_path}/bin >&2
    set_perm ${module_path}/bin/xrayhelper 0 0 0755
    set_perm ${module_path}/bin/xray 0 0 0755
    [ -f ${module_path}/xrayhelper.yml ] ||
        unzip -j -o "${ZIPFILE}" 'xray/etc/xrayhelper.yml' -d ${module_path} >&2

    ui_print "- Release configs"
    unzip -j -o "${ZIPFILE}" 'xray/etc/v2ray.v5.json' -d ${module_path} >&2
    if [ ! -d ${module_path}/confs ]; then
        mkdir -p ${module_path}/confs
        unzip -j -o "${ZIPFILE}" 'xray/etc/confs/proxy.json' -d ${module_path}/confs >&2
    fi
    unzip -j -o "${ZIPFILE}" 'xray/etc/confs/base.json' -d ${module_path}/confs >&2
    unzip -j -o "${ZIPFILE}" 'xray/etc/confs/dns.json' -d ${module_path}/confs >&2
    unzip -j -o "${ZIPFILE}" 'xray/etc/confs/policy.json' -d ${module_path}/confs >&2
    unzip -j -o "${ZIPFILE}" 'xray/etc/confs/routing.json' -d ${module_path}/confs >&2
    if [ ! -d ${module_path}/singconfs ]; then
        mkdir -p ${module_path}/singconfs
        unzip -j -o "${ZIPFILE}" 'xray/etc/singconfs/proxy.json' -d ${module_path}/singconfs >&2
    fi
    unzip -j -o "${ZIPFILE}" 'xray/etc/singconfs/base.json' -d ${module_path}/singconfs >&2
    unzip -j -o "${ZIPFILE}" 'xray/etc/singconfs/dns.json' -d ${module_path}/singconfs >&2
    unzip -j -o "${ZIPFILE}" 'xray/etc/singconfs/route.json' -d ${module_path}/singconfs >&2
    if [ ! -d ${module_path}/mihomoconfs ]; then
        mkdir -p ${module_path}/mihomoconfs
    fi
    unzip -j -o "${ZIPFILE}" 'xray/etc/mihomoconfs/template.yaml' -d ${module_path}/mihomoconfs >&2

    if [ -f /sdcard/xray4magisk.setup ]; then
        installCore $(head -1 /sdcard/xray4magisk.setup)
    else
        installCore xray
    fi
    ui_print "- Release scripts"
    mkdir -p ${module_path}/run
    mkdir -p ${module_path}/scripts
    unzip -j -o "${ZIPFILE}" 'xray/scripts/*' -d ${module_path}/scripts >&2
    if [ ! -d /data/adb/service.d ]; then
        mkdir -p /data/adb/service.d
    fi
    unzip -j -o "${ZIPFILE}" 'xray4magisk_service.sh' -d /data/adb/service.d >&2
    unzip -j -o "${ZIPFILE}" 'uninstall.sh' -d $MODPATH >&2

    ui_print "- Set permission"
    set_perm /data/adb/service.d/xray4magisk_service.sh 0 0 0755
    set_perm $MODPATH/uninstall.sh 0 0 0755
    set_perm_recursive ${module_path}/scripts 0 0 0755 0755
    set_perm ${module_path} 0 0 0755
    unzip -j -o "${ZIPFILE}" "module.prop" -d $MODPATH >&2
}

main() {
    if [ ! $BOOTMODE ]; then
        abort "Error: Please install in Magisk Manager or KernelSU Manager"
    fi
    if [ ! -d ${module_path} ]; then
        mkdir -p ${module_path}
    fi
    unzip -j -o "${ZIPFILE}" "xray/bin/${ARCH}/keycheck" -d ${TMPDIR} >&2
    set_perm ${TMPDIR}/keycheck 0 0 0755
    installModule
}

main
