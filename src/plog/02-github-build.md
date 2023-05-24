---
title: GitHub Build
---
Now with the static site built, the next step I'm working on
is getting the site to build on GitHub. I've pushed the last
commit to GitHub, made a
[repo](https://github.com/GilchristTech/mini230523_s3-cicd),
and am attempting to get the GitHub build workflow working
with as little fuss as possible. This commit also adds a
`README.md`.

First is making a YAML build file in `.github/workflows/`.
For this, I'm re-typing some similar code I wrote a couple
days ago. I had used
[this guide](https://monicagranbois.com/blog/webdev/use-github-actions-to-deploy-11ty-site-to-s3/)
to piece things together, with some changes. Right now, I'm
just putting in the build-related code to see how it works:

```yaml
name: Build

on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]

jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 5

    steps:
      - uses: actions/checkout@v3

      - uses: actions/setup-node@v3
        with:
          node-version: 19
          cache: npm

      - name: Install packages
        run:  npm ci

      - name: Build static site
        run:  npm run build
```
<span style="font-size:0.75em">(I also added an 11ty plugin just for this syntax highlighting.)</span>

One challenging thing with GitHub actions, is that I don't
want to commit erronious code, but in order to see if the
action works, one needs to push a commit to trigger the
build. A Google into this pointed me to this
[Stack Overflow
answer](https://stackoverflow.com/a/74986993), which points
me to
[this project](https://github.com/nektos/act) for running
GitHub actions locally. Let's give it a go!

```bash
$ yay -Syu act
```
....aaaannnd I'm low on space in my non-home partition. <span style=font-size:0.5em>btw I use Arch</span>
```bash
$ sudo pacman -Sc  # clearing out my package cache should do it
$ yay -Syu act
```
While waiting for the package manager to do it's thing and
update all my packages, let's do some irrelevant static site
stuff! This project log's entries should have next/previous
buttons. So let's get those in, if there's time. I already
got shamelessly distracted with the syntax highlighting.

Packages finished doing their thing, and luckily I'm mostly
done with the plog page navigation. Looked up the
[11ty collection next/previous documentation](https://www.11ty.dev/docs/filters/collection-items/). 
Ideally, it would be nice to hide the next and previous and
next buttons on the respective first and last pages, where
there isn't a new page to go to, but it's best I get back to
the task at hand: checking my GitHub action workflow.

<details style="border:1px solid #eee; padding: 8px;">
  <summary>
<span style="font-style:italic; font-size:0.9em;">Click to see the output, if interested</span>

```bash
$ act
```

  </summary>

  ```bash
  ? Please choose the default image you want to use with act:

    - Large size image: +20GB Docker image, includes almost all tools used on GitHub Actions (IMPORTANT: currently only ubuntu-18.04 platform is available)
    - Medium size image: ~500MB, includes only necessary tools to bootstrap actions and aims to be compatible with all actions
    - Micro size image: <200MB, contains only NodeJS required to bootstrap actions, doesn't work with all actions

  Default image and other options can be changed manually in ~/.actrc (please refer to https://github.com/nektos/act#configuration for additional information about file structure) Medium
  [Build/build] 🚀  Start image=catthehacker/ubuntu:act-latest
  [Build/build]   🐳  docker pull image=catthehacker/ubuntu:act-latest platform= username= forcePull=true
  [Build/build]   🐳  docker create image=catthehacker/ubuntu:act-latest platform= entrypoint=["tail" "-f" "/dev/null"] cmd=[]
  [Build/build]   🐳  docker run image=catthehacker/ubuntu:act-latest platform= entrypoint=["tail" "-f" "/dev/null"] cmd=[]
  [Build/build]   ☁  git clone 'https://github.com/actions/setup-node' # ref=v3
  [Build/build] ⭐ Run Main actions/checkout@v3
  [Build/build]   🐳  docker cp src=/home/gill/mini/2305-23/. dst=/home/gill/mini/2305-23
  [Build/build]   ✅  Success - Main actions/checkout@v3
  [Build/build] ⭐ Run Main actions/setup-node@v3
  [Build/build]   🐳  docker cp src=/home/gill/.cache/act/actions-setup-node@v3/ dst=/var/run/act/actions/actions-setup-node@v3/
  [Build/build]   🐳  docker exec cmd=[node /var/run/act/actions/actions-setup-node@v3/dist/setup/index.js] user= workdir=
  [Build/build]   💬  ::debug::isExplicit: 
  [Build/build]   💬  ::debug::explicit? false
  [Build/build]   💬  ::debug::isExplicit: 16.20.0
  [Build/build]   💬  ::debug::explicit? true
  [Build/build]   💬  ::debug::evaluating 0 versions
  [Build/build]   💬  ::debug::match not found
  | Attempting to download 19...
  [Build/build]   💬  ::debug::No manifest cached
  [Build/build]   💬  ::debug::Getting manifest from actions/node-versions@main
  [Build/build]   💬  ::debug::check 20.2.0 satisfies 19
  [Build/build]   💬  ::debug::check 20.1.0 satisfies 19
  [Build/build]   💬  ::debug::check 20.0.0 satisfies 19

  [ ... there were a bunch of these ... ]

  [Build/build]   💬  ::debug::check 8.1.1 satisfies 19
  [Build/build]   💬  ::debug::check 8.1.0 satisfies 19
  [Build/build]   💬  ::debug::check 8.0.0 satisfies 19
  [Build/build]   💬  ::debug::check 6.17.1 satisfies 19
  | Not found in manifest. Falling back to download directly from Node
  [Build/build]   💬  ::debug::evaluating 573 versions
  [Build/build]   💬  ::debug::matched: v19.9.0
  | Acquiring 19.9.0 - x64 from https://nodejs.org/dist/v19.9.0/node-v19.9.0-linux-x64.tar.gz
  [Build/build]   💬  ::debug::Downloading https://nodejs.org/dist/v19.9.0/node-v19.9.0-linux-x64.tar.gz
  [Build/build]   💬  ::debug::Destination /tmp/2ba01b55-7e76-43b7-a935-566f3fd6829a
  [Build/build]   💬  ::debug::download complete
  | Extracting ...
  [Build/build]   💬  ::debug::Checking tar --version
  [Build/build]   💬  ::debug::tar (GNU tar) 1.34%0ACopyright (C) 2021 Free Software Foundation, Inc.%0ALicense GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>.%0AThis is free software: you are free to change and redistribute it.%0AThere is NO WARRANTY, to the extent permitted by law.%0A%0AWritten by John Gilmore and Jay Fenlason.
  | [command]/usr/bin/tar xz --strip 1 --warning=no-unknown-keyword -C /tmp/87767af2-7088-420b-836b-ac2948105775 -f /tmp/2ba01b55-7e76-43b7-a935-566f3fd6829a
  | Adding to the cache ...
  [Build/build]   💬  ::debug::Caching tool node 19.9.0 x64
  [Build/build]   💬  ::debug::source dir: /tmp/87767af2-7088-420b-836b-ac2948105775
  [Build/build]   💬  ::debug::destination /opt/hostedtoolcache/node/19.9.0/x64
  [Build/build]   💬  ::debug::finished caching tool
  | Done
  [Build/build]   ❓  ::group::Environment details
  | node: v19.9.0
  | npm: 9.6.3
  | yarn: 
  [Build/build]   ❓  ::endgroup::
  | [command]/opt/hostedtoolcache/node/19.9.0/x64/bin/npm config get cache
  | /root/.npm
  [Build/build]   💬  ::debug::npm path is /root/.npm
  [Build/build]   💬  ::debug::followSymbolicLinks 'true'
  [Build/build]   💬  ::debug::followSymbolicLinks 'true'
  [Build/build]   💬  ::debug::implicitDescendants 'true'
  [Build/build]   💬  ::debug::matchDirectories 'true'
  [Build/build]   💬  ::debug::omitBrokenSymbolicLinks 'true'
  [Build/build]   💬  ::debug::Search path '/home/gill/mini/2305-23/package-lock.json'
  [Build/build]   💬  ::debug::/home/gill/mini/2305-23/package-lock.json
  [Build/build]   💬  ::debug::Found 1 files to hash.
  [Build/build]   💬  ::debug::primary key is node-cache-Linux-npm-77ec0df9a1e1a666853fb7b97e5dc251d4c3639dc4fbe67d3cff3c8d3f212a00
  [Build/build]   💬  ::debug::Resolved Keys:
  [Build/build]   💬  ::debug::["node-cache-Linux-npm-77ec0df9a1e1a666853fb7b97e5dc251d4c3639dc4fbe67d3cff3c8d3f212a00"]
  [Build/build]   💬  ::debug::Checking zstd --version
  [Build/build]   💬  ::debug::*** zstd command line interface 64-bits v1.4.8, by Yann Collet ***
  [Build/build]   💬  ::debug::Resource Url: http://192.168.1.14:34353/_apis/artifactcache/cache?keys=node-cache-Linux-npm-77ec0df9a1e1a666853fb7b97e5dc251d4c3639dc4fbe67d3cff3c8d3f212a00&version=b3f0cb83629d634645a5146420c017462ebb5229bd60271a7a86e489a6066469
  [Build/build]   💬  ::debug::Failed to delete archive: Error: ENOENT: no such file or directory, unlink ''
  | npm cache is not found
  [Build/build]   ❓ add-matcher /run/act/actions/actions-setup-node@v3/.github/tsc.json
  [Build/build]   ❓ add-matcher /run/act/actions/actions-setup-node@v3/.github/eslint-stylish.json
  [Build/build]   ❓ add-matcher /run/act/actions/actions-setup-node@v3/.github/eslint-compact.json
  [Build/build]   ✅  Success - Main actions/setup-node@v3
  [Build/build]   ⚙  ::set-output:: node-version=v19.9.0
  [Build/build]   ⚙  ::set-output:: cache-hit=false
  [Build/build]   ⚙  ::add-path:: /opt/hostedtoolcache/node/19.9.0/x64/bin
  [Build/build] ⭐ Run Main Install packages
  [Build/build]   🐳  docker exec cmd=[bash --noprofile --norc -e -o pipefail /var/run/act/workflow/2] user= workdir=
  | 
  | added 216 packages, and audited 217 packages in 4s
  | 
  | 40 packages are looking for funding
  |   run `npm fund` for details
  | 
  | found 0 vulnerabilities
  [Build/build]   ✅  Success - Main Install packages
  [Build/build] ⭐ Run Main Build static site
  [Build/build]   🐳  docker exec cmd=[bash --noprofile --norc -e -o pipefail /var/run/act/workflow/3] user= workdir=
  | 
  | > mini230523_s3-cicd@1.0.0 build
  | > eleventy
  | 
  | [11ty] Writing dist/common.css from ./src/common.scss
  | [11ty] Writing dist/index.html from ./src/index.njk
  | [11ty] Writing dist/index.css from ./src/index.scss
  | [11ty] Writing dist/plog/index.html from ./src/plog.njk
  | [11ty] Writing dist/plog.css from ./src/plog.scss
  | [11ty] Writing dist/plog/01-initial-commit/index.html from ./src/plog/01-initial-commit.md (liquid)
  | [11ty] Writing dist/plog/02-github-build/index.html from ./src/plog/02-github-build.md (liquid)
  | [11ty] Copied 2 files / Wrote 7 files in 0.32 seconds (v2.0.1)
  [Build/build]   ✅  Success - Main Build static site
  [Build/build] ⭐ Run Post actions/setup-node@v3
  [Build/build]   🐳  docker exec cmd=[node /var/run/act/actions/actions-setup-node@v3/dist/cache-save/index.js] user= workdir=
  | [command]/opt/hostedtoolcache/node/19.9.0/x64/bin/npm config get cache
  | /root/.npm
  [Build/build]   💬  ::debug::npm path is /root/.npm
  [Build/build]   💬  ::debug::Checking zstd --version
  [Build/build]   💬  ::debug::*** zstd command line interface 64-bits v1.4.8, by Yann Collet ***
  [Build/build]   💬  ::debug::implicitDescendants 'false'
  [Build/build]   💬  ::debug::followSymbolicLinks 'true'
  [Build/build]   💬  ::debug::implicitDescendants 'false'
  [Build/build]   💬  ::debug::omitBrokenSymbolicLinks 'true'
  [Build/build]   💬  ::debug::Search path '/root/.npm'
  [Build/build]   💬  ::debug::Matched: ../../../../root/.npm
  [Build/build]   💬  ::debug::Cache Paths:
  [Build/build]   💬  ::debug::["../../../../root/.npm"]
  [Build/build]   💬  ::debug::Archive Path: /tmp/7db24e4b-65e5-4d54-b335-3c4ed9db9554/cache.tzst
  | [command]/usr/bin/tar --posix --use-compress-program zstdmt -cf cache.tzst --exclude cache.tzst -P -C /home/gill/mini/2305-23 --files-from manifest.txt
  [Build/build]   💬  ::debug::File Size: 7905760
  [Build/build]   💬  ::debug::Reserving Cache
  [Build/build]   💬  ::debug::Resource Url: http://192.168.1.14:34353/_apis/artifactcache/caches
  [Build/build]   💬  ::debug::Saving Cache (ID: 1)
  [Build/build]   💬  ::debug::Upload cache
  [Build/build]   💬  ::debug::Resource Url: http://192.168.1.14:34353/_apis/artifactcache/caches/1
  [Build/build]   💬  ::debug::Upload concurrency: 4
  [Build/build]   💬  ::debug::Upload chunk size: 33554432
  [Build/build]   💬  ::debug::Awaiting all uploads
  [Build/build]   💬  ::debug::Uploading chunk of size 7905760 bytes at offset 0 with content range: bytes 0-7905759/*
  [Build/build]   💬  ::debug::Commiting cache
  | Cache Size: ~8 MB (7905760 B)
  [Build/build]   💬  ::debug::Resource Url: http://192.168.1.14:34353/_apis/artifactcache/caches/1
  | Cache saved successfully
  | Cache saved with the key: node-cache-Linux-npm-77ec0df9a1e1a666853fb7b97e5dc251d4c3639dc4fbe67d3cff3c8d3f212a00
  ```
  <span style="font-size:0.75em">(Funny thing, this looks
  better on web than my terminal, because I haven't
  configured my terminal for emojis.</span>
</details>

Neat! Act seems to have worked, and with no finagling to
boot. Also the GitHub action script seems to be getting to
the build. Let's give a commit a go!
