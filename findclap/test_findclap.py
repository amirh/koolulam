from findclap import find_clap

import unittest

class TestFindClap(unittest.TestCase):
    def test_find_clap(self):
        expected_clap_position = 8.2627
        clap_position = find_clap('testdata/1.wav')
        self.assertAlmostEqual(clap_position, expected_clap_position, delta=0.001)

if __name__ == '__main__':
    unittest.main()