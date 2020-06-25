# VIRTUAL PRIVATE CLOUD
## VPC
- A VPC is an isolated portion of the AWS cloud populated by AWS objects, such as Amazon EC2 instances
- Bạn phải chỉ định 1 dải địa chỉ IP cho VPC này (IPv4 hoặc IPv6), ví dụ 10.0.0.0/16
- Sau khi tạo VPC, default hệ thống sẽ tạo cho bạn 1 **Route Tables** tương ứng với VPC đó.
## Subnets
- Là các subnet IP thuộc VPC, bạn phải chỉ định 1 dải địa chỉ IP cho Subnet muốn tạo (IPv4 hoặc IPv6), dải IP của Subnet phải nằm trong dải IP của VPC chứa nó.
- Bạn có thể enable (khi dùng kiểu Internet Gateways) hoặc disable tính năng auto gán IP public cho các subnet này.
    - **Internet Gateways:** Điều này có nghĩa là nếu 1 instance sử dụng subnet này, nó sẽ được gán 1 IP private và 1 IP Public.
    - **NAT Gateways:** nghĩa là các instances sử dụng subnet này ra internet sẽ được NAT qua 1 cái gọi là **NAT gateways**
## Route Tables
- Là bảng định tuyến xem **Subnet** của các **VPC** ra internet theo đường nào (NAT Gateways hoặc Internet Gateways). Để thực hiện điều này, hãy cấu hình **Routes** cho nó.
    - `Lưu ý:` Trước khi cấu hình **Routes**, cần phải tạo **NAT gateways** hoặc **Internet gateways** trước.
## Internet Gateways
- Là cổng đi ra interntes của `VPC` gán với nó. Mỗi `instance` sử  dụng subnet của `VPC` với Internet gateways, được gán 1 IP public
## NAT Gateways
- Là cổng `NAT` đi ra internet của `VPC` gán với nó
- Khi tạo **NAT gateways**, bạn phải tạo 1 **Elastic IPs** trước (chính  là IP public tĩnh) để gán cho **NAT gateways** đó
## Peering Connections
- Là tính năng cho phép các `VPC` có thể kết nối với nhau
