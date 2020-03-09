#!/usr/bin/python3
import sys
import unittest
import os
import tempfile
import shutil
import glob
import time
import subprocess
import hashlib

# PYCOMPAT
import six
try:
    from StringIO import StringIO
except:
    from io import StringIO


class SosRunTests(unittest.TestCase):
    @classmethod
    def run_sosreport(self):
        try:
            subprocess.check_call(['sosreport', '--batch',
                                   '--tmp-dir', '%s' % self.workdir],
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE)
        except subprocess.CalledProcessError as err:
            self.fail('sosreport Error : %s' % err)

    @classmethod
    def locate_tarball(self):
        self.tarball = None
        for self.path, self.names, self.filename in os.walk(self.workdir):
            if self.path == self.workdir:
                if len(self.filename) > 0:
                    if self.filename[0].endswith('md5'):
                        self.tarball = self.filename[0].strip('.md5')
                    else:
                        self.tarball = self.filename[0]

    @classmethod
    def setUpClass(self):
        self.artifact_dir = os.environ.get("ADT_ARTIFACTS")
        self.workdir = tempfile.mkdtemp()
        self.run_sosreport()
        self.locate_tarball()

        assert (self.artifact_dir is not None), "ADT_ARTIFACTS undefined"

    @classmethod
    def tearDownClass(self):
        shutil.rmtree(self.workdir)

    def _add_artifact(self, artifact):
        if os.path.exists(artifact):
            shutil.copy(artifact, self.artifact_dir)

    def _test_tarball_presence(self):
        if self.tarball:
            pass
        else:
            self.fail('Missing tarball')

    def test_extract_tarball(self):
        try:
            if self.tarball is not None:
                subprocess.check_call(['tar', '-C', '%s' % self.workdir,
                                      '-xf', '%s' % os.path.join(
                                       self.workdir, self.tarball)],
                                      stdout=subprocess.PIPE,
                                      stderr=subprocess.PIPE)
            else:
                raise FileNotFoundError('No tarball found')
        except subprocess.CalledProcessError as err:
            self.fail('Extract Error : %s' % err)

    def test_check_run_errors(self):
        self.test_extract_tarball()
        self.error_logs = glob.glob("%s/*errors.txt" % os.path.join(
                                    self.workdir, self.tarball.split('.')[0],
                                    'sos_logs'))
        if self.error_logs:
            print("Execution logs found in sos_logs. Please investigate : %s" %
                  self.error_logs)
            self._add_artifact(self.error_logs[0])
            raise AssertionError

    def test_md5_checksum(self):
        with open(os.path.join(self.workdir, self.tarball), 'rb') as report:
            checksum = hashlib.md5(report.read()).hexdigest()

        with open(os.path.join(
                  self.workdir, self.tarball + '.md5'), 'r') as md5sum:
            calculated_md5 = md5sum.readline().strip()

        try:
            self.assertEqual(checksum, calculated_md5)
        except AssertionError:
            self._add_artifact(os.path.join(self.workdir, self.tarball))
            self._add_artifact(os.path.join(
                               self.workdir, self.tarball + '.md5'))
            raise


if __name__ == "__main__":
    unittest.main(verbosity=0)

# vim: et ts=4 sw=4
