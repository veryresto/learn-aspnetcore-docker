
# ASP.NET Core Web API - Deploy to GCP

This is a simple ASP.NET Core Web API project demonstrating how to containerize and deploy to **Google Cloud Platform (GCP)**. The guide supports two deployment targets:

1. **Google Compute Engine (VM)**
2. **Google Kubernetes Engine (GKE)**

---

## 📦 Project Structure

```
MyApi/
├── Controllers/
│   └── WeatherForecastController.cs
├── Program.cs
├── MyApi.csproj
├── Dockerfile
├── .dockerignore
└── README.md
```

---

## 🛠 Requirements

- [.NET SDK 8+](https://dotnet.microsoft.com/download)
- [Docker](https://www.docker.com/)
- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)
- GCP Project with billing enabled

---

## 🚀 1. Clone & Build the Project

```bash
git clone https://github.com/veryresto/learn-aspnetcore-docker.git myapi
cd myapi
```

---

## 🐳 2. Build and Tag Docker Image

```bash
docker build -t gcr.io/project-eksplor/myapi .
```

Replace `project-eksplor` with your GCP project ID.

---

## ☁️ 3. Authenticate & Configure GCP

```bash
gcloud auth login
gcloud config set project project-eksplor
gcloud auth configure-docker
```

---

## 📤 4. Push Docker Image to Google Container Registry

```bash
docker push gcr.io/project-eksplor/myapi
```

---

## 🔁 OPTION A: Deploy to Google Compute Engine (VM)

### Step 1: Create VM Instance

```bash
gcloud compute instances create-with-container myapi-vm   --container-image=gcr.io/project-eksplor/myapi   --zone=asia-southeast1-a   --tags=http-server   --container-port=80
```

### Step 2: Allow HTTP Traffic

```bash
gcloud compute firewall-rules create allow-http   --allow tcp:80   --target-tags http-server   --description="Allow port 80 access"   --direction=INGRESS
```

### Step 3: Access the API

Get the external IP:

```bash
gcloud compute instances list
```

Access via: `http://<EXTERNAL_IP>/weatherforecast`

---

## 🔁 OPTION B: Deploy to Google Kubernetes Engine (GKE)

### Step 1: Create Kubernetes Cluster

<details>
  <summary> Due to quota issue, disk type & size are specified </summary
  ERROR: (gcloud.container.clusters.create) ResponseError: code=403, message=Insufficient regional quota to satisfy request: resource "SSD_TOTAL_GB": request requires '300.0' and is short '50.0'. project has a quota of '250.0' with '250.0' available.
</details>

```bash
gcloud container clusters create my-cluster \
  --zone asia-southeast1-a \
  --disk-type pd-ssd \
  --disk-size 20GB

```

### Step 2: Authenticate kubectl

```bash
gcloud container clusters get-credentials my-cluster --zone=asia-southeast1-a
```

If you get an error about `gke-gcloud-auth-plugin`, install it:

```bash
gcloud components install gke-gcloud-auth-plugin
```

Or via Homebrew:

```bash
brew install google-cloud-sdk
```

### Step 3: Create Deployment and Service YAML

**deployment.yaml**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapi
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapi
  template:
    metadata:
      labels:
        app: myapi
    spec:
      containers:
      - name: myapi
        image: gcr.io/project-eksplor/myapi
        ports:
        - containerPort: 80
```

**service.yaml**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapi-service
spec:
  type: LoadBalancer
  selector:
    app: myapi
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

### Step 4: Deploy to GKE

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

### Step 5: Get External IP

```bash
kubectl get service myapi-service
```

Access via: `http://<EXTERNAL_IP>/weatherforecast`

---

## ✅ Example Output

Accessing:

```
http://<EXTERNAL_IP>/weatherforecast
```

Returns JSON:

```json
["Rainy", "Stormy", "Sunny"]
```

---

## 📚 Learn More

- [.NET Core + Docker Docs](https://docs.microsoft.com/en-us/dotnet/core/docker/)
- [GCP Container Registry](https://cloud.google.com/container-registry)
- [GCP Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine)
- [GKE Auth Plugin](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)

---

## 🔜 To Do (Optional Improvements)

- Add CI/CD using GitHub Actions or Cloud Build
- Add health checks
- Enable HTTPS
- Add logging and monitoring via Google Cloud Operations

---

## 🧼 Clean Up (To Avoid Charges)

```bash
# Delete GKE
gcloud container clusters delete my-cluster --zone=asia-southeast1-a

# Delete VM
gcloud compute instances delete myapi-vm --zone=asia-southeast1-a

# Delete image
gcloud container images delete gcr.io/project-eksplor/myapi
```

---

## 🧑‍💻 Author

Built by @veryresto, helped by chatgpt.
