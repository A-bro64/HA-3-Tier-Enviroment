resource "aws_vpc" "Project-VPC" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "Project_VPC"
    }
}

resource "aws_subnet" "public-subnet-1" {
    vpc_id = aws_vpc.Project-VPC.id
    cidr_block = var.public_subnet_1_cidr
    map_public_ip_on_launch = true
    availability_zone = var.public_subnet_1_availability_zone
    tags = {
        Name = "Public Subnet 1"
    }
}

resource "aws_subnet" "public-subnet-2" {
    vpc_id = aws_vpc.Project-VPC.id
    cidr_block = var.public_subnet_2_cidr
    map_public_ip_on_launch = true
    availability_zone = var.public_subnet_2_availability_zone
    tags = {
        Name = "Public Subnet 2"
    }
}

resource "aws_subnet" "private-subnet-1" {
    vpc_id = aws_vpc.Project-VPC.id
    cidr_block = var.private_subnet_1_cidr
    availability_zone = var.private_subnet_1_availability_zone
    tags = {
        Name = "Private Subnet 1"
    }
}

resource "aws_subnet" "private-subnet-2" { 
    vpc_id = aws_vpc.Project-VPC.id
    cidr_block = var.private_subnet_2_cidr
    availability_zone = var.private_subnet_2_availability_zone
    tags = {
        Name = "Private Subnet 2"
    }
}

resource "aws_subnet" "private-subnet-3" { 
    vpc_id = aws_vpc.Project-VPC.id
    cidr_block = var.private_subnet_3_cidr
    availability_zone = var.private_subnet_3_availability_zone
    tags = {
        Name = "Private Subnet 3"
    }
}

resource "aws_subnet" "private-subnet-4" { 
    vpc_id = aws_vpc.Project-VPC.id
    cidr_block = var.private_subnet_4_cidr
    availability_zone = var.private_subnet_4_availability_zone
    tags = {
        Name = "Private Subnet 4"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.Project-VPC.id
    tags = {
        Name = "Project-IGW"
    }
}

resource "aws_eip" "eip" {
    vpc=true
}
resource "aws_nat_gateway" "Project-NATGTW" {
    allocation_id = aws_eip.eip.id
    subnet_id = aws_subnet.public-subnet-1.id
    tags = {
        Name = "Project-NATGateway"
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.Project-VPC.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "Public-RT"
    }
}

resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.Project-VPC.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.Project-NATGTW.id
    }
    tags = {
        Name = "Private-RT"
    }
}

resource "aws_route_table_association" "Web_public_rt1a" {
    subnet_id = aws_subnet.public-subnet-1.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "Web_public_rt1b" {
    subnet_id = aws_subnet.public-subnet-2.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "Web_private_rt1a" {
    subnet_id = aws_subnet.private-subnet-1.id
    route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "Web_private_rt1b" {
    subnet_id = aws_subnet.private-subnet-2.id
    route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "Web_private_rt1c" {
    subnet_id = aws_subnet.private-subnet-3.id
    route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "Web_private_rt1d" {
    subnet_id = aws_subnet.private-subnet-4.id
    route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "Bastion-ssh-sg" {
    name = "Bastion-Host-SG"
    description = "Allow incoming SSH access"
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    vpc_id = aws_vpc.Project-VPC.id
    tags = {
        Name = "Bastion SSH SG"
    }
}
resource "aws_security_group" "web-http-ssh-sg" {
    name = "instance-Security-group"
    description = "Allow incoming HTTP connection and SSH access"
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    vpc_id = aws_vpc.Project-VPC.id
    tags = {
        Name = "HTTP SSH SG"
    }
}
resource "aws_security_group_rule" "web-serversg-http-rule" {
    description              = "HTTP"
    type                     = "ingress"
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.ALB-SG.id
    security_group_id        = aws_security_group.web-http-ssh-sg.id
}
resource "aws_security_group_rule" "web-serversg-ssh-rule" {
    description              = "SSH"
    type                     = "ingress"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    cidr_blocks              = [var.vpc_cidr]
    security_group_id        = aws_security_group.web-http-ssh-sg.id
}

resource "aws_security_group" "app-http-ssh-sg" {
    name = "App-instance-Security-group"
    description = "Allow incoming HTTP connection and SSH access"
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    vpc_id = aws_vpc.Project-VPC.id
    tags = {
        Name = "App HTTP SSH SG"
    }
}
resource "aws_security_group_rule" "app-serversg-http-rule" {
    description              = "HTTP"
    type                     = "ingress"
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.App-Server-ALB-SG.id
    security_group_id        = aws_security_group.app-http-ssh-sg.id
}
resource "aws_security_group_rule" "app-serversg-ssh-rule" {
    description              = "SSH"
    type                     = "ingress"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    cidr_blocks              = [var.vpc_cidr]
    security_group_id        = aws_security_group.app-http-ssh-sg.id
}

resource "aws_network_acl" "Web-ACL" {
    vpc_id = aws_vpc.Project-VPC.id
    subnet_ids = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id, aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]
    ingress {
        protocol   = "tcp"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 80
        to_port    = 80
    }
     ingress {
        protocol   = "tcp"
        rule_no    = 200
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 22
        to_port    = 22
    }
    ingress {
        protocol   = "tcp"
        rule_no    = 300
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 32768
        to_port    = 65353
    }
    ingress {
        protocol   = "tcp"
        rule_no    = 400
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 443
        to_port    = 443
    }
    egress {
        protocol   = "-1"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 0
        to_port    = 0
    }
    tags = {
        Name = "Web-ACL"
  }
}

resource "aws_security_group" "ALB-SG" {
    name = "Web-ALB-Security-Group"
    description = "Allow incoming HTTP connection"
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }   
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    vpc_id = aws_vpc.Project-VPC.id
    tags = {
        Name = "ALB Security Group"
    }
}

resource "aws_security_group" "App-Server-ALB-SG" {
    name = "App Server ALB SG"
    description = "Allow incoming HTTP connection"
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    vpc_id = aws_vpc.Project-VPC.id
    tags = {
        Name = "App Server ALB SG"
    }
}
resource "aws_security_group_rule" "App-Server-ALB-SG-Rule" {
    description              = "HTTP"
    type                     = "ingress"
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.web-http-ssh-sg.id
    security_group_id = aws_security_group.App-Server-ALB-SG.id
}

resource "aws_lb" "web-alb" {
    name = "Web-Project-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.ALB-SG.id]
    subnets = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id ]
    ip_address_type = "ipv4"
    tags = {
        Name = "Web-Project-ALB"
    }
}

resource "aws_lb_target_group" "web-project-tg" {
    name = "Web-Project-target-group"
    port = 80
    protocol = "HTTP"
    target_type = "instance"
    vpc_id   = aws_vpc.Project-VPC.id
}

resource "aws_lb_listener" "ALB-Listener" {
    load_balancer_arn = aws_lb.web-alb.arn
    port = 80
    protocol = "HTTP"
    default_action {
        target_group_arn = aws_lb_target_group.web-project-tg.arn
        type = "forward"
    }
}

resource "aws_lb_target_group_attachment" "project-tg-Attachement-a" {
    target_group_arn = aws_lb_target_group.web-project-tg.arn
    target_id        = aws_instance.Project-Web-tier-1.id
}

resource "aws_lb_target_group_attachment" "project-tg-Attachement-b" {
    target_group_arn = aws_lb_target_group.web-project-tg.arn
    target_id        = aws_instance.Project-Web-tier-2.id
}

resource "aws_lb" "app-alb" {
    name = "App-Project-alb"
    internal           = true
    load_balancer_type = "application"
    security_groups = [aws_security_group.App-Server-ALB-SG.id]
    subnets = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id ]
    ip_address_type = "ipv4"
    tags = {
        Name = "App-Project-ALB"
    }
}

resource "aws_lb_target_group" "app-project-tg" {
    name = "App-Project-target-group"
    port = 80
    protocol = "HTTP"
    target_type = "instance"
    vpc_id   = aws_vpc.Project-VPC.id
}

resource "aws_lb_listener" "App-ALB-Listener" {
    load_balancer_arn = aws_lb.app-alb.arn
    port = 80
    protocol = "HTTP"
    default_action {
        target_group_arn = aws_lb_target_group.app-project-tg.arn
        type = "forward"
    }
}

resource "aws_lb_target_group_attachment" "App-project-tg-Attachement-a" {
    target_group_arn = aws_lb_target_group.app-project-tg.arn
    target_id        = aws_instance.Project-App-tier-1.id
}                     

resource "aws_lb_target_group_attachment" "App-project-tg-Attachement-b" {
    target_group_arn = aws_lb_target_group.app-project-tg.arn
    target_id        = aws_instance.Project-App-tier-2.id
}

resource "aws_instance" "Bastion_host_instance" {
    ami                    = var.instance_image_id
    instance_type          = var.instance_type
    vpc_security_group_ids = [aws_security_group.Bastion-ssh-sg.id]
    subnet_id = aws_subnet.public-subnet-1.id
    tags = {
        Name = "Bastion_host"
    }  
    key_name = var.instance_private_key
}

resource "aws_instance" "Project-Web-tier-1" {
    ami                    = var.instance_image_id
    instance_type          = var.instance_type
    vpc_security_group_ids = [aws_security_group.web-http-ssh-sg.id]
    subnet_id = aws_subnet.private-subnet-1.id
    user_data = <<-EOF
            #!/bin/bash
            sudo su
            yum update -y
            yum install httpd php php-mysql -y
            cd /var/www/html
            echo "healthy" > healthy.html
            wget https://wordpress.org/wordpress-5.1.1.tar.gz
            tar -xzf wordpress-5.1.1.tar.gz
            cp -r wordpress/* /var/www/html/
            rm -rf wordpress
            rm -rf wordpress-5.1.1.tar.gz
            chmod -R 755 wp-content
            chown -R apache:apache wp-content
            wget https://s3.amazonaws.com/bucketforwordpresslab-donotdelete/htaccess.txt
            mv htaccess.txt .htaccess
            chkconfig httpd on
            systemctl start httpd
            EOF
    tags = {
        Name = "Web-Server-1"
    }  
    key_name = var.instance_private_key  
}

resource "aws_instance" "Project-Web-tier-2" {
    ami                    = var.instance_image_id
    instance_type          = var.instance_type
    vpc_security_group_ids = [aws_security_group.web-http-ssh-sg.id]
    subnet_id = aws_subnet.private-subnet-2.id
    user_data = <<-EOF
            #!/bin/bash
            sudo su
            yum update -y
            yum install httpd php php-mysql -y
            cd /var/www/html
            echo "healthy" > healthy.html
            wget https://wordpress.org/wordpress-5.1.1.tar.gz
            tar -xzf wordpress-5.1.1.tar.gz
            cp -r wordpress/* /var/www/html/
            rm -rf wordpress
            rm -rf wordpress-5.1.1.tar.gz
            chmod -R 755 wp-content
            chown -R apache:apache wp-content
            wget https://s3.amazonaws.com/bucketforwordpresslab-donotdelete/htaccess.txt
            mv htaccess.txt .htaccess
            chkconfig httpd on
            systemctl start httpd
            EOF
    tags = {
        Name = "Web-Server-2"
    }  
    key_name = var.instance_private_key  
}

resource "aws_instance" "Project-App-tier-1" {
    ami                    = var.instance_image_id
    instance_type          = var.instance_type
    vpc_security_group_ids = [aws_security_group.app-http-ssh-sg.id]
    subnet_id = aws_subnet.private-subnet-3.id
    user_data = <<-EOF
            #!/bin/bash
            yum -y install httpd php mysql php-mysql
            chkconfig httpd on
            service httpd start
            if [ ! -f /var/www/html/lab-app.tgz ]; then
            cd /var/www/html
            wget https://aws-tc-largeobjects.s3-us-west-2.amazonaws.com/CUR-TF-200-ACACAD/studentdownload/lab-app.tgz
            tar xvfz lab-app.tgz
            chown apache:root /var/www/html/rds.conf.php
            fi
            EOF
    tags = {
        Name = "App-Server-1"
    }  
    key_name = var.instance_private_key  
}

resource "aws_instance" "Project-App-tier-2" {
    ami                    = var.instance_image_id
    instance_type          = var.instance_type
    vpc_security_group_ids = [aws_security_group.app-http-ssh-sg.id]
    subnet_id = aws_subnet.private-subnet-4.id
    user_data = <<-EOF
            #!/bin/bash
            yum -y install httpd php mysql php-mysql
            chkconfig httpd on
            service httpd start
            if [ ! -f /var/www/html/lab-app.tgz ]; then
            cd /var/www/html
            wget https://aws-tc-largeobjects.s3-us-west-2.amazonaws.com/CUR-TF-200-ACACAD/studentdownload/lab-app.tgz
            tar xvfz lab-app.tgz
            chown apache:root /var/www/html/rds.conf.php
            fi
            EOF
    tags = {
        Name = "App-Server-2"
    }  
    key_name = var.instance_private_key  
}

resource "aws_launch_template" "web_template" {
    name = "Web-Project_LT"
    instance_type = var.instance_type
    key_name = var.instance_private_key
    image_id = var.instance_image_id
    vpc_security_group_ids = [aws_security_group.web-http-ssh-sg.id]
    user_data = base64encode(file("webuserdata.sh"))
}

resource "aws_autoscaling_group" "Web-asg" {
    vpc_zone_identifier   = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]
    name                 = "web-project-asg"
    max_size             = var.asg_max
    min_size             = var.asg_min
    desired_capacity     = var.asg_desired
    health_check_grace_period = "300"
    health_check_type = "ELB"
    force_delete         = true
    launch_template {
        id = aws_launch_template.web_template.id
        version = "$Latest"
    }
    target_group_arns = [aws_lb_target_group.web-project-tg.arn] 
    tag {
        key                 = "Name"
        value               = "Web-Server"
        propagate_at_launch = "true"
    }
}

resource "aws_autoscaling_policy" "Web-Scale-Up-Policy" {
    name                   = "Web-Scale-up-policy"
    scaling_adjustment     = 1
    adjustment_type        = "ChangeInCapacity"
    cooldown               = 300
    autoscaling_group_name = aws_autoscaling_group.Web-asg.name
    policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "Web-Alarm-To-Scale-Up" {
    alarm_name          = "CPU-Utilization-Web-Scale-Up-Alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = "2"
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = "120"
    statistic           = "Average"
    threshold           = "75"
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.Web-asg.name
    }
    actions_enabled = true
    alarm_actions     = [aws_autoscaling_policy.Web-Scale-Up-Policy.arn]
}

resource "aws_autoscaling_policy" "Web-Scale-Down-Policy" {
    name                   = "Web-Scale-Down-policy"
    scaling_adjustment     = -1
    adjustment_type        = "ChangeInCapacity"
    cooldown               = 300
    autoscaling_group_name = aws_autoscaling_group.Web-asg.name
    policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "Web-Alarm-To-Scale-Down" {
    alarm_name          = "CPU-Utilization-Web-Scale-Down-Alarm"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods  = "2"
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = "300"
    statistic           = "Average"
    threshold           = "30"
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.Web-asg.name
    }
    actions_enabled = true
    alarm_actions     = [aws_autoscaling_policy.Web-Scale-Down-Policy.arn]
}

resource "aws_launch_template" "app_template" {
    name = "App-Project_LT"
    instance_type = var.instance_type
    key_name = var.instance_private_key
    image_id = var.instance_image_id
    vpc_security_group_ids = [aws_security_group.app-http-ssh-sg.id]
    user_data = base64encode(file("appuserdata.sh"))
}

resource "aws_autoscaling_group" "App-asg" {
    vpc_zone_identifier   = [aws_subnet.private-subnet-3.id, aws_subnet.private-subnet-4.id]
    name                 = "app-project-asg"
    max_size             = var.asg_max
    min_size             = var.asg_min
    desired_capacity     = var.asg_desired
    health_check_grace_period = "300"
    health_check_type = "ELB"
    force_delete = true
    launch_template {
        id = aws_launch_template.app_template.id
        version = "$Latest"
    }
    target_group_arns = [aws_lb_target_group.app-project-tg.arn] 
    tag {
        key                 = "Name"
        value               = "Web-Server"
        propagate_at_launch = "true"
    }
}

resource "aws_autoscaling_policy" "App-Scale-Up-Policy" {
    name                   = "App-Scale-up-policy"
    scaling_adjustment     = 1
    adjustment_type        = "ChangeInCapacity"
    cooldown               = 300
    autoscaling_group_name = aws_autoscaling_group.App-asg.name
    policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "App-Alarm-To-Scale-Up" {
    alarm_name          = "CPU-Utilization-App-Scale-Up-Alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = "2"
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = "120"
    statistic           = "Average"
    threshold           = "75"
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.App-asg.name
    }
    actions_enabled = true
    alarm_actions     = [aws_autoscaling_policy.App-Scale-Up-Policy.arn]
}

resource "aws_autoscaling_policy" "App-Scale-Down-Policy" {
    name                   = "App-Scale-Down-policy"
    scaling_adjustment     = -1
    adjustment_type        = "ChangeInCapacity"
    cooldown               = 300
    autoscaling_group_name = aws_autoscaling_group.App-asg.name
    policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "App-Alarm-To-Scale-Down" {
    alarm_name          = "CPU-Utilization-App-Scale-Down-Alarm"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods  = "2"
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = "300"
    statistic           = "Average"
    threshold           = "30"
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.App-asg.name
    }
    actions_enabled = true
    alarm_actions     = [aws_autoscaling_policy.App-Scale-Down-Policy.arn]
}

resource "aws_sns_topic" "httperror400" {
    name = "httperror400"
    delivery_policy = <<EOF
{
    "http": {
        "defaultHealthyRetryPolicy": {
            "minDelayTarget": 20,
            "maxDelayTarget": 20,
            "numRetries": 3,
            "numMaxDelayRetries": 0,
            "numNoDelayRetries": 0,
            "numMinDelayRetries": 0,
            "backoffFunction": "linear"
        },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
        "maxReceivesPerSecond": 1
    }
  }
}
EOF
}

resource "aws_cloudwatch_metric_alarm" "http-400-alarm" {
    alarm_name                = "http400-alarm"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "2"
    metric_name               = "http400"
    namespace                 = "AWS/ApplicationELB"
    period                    = "60"
    statistic                 = "Sum"
    threshold                 = "100"
    alarm_description         = "This metric monitors http error 400"
    alarm_actions             = [aws_sns_topic.httperror400.arn]
    ok_actions                = [aws_sns_topic.httperror400.arn]
}

resource "aws_route53_record" "www" {
    zone_id = var.zone_id
    name    = var.route53_dns 
    type    = "A"
    alias {
        name = aws_lb.web-alb.dns_name
        zone_id = aws_lb.web-alb.zone_id
        evaluate_target_health = true
    }
}

resource "aws_db_instance" "default" {
 db_subnet_group_name = aws_db_subnet_group.gogreen_subnet_group.id
  # DB instance size
  allocated_storage    = 20
  max_allocated_storage = 100
  storage_type         = "gp2"
  instance_class       = "db.t2.micro"
  # Engine options
  engine               = "mysql"
  engine_version       = "5.7"
  # DB instance identifier
  identifier           = "database-project"
  name                 = "ProjectDB"
  username             = "admin"
  password             = "password"
  # Availity & durability
  #multi_az             = "true"
  #availability_zone    = "us-west-1b"
  # Connectivity
  port                 = "3306"
  #vpc_security_group_ids = ["${aws_security_group.MySQL-DB-SG.id}"]
  # Additional configuration
  parameter_group_name = "default.mysql5.7"
  storage_encrypted    = "false"
  skip_final_snapshot  = "true"
  publicly_accessible  = "false"
  # DB deletion protection
  deletion_protection  = "false"
}  
resource "aws_db_subnet_group"  "gogreen_subnet_group" {
  name       = "gogreen_subnet_group"
  subnet_ids = [aws_subnet.BD-subnet-1.id, aws_subnet.BD-subnet-2.id]
  tags       = {
    name = "gogreen_subnet_group"
  }
}

resource "aws_subnet" "BD-subnet-1" { 
    vpc_id = aws_vpc.Project-VPC.id
    cidr_block = var.DB_subnet_1_cidr
    availability_zone = var.DB_subnet_1_availability_zone
    tags = {
        Name = "DB Subnet 1"
    }
}

resource "aws_subnet" "BD-subnet-2" { 
    vpc_id = aws_vpc.Project-VPC.id
    cidr_block = var.DB_subnet_2_cidr
    availability_zone = var.DB_subnet_2_availability_zone
    tags = {
        Name = "DB Subnet 2"
    }
}

resource "aws_route_table_association" "DB_rt_1" {
    subnet_id = aws_subnet.BD-subnet-1.id
    route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "DB_rt_2" {
    subnet_id = aws_subnet.BD-subnet-2.id
    route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "MySQL-DB-SG" {
   name         = "MySQL-DB-SG"
   description  = "3-Tier DB security group"
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    vpc_id = aws_vpc.Project-VPC.id
    tags = {
        Name = "MySQL DB SG"
    }
}
resource "aws_security_group_rule" "DB-server-mysql-sg-rule" {
    description              = "MySQL/Aurora"
    type                     = "ingress"
    from_port                = 3306
    to_port                  = 3306
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.app-http-ssh-sg.id
    security_group_id        = aws_security_group.MySQL-DB-SG.id
}
resource "aws_security_group_rule" "DB-server-ssh-sg-rule" {
    description              = "SSH"
    type                     = "ingress"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    cidr_blocks              = [var.vpc_cidr]
    security_group_id        = aws_security_group.MySQL-DB-SG.id
}
