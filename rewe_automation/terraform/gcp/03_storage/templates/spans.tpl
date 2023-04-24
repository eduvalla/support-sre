spans_location {
  s3 {
    storage_class = "${storage_class}"
    access_key = "${access_key}"
    secret_key = "${secret_key}"
    endpoint = "${endpoint}"
    region = "${region}"
    bucket = "${bucket_name}"
    prefix = "onprem"
    storage_class_long_term = "${storage_class}"
    bucket_long_term = "${bucket_name}"
    prefix_long_term = "longterm-onprem"
  }
}