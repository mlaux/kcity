# magick -font FindersKeepers -pointsize 16 label:abcde test.png
import subprocess

def main():

  for ch in range(32, 128):
    label = chr(ch)
    if ch == ord(' '):
      subprocess.run(['convert -size 8x8 xc:white ch032.png'], shell=True)
      continue
    elif ch == ord('\\'):
      label = '\\\\'
    subprocess.run([
      "magick",
      "-font",
      "FindersKeepers",
      "-pointsize",
      "16",
      f"label:{label}",
      "-bordercolor",
      "white",
      "-border",
      "1",
      "-crop", "+0+4", "+repage",
      "-crop", "+1+0", "+repage",
      #"-crop", "+0-1", "+repage",
      #"-trim", "+repage",
      #"-gravity", "northwest", 
      "-extent", "8x8",
      f"ch{ch:03d}.png"
    ])

  subprocess.run([
    "montage ch*.png +set label -tile 16x -geometry 8x8+0+0 geneva.png"
  ], shell=True)

if __name__ == '__main__':
  main()
