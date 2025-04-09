resource "aws_s3_bucket" "s3_bucket_special" {
    bucket = "our-s3-bucket-special-001"
    
    tags = {
        Name = "our-s3-bucket-tag"
    }
}

resource "aws_s3_bucket" "s3_bucket_special_2" {
    bucket = "our-s3-bucket-special-002"
    
    tags = {
        Name = "our-s3-bucket-tag"
    }
}