output "web-tier-security_group" {
    value = aws_security_group.web-http-ssh-sg.id
}

output "web-target-group" {
    value = aws_lb_target_group.web-project-tg.id
}

output "app-target-group" {
    value = aws_lb_target_group.app-project-tg.id
}

output "aws-web-alb" {
    value = aws_lb.web-alb.id
}
