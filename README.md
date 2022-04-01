## Тестовый скейлер

Немного затянул с выдачей решения задания, не обратил внимание, что нужно использовать конкретные модули для создания ресурсов, 
и сначала сделал все просто на стандартных ресурсах (Папка aws-resources) Там все примитивно и не секурно, но задачу выполняет :).

В папке aws-modules 2 версии кода, одна для [EKS Managed Node-Group](https://github.com/leonix2/TZRKS/aws-modules/eks-managed), вторая для [Self-Managed](https://github.com/leonix2/TZRKS/aws-modules/eks-self-managed), просто потому что было интересно поэкспериментировать... можете выбирать любую.

Деплой ресурсов разделен на 2 стадии:

1. Директория [network](https://github.com/leonix2/TZRKS/aws-modules/network) - содержит в себе все необходимые сетевые абстракции AWS.
2. Директория eks_xxx (одна из двух на выбор) - содержит ресурсы для создания кластера, Node-groups, Автоскейлера.


## Стейты

Изначально тестировал ня S3 бэкенде, но потом подумал, что если вы будете тестировать на своем аккаунте AWS, то лучше переделать 
на локальные стейты. Если вдруг захотите протестировать на S3, раскомментируйте нужные state.tf со своим бакетом.

## Параметры

Что бы не ждать 20 минут до Scale Down - поправил таймауты Автоскейлера в настройках Helm чарта. Вроде в 10 минут сейчас вполне укладывается цикл.

## Нюансы

Так как задействованы EC2 типа t3.small - ограничение по количеству подов на них = 11, у меня не вышло запустить все 25 подов на 3 нодах этого типа. Требуется 9 служебных, и остается 24 для полезной нагрузки. Можно поковыряться и попытаться избавиться от одного core-dns, но я подумал что это уже паранойя :)

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
