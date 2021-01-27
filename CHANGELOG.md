# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2021-01-25
### `Added`
- This CHANGELOG file to hopefully serve as an evolving example of a
  standardized open source project CHANGELOG.
- CNAME file to enable GitHub Pages custom domain
- README now contains answers to common questions about CHANGELOGs
- CODE_OF_CONDUCT now contains answers to common questions about CODE_OF_CONDUCT

### `Security`
- Introducing `gpg` key(s) sharing [build gpg](https://github.com/djanta/djanta-build-gpg.git) to support `org.apache.maven.plugins:maven-gpg-plugin`

### `Fixed`
- Fix external `gpg` secure key sharing throug module [build gpg](https://github.com/djanta/djanta-build-gpg.git) repository
- Fix maven plugin `org.apache.maven.plugins:maven-gpg-plugin` to support shared external credential variable through `github` secret setting for each repository configuration
- Introducing the project explicit name `<name>${project.artifactId}</name>` in order to avoid following ossrh error:
```shell
ossrh deploy (Invalid POM: xxx.pom: Project name missing
```
while releasing or tempting to close the `ossrh` node for release or promoting purpose.

### `Removed`
- Removed using `djanta-java-parent` as root parent and has been switch to `djanta-java-bom`


[Unreleased]: https://github.com/djanta/djanta-maven-plugin/compare/v1.0.0...HEAD
[0.0.2]: https://github.com/djanta/djanta-maven-plugin/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/djanta/djanta-maven-plugin/releases/tag/v1.0.0