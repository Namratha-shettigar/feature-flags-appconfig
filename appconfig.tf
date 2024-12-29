provider "aws" {
  region = "your-aws-region"
  alias = "deployment-ca"   # Specify a default AWS region here
  profile = "site2gym-${var.STAGE}"
}


resource "aws_appconfig_application" "application" {
  name        = "${var.STAGE}-application"
  description = "AppConfig Application"
  provider = aws.deployment-ca
}


resource "aws_appconfig_configuration_profile" "profile"{
  application_id = aws_appconfig_application.application.id
  description    =  "Configuration Profile"
  name           = "${var.STAGE}-profile"
  location_uri = "hosted"
  type           = "AWS.AppConfig.FeatureFlags"  # Specify the Feature Flags configuration type
  provider = aws.deployment-ca
  
}
resource "aws_appconfig_environment" "environment" {
  application_id = aws_appconfig_application.application.id
  name           = var.STAGE
  description    = "Environment for application"
  provider = aws.deployment-ca
}

# Fetch the latest hosted configuration version
data "aws_appconfig_configuration_profile" "example" {
  application_id           = aws_appconfig_application.application.id
  configuration_profile_id = aws_appconfig_configuration_profile.profile.configuration_profile_id
  provider = aws.deployment-ca
}



# AppConfig Deployment Strategy (Full Deployment at Once)
resource "aws_appconfig_deployment_strategy" "full_deployment" {
  name                        = "FullDeploymentStrategy"
  description                 = "Deploy all configuration changes at once"
  deployment_duration_in_minutes = 1
  growth_factor               = 100
  growth_type                 = "EXPONENTIAL"
  replicate_to                = "NONE"  # No replication to SSM documents
  provider = aws.deployment-ca

}


resource "aws_appconfig_hosted_configuration_version" "config" {
  depends_on = [resource.null_resource.run_script]
  application_id           = aws_appconfig_application.application.id
  configuration_profile_id = aws_appconfig_configuration_profile.profile.configuration_profile_id
  description              = "Feature Flag Configuration Version"
  content_type             = "application/json"
  content = jsonencode(jsondecode(file("${path.module}/flags.json")))

  provider = aws.deployment-ca
}

resource "aws_appconfig_deployment" "deployment" {
  depends_on = [ aws_appconfig_deployment_strategy.full_deployment ]
  application_id          = aws_appconfig_application.application.id
  configuration_profile_id = aws_appconfig_configuration_profile.profile.configuration_profile_id
  environment_id          = aws_appconfig_environment.environment.environment_id
  configuration_version   = aws_appconfig_hosted_configuration_version.config.version_number
  deployment_strategy_id  =  aws_appconfig_deployment_strategy.full_deployment.id
  provider = aws.deployment-ca
}




resource "aws_ssm_parameter" "environment_id" {
  name  = "ENVIORNMENT_ID"
  type  = "String"
  value = aws_appconfig_environment.environment.environment_id
  provider = aws.deployment-ca
  overwrite = true
}

resource "aws_ssm_parameter" "configuration_id" {
  name  = "CONFIGURATION_ID"
  type  = "String"
  value = aws_appconfig_configuration_profile.profile.configuration_profile_id
  provider = aws.deployment-ca
  overwrite = true
}
resource "aws_ssm_parameter" "application_id" {
  name  = "APPLICATION_ID"
  type  = "String"
  value = aws_appconfig_application.application.id
  provider = aws.deployment-ca
  overwrite = true
}
resource "aws_ssm_parameter" "deployment" {
  name  = "DEPLOYMENT_STRATEGY_ID"
  type  = "String"
  value = aws_appconfig_deployment_strategy.full_deployment.id
  provider = aws.deployment-ca
  overwrite = true
}


