# 🚀 DevOps Project 2 — Terraform + Kubernetes + CI/CD

> **Extends Project 1** by adding Infrastructure as Code (Terraform) and container orchestration (Kubernetes) into the same GitHub Actions CI/CD pipeline.

---

## 🔄 Full Pipeline Flow

```
Developer pushes to main
         ↓
   GitHub Actions
   ┌─────────────────────────────────────────────┐
   │  Job 1: build-and-push                      │
   │    → Build Docker image (multi-arch)        │
   │    → Push to DockerHub                      │
   └────────────────┬────────────────────────────┘
                    ↓ (on success)
   ┌─────────────────────────────────────────────┐
   │  Job 2: terraform                           │
   │    → terraform init                         │
   │    → terraform apply                        │
   │       Creates: EC2 + Security Group         │
   │       Installs: Docker + k3s on EC2         │
   │    → outputs EC2 public IP                  │
   └────────────────┬────────────────────────────┘
                    ↓ (on success)
   ┌─────────────────────────────────────────────┐
   │  Job 3: deploy                              │
   │    → SSH into EC2                           │
   │    → Wait for k3s to be ready               │
   │    → kubectl apply deployment.yaml          │
   │    → kubectl apply service.yaml             │
   │    → App live at http://<EC2-IP>:30080      │
   └─────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
DevOps-app_Project2/
├── .github/
│   └── workflows/
│       └── cicd.yml          ← Full integrated pipeline
├── terraform/
│   ├── main.tf               ← EC2 + Security Group + k3s setup
│   ├── variables.tf          ← Config values (region, instance type)
│   └── outputs.tf            ← Prints EC2 IP after apply
├── k8s/
│   ├── deployment.yaml       ← Runs 2 replicas of your app
│   └── service.yaml          ← Exposes app on port 30080
└── README.md
```

> **Note:** Keep your `app/`, `Dockerfile`, and `nginx.conf` from Project 1 in the same repo root. The pipeline reuses them.

---

## ⚙️ One-Time Setup (do this before first push)

### 1. Install required tools locally (optional — just for testing)

| Tool | Purpose | Install |
|------|---------|---------|
| Terraform | Provision AWS infra | https://developer.hashicorp.com/terraform/install |
| AWS CLI | Authenticate with AWS | https://aws.amazon.com/cli/ |

### 2. Create AWS Key Pair

1. AWS Console → EC2 → Key Pairs → **Create key pair**
2. Name it `devops-project2-key`
3. Download the `.pem` file — **keep it safe, you can't re-download it**
4. Update `terraform/variables.tf` → set `key_pair_name = "devops-project2-key"`

### 3. Add GitHub Secrets

Go to your repo → Settings → Secrets and variables → Actions → New repository secret

| Secret name | Value |
|-------------|-------|
| `DOCKER_USERNAME` | Your DockerHub username |
| `DOCKER_PASSWORD` | Your DockerHub password or access token |
| `AWS_ACCESS_KEY_ID` | From AWS IAM → Your user → Security credentials |
| `AWS_SECRET_ACCESS_KEY` | Same as above |
| `EC2_SSH_KEY` | The full content of your `.pem` file (open it in a text editor, copy everything) |

### 4. Update the Docker image name

In `k8s/deployment.yaml`, change:
```yaml
image: vigneshwari08/devops-app:latest
```
to:
```yaml
image: YOUR_DOCKERHUB_USERNAME/devops-app:latest
```

---

## 🚀 Run the Pipeline

```bash
git add .
git commit -m "Project 2: Add Terraform + Kubernetes"
git push origin main
```

That's it. Watch the Actions tab in GitHub — three jobs will run in sequence.

---

## ✅ Verify Deployment

After the pipeline succeeds, SSH into your server:

```bash
ssh -i devops-project2-key.pem ubuntu@<EC2-IP>

# Check pods are running
kubectl get pods

# Check service
kubectl get service devops-app-service

# See app logs
kubectl logs -l app=devops-app
```

Then open your browser: **http://\<EC2-IP\>:30080**

---

## 🧹 Teardown (avoid AWS charges)

Run locally:
```bash
cd terraform
terraform destroy
# Type 'yes' when prompted
```

This deletes the EC2 instance and security group — stops billing immediately.

---

## 🔑 Key Concepts Learned

| Concept | What it means |
|---------|--------------|
| `terraform apply` | Creates real infrastructure from code |
| `user_data` | Shell script that runs once when EC2 boots |
| k3s | Lightweight single-node Kubernetes |
| `Deployment` | Kubernetes object — runs and restarts your pods |
| `Service` (NodePort) | Exposes pods to external traffic |
| `needs:` in GitHub Actions | Makes jobs run in sequence, not parallel |
| `outputs:` in GitHub Actions | Passes data (EC2 IP) between jobs |

---

## 🔜 Project 3 Ideas
- Replace k3s with AWS EKS (managed Kubernetes)
- Add Prometheus + Grafana monitoring
- Add a rollback step to the pipeline
- Use Helm charts instead of raw YAML

---
## Author
Vigneshwari K
