# Monitoring Kubernetes cluster example

## Intro
Setup a kubernetes cluster and enable cluster monitoring using Prometheus and grafana.
Deploy a demo application that is exposed via Ingress to test networking metrics
THIS FOR WSL2 based kubernetes deployments

### Prerequisites
- Docker v19.03.13
- Kubernetes v1.18.8
- Helm v3.3.4

### Descriptions
`README.md`: well, this\
`monitoring.yaml`: deploy monitoring resources (Prometheus and Grafana)\
`test.yaml`: demo application

### Instuctions
1. Add the following entries in: `C:\Windows\System32\drivers\etc\hosts`
```
127.0.0.1 kibana.local
127.0.0.1 elasticsearch.local
127.0.0.1 infuxdb.local
127.0.0.1 test.local
127.0.0.1 monitoring.local
```
2. Create appropriate namespaces:
    - `kubectl apply -f namespaces.yaml`
3. Add relevant helm repositories
    - `helm repo add stable https://kubernetes-charts.storage.googleapis.com/`
    (requirement for prometheus-community)
    - prometheus - grafana: `helm repo add prometheus-community https://prometheus-community.github.io/helm-charts` 
    - elasticsearch stack: `helm repo add elastic https://helm.elastic.co`
    - `helm repo update`
4. Install Ingress resources\
    This is for WSL2 kubernetes clusters, you can find more info at (https://kubernetes.github.io/ingress-nginx/deploy/) \
    `kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.41.2/deploy/static/provider/cloud/deploy.yaml`\
    To test that ingress is working:
    - `kubectl apply -f test.yaml`
    - `curl test.local` should produce:
```
<html>
  <head>
    <title>Die Bard</title>
  </head>
  <body>
    <h1>Die Bart</h1>
    <h2>DIIIIIEEEE</h2>
  </body>
</html>
```
5. Deploy monitoring stack: `helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring -f monitoring.yaml`
    - http://monitoring.local/grafana
    - http://monitoring.local/prometheus

6. Deploy elasticsearch stack
  1. Generate the necessary certificates to enable stack <ins>transport</ins> security: `./gen-certs.sh`
    - To get elastic superuser pass: `echo $(kubectl get secret elastic-credentials --template={{.data.password}} | base64 -d)`
  2. Install master nodes deployemnt `helm install master elastic/elasticsearch -n logging -f elastic-master.yml`
  3. Install data nodes deployemnt `helm install data elastic/elasticsearch -n logging -f elastic-data.yml`
  4. Install ingest nodes deployemnt `helm install ingest elastic/elasticsearch -n logging -f elastic-ingest.yml`
  5. Install ingest nodes deployemnt `helm install coord elastic/elasticsearch -n logging -f elastic-coord.yml`



#### Sources
- https://kubernetes.github.io/ingress-nginx/deploy/
- https://docs.nginx.com/nginx-ingress-controller/logging-and-monitoring/prometheus/#
- https://github.com/elastic/helm-charts

