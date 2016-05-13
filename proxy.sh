#!/bin/sh
set -e

usage () {
  >&2 echo "Usage: proxy [-t bind_port:remote_host:remote_port | -u bind_port:remote_host:remote_port]..."
  >&2 echo "  -t  Forward a TCP port"
  >&2 echo "  -u  Forward a UDP port"
  exit
}

invalid_param () {
  >&2 echo "ERROR: Invalid parameter '$1'"
  exit 1
}

assert_nonempty () {
  if [ -z "$1" ]; then
    return 1
  fi
}

assert_numeric () {
  if echo "$1" | egrep -q '[^0-9]'; then
    return 1
  fi
}

add_service () {
  PROTO=$1
  BIND_PORT=$(echo $2 | cut -d: -f1)
  REMOTE_HOST=$(echo $2 | cut -d: -f2)
  REMOTE_PORT=$(echo $2 | cut -d: -f3)

  assert_nonempty $BIND_PORT \
    && assert_nonempty $REMOTE_HOST \
    && assert_nonempty $REMOTE_PORT \
    && assert_numeric $BIND_PORT \
    && assert_numeric $REMOTE_PORT \
  || invalid_param $2

  SERVICE_NAME=${PROTO}_${BIND_PORT}
  case $PROTO in
    tcp)
      SOCKET_TYPE=stream
      ;;
    udp)
      SOCKET_TYPE=dgram
      ;;
    *)
      >&2 echo "ERROR: Invalid protocol '$PROTO'"
      exit 1
      ;;
  esac

  echo "$SERVICE_NAME $BIND_PORT/$PROTO" >> /etc/services
  echo "$SERVICE_NAME $SOCKET_TYPE $PROTO nowait root /bin/nc nc $REMOTE_HOST $REMOTE_PORT" >> /etc/inetd.conf
}

while [ "$1" != "" ]; do
  case $1 in
    -h | --help)
      usage
      ;;
    -t)
      add_service tcp $2
      shift
      ;;
    -u)
      add_service udp $2
      shift
      ;;
    *)
      invalid_param $1
      ;;
  esac
  shift
done

inetd -f
