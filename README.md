# Chatbot App & Azure Infrastructure

An end-to-end DevOps learning project that provisions Azure infrastructure with Terraform, runs infrastructure pipelines in Azure DevOps, and hosts a lightweight chatbot web application on an Azure Linux VM. The project is being developed incrementally, with CI/CD automation, secure access, DNS, and production-readiness improvements planned as the next milestones.

> **Current result:** The Demo ChatBot frontend is hosted on an Azure VM and was verified in a browser over HTTP. The page is a static front-end demo; its replies are handled locally by JavaScript and it does not call an AI API or backend service.

## Table of contents

- [Project goals](#project-goals)
- [Architecture](#architecture)
- [Technology stack](#technology-stack)
- [Repository layout](#repository-layout)
- [Infrastructure resources](#infrastructure-resources)
- [Terraform workflow](#terraform-workflow)
- [Azure DevOps pipeline](#azure-devops-pipeline)
- [Application deployment](#application-deployment)
- [Network and access configuration](#network-and-access-configuration)
- [Run locally](#run-locally)
- [Roadmap](#roadmap)
- [Security notes](#security-notes)

## Project goals

- Provision and manage Azure infrastructure as code with Terraform.
- Organize Terraform into reusable modules and environment-specific configuration.
- Run Terraform validation and deployment through Azure DevOps.
- Store Terraform state remotely in Azure Blob Storage.
- Host a simple, responsive web application on an Azure Linux VM.
- Progressively improve the workflow toward controlled CI/CD, secure networking, and production readiness.

## Architecture

```text
Developer workstation
        |
        | Git push / pull request
        v
Azure Repos (Git)
        |
        v
Azure DevOps YAML pipeline
        |
        | Terraform init / validate / plan / apply
        v
Azure subscription
        |
        +-- Resource group: rg-prod
        |
        +-- Virtual network: vnet-prod
        |     |
        |     +-- Frontend subnet: frontend-prod
        |     +-- Network security group: nsg-prod
        |
        +-- Frontend Linux VM: frontvm-prod
        |     +-- NIC: nicfront-prod
        |     +-- Apache HTTP server
        |     +-- Demo ChatBot (index.html)
        |
        +-- Backend VM configuration: backvm-prod
        |
        +-- Azure Blob Storage for Terraform remote state
```

This diagram represents the resources and workflow configured during the project. Resource existence and state can vary by the latest Terraform apply; verify the Azure portal and Terraform plan before making infrastructure changes.

## Technology stack

| Area | Technology |
|---|---|
| Cloud platform | Microsoft Azure |
| Infrastructure as Code | Terraform |
| CI/CD and pipeline orchestration | Azure DevOps Pipelines (YAML) |
| Source control | Azure Repos; GitHub portfolio repository |
| Terraform state | Azure Blob Storage backend |
| Compute | Azure Linux Virtual Machines |
| Networking | Azure VNet, subnet, NIC, public IP, NSG |
| Web hosting | Apache HTTP Server |
| Application | HTML, CSS, JavaScript in a single `index.html` file |
| Secrets management | Azure Key Vault — integration/status to be documented against the current Terraform and pipeline configuration |

## Repository layout

The Terraform environment used by the pipeline is under `Environments/Prod`, with reusable VM resources defined in the VM module.

```text
.
├── Environments/
│   └── Prod/
│       ├── provider.tf
│       ├── azure-pipelines.yml   # pipeline YAML location may vary in the repo
│       └── ...                   # production environment configuration
├── Modules/
│   └── VM/
│       └── main.tf
├── app/
│   └── index.html                # recommended location for the chatbot app
└── README.md
```

Adjust this tree to match the actual checked-in filenames before publishing. Do not commit Terraform state files, local plans, credentials, or secret values.

## Infrastructure resources

The project has used or configured the following Azure resources:

- **Resource group:** `rg-prod`
- **Virtual network:** `vnet-prod`
- **Frontend subnet:** `frontend-prod`
- **Network security group:** `nsg-prod`
- **Frontend NIC:** `nicfront-prod`
- **Frontend VM:** `frontvm-prod`
- **Backend VM:** `backvm-prod`
- **Terraform state resource group:** `rg-backend-storage`
- **Terraform state storage account:** `backendstorage102026`
- **Terraform state container:** `statefile-container`
- **Terraform state key:** `utstate.tf`

The production VM configuration also referenced managed OS disks named `frontdisk1` and `backdisk1`. Azure returned a `409 Conflict` during one deployment attempt because disks with those names already existed. This illustrates why Terraform state and existing Azure resources must be reconciled before retrying a deployment or deleting resources.

> Resource names are documented to explain the implementation. Confirm current state in Azure before relying on any resource being present.

## Terraform workflow

The infrastructure workflow follows this general sequence:

1. Update the Terraform configuration in the appropriate environment/module.
2. Run formatting and validation.
3. Initialize Terraform with the configured Azure Blob backend.
4. Generate and review a Terraform plan.
5. Apply the reviewed changes through the Azure DevOps pipeline.
6. Verify the resulting resources in Azure.

Useful commands when working in the correct environment directory:

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan
```

Run `terraform apply` only after reviewing the plan and confirming the target subscription, environment, and intended resource changes. If the pipeline owns deployment, prefer the pipeline's controlled apply stage rather than applying independently from a workstation.

### Remote state

The configured Azure Blob backend uses:

- Resource group: `rg-backend-storage`
- Storage account: `backendstorage102026`
- Container: `statefile-container`
- State key: `utstate.tf`

Remote state helps the team share the current infrastructure state and supports state locking. A state lock or lease error should be investigated before attempting to break a lock. Confirm that no Terraform process or pipeline is still running first.

## Azure DevOps pipeline

The Azure DevOps YAML pipeline has been configured to run Terraform tasks including:

- `terraform init`
- `terraform validate`
- `terraform plan`
- `terraform apply`

The pipeline has been triggered from the `master` branch and uses the Azure service connection named `UtConnection`. A self-hosted agent named `Jarvis` has been used for pipeline execution.

The pipeline has reached a successful green Apply run during the project. The long-term goal is to strengthen the delivery workflow with pull-request validation, explicit approvals, clearer separation between plan and apply, and automated application deployment. Verify the current YAML and branch policies before describing those controls as fully enforced.

## Application deployment

The hosted application is a small static chatbot demonstration.

### Features

- Responsive chat interface for desktop and mobile.
- Send button and Enter/form submission.
- Local JavaScript responses for greetings, help, current time/date, and random facts.
- No external JavaScript libraries or backend required.
- User messages are inserted as text rather than interpreted as HTML.

### Hosting steps completed

1. Created a single-file `index.html` containing HTML, CSS, and JavaScript.
2. Connected to the Linux VM over SSH.
3. Copied the file from Windows to the VM with `scp`.
4. Placed the page at `/var/www/html/index.html`.
5. Configured Apache as the web server.
6. Added an inbound NSG rule for HTTP/TCP port `80`.
7. Opened the VM's public IP in a browser and verified the chatbot page.

The application was verified at:

```text
http://20.198.84.136
```

This is a development/demo endpoint, not a permanent production URL. The page is served over HTTP, so browser traffic is not encrypted. Do not use it to transmit sensitive information.

## Network and access configuration

- SSH uses TCP port `22`.
- HTTP uses TCP port `80`.
- HTTPS/TCP port `443` has not been confirmed as configured.
- The frontend subnet was associated with `nsg-prod` during troubleshooting because the VM NIC initially showed no directly associated NSG.
- An inbound rule named `test123` was created for TCP/22 with source `Any` during connectivity troubleshooting.
- An HTTP allow rule was added to permit browser access to the website.

For safer ongoing use, replace broad SSH access with a source-IP-restricted rule or a managed access solution, verify which NSGs are associated at both NIC and subnet levels, and keep only the required inbound ports open.

## Run locally

No build step is required. Open `app/index.html` (or the actual location of `index.html`) in a modern browser.

Alternatively, from the directory containing the file:

```bash
python -m http.server 8000
```

Then open `http://localhost:8000`.

The chatbot is a front-end demonstration. It does not provide genuine AI-generated answers, persist conversations, or call a server-side API.

## Roadmap

- [ ] Finalize the GitHub repository structure and keep the application under `app/`.
- [ ] Review and document the actual Azure Key Vault integration, including how secrets are referenced without committing secret values.
- [ ] Make application deployment repeatable through Azure DevOps instead of manual SCP.
- [ ] Add pull-request build validation and enforce branch policies.
- [ ] Add controlled approval gates and a reviewed Terraform plan/apply workflow.
- [ ] Restrict SSH access and review effective NSG rules.
- [ ] Configure a DNS zone and custom domain.
- [ ] Configure HTTPS with a valid TLS certificate.
- [ ] Add deployment health checks and a rollback strategy.
- [ ] Add monitoring, logs, and operational documentation.
- [ ] Add security scanning and additional automated checks.
- [ ] Consider containerization only after the VM-based deployment workflow is stable.

## Security notes

- Never commit service-principal credentials, passwords, private keys, Terraform state files, or real secret values.
- Use Azure Key Vault for secrets where the current design supports it, and document the identity/RBAC path used to retrieve them.
- Use least-privilege Azure RBAC and NSG rules.
- Restrict SSH to trusted source IPs; do not leave TCP/22 open to `Any`.
- Use HTTPS for any non-demo or sensitive traffic.
- Review every Terraform plan before applying changes, especially plans that delete disks, VMs, or networking resources.
- Do not delete Azure resources manually without understanding their Terraform state and dependencies.

## Project status

**Working milestone:** Terraform infrastructure pipeline and browser-accessible static chatbot hosting on an Azure Linux VM.

**In progress / next:** repeatable application deployment, stronger pipeline controls, verified Key Vault integration, DNS/HTTPS, and production security hardening.
