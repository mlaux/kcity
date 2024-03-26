# magick -font FindersKeepers -pointsize 16 label:abcde test.png
# trim 3 from top, 1 from right, 1 from bottom
import subprocess

def main():
  widths = []

  for ch in range(33, 128):
    label = chr(ch)
    if ch == ord('\\'):
      label = '\\\\'
    subprocess.run([
      "magick",
      "-font",
      "FindersKeepers",
      "-pointsize",
      "16",
      f"label:{label}",
      "-crop", "+0+3", "+repage",
      "-crop", "-1+0", "+repage",
      "-crop", "+0-1", "+repage",
      f"{ch}.png"
    ])
    out = subprocess.run([
      "identify",
      "-ping",
      "-format",
      "%w",
      f"{ch}.png"
    ], capture_output=True)
    widths.append(int(out.stdout))
  print(widths)

if __name__ == '__main__':
  main()
