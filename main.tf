module "s3_bucket" {
    source = "./modules/s3"
}

module "ec2_iam" {
    source = "./modules/iam"
}