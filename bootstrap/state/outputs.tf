output "state_bucket_names" {
  description = "Bucket name per environment; these must match the bucket in envs/<env>/<env>.tfbackend"
  value       = { for env, bucket in aws_s3_bucket.state : env => bucket.bucket }
}
