resource "aws_eks_cluster" "odhk_data_pipeline_eks" {
  name     = "odhk_data_pipeline_eks"
  role_arn = aws_iam_role.odhk_data_prod_app_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.odhk_data_public_subset_1.cidr_block, aws_subnet.odhk_data_public_subset_2.cidr_block, aws_subnet.odhk_data_public_subset_5.cidr_block]
    security_group_ids = [aws_security_group.odhk_data_pipeline_eks_sg.id]
  }
}

resource "aws_eks_node_group" "odhk_data_pipeline_eks_ng" {
  cluster_name    = aws_eks_cluster.odhk_data_pipeline_eks.name
  node_group_name = "odhk_data_pipeline_eks_ng"
  node_role_arn   = aws_iam_role.odhk_data_prod_app_role.arn
  subnet_ids      = [aws_subnet.odhk_data_public_subset_1.cidr_block, aws_subnet.odhk_data_public_subset_2.cidr_block, aws_subnet.odhk_data_public_subset_5.cidr_block]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
}
