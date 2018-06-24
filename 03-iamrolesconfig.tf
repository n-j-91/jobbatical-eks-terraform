resource "aws_iam_role" "jobbatical-eks-master-iam-role" {
  name = "jobbatical-eks-master-iam-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "jobbatical-eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.jobbatical-eks-master-iam-role.name}"
}

resource "aws_iam_role_policy_attachment" "jobbatical-eks-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.jobbatical-eks-master-iam-role.name}"
}

resource "aws_iam_role" "jobbatical-eks-minion-iam-role" {
  name = "jobbatical-eks-minion-iam-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "djobbatical-eks-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.jobbatical-eks-minion-iam-role.name}"
}

resource "aws_iam_role_policy_attachment" "jobbatical-eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.jobbatical-eks-minion-iam-role.name}"
}

resource "aws_iam_role_policy_attachment" "jobbatical-eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.jobbatical-eks-minion-iam-role.name}"
}

resource "aws_iam_instance_profile" "jobbatical-eks-minion-profile" {
  name = "jobbatical-eks-minion-profile"
  role = "${aws_iam_role.jobbatical-eks-minion-iam-role.name}"
}

resource "aws_key_pair" "deployer-key" {
  key_name   = "deployer-key"
  public_key = "${file(var.deployer_key_file)}"
}
