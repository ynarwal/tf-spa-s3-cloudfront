
## Sample Deployment: Terraform + AWS CloudFront + S3 (Static Website Hosting)


### AWS Credentials

#### Option 1: Use AWS Named Profile (Recommended for local dev)

```ini
[terraform]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
```

```bash
export AWS_PROFILE=terraform
```

#### Option 2: Export AWS Keys as Environment Variables

If you're running in CI (e.g., GitHub Actions) or prefer not to use a named profile, you can override credentials by exporting them directly:

```bash
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
```



### Apply terraform changes

Initialise your Terraform configuration by running:

This facilitates mulultiple environments deployment by storing states in differnet bucket or different folders within same bucket.

```bash
export AWS_REGION=
export AWS_BUCKET=
export TF_STATE_KEY=
```

```bash
terraform init \
    -backend-config="bucket=${AWS_BUCKET}" \
    -backend-config="key=${TF_STATE_KEY}" \
    -backend-config="region=${AWS_REGION}"
```

```bash
terraform apply
```


### Accessing Your Deployed Website

**Sample CloudFront URL:**  
👉 [https://d2l0jwoksfdw2a.cloudfront.net/](https://d2l0jwoksfdw2a.cloudfront.net/)

