Slinky Containers
=================

`SchedMD <https://www.schedmd.com/>`__ provides the images in the
containers repository primarily for use with
`Slinky <https://slinky.ai/>`__ - to enable the orchestration of
`Slurm <https://slurm.schedmd.com/>`__ clusters using
`Kubernetes <https://kubernetes.io/>`__. These
`OCI <https://opencontainers.org/>`__ container images track
`Slurm <https://slurm.schedmd.com/>`__ releases closely.

Image Registries
----------------

OCI artifacts are pushed to public registries:

- `GitHub <https://github.com/orgs/SlinkyProject/packages>`__

Build Slurm Images
------------------

.. code:: sh

   export BAKE_IMPORTS="--file ./docker-bake.hcl --file ./$VERSION/$FLAVOR/slurm.hcl"
   cd ./schedmd/slurm/
   docker bake $BAKE_IMPORTS --print
   docker bake $BAKE_IMPORTS

For example, the following will build Slurm 25.11 on Rocky Linux 9.

.. code:: sh

   export BAKE_IMPORTS="--file ./docker-bake.hcl --file ./25.11/rockylinux9/slurm.hcl"
   cd ./schedmd/slurm/
   docker bake $BAKE_IMPORTS --print
   docker bake $BAKE_IMPORTS

For additional instructions, see the `build guide <build.html>`__.

Support and Development
-----------------------

Feature requests, code contributions, and bug reports are welcome!

Github/Gitlab submitted issues and PRs/MRs are handled on a best effort
basis.

The SchedMD official issue tracker is at https://support.schedmd.com/.

To schedule a demo or simply to reach out, please `contact
SchedMD <https://www.schedmd.com/slurm-resources/contact-schedmd/>`__.

License
-------

Copyright (C) SchedMD LLC.

Licensed under the `Apache License, Version
2.0 <http://www.apache.org/licenses/LICENSE-2.0>`__ you may not use
project except in compliance with the license.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an “AS IS” BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

.. raw:: html

   <!-- Links -->

.. toctree::
    :maxdepth: 2
    :hidden:

    build.md
