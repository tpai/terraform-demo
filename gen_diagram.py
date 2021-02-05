from urllib.request import urlretrieve

from diagrams import Cluster, Diagram
from diagrams.aws.compute import EC2, ECS, EKS, Fargate
from diagrams.aws.network import CloudFront, ELB, InternetGateway, NATGateway, Route53, RouteTable
from diagrams.aws.database import ElastiCache, RDS
from diagrams.aws.security import WAF
from diagrams.aws.storage import S3
from diagrams.custom import Custom
from diagrams.generic.network import Switch, VPN

azure_url="https://cdn.wccftech.com/wp-content/uploads/2016/05/Azure_.png"
azure_icon = "azure.png"
urlretrieve(azure_url, azure_icon)

with Diagram(""):
    azure = Custom("Azure", azure_icon)
    dns = Route53("dns")
    office = Switch("office")
    with Cluster("odhk-data-vpc"):
        cf = CloudFront("odhk-data-cf")
        waf = WAF("odhk-data-waf")
        s3 = S3("odhk-data-s3")
        rt = RouteTable("odhk-data-rt")
        natrt = RouteTable("odhk-data-nat-rt")
        igw = InternetGateway("odhk-data-igw")
        with Cluster("odhk-data-gw-subnet"):
            natgw = NATGateway("odhk-data-nat-gw")
        with Cluster("data-public-subnet"):
            elb = ELB("data-pipeline-elb")
            with Cluster("data-pg-sg"):
                ppg = RDS("pipeline-pg")
                wpg = RDS("warehouse-pg")
        with Cluster("data-pipeline-subnet"):
            eks = EKS("data-pipeline-eks")
            with Cluster("data-pipelie-eks-ng"):
                ng = EC2("data-pipelie-eks-node")
        with Cluster("data-pipelie-redis-sg"):
            ec = ElastiCache("data-pipeline-ec")
        with Cluster("odhk-data-integration-subnet"):
            alb = ELB("odhk-data-integration-alb")
            ecs = ECS("odhk-data-integration-ecs")
            with Cluster("data-integration-tg"):
                node = EC2("data-integration-ecss-node")
                fg = Fargate("odhk-data-integration-fg")

    dns >> cf >> elb >> eks >> ec
    cf - waf
    eks - ng
    ng >> ppg - wpg << office
    ng >> s3

    dns >> alb >> ecs >> node
    fg >> s3

    node >> rt >> igw
    ng >> natrt >> natgw

    natgw >> azure
