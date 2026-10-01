"""Print PNG IHDR info."""
import struct
import sys

with open(sys.argv[1], 'rb') as f:
    d = f.read(64)
print(d[:8])
ln, typ = struct.unpack('>I4s', d[8:16])
w, h, bd, ct = struct.unpack('>IIBB', d[16:26])
print('IHDR', w, h, 'bitdepth', bd, 'colortype', ct)
