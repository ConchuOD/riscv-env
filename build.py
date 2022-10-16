#! /bin/python3

import argparse
import subprocess
import yaml

class Build:

    def __init__(self, config):
        self.cc = try_default(config, "cc", "ccache clang")
        self.cc_path = try_default(config, "cc_path", "")
        self.llvm = try_default(config, "llvm", 1)
        self.llvm_ias = try_default(config, "llvm_ias", self.llvm)
        self.as_path = try_default(config, "llvm_ias", "")
        self.lld = try_default(config, "lld", self.llvm)
        self.ld_path = try_default(config, "ld", "")
        self.dryrun = False

    def simple_build(self):
        command = [
                    "make",
                    f"LINUX_CC=\"CC={self.cc}\"",
                    f"CLANG={self.llvm}",
                    "tftp-boot-py",
                    "DEVKIT=lowmem"
                  ]

        stdout = ""

        if self.dry_run == True:
            print(command)
            return (0, stdout)

        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            universal_newlines = True
        )

        # spit out stdout so the program seems alive
        while True:

            if process.stdout != None:
                output = process.stdout.readline()
                stdout = stdout + output
                print(output.strip())

            return_code = process.poll()

            if return_code is not None:
                # once done, we need to dump out w/e is left
                for output in process.stdout.readlines():
                    stdout = stdout + output
                    print(output.strip())

                break

        return (process.returncode, stdout)

    def dry_run(self):
        self.dry_run = True

def try_default(config, key, default):
    try:
        return config[key]
    except KeyError:
        return default

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description = 'kbuild helper')

    parser.add_argument('-c', '--config', help = 'yaml config file', default = 'conf/targets.yaml')
    parser.add_argument('-t', '--target', help = 'the target config', default = 'default')
    parser.add_argument('--dry-run', help = "dry run", default = False, action = 'store_true')
    parser.add_argument('--pattern', help = "pattern to match in stderr")

    args = parser.parse_args()

    with open(args.config, 'r') as stream:
        try:
            config = yaml.safe_load(stream)
        except yaml.YAMLError as exc:
            print(exc)

    target_config = config["targets"][args.target]
    build = Build(target_config)

    if args.dry_run == True:
        build.dry_run()

    rc, stdout = build.simple_build()

    if rc != 0:
        print(stdout)
        os.exit()

    if args.pattern != None and args.pattern in stdout:
        print(stdout)


