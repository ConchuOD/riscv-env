#! /bin/python3

import argparse
import re
import subprocess
import yaml

class Build:

    def __init__(self, config):
        self.cc = try_default(config, "cc", "ccache clang")
        self.cc_path = try_default(config, "cc_path", "")
        self.llvm = try_default(config, "llvm", 1)
        self.llvm_ias = try_default(config, "llvm_ias", self.llvm)
        self.as_path = try_default(config, "as_path", None)
        self.ld_path = try_default(config, "ld_path", None)
        self.llvm_version = try_default(config, "llvm_version", 15)
        self.gcc_version = try_default(config, "gcc_version", 12)
        self.type = try_default(config, "type", "tftp-boot")
        self.devkit = try_default(config, "devkit", "lowmem")
        self.dryrun = False

    def simple_build(self):
        command = [
                    "make",
                    f"LINUX_CC=\"CC={self.cc}\"",
                    f"GCC_VERSION={self.gcc_version}",
                    f"LLVM_VERSION={self.llvm_version}",
                    f"LINUX_IAS=\"LLVM_IAS={self.llvm_ias}\"",
                    f"CLANG={self.llvm}",
                    f"{self.type}",
                    f"DEVKIT={self.devkit}"
                  ]

        if self.ld_path != None:
            command.append(f"LINUX_LD=\"LD={self.ld_path}\"")
        if self.as_path != None:
            command.append(f"LINUX_AS=\"AS={self.as_path}\"")

        stdout = []

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
                stdout.append(output)
                print(output.strip())

            return_code = process.poll()

            if return_code is not None:
                # once done, we need to dump out w/e is left
                for output in process.stdout.readlines():
                    stdout.append(output)
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

    if args.pattern != None:
        print(f"pattern matches for {args.pattern}:\n")
        lines = len(stdout)
        matches = 0
        for line in stdout:
            match = re.search(args.pattern, line)
            if match:
                matches = matches + 1
                print(line.strip())
        print(f"{matches} matches in {lines} lines")

