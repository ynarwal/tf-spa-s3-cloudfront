
## Sample Deployment: Terraform + AWS CloudFront + S3 (Static Website Hosting)

This guide demonstrates how to deploy a Single Page Application (SPA) using a combination of Terraform, Amazon S3 (for static file hosting), and CloudFront (for global content delivery).

### Steps to Deploy

#### 1. Build the SPA

```bash
npm run build
```
#### 2. Deploy Infrastructure with Terraform
With your static files ready, you can now use Terraform to provision the required AWS resources, including:

- An S3 bucket configured for static website hosting
- A CloudFront distribution to serve your content globally with low latency


## Deployment Notes

### AWS Credentials

#### Option 1: Use AWS Named Profile (Recommended for local dev)

```ini
[terraform]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
```

Then run Terraform commands like this:

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

Apply your Terraform configuration by running:

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

