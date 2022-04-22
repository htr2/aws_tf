# aws_tf_initial setup...

this is kept deliberately seperate and intended to assist enabling an new aws account for subsequent tf management 

 Markup :

    - requires manual steps from linux:
        - install terraform
        - install aws cli
        - create new aws management account https://portal.aws.amazon.com/billing/signup#/start/email
        - login as root user
        - add mfa to root
        - under myaccount settings edit "IAM User and Role Access to Billing Information" to "activate iam"
        - under billing preferences enable pdf, free tier usage alerts and billing alerts 
        - under iam create aws temp-user for programatic access: tf, assign admin rights, 
        - save key and secret to ~/.aws/credentials [default]
        - edit iam.tf with account id
        - terraform init
        - terraform apply
        - record access credentials
        - delete tf user
        - enable mfa for admin user
        - delete ~/.aws/credentials

    - creates 
        - account alias
        - administrator group with admin rights and enforced mfa (even for programatic access)
        - admin user
        - billing alerts
        - organisation with prod and dev account

