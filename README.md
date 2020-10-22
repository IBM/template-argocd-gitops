# Continuous Deployment with Argo CD and IBM Multi Cloud Manager

This repository contains a sample app configuration to use as a reference for configuring a helm repo deployment via Continuous Delivery (CD) using GitOps. There are samples for both [Argo CD](https://argoproj.github.io/argo-cd/)  and [IBM Multi Cloud Manager]()

## IBM Multi Cloud Manager

IBM Multi Cloud Manager will enable SRE and IT operations to remotely manage the entire development, security and operations pipelines from a single control plane. Automation delivers the operational efficiency and application resiliency necessary to ensure business continuity and continuous innovation.

For more information on how to manage Continuous Delivery of applications
 with MCM see the details documented here [Configure Applications with MCM
 ](./templates/app-mcm/README.md)

## ArgoCD

ArgoCD is an open source tool that has been 
created to enable declarative GitOps Continuous Delivery on container platforms. It fully supports IBM Kubernetes Services 
and Red Hat OpenShift.

Argo CD follows the GitOps pattern of using Git repositories as the source of truth for defining the desired application 
state. Kubernetes manifests can be specified in several ways:

1. [kustomize](https://kustomize.io/) applications
2. [helm](https://helm.sh/) charts
3. Plain directory of YAML/json manifests
4. Any custom config management tool configured as a config management plugin

Argo CD automates the deployment of the desired application states in the specified target environments. Application 
deployments can track updates to branches, tags, or pinned to a specific version of manifests at a Git commit. See 
tracking strategies for additional details about the different tracking strategies available.

## Prerequisites

The provided sample assumes the following components are already available:

1. Helm repository containing versioned artifacts

    The helm repository is used as the source of the base configuration for the application deployment.

2. ArgoCD instance

## Configuring an application

### Configuring the GitOps repository for an application

The following steps are required for each application that will be deployed by ArgoCD:

1. Copy `templates/app-helm` into the root of the repository and name the folder after the application that 
will be installed
2. Update `{directory}/Chart.yaml`
     - Set `name` value to the directory name
     - Update `description` value with a brief descrption of the application
3. Update `{directory}/requirements.yaml`
     - Set `name` value to the helm chart name
     - Set `repository` value to the helm repository url
4. Update `{directory}/values.yaml`
     - Replace `<app-chart-name>` with the helm chart name
     - Add any application-specific configuration under the heading

### Configuring the GitOps repository for a secret

The following steps will set up the configuration for a set of secrets to be generated using the [Key Protect plugin](https://github.com/ibm-garage-cloud/argocd-plugin-key-protect):

1. Copy `templates/secrets-plugin` into the root of the repository and give the folder a name that represents the collection of secrets
2. Update `secret.yaml` with the name and values section for values that should be created in the Secret. The structure and purpose of the configuration values is as follows:

    ```yaml
    apiVersion: keymanagement.ibm/v1
    kind: SecretTemplate
    metadata:
      name: mysecret
      annotations:
        key-manager: key-protect
        key-protect/instanceId: instance-id
        key-protect/region: us-east
    spec:
      labels: {}
      annotations: {}
      values:
        - name: url
          value: https://ibm.com
        - name: username
          b64value: dGVhbS1jYXA=
        - name: password
          keyId: 36397b07-d98d-4c0b-bd7a-d6c290163684
    ``` 
    
    - The `metadata.annotations` value is optional. 
    
        - `key-manager` - the only value supported currently is `key-protect`
        - `key-protect/instanceId` - the instance id of the key protect instance. If not provided then the `instance-id` value from the `key-protect-access` secret will be used.
        - `key-protect/region` - the region where the key protect instance has been provisioned. If not provided then the `region` value from the `key-protect-access` secret will be used.
        
    - The `metadata.name` value given will be used as the name for the Secret that will be generated.
    - The information in `spec.labels` and `spec.annotations` will be copied over as the `labels` and `annotations` in the Secret that is generated
    - The `spec.values` section contains the information that should be provided in the `data` section of the generated Secret. There are three prossible ways the values can be provided:
    
        - `value` - the actual value can be provided directly as clear text. This would be appropriate for information that is not sensitive but is required in the secret
        - `b64value` - a base64 encoded value can be provided to the secret. This can be used for large values that might present formatting issues or for information that is not sensitive but that might be obfuscated a bit (like a username)
        - `keyId` - the id (not the name) of the Standard Key that has been stored in Key Protect. The value stored in Key Protect can be anything


## Creating ArgoCD projects and applications

Components deployed by ArgoCD are called Applications. Applications can
be grouped into projects. These components can be defined via the ArgoCD
user interface, the ArgoCD CLI, or via custom resources for the ArgoCD 
operator.

### ArgoCD CLI

- Create a project

```shell script
argocd proj create {PROJECT} --dest {CLUSTER_HOST},{NAMESPACE} --src {GIT_REPO}
```

where:
- `{PROJECT}` is the name you want to give to the project
- `{CLUSTER_HOST}` is the url for the cluster server to which the project applications can be deployed. 
Use https://kubernetes.default.svc to reference the same cluster where ArgoCD has been deployed. "*" can also
be used to allow deployments to any server
- `{NAMESPACE}` is the namespace in the cluster where the applications can be deployed. "*" can be used to indicate any
namespace
- `{GIT_REPO}` is the url of the git repository where the gitops config will be located or "*" if you want to allow any

- Create an application

```shell script
argocd app create {APP_NAME} --project {PROJECT} --repo {GIT_REPO} --path {APP_FOLDER} --dest-namespace {NAMESPACE} --dest-server {SERVER_URL}
```

where:
- `{APP_NAME}` is the name you want to give the application
- `{PROJECT}` is the name of the project created above or "default"
- `{GIT_REPO}` is the url of the git repository where the gitops config is be located
- `{APP_FOLDER}` is the path to the configuration for the application in the gitops repo
- `{DEST_NAMESPACE}` is the target namespace in the cluster where the application will be deployed
- `{SERVER_URL}` is the url of the cluster where the application will be deployed. Use https://kubernetes.default.svc to reference the same cluster where ArgoCD has been dployed

### Operator custom resources

The operator defines a custom resource for a Project and Application
component in ArgoCD. These are simple yaml files that define the attributes
required to configure ArgoCD. The following steps can be followed to create
te necessary resources by hand:

1. Copy the template project from `templates/project-config-manual` into the root directory and name the folder
after the project (e.g. `{project name}-config`)
2. Update the `project.yaml` file with the details of the project. The destinations block can use "*" for the
server and namespace or can list multiple destinations explicitly.
3. Rename the `application.yaml` file after one of the applications that will be deployed. Update the values
to match the application deployment configuration.
4. For each additional application, copy one of the application yaml files and update
the values accordingly.
5. Register the `{project-name}-config` folder as a "bootstrap application"

```shell script
argocd app create {APP_NAME} --repo {GIT_REPO} --path {APP_FOLDER} --revision {GIT_BRANCH} --dest-namespace {NAMESPACE} --dest-server https://kubernetes.default.svc
```
 
where:
- `APP_NAME` is the name you want to give the application (e.g. `{project-name}-config`)
- `GIT_REPO` is the url of the git repository where the gitops config is be located
- `APP_FOLDER` is the path to the configuration for the application in the gitops repo (e.g. `{project-name}-config`)
- `GIT_BRANCH` is the branch where the "bootstrap application" config has been stored
- `DEST_NAMESPACE` is the namespace where the ArgoCD operator has been deployed (e.g. `tools`)
- `SERVER_URL` is the url of the cluster where the application will be deployed. Use https://kubernetes.default.svc to 
reference the same cluster where ArgoCD has been deployed

**Note:** As new applications are added to the project, simply update add another application yaml file
to the folder and ArgoCD will update the configuration

### Operator custom resources with helm

The operator defines a custom resource for a Project and Application
component in ArgoCD. In order to simplify the configuration of the
components, a helm chart has been provided that will generate the various
combinations of applications for various namespaces. The following steps can
be used to apply custom resources:

1. Copy the template project from `templates/project-config-helm` into the root directory and name the folder
after the project (e.g. `{project name}-config`)
2. Update `{project-name}-config/Chart.yaml`
    - Set `name` to match the name of the folder (e.g. `{project-name}-config`)
    - Update `description` with the name of your project
3. Update `{project-name}-config/values.yaml` with the project information
    - Set `<project-name>` to the name of the project. This name will be used to group the applications 
    together and the name can be whatever you want
    - For each branch, create an entry under the `applicationTargets` heading and provide the appropriate values:
        - `<git-branch>` is the branch in the gitops repo that contains the configuration
        - `<cluster-namespace>` is the namespace into which the application will be deployed, it must already exist
        - `<server-url>` is the url of the target cluster if deploying to a remote cluster. If deploying to the same
        cluster where ArgoCD is deployed then this value can be set to empty string ("")
        - `<value-yaml>` is the name of the yaml file containing the values. The `valueFiles` field is an array that can
        accept multiple files, applied in the order they are provided. If not provided it will default to `values.yaml`
        - `<app-name-1>`, `<app-name-2>`, etc are the names of the applications that will be deployed. Each value
        should correspond to directory of the same name in the git repo. Each directory should contain the
        configuration for that application.

    For example:
    ```yaml
    argocd-config:
      project: inventory
    
      applicationTargets:
        - targetRevision: test
          targetNamespace: inventory-test
          applications: 
          - name: inventory-ui
          - name: inventory-bff
          - name: inventory-svc
        - targetRevision: staging
          targetNamespace: inventory-staging
          applications: 
          - name: inventory-ui
          - name: inventory-bff
            path: inventory-bff
          - name: inventory-svc
    ```
   
   will configure ArgoCD to deploy the `inventory-ui`, `inventory-bff`, and `inventory-svc` apps as part of the 
   `inventory` project into the `invantory-test` and `inventory-staging` namespaces according to the contents of those 
   folders in the `test` and `staging` branches, respectively

4. Register the `{project-name}-config` folder as a "bootstrap application"

```shell script
argocd app create {APP_NAME} --repo {GIT_REPO} --path {APP_FOLDER} --revision {GIT_BRANCH} --dest-namespace {NAMESPACE} --dest-server https://kubernetes.default.svc
```
 
where:
- `APP_NAME` is the name you want to give the application (e.g. `{project-name}-config`)
- `GIT_REPO` is the url of the git repository where the gitops config is be located
- `APP_FOLDER` is the path to the configuration for the application in the gitops repo (e.g. `{project-name}-config`)
- `GIT_BRANCH` is the branch where the "bootstrap application" config has been stored
- `DEST_NAMESPACE` is the namespace where the ArgoCD operator has been deployed (e.g. `tools`)
- `SERVER_URL` is the url of the cluster where the application will be deployed. Use https://kubernetes.default.svc to 
reference the same cluster where ArgoCD has been deployed

**Note:** As new applications are added to the project, simply update the `{project-name}-config/values.yaml`
to include the new application and its configuration

## CLI quick reference

### Login

```shell script
argocd login {GRPC_INGRESS_HOST} --grpc-web [--sso]
```

where:
- `GRPC_INGRESS_HOST` is the host name of the grpc ingress
- the optional`--sso` flag is used when sso authentication is enabled

The command will prompt for a password. The grpc url and credentials can be retrieved
from the `igc credentials` command
