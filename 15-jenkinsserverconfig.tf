data "template_file" "configure-awscli" {
  template = "${file("./scripts/configure-awscli.tpl")}"

  vars {
    accesskey   = "${var.access_key}"
    secretkey   = "${var.secret_key}"
    profilename = "${var.profilename}"
    region      = "${var.region}"
  }
}

data "template_file" "mongodb-replicaset" {
  template = "${file("./scripts/mongodb-replicaset.tpl")}"
}

data "template_file" "mongodb-service" {
  template = "${file("./scripts/mongodb-service.tpl")}"
}

data "template_file" "node-todo-service" {
  template = "${file("./scripts/node-todo-service.tpl")}"
}

data "template_file" "node-todo-replicaset" {
  template = "${file("./scripts/node-todo-replicaset.tpl")}"

  vars {
    image_repo = "${aws_ecr_repository.jobbatical-ecr.repository_url}"
  }
}

resource "aws_instance" "jobbatical-jenkins-server" {
  ami                         = "${var.jenkins_ami}"
  instance_type               = "t2.small"
  key_name                    = "${aws_key_pair.deployer-key.key_name}"
  security_groups             = ["${aws_security_group.jobbatical-jenkins-sg.id}"]
  subnet_id                   = "${aws_subnet.jobbatical-az-1-subnets.*.id[0]}"
  associate_public_ip_address = true

  //user_data_base64 = "${base64encode(local.jobbatical-eks-minion-userdata)}"
  connection {
    user        = "ec2-user"
    private_key = "${file(var.deployer_pvt_key_file)}"
    agent       = false
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "jobbatical-jenkins-server"
  }

  depends_on = [
    "aws_eks_cluster.jobbatical-eks-cluster",
    "null_resource.client-configs",
  ]

  provisioner "file" {
    source      = "files/jobbatical-kubeconfig"
    destination = "/tmp/jobbatical-kubeconfig"
  }

  provisioner "file" {
    content     = "${data.template_file.configure-awscli.rendered}"
    destination = "/tmp/configure-awscli.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.mongodb-replicaset.rendered}"
    destination = "/tmp/mongodb-replicaset.yaml"
  }

  provisioner "file" {
    content     = "${data.template_file.mongodb-service.rendered}"
    destination = "/tmp/mongodb-service.yaml"
  }

  provisioner "file" {
    content     = "${data.template_file.node-todo-service.rendered}"
    destination = "/tmp/node-todo-service.yaml"
  }

  provisioner "file" {
    content     = "${data.template_file.node-todo-replicaset.rendered}"
    destination = "/tmp/node-todo-replicaset.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "sed -i '1,2d' /tmp/configure-awscli.sh",
      "chmod +x /tmp/configure-awscli.sh",
      "/bin/bash /tmp/configure-awscli.sh",
      "rm -f /tmp/configure-awscli.sh",
      "sed -i '1,2d' /tmp/jobbatical-kubeconfig",
      "mkdir -p ~/.kube",
      "mv /tmp/jobbatical-kubeconfig ~/.kube/",
      "echo 'export KUBECONFIG=~/.kube/jobbatical-kubeconfig' >> ~/.bashrc",
      "kubectl create namespace jobbatical || true",
      "kubectl apply --force -f /tmp/mongodb-replicaset.yaml -n jobbatical || true",
      "kubectl apply --force -f /tmp/mongodb-service.yaml -n jobbatical || true",
      "kubectl apply --force -f /tmp/node-todo-service.yaml -n jobbatical || true",

      //"kubectl apply --force -f /tmp/node-todo-replicaset.yaml -n jobbatical || true",
      "echo ${aws_ecr_repository.jobbatical-ecr.repository_url} > ~/dockerregistry",
    ]
  }

  provisioner "remote-exec" {
    when = "destroy"
    inline = [
      "kubectl delete svc node-todo -n jobbatical || true",
    ]
    }
}

output "jenkins-address" {
  value = "${aws_instance.jobbatical-jenkins-server.public_ip}"
}

output "jenkins-username" {
  value = "jobbatical-admin"
}

output "jenkins-password" {
  value = "j0Bb@t!c@1"
}
