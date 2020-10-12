# GCS bucket for storing our uploaded function zip.
# @see https://www.terraform.io/docs/providers/google/r/storage_bucket.html
resource "google_storage_bucket" "function_artifacts" {
  name = "${var.project}-function-artifacts"
}

# GCS Object for our hello_world function zip.
# @see https://www.terraform.io/docs/providers/google/r/storage_bucket_object.html
resource "google_storage_bucket_object" "hello_world_gcf" {
  name   = "${var.environment}_hello_world_gcf/${timestamp()}.zip"
  bucket = google_storage_bucket.function_artifacts.name
  source = "functions.zip"
}

# Define our function
# @see https://www.terraform.io/docs/providers/google/r/cloudfunctions_function.html
resource "google_cloudfunctions_function" "hello_world" {
  # Make the name unique per environment!
  name    = "${var.environment}-helloWorld"
  runtime = "nodejs10"

  # The exported function we wish to execute from within build/src/index.js
  entry_point = "helloWorld"

  source_archive_bucket = google_storage_bucket.function_artifacts.id
  source_archive_object = google_storage_bucket_object.hello_world_gcf.output_name

  # Our service account that only allows this function to write to logs and metrics.
  service_account_email = google_service_account.hello_world_gcf.email

  # Allow our function to be triggered via http requests.
  trigger_http = true

}

# Allow our cloud function to invoked by all users - WARNING this make your cloud function public.
# be sure to check the docs and consider if this is really what you want.
# @see https://www.terraform.io/docs/providers/google/r/cloudfunctions_cloud_function_iam.html
resource "google_cloudfunctions_function_iam_member" "hello_world" {
  cloud_function = google_cloudfunctions_function.hello_world.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}

# A service account just for our helloWorld function.
# this ensures our cloud function only has the absolute minimum needed permissions.
# @see https://www.terraform.io/docs/providers/google/r/google_service_account.html
resource "google_service_account" "hello_world_gcf" {
  provider     = google-beta
  account_id   = "${var.environment}-gcf-helloworld"
  display_name = "${var.environment}-gcf-helloworld"
}

# Add the monitoring.metricWriter role to our service account.
# @see https://www.terraform.io/docs/providers/google/r/google_project_iam.html#google_project_iam_member
resource "google_project_iam_member" "hello_world_gcf_monitoring_writer" {
  provider = google-beta
  role     = "roles/monitoring.metricWriter"
  member   = "serviceAccount:${google_service_account.hello_world_gcf.email}"
}

# Add the logging.logWriter role to our service account.
# @see https://www.terraform.io/docs/providers/google/r/google_project_iam.html#google_project_iam_member
resource "google_project_iam_member" "hello_world_gcf_logging_writer" {
  provider = google-beta
  role     = "roles/logging.logWriter"
  member   = "serviceAccount:${google_service_account.hello_world_gcf.email}"
}
