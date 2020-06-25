## Kubernetes persistent storage sử dụng EFS
- B1: Deploy EFS CSI driver:
    - `kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"`
- B2: Lấy `VPC ID` đang sử dụng trên cluster của bạn
    - `aws eks describe-cluster --name cluster_name --query "cluster.resourcesVpcConfig.vpcId" --output text`
- B3: Thay thế VPC ID ở câu lệnh bên dưới để lấy `CIDR` của `VPC` của bạn
    - `aws ec2 describe-vpcs --vpc-ids vpc-id --query "Vpcs[].CidrBlock" --output text`
- B4: Tạo `security group` cho phép traffic NFS đi vào hệ thống
    - `aws ec2 create-security-group --description efs-test-sg --group-name efs-sg --vpc-id VPC_ID`
- B5: Thay thế `GroupId` vào câu lệnh sau để add `NFS inbound rule` vào `security group` vừa tạo bên trên
    - `aws ec2 authorize-security-group-ingress --group-id sg-xxx  --protocol tcp --port 2049 --cidr VPC_CIDR`
- B6: Tạo filesystem
    - `aws efs create-file-system --creation-token eks-efs`
- B7: folder để mount bên trong Filesystem
- B8: Sử dụng
    - Khai báo trong chart (nếu sử dụng helm chart)
    
    ```
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
    ```
- **Lưu ý:**
    - Tạo thư mục trên filesystem của efs trước, rồi mới mount được vào pod thông qua pv, nếu không tạo trước, default mount vào /
    - Không thể mount chung 1 filesystem trong cùng 1 deployment
    - Để chia sẻ pvc giữa các deployment, các deployment phải nằm chung 1 namespace