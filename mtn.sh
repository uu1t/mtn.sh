#!/usr/bin/env bash
set -e

usage_exit() {
  echo "
Usage:
  mtn.sh [options] <file>...

Options:
  -c <n_columns>  # of columns [default: 3]
  -o <suffix>     Output filename suffix [default: _s.jpg]
  -r <n_rows>     # of rows. Setting positive value overrides -s option [default: 0]
  -s <step>       Time step between each shot in second [default: 120]
  -w <width>      Width of total output image in px [default: 1024]
  -h              Show this screen
"
  exit $1
}

hhmmss() {
  printf "%02d:%02d:%02d" $(($1 / 3600)) $(($1 / 60 % 60)) $(($1 % 60))
}

main() {
  local input="$1"
  local duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input")
  duration=${duration%.*}

  local n_thumbnails
  local step=$base_step
  if [[ $n_rows -gt 0 ]]; then
    n_thumbnails=$(($n_columns * $n_rows))
    step=$(($duration / $n_thumbnails))
  else
    n_thumbnails=$(($duration / $base_step))
  fi
  local offset=$(($step / 2))

  local lockfile=$(mktemp "$workdir/tmp.XXXXXXXXXX")
  printf "Extract thumbnails from $input"

  local n pos label
  for ((i=0; i<$n_thumbnails; i++)); do
    n=$(printf '%06d' $i)
    pos=$(($step * $i + $offset))
    ffmpeg -ss $pos -i "$input" -vf scale=$each_width:-1 -frames:v 1 -loglevel error -y "$lockfile.t_$n.jpg"

    label=$(hhmmss pos)
    convert "$lockfile.t_$n.jpg" -gravity SouthEast -font TrebuchetMSI -pointsize 16 \
      -stroke '#000C' -strokewidth 2 -annotate +4+0 $label \
      -stroke none    -fill '#eee'   -annotate +4+0 $label \
      "$lockfile.l_$n.jpg"

    printf '.'
  done

  local output="${input%.*}${suffix}"
  printf "\nCreate $output\n"
  montage "$lockfile.l_*.jpg" -tile ${n_columns}x -geometry +0+0 "$output"
}

declare n_columns=3
declare suffix=_s.jpg
declare n_rows=0
declare base_step=120
declare width=1024

while getopts c:o:r:s:w:h OPT; do
  case $OPT in
    c)
      if [[ $OPTARG -le 0 ]]; then
        echo "invalid argument -- -c $OPTARG: Must be > 0"
        exit 1
      fi
      n_columns=$OPTARG
      ;;
    o)
      suffix=$OPTARG
      ;;
    r)
      if [[ $OPTARG -lt 0 ]]; then
        echo "invalid argument -- -r $OPTARG: Must be >= 0"
        exit 1
      fi
      n_rows=$OPTARG
      ;;
    s)
      if [[ $OPTARG -le 0 ]]; then
        echo "invalid argument -- -s $OPTARG: Must be > 0"
        exit 1
      fi
      base_step=$OPTARG
      ;;
    w)
      if [[ $OPTARG -le 0 ]]; then
        echo "invalid argument -- -w $OPTARG: Must be > 0"
        exit 1
      fi
      width=$OPTARG
      ;;
    h)
      usage_exit 0
      ;;
    \?)
      usage_exit 1
      ;;
    esac
done

readonly each_width=$(($width / $n_columns))
if [[ $each_width -le 0 ]]; then
  "invalid argument -- -c or -w: # of columns is too big or width is too small"
  exit 1
fi

shift $((OPTIND - 1))

if [[ $# -lt 1 ]]; then
  usage_exit 1
fi

readonly workdir="$(mktemp -d)"
trap "rm -rf $workdir" EXIT

for f in "$@"; do
  main "$f"
done

