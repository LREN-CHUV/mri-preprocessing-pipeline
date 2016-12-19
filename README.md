
[![License](https://img.shields.io/badge/license-AGPL--3.0-blue.svg)](https://www.gnu.org/licenses/agpl-3.0.html)

# MRI preprocesing pipeline

## Git branches

* master: for normal development of the pipelines
* deploy: for deployment of the pipelines to a Data Factory.

All commits on the deploy branch should be signed with PGP by an authorised developer.
Use

```
   git checkout deploy
   git merge --no-ff master
```

to merge code from master branch to deploy branch.
Add a signoff in file signoff.md, then

```
  git commit -S -m "Signoff"
  git tag -s 1.0
```

to add a signoff and allow deployment of the pipeline to the Data Factories.
It is best practice to tag with signing the version ready for deployment with a release number.

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
