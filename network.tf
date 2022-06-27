
resource "aws_vpc" "patlolla" {
    cidr_block      = var.network_cidr
    tags            = {
        Name        = "patlolla"
    } 
}   
# resource "aws_lb_target_group" "my_target_group" {
#     health_check {
#         interval =              10
#         path =                  "/index.html"
#         protocol =              "HTTP"
#         timeout =               5
#         healthy_threshold =     5
#         unhealthy_threshold =   2
#     }
#     name     = "tf-example-lb-tg"
#     port     = 80
#     protocol = "HTTP"
#     vpc_id   = var.vpc_id
# }

resource "aws_subnet" "subnets" {
    count           = length(var.subnet_name_tags) 
    cidr_block      = cidrsubnet(var.network_cidr,8,count.index)
    tags            = {
        Name        = var.subnet_name_tags[count.index]
    } 
    availability_zone = format("${var.region}%s", count.index%2==0?"a":"b")
    vpc_id          = aws_vpc.patlolla.id 
}


resource "aws_internet_gateway" "patlolla_igw" {
    vpc_id          = aws_vpc.patlolla.id
    tags            = {
        Name        = "patlolla-igw"
    } 

}

resource "aws_s3_bucket" "my_bucket" {
    bucket          = var.bucket_name 

}

resource "aws_security_group" "websg" {
    vpc_id              = aws_vpc.patlolla.id
    description         = local.default_description
    ingress {
        from_port       = local.ssh_port
        to_port         = local.ssh_port
        protocol        = local.tcp
        cidr_blocks     = [local.any_where]
    } 
    ingress {
        from_port       = local.http_port
        to_port         = local.http_port
        protocol        = local.tcp
        cidr_blocks     = [local.any_where]
    }
    egress {
        from_port       = local.all_ports
        to_port         = local.all_ports
        protocol        = local.any_protocol
        cidr_blocks      = [var.network_cidr]
        ipv6_cidr_blocks = [local.any_where_ip6]
    }
    tags = {
        Name            = "Web Security"
    } 

}

resource "aws_security_group" "appsg" {
    vpc_id              = aws_vpc.patlolla.id
    description         = local.default_description
    ingress {
        from_port       = local.ssh_port
        to_port         = local.ssh_port
        protocol        = local.tcp
        cidr_blocks     = [local.any_where]
    } 
    ingress {
        from_port       = local.app_port
        to_port         = local.app_port
        protocol        = local.tcp
        cidr_blocks     = [var.network_cidr]
    }
    egress {
        from_port       = local.all_ports
        to_port         = local.all_ports
        protocol        = local.any_protocol
        cidr_blocks      = [var.network_cidr]
        ipv6_cidr_blocks = [local.any_where_ip6]
    }
    tags = {
        Name            = "App Security Group"
    } 

}
} 
resource "aws_route_table" "publicrt" {
    vpc_id          =  aws_vpc.patlolla.id
    route {
        cidr_block  = local.any_where
        gateway_id  = aws_internet_gateway.patlolla_igw.id
    }
    tags            = {
        Name        = "Public RT"
    } 
}

resource "aws_route_table" "privatert" {
    vpc_id          =  aws_vpc.patlolla.id

    tags            = {
        Name        = "Private RT"
    } 
}

resource "aws_route_table_association" "associations" {
    count               = length(aws_subnet.subnets)
    subnet_id           = aws_subnet.subnets[count.index].id
    route_table_id      = contains(var.public_subnets, lookup(aws_subnet.subnets[count.index].tags_all, "Name", ""))?aws_route_table.public.id :  aws_route_table.privat
