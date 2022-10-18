[3.1.0] (https://bitbucket.bics-collaboration.homeoffice.gov.uk/projects/SRE/repos/docker-desktop/browse?at=refs%2Ftags%2Fv3.0.2) - 2022-07-18
Added :
- vault:rewrite-secrets moved to demo-app; secrets belong to the demo-app
- aws:temporary:creds parameterised; can be called with AWS_REGION=<region> and AWS_ACCOUNT=np to get creds for region/account

[3.0.1] (https://bitbucket.bics-collaboration.homeoffice.gov.uk/projects/SRE/repos/docker-desktop/browse?at=refs%2Ftags%2Fv3.0.1) - 2022-06-23
Added :
-  vault:rewrite-secrets task to put secrets if it doesn't exists

[3.0.0](https://bitbucket.bics-collaboration.homeoffice.gov.uk/projects/SRE/repos/docker-desktop/browse?at=refs%2Ftags%2Fv3.0.0) - 2022-01-04

Changed:
- Dropped `docker-desktop` for `rancher-desktop`
  - Introducted new variable (`K8S_CONTEXT`), so that you can continue to use `docker-desktop` should you so wish (defaults to `rancher-desktop`)
- Updated README.md; please read pre-requisites before installing, not all tasks can be automated unfortunately

[2.0.0](https://bitbucket.bics-collaboration.homeoffice.gov.uk/projects/SRE/repos/docker-desktop/browse?at=refs%2Ftags%2Fv2.0.0) - 2021-09-02

Changed:
- Dropped Makefile; now using Taskfile - don't forget to install from https://taskfile.dev/#/installation
- Dropped robotshop; robotshop demo app can be installed from demo-app repo
