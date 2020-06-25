## EKS
### Tạo Cluster
- B1: Tạo **IAM Roles** (cấp quyền quản lý K8s cluster)
    - link https://console.aws.amazon.com/iam/home?#/roles
    - Chọn `use case` là `EKS`
- B2: Tạo **VPC, Subnet, Security group** (Network cho K8s cluster)
    - `Lưu ý:` Nếu sử dụng **VPC** với **Internet gateways** thì cần `enable` tính năng `Auto-assign IPv4 Public` trên subnet
- B3: Tạo Cluster
    - https://ap-southeast-1.console.aws.amazon.com/eks/home?region=ap-southeast-1#/cluster-create
### Cấu hình kubectl
- B1: Cài đặt kubectl
    - Download package:
        - Kubernetes 1.16: `curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.16.8/2020-04-16/bin/linux/amd64/kubectl`
        - Kubernetes 1.15: `curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/kubectl`
        - Kubernetes 1.14: `curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/kubectl`
    - chmod +x ./kubectl
    - Tham khảo: https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html
- B2: Tạo **kubeconfig**
    - Cài đặt và cấu hình `aws cli` : https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html
        - **Lưu ý:** Phải cài đặt AWS CLI version `1.16.156` trở lên, Python version 2.7.9 trở lên
    - `aws eks --region region-code update-kubeconfig --name cluster_name`
        - **Lưu ý:** Mặc định sau khi chạy câu lệnh trên, `kubeconfig` sẽ được tạo ở `.kube/config` trên server của bạn, nếu bạn muốn chỉ định path, hãy thêm option `--kubeconfig`
        - Để chạy được câu lệnh này, tài khoản của bạn phải được gán quyền `eks:DescribeCluster` với tên cluster
    - Test
        - `kubectl get svc`
