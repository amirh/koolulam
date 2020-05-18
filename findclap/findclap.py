import scipy.io.wavfile as siow
import sys

def find_clap(filepath):
     samplerate, data = siow.read(filepath)
     max_pos = data.argmax(0)
     clap_pos_seconds = max_pos[0] / samplerate
     return clap_pos_seconds

if __name__ == '__main__':
    filename = sys.argv[1]
    clap_pos = find_clap(filename)
    print(clap_pos)