# Spectrocloud Community Packs
A place for community driven integrations with Spectro Cloud Palette.

This repository is dedicated to Spectrocloud packs that are created and maintained by the Spectro Cloud community.

## How to use packs from this repository
You can
* Setup your own Spectro Cloud pack registry using the instructions provided [here](https://docs.spectrocloud.com/registries-and-packs/adding-a-custom-registry)
* Push the packs to your registry using [these](https://docs.spectrocloud.com/registries-and-packs/spectro-cli-reference) instructions

OR

Use them from the Spectro Cloud public registry on our [SaaS offering](https://www.spectrocloud.com)

## How to collaborate

  *  Create new packs for different k8s addons and applications
  *  Fix and report bugs
  *  Improve pack documentation
  *  Answer questions and discuss in GitHub issues

## Contributing
We welcome contributions of new packs and updates to existing packs. This repository uses a fork and pull model. Here are the steps for becoming a contributor:

  * Clone this repository and create a new branch.
  * In the packs/ directory, add your changes.
  *  If you are adding a new pack, then create a directory having the format <name of the pack>-x.y.z, where x is the major version, y is the minor version and z is the patch version. If your name of the pack has multiple words, use ‘-’ as the separator while naming the top level directory of the pack.
  * Push your pack changes to your private registry and test it in your Palette environment.
  * Push your changes to your fork, then open a pull request against this repository.
  * While opening a pull request, mention the purpose of the pack and the scenarios that have been validated.
  * If you are making changes that address an existing issue, please make a comment in the issue so we can assign it to you. This helps to prevent accidentally doubling up on work.

## Rules for contributors
Your contribution must be your own original work. You may not submit copyrighted content you do not own. Please do not plagiarize.

By contributing to this repository, you agree to abide by the following code of conduct:

* You will not include any content or language that is racist, sexist, homophobic, transphobic, ableist, or otherwise discriminatory or prejudiced in any way.

* You will treat all contributors and users with respect and professionalism.

* You will not engage in any harassment, bullying, or other inappropriate behavior.

* You will uphold the highest ethical standards in your contributions.

Failure to comply with this code of conduct may result in the removal of your contributions and/or revocation of your contributor privileges.

By contributing to this repository, you acknowledge that you have read and agree to abide by this code of conduct.

## Pull Request guidelines
* Be sure to test your functionality by uploading the pack to your own pack registry before raising the pull request.
* Please give a brief account of the pack functionality. You can add usage instructions and document the nuances for using the pack as part of the README.md file within the pack.
* Mention the list of container images being used by your pack as part images section in values.yaml file of the pack. This will help us in identifying the images to run security scans.
* Typically you should get a response within 72 hours of raising your pull request. Make sure you watchout for any review comments and handle them.
* Once your PR is merged, it will be deployed to the Spectro Cloud public pack registry.
* Frequency of pushing to the registry is biweekly and happens on Tuesdays and Thursdays.

## Creating a new pack
Go through the tutorial on how to [Create and Deploy a custom addon pack ](https://docs.spectrocloud.com/registries-and-packs/deploy-pack)

Read more about [packs](https://docs.spectrocloud.com/registries-and-packs)

Understand the packs values constraints, defining dependencies and macros [here](https://docs.spectrocloud.com/registries-and-packs/pack-constraints)

## Disclaimer
Spectro Cloud provides this repository to facilitate collaborations and contributions from the wider community.  However, these packs are not verified by Spectro Cloud.

The content in this repository is provided "as is" without warranty of any kind, either express or implied, including without limitation any implied warranties of condition, uninterrupted use, merchantability, fitness for a particular purpose, or non-infringement.

The authors of this content and Spectro Cloud are not liable for any damages or losses, including but not limited to direct, indirect, special, incidental, or consequential damages, arising out of the use or inability to use the content or any of its derivatives. 
The user assumes all responsibility for the use of this content, including but not limited to, the use of any third-party libraries or services used in this code.
