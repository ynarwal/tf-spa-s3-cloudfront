
## 📦 Sample Deployment: Terraform + AWS CloudFront + S3 (Static Website Hosting)

This guide demonstrates how to deploy a Single Page Application (SPA) using a combination of Terraform, Amazon S3 (for static file hosting), and CloudFront (for global content delivery).

### 🚀 Steps to Deploy

#### 1. Build the SPA
Start by generating a production-ready version of your Single Page Application using your frontend framework's build command.

```bash
npm run build
```

This command compiles your application and outputs the static assets (HTML, CSS, JavaScript, etc.) into a `build/` or `dist/` directory, depending on your project configuration.

#### 2. Deploy Infrastructure with Terraform
With your static files ready, you can now use Terraform to provision the required AWS resources, including:

- An S3 bucket configured for static website hosting
- A CloudFront distribution to serve your content globally with low latency
- Optional: Route53 DNS configuration (if you want to use a custom domain)

Apply your Terraform configuration by running:

```bash
terraform apply
```

Terraform will prompt you to confirm the execution and then provision the infrastructure defined in your `.tf` files.

### 🌐 Accessing Your Deployed Website

Once the deployment is complete, your application will be accessible via the CloudFront distribution URL. For example:

**Sample CloudFront URL:**  
👉 [https://d2l0jwoksfdw2a.cloudfront.net/](https://d2l0jwoksfdw2a.cloudfront.net/)

