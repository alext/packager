# Tips

## debuild arguments

Additional arguments can be passed to `build_source.rb`/`debuild` by using
the environment variable `DEBUILD_ARGS`.

### Unsigned source packages

Useful for testing packages locally before rebuilding for submission:
```
DEBUILD_ARGS="-uc -us" ./build_source.rb pkg/foo
```
Options "-uc -us": Build only the binary package(s) without signing the .changes file

### Sign against a different GPG key

Useful if your GPG key email address differs from the changelog entry:
```
DEBUILD_ARGS="-k12345678" ./build_source.rb pkg/foo
```

### Uploading tar files

A successful upload can be rejected if tar.gz can't be found in the
upload or distribution. A particular email you would get for the same
would be like

    Rejected:
    Unable to find foo.orig.tar.gz in upload or distribution.
    Files specified in DSC are broken or missing, skipping package unpack verification.

To fix this you can use -sa which uploads .tar.gz along the .changes
```
DEBUILD_ARGS="-sa" ./build_source.rb pkg/foo
```


## sbuild

### Inspect a failed build

Instruct `sbuild` to not purge the build directory or chroot session:
```
sbuild --purge never --purge-session never [...]
```

List the available sessions:
```
vagrant@packager:~/packager$ schroot -l --all-sessions
session:precise-amd64-7c376c42-0b8d-49ac-abb2-0dd659a11551
```

Attach to the session and look in the `/build` directory:
```
vagrant@packager:~/packager$ schroot -rc precise-amd64-7c376c42-0b8d-49ac-abb2-0dd659a11551
(precise-amd64)vagrant@packager:~/packager$ ls -al /build
total 12
drwxrws--- 1 sbuild  sbuild 4096 May 14 16:09 .
drwxr-xr-x 1 root    root   4096 May 14 16:09 ..
drwxr-x--- 4 vagrant sbuild 4096 May 14 16:14 foo-E8JFbs
```

Delete it afterwards:
```
vagrant@packager:~/packager$ schroot -ec precise-amd64-7c376c42-0b8d-49ac-abb2-0dd659a11551
```

## Testing

For testing on lucid/precise boxes you can add a temporary json to your vcloud-template.
example: machines/tester/lucid.json

        {
            "role":             "lucid",
            "class":            "tester",
            "zone":             "tester",
            "vm_name":          "lucid",
            "ip":               "10.11.12.14",
            "box_dist":         "lucid"
        }

You can add a temporary class in puppet to get this up and running: modules/govuk/manifests/node/s_tester.pp

        class govuk::tester {
          include apt
        }

To test and install packages, drop the packages in vagrant-govuk folder, example: debs/abc.deb. This would
make your packages available at /vagrant/<path> example: /vagrant/debs/abc.deb.
