# Change log for GPRegistryPolicyDsc

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Added DscResources.Common in submodule instead of GPRegistryPolicyDsc.Common [issue#30](https://github.com/dsccommunity/GPRegistryPolicyDsc/issues/30).

### Removed

- Removed GPRegistryPolicyDsc.Common submodule [issue#30](https://github.com/dsccommunity/GPRegistryPolicyDsc/issues/30) and its pester tests.

### Fixed

- Fixed azure Devops pipeline.

## [1.3.1] - 2023-11-03

### Fixed

- GPRegistryPolicyDsc
  - Fixed the GitHub repository wiki home page.

## [1.3.0] - 2023-11-03

### Changes

- GPRegistryPolicyDsc
  - Updated to latest pipeline files.

### Fixed

- GPRegistryPolicyDsc
  - Fixed REG_MULTI_SZ double null termination issue ([issue #25](https://github.com/dsccommunity/GPRegistryPolicyDsc/issues/25)).

## [1.2.0] - 2020-03-13

### Added

- GPRegistryPolicyDsc
  - Add support to upload coverage to Codecov.io ([issue #16](https://github.com/dsccommunity/GPRegistryPolicyDsc/issues/16)).

### Fixed

- GPRegistryPolicyDsc
  - Update GitVersion.yml with the correct regular expression.
  - Added GPT.ini creation/updating logic in order to properly apply Group Policy.

### Changed

- GPRegistryPolicyDsc
  - Set a display name on all the jobs and tasks in the CI pipeline.
  - Change the Azure Pipelines Microsoft Host Agents to use the image 
    `windows-2019` ([issue #15](https://github.com/dsccommunity/GPRegistryPolicyDsc/issues/15)).

## [1.1.0] - 2020-01-05

### Added

- GPRegistryPolicyDsc
  - Added continuous delivery with a new CI pipeline.

## [1.0.1] - 2019-09-29

- Fixed [#3](https://github.com/dsccommunity/GPRegistryPolicyDsc/issues/3)
- Updated release logic to not include .git folder.

## [1.0.0] - 2019-09-18

- Initial release.
