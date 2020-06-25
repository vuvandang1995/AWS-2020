## Các bước deploy 1 service
- B1: Tạo domain trỏ về địa chỉ của ingress nginx (nếu có)
  - Xem địa chỉ ingress nginx
      - `kubectl -n dangvv-system get svc | grep nginx-ingress-controller`
- B2: Tạo secret chứa account registry container theo namespace service
  - `kubectl -n [namespace] create secret docker-registry dangvv-hub --docker-server='***' --docker-username='' --docker-password='***'`
- B3: tạo cert cho domain theo namespace service
  - `kubectl -n [namespace] create -f sre/cert-manager/cert-dangvv-vn.yaml`
- B4: Tạo file value cho service với template sau :
  ```
  imagePullSecrets:
    - name: dangvv-hub

  image:
    repository: abc.com/sohoa-backend
    tag: "1.0.0"

  resources:
    requests:
      memory: 1Gi
      cpu: 250m
    limits:
      memory: 1Gi
      cpu: 500m

  deploys:
  - name: app
    prometheusScrapeEnabled: 'false'
    replicasCount: 1
    service:
      type: ClusterIP
      containerPort: 
        http: 8888
      health:
        live: /health/live
        ready: /health/ready
    ### sử dụng nêu persistence volume đã được tạo trước đó (cùng namespace)
    # persistence:
    # - name: kaldi
    #   newpv: false
    #   mountPath: /kaldi_data
    #   claimName: audio-preprocess-app-kaldi
    
    ### sử dụng nêu persistence volume chưa từng được tạo trước đó (cùng namespace)
    persistence:
    - name: kaldi
      newpv: true
      mountPath: /kaldi_data
      accessModes: ReadWriteOnce
      # subPath: kaldi_data
      storage: 100Gi
      storageClassName: efs-sc
      resourcePolicy: keep
      csi:
        driver: efs.csi.aws.com
        volumeHandle: fs-486d3009
        volumeAttributes:
          path: /kaldi_data
    
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/rewrite-target: /$2
      nginx.ingress.kubernetes.io/ssl-redirect: 'true'
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      nginx.ingress.kubernetes.io/enable-cors: 'true'
      nginx.ingress.kubernetes.io/cors-allow-methods: GET, PUT, POST, DELETE, PATCH,
        OPTIONS
      nginx.ingress.kubernetes.io/cors-allow-origin: '*'
      nginx.ingress.kubernetes.io/use-regex: "true"
    tls:
    - secretName: dangvv-vn-tls
      hosts:
      - api-dev2.dangvv.vn
    - secretName: dangvv-vn-tls
      hosts:
      - dangvvapis.dangvv.vn
    rules:
    - host: api-dev2.dangvv.vn
      paths:
      - path: /analytic(/|$)(.*)
        serviceName: sohoa-api-app
    - host: dangvvapis.dangvv.vn
      paths:
      - path: /analytic(/|$)(.*)
        serviceName: sohoa-api-app

  env:
    DB_URI: abc
    VNPAY_HASH_SECRET_KEY: secret:sohoa-api.VNPAY_HASH_SECRET_KEY

  secret:
    VNPAY_HASH_SECRET_KEY: AgCCComL8SGS3Xr3VBL
  ```

- B5: Mã hóa các env (nếu cần)
  - `kubectl -n [tên namespace] create secret generic [tên secret] --from-literal=[key]=[value] --dry-run -o yaml | kubeseal --cert seal.crt`
- B6: Viết helmfile cho service
  ```
  releases:
  - name: sohoa-api
    namespace: sohoa-service
    labels:
      tier: dangvv-app
    values:
    - ./sohoa-api.yaml
    chart: dangvv/chart-backend

  ```
- B7: Khai báo trong helmfile tổng
  - `- path: sohoa-service/helmfile.yaml`