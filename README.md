
[![License](https://img.shields.io/badge/license-AGPL--3.0-blue.svg)](https://www.gnu.org/licenses/agpl-3.0.html) [![CHUV](https://img.shields.io/badge/CHUV-LREN-AF4C64.svg)](https://www.unil.ch/lren/en/home.html)

# MRI preprocesing pipeline

Pre-processing pipelines for MRI neuroimaging.

Those pipelines work on Matlab and [SPM 12](http://www.fil.ion.ucl.ac.uk/spm).

They are used daily by [LREN](https://www.unil.ch/lren/en/home.html) to extract features from subjects enrolled in neuroscience research studies.

In addition, those pipelines will be deployed to hospitals participating in the [Medical Informatics platform](https://mip.humanbrainproject.eu) of the [Human Brain Project](https://humanbrainproject.eu) to process clinical MRI scans.

## Release process

This project is organised around two Git branches:

* master: for normal development of the pipelines
* deploy: for deployment of the pipelines to a Data Factory.

All commits on the deploy branch should be signed with PGP by an authorised developer.
Use

```
   git checkout deploy
   git merge --no-ff master
```

to merge code from master branch to deploy branch.
Add a signoff in file signoffs.md, then

```
  git commit -S -m "Signoff" signoffs.md
  git tag -s 1.0
```

to add a signoff and allow deployment of the pipeline to the Data Factories.
It is best practice to tag with signing the version ready for deployment with a release number.

More information about GPG and verified Git commits can be found on this [Git signing guide](https://developers.yubico.com/PGP/Git_signing.html).

After release, merge the changes on deploy branch back to master branch:

```
  git checkout master
  git merge deploy
```

## Deployment

As Git signing is used, to deploy a new version of mri-preprocessing-pipeline on a target computer,
you need to:

1. For the user running the pipelines (airflow user if you use the default Data Factory settings),
   you need to create a PGP key.
2. Then for each trusted release managers of this project, you need add trust to this PGP key.

Trusted release managers are currently (31/03/2017):

* Ludovic Claude \<ludovic.claude54@googlemail.com\>, PGP key fingerprint
* Mirco Nasuti \<mirco.nasuti@chuv.ch\>, PGP key fingerprint C498B2898A53B394BECBDDDEED29A425D7F848B3

## License

Copyright © 2016 LREN CHUV

Licensed under the GNU Affero General Public License, Version 3.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   [https://www.gnu.org/licenses/agpl-3.0.html](https://www.gnu.org/licenses/agpl-3.0.html)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
