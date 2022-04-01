## �������� �������

������� ������� � ������� ������� �������, �� ������� ��������, ��� ����� ������������ ���������� ������ ��� �������� ��������, 
� ������� ������ ��� ������ �� ����������� �������� (����� aws-resources) ��� ��� ���������� � �� �������, �� ������ ��������� :).

� ����� aws-modules 2 ������ ����, ���� ��� [EKS Managed Node-Group](https://github.com/leonix2/TZRKS/aws-modules/eks-managed), ������ ��� [Self-Managed](https://github.com/leonix2/TZRKS/aws-modules/eks-self-managed), ������ ������ ��� ���� ��������� ��������������������... ������ �������� �����.

������ �������� �������� �� 2 ������:

1. ���������� [network](https://github.com/leonix2/TZRKS/aws-modules/network) - �������� � ���� ��� ����������� ������� ���������� AWS.
2. ���������� eks_xxx (���� �� ���� �� �����) - �������� ������� ��� �������� ��������, Node-groups, ������������.


## ������

���������� ���������� �� S3 �������, �� ����� �������, ��� ���� �� ������ ����������� �� ����� �������� AWS, �� ����� ���������� 
�� ��������� ������. ���� ����� �������� �������������� �� S3, ���������������� ������ state.tf �� ����� �������.

## ���������

��� �� �� ����� 20 ����� �� Scale Down - �������� �������� ������������ � ���������� Helm �����. ����� � 10 ����� ������ ������ ������������ ����.

## ������

��� ��� ������������� EC2 ���� t3.small - ����������� �� ���������� ����� �� ��� = 11, � ���� �� ����� ��������� ��� 25 ����� �� 3 ����� ����� ����. ��������� 9 ���������, � �������� 24 ��� �������� ��������. ����� ������������ � ���������� ���������� �� ������ core-dns, �� � ������� ��� ��� ��� �������� :)

## Example

```shell
ubuntu@ip-192-168-41-141:~$ kubectl get all -A
NAMESPACE     NAME                                                             READY   STATUS    RESTARTS   AGE
default       pod/test-5f6778868d-27z7k                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-695js                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-6s66f                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-6tp45                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-75cfh                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-8tc4g                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-bhzvz                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-dh62b                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-dxfkv                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-fxl9p                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-h67fh                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-khdtn                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-ltn9s                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-m2cfv                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-mwj79                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-mzmt4                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-npzzg                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-pdft5                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-prn8f                                        0/1     Pending   0          5m39s      # FFFFUUUUUUUUUUU......
default       pod/test-5f6778868d-q4v8h                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-scs95                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-v24jv                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-wnv8t                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-wwkjl                                        1/1     Running   0          5m39s
default       pod/test-5f6778868d-ztnrk                                        1/1     Running   0          5m39s
kube-system   pod/aws-node-l48sr                                               1/1     Running   0          6m45s
kube-system   pod/aws-node-q2j7c                                               1/1     Running   0          4m36s
kube-system   pod/aws-node-sqwpw                                               1/1     Running   0          4m42s
kube-system   pod/cluster-autoscaler-aws-cluster-autoscaler-5bf4c8b568-t62xl   1/1     Running   0          6m52s
kube-system   pod/coredns-7cc879f8db-5d27t                                     1/1     Running   0          13m
kube-system   pod/coredns-7cc879f8db-6vgxg                                     1/1     Running   0          13m
kube-system   pod/kube-proxy-6wd4p                                             1/1     Running   0          4m42s
kube-system   pod/kube-proxy-sc5kw                                             1/1     Running   0          7m48s
kube-system   pod/kube-proxy-w58wc                                             1/1     Running   0          4m36s

NAMESPACE     NAME                                                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)         AGE
default       service/kubernetes                                  ClusterIP   172.20.0.1      <none>        443/TCP         13m
kube-system   service/cluster-autoscaler-aws-cluster-autoscaler   ClusterIP   172.20.70.190   <none>        8085/TCP        6m52s
kube-system   service/kube-dns                                    ClusterIP   172.20.0.10     <none>        53/UDP,53/TCP   13m

NAMESPACE     NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
kube-system   daemonset.apps/aws-node     3         3         3       3            3           <none>          13m
kube-system   daemonset.apps/kube-proxy   3         3         3       3            3           <none>          13m

NAMESPACE     NAME                                                        READY   UP-TO-DATE   AVAILABLE   AGE
default       deployment.apps/test                                        24/25   25           24          5m40s
kube-system   deployment.apps/cluster-autoscaler-aws-cluster-autoscaler   1/1     1            1           6m53s
kube-system   deployment.apps/coredns                                     2/2     2            2           13m

NAMESPACE     NAME                                                                   DESIRED   CURRENT   READY   AGE
default       replicaset.apps/test-5f6778868d                                        25        25        24      5m40s
kube-system   replicaset.apps/cluster-autoscaler-aws-cluster-autoscaler-5bf4c8b568   1         1         1       6m53s
kube-system   replicaset.apps/coredns-7cc879f8db                                     2         2         2       13m

```
