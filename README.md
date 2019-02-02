# mtn.sh

> A Bash script to create thumbnails from videos, alternative to [kwent/mtn](https://github.com/kwent/mtn)

# Requirements

The following executables are installed in `$PATH`.

- ffmpeg (`ffmpeg` and `ffprobe`)
- imagemagick (`montage`)

# Installation

Add [mtn.sh](mtn.sh) to `$PATH`.

# Usage

```
Usage:
  mtn.sh [options] <file>...

Options:
  -c <n_columns>  # of columns [default: 3]
  -o <suffix>     Output filename suffix [default: _s.jpg]
  -r <n_rows>     # of rows. Setting positive value overrides -s option [default: 0]
  -s <step>       Time step between each shot in second [default: 120]
  -w <width>      Width of total output image in px [default: 1024]
  -h              Show this screen
```

# License

MIT
