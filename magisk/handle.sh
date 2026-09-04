#!/system/bin/sh

MODDIR=${0%/*}

# load variables
. $MODDIR/lib.sh

log_cli() {
  echo -e "$1" >> $ZTROOT/run/cli.out
}
log() {
  t=`date +"%m-%d %H:%M:%S.%3N"`
  echo -e "[$t][$$][L] $@" >> $DAEMON_LOG
  log_cli "$@"
}
_stop() {
  pid=`pidof zerotier-one`
  if [[ $? -ne 0 ]]; then
    log "zerotier-one not running"
    return
  fi

  kill -9 $pid
  
  # delete from ip rules
  ip rule del from all lookup main pref 1
  ip -6 rule del from all lookup main pref 1
  
  if [[ $? -ne 0 ]]; then
    log "kill zerotier-one failed"
    return
  fi

  log "stopped zerotier-one"
}
_start() {
  if pidof zerotier-one > /dev/null; then
    log "zerotier-one already running"
  else
    __start
    log "started zerotier-one"
  fi
}
_status() {
  # fake systemd lol
  read pid < $ZTROOT/home/zerotier-one.pid

  if pidof zerotier-one > /dev/null; then
    log_cli "\033[32m●\033[0m zerotier-one.service - ZeroTier One - Global Area Networking"
    log_cli "     Active: \033[32mactive (running)\033[0m"
    log_cli "   Main PID: $pid (zerotier-one)"
  else
    log_cli "○ zerotier-one.service - ZeroTier One - Global Area Networking"
    log_cli "     Active: inactive (dead)"
    log_cli "   Main PID: $pid (code=exited)"
  fi
}
_restart() {
  _stop
  __start
  log "started zerotier-one"
}
_valid_nwid() {
  # network ids are 16 lowercase hex characters
  [ ${#1} -eq 16 ] || return 1
  case "$1" in *[!0-9a-f]*) return 1;; esac
  return 0
}
_netconf_read() {
  # export <nwid>.local.conf to the app so it can be edited there
  nwid=$1
  if ! _valid_nwid "$nwid"; then
    log "netconf read: invalid network id $nwid"
    return
  fi

  mkdir -p $APPROOT/run/netconf
  rm -f $APPROOT/run/netconf/$nwid.current

  if [[ -f "$ZTROOT/home/networks.d/$nwid.local.conf" ]]; then
    cp $ZTROOT/home/networks.d/$nwid.local.conf $APPROOT/run/netconf/$nwid.current
  else
    # empty marker tells the app that no local.conf exists yet
    touch $APPROOT/run/netconf/$nwid.current
  fi
  chmod 666 $APPROOT/run/netconf/$nwid.current
}
_netconf_write() {
  # install a <nwid>.local.conf prepared by the app, used while zerotier-one is not running
  nwid=$1
  if ! _valid_nwid "$nwid"; then
    log "netconf write: invalid network id $nwid"
    return
  fi

  src=$APPROOT/run/netconf/$nwid.pending
  if [[ -f "$src" ]]; then
    mkdir -p $ZTROOT/home/networks.d
    cp $src $ZTROOT/home/networks.d/$nwid.local.conf
    chmod 644 $ZTROOT/home/networks.d/$nwid.local.conf
    log "netconf write: updated $nwid.local.conf"
  else
    log "netconf write: pending file missing for $nwid"
  fi
}

# ----------------------------------------------
#             call from inotifyd
# ----------------------------------------------

if [[ $# == 2 && "$1" == "w" ]]; then
  read cmd < $2
  rm -f $ZTROOT/run/cli.out

  case "$cmd" in
    "start") _start;;
    "stop") _stop;;
    "restart") _restart;;
    "status") _status;;
    "netconf read "*) _netconf_read "${cmd#netconf read }";;
    "netconf write "*) _netconf_write "${cmd#netconf write }";;
    *) log "unknown command $cmd";;
  esac

  if [[ -f "$ZTROOT/run/cli.pid" ]]; then
    read cpid < $ZTROOT/run/cli.pid
    rm -f $ZTROOT/run/cli.pid
    kill -SIGUSR1 $cpid
  fi

  exit 0
fi