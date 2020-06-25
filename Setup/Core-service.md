## Cài đặt các core-service
- Môi trường: Kubernetes
- Công cụ : helm, helmfile
- Source config: gitlab
### Chuẩn bị các công cụ trên kube-client của bạn trước khi tạo CD cài đặt các core-service
- Cài đặt helm:
    - `curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3`
    - `chmod 700 get_helm.sh`
    - `./get_helm.sh`
    - `helm repo add gitlab https://charts.gitlab.io`

- Cài đặt helm git:
    - `helm plugin install https://github.com/aslafy-z/helm-git.git`

- Càì đặt helm diff:
    - `helm plugin install https://github.com/databus23/helm-diff --version master`

- Cài đặt helmfile:
    - `https://github.com/roboll/helmfile`

- Tạo repository chứa config deploy các core-service
    - `https://gitlab.com/dangvv/product/k8s-workload/-/tree/master/sre`

- Cài đặt gitlab-runner:
    - `kubectl create ns gitlab-runner`
    - `kubectl -n gitlab-runner create serviceaccount gitlab-runner`
    - `kubectl create -f gitlab-runner/rbac.yaml`
    - Chỉnh sửa  `gitlabUrl`, `runnerRegistrationToken`, `tags` cho đúng với repository của bạn
    - `helm install -f gitlab-runner/ci.yaml gitlab-runner --namespace=gitlab-runner gitlab/gitlab-runner`

- Tạo `crd` cho `cert-manager` trước khi chạy CD
    - `kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.12/deploy/manifests/00-crds.yaml`

- Tạo namespace chứa các core-service
    - `kubectl create ns dangvv-system`

- Tạo `helmfile` tổng
    ```
    repositories:
    - name: stable
    url: https://kubernetes-charts.storage.googleapis.com
    - name: dangvv
    url: https://raw.githubusercontent.com/lehoangnam040/Helm-Chart/master/


    helmDefaults:
    verify: true
    wait: true
    timeout: 600
    #recreatePods: true
    force: true


    helmfiles:
    # - path: sre/helmfile.yaml
    - path: authen-service/helmfile.yaml
    - path: asr-engine-gateway/helmfile.yaml
    - path: sohoa-service/helmfile.yaml
    - path: plugin-dangvv/helmfile.yaml
    #- path: gobang/helmfile.yaml
    - path: logstash/helmfile.yaml
    - path: asr-cloud/helmfile.yaml
    ```
- Tạo các `helmfile` cho các thư mục service. ví dụ :
    ```
    repositories:
    - name: stable
    url: https://kubernetes-charts.storage.googleapis.com
    - name: jetstack
    url: https://charts.jetstack.io
    - name: loki
    url: https://grafana.github.io/loki/charts
    - name: dangvv
    url: https://raw.githubusercontent.com/lehoangnam040/Helm-Chart/master/
    - name: elastic
    url: https://helm.elastic.co

    helmDefaults:
    verify: false
    wait: false
    timeout: 600
    force: false

    releases:
    - name: sealed-secrets-controller
      namespace: dangvv-system
      chart: stable/sealed-secrets
      version: 1.4.3
      values:
        - sealed-secrets/values.yaml

    - name: events-influxdb
      namespace: dangvv-system
      chart: stable/influxdb
      version: 3.1.1
      values:
        - events-influxdb/values.yaml

    - name: nginx-ingress
      namespace: dangvv-system
      chart: stable/nginx-ingress
      version: 1.30.0
      values:
        - nginx-ingress/values.yaml

    - name: loki
      namespace: dangvv-system
      chart: loki/loki-stack

    - name: cert-manager
      namespace: dangvv-system
      version: v0.11.0
      chart: jetstack/cert-manager
      values:
        - cert-manager/values.yaml

    - name: grafana-psql
      namespace: dangvv-system
      version: 8.1.4
      values:
      - prometheus-operator/grafana-psql.yaml
      chart: stable/postgresql
    
    
    - name: prometheus-operator
      namespace: dangvv-system
      version: 8.5.2
      values:
      - prometheus-operator/prom-operator.yaml
      chart: stable/prometheus-operator

    - name: fluent-bit
      namespace: dangvv-system
      version: 2.8.7
      values:
      - fluent-bit/fluent-bit.yaml
      chart: stable/fluent-bit
    

    - name: kibana
      namespace: dangvv-system
      version: 7.5.1
      values:
      - kibana/kibana.yaml
      chart: elastic/kibana

    - name: kong
      namespace: dangvv-system
      chart: stable/kong
      version: 0.36.2
      values:
        - kong/kong.yaml
    ```

- Tạo file CD cho repository 
    ```
    stages:
    - apply

    .apply_template: &apply
    image:
        name: dangvv1995/helmfile:v3
    before_script:
        - echo Before script
    script:
        #- helm repo update
        - helmfile repos
        - helmfile apply --context=3 --skip-deps
    tags:
        - ci-lab
    only:
        refs:
        - master
    retry: 2

    apply:all:
        <<: *apply
        stage: apply
        tags:
            - ci-lab
        only:
            refs:
            - master
    ```
### Sử dụng
- Tạo `Issuer` cho Cluster
    - `kubectl create -f sre/cert-manager/letsencrypt-prod.yaml`

- Tạo cert tls cho domain `dangvv.vn` đối với các namespace nào có ingress (domain)
    - `kubectl -n [namespace] create -f sre/cert-manager/cert-dangvv-vn.yaml`

- Lấy public key để mã hóa với `seal-secret`
    - `kubectl get secrets -n dangvv-system sealed-secrets-keyfqnhh -o="jsonpath={.data['tls\.crt']}" | base64 -d > seal.cert`

- Mã hóa client với `seal-secret`
    - `kubectl -n [tên namespace] create secret generic [tên secret] --from-literal=[key]=[value] --dry-run -o yaml | kubeseal --cert seal.crt`