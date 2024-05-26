resource "aws_lb" "alb" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [ aws_security_group.alb.id ]
  subnets = [ aws_subnet.sn1.id, aws_subnet.sn4.id, aws_subnet.sn3.id ]
}

resource "aws_lb_target_group" "fruit" {
  name     = "fruit-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "fruita" {
  target_group_arn = aws_lb_target_group.fruit.arn
  target_id        = aws_instance.webs1.id
  port             = 80
}

resource "aws_lb_target_group" "vegetable" {
  name     = "vegetable-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "vegetablea" {
  target_group_arn = aws_lb_target_group.vegetable.arn
  target_id        = aws_instance.web2.id
  port             = 80
}

resource "aws_lb_listener" "fruitlis" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fruit.arn
  }
}


resource "aws_lb_listener_rule" "fruitlisr" {
  listener_arn = aws_lb_listener.fruitlis.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fruit.arn
  }

  condition {
    path_pattern {
      values = ["/fruit/*"]
    }
  }
}

resource "aws_lb_listener_rule" "vegetablelisr" {
  listener_arn = aws_lb_listener.fruitlis.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vegetable.arn
  }

  condition {
    path_pattern {
      values = ["/vegetable/*"]
    }
  }
}