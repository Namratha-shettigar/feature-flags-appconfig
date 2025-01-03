# AWS AppConfig Feature Flags Setup with Terraform

This repository contains Terraform code to automate the creation of AWS AppConfig resources for managing feature flags. The setup includes:

- Creating an AWS AppConfig Application.
- Setting up an AppConfig Environment.
- Creating a Configuration Profile.
- Deploying flags from a JSON file with all flags set to `false` by default.
- Managing the deployment of these flags to the specified environment.

This setup uses AWS Cognito for authentication and AWS AppConfig for dynamic feature flag management, allowing for scalable, secure, and dynamic control of application features without requiring code redeployment.

For more details on integrating feature flags into your web application, you can check out my article on medium:
link: https://medium.com/@namrathashettigar2001/implementing-feature-flags-in-a-web-application-using-aws-appconfig-caee361ea83e.
