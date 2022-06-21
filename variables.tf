variable "region" {
    type    = string
    default = "ap-south-1"
}

variable "network_cidr" {
    type    = string
    default = "10.0.0.0/16"

}

variable "subnet_name_tags" {
    type    = list(string)
    default = [ "Public-1", "Public-1", "private-1", "private-2",  ]

}

variable "bucket_name" {
    type    = string
    default = "patlolla_sample"

} 
