data "template_file" "configure-awscli" {
  template = "${file("./scripts/configure-awscli.tpl")}"

  vars {
    accesskey   = "${var.access_key}"
    secretkey   = "${var.secret_key}"
    profilename = "${var.profilename}"
    region      = "${var.region}"
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
