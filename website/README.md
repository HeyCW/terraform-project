# Terraform - The Easiest Way to Deploy a Website on AWS 🚀

If you've ever deployed a website manually on AWS, you probably know how repetitive it can get. Create a VPC, create a subnet, configure a route table, launch an EC2 instance... and before you know it, you've clicked through dozens of pages in the AWS Console.

This is where **Terraform** shines. Instead of clicking around, we can describe our infrastructure as code and let Terraform build everything for us.

In this article, we'll deploy a simple website using **just one EC2 instance**. Before writing any Terraform code, let's first understand the AWS networking components that make everything work.

---

# VPC

Think of a **VPC (Virtual Private Cloud)** as your own private network inside AWS. Every AWS resource that needs networking—such as an EC2 instance, RDS database, or Load Balancer—lives inside a VPC.

A VPC is responsible for the networking components, including:

* Subnets
* Route Tables
* Internet Gateway
* NAT Gateway
* Security Groups
* Elastic IP (EIP)

Don't worry if some of these sound unfamiliar. We'll go through each one briefly.

---

# Subnet

A **Subnet** is simply a smaller network inside your VPC.

Imagine your VPC is an apartment building, and each subnet is a different floor. Every EC2 instance must live on one of those floors.

There are generally two types of subnets:

* **Public Subnet** – Resources can communicate directly with the internet.
* **Private Subnet** – Resources stay hidden from the internet and can only communicate internally (or through a NAT Gateway).

Since we're deploying a website that users need to access, we'll place our EC2 instance in a **public subnet**.

---

# Internet Gateway (IGW)

Having your EC2 inside a public subnet isn't enough.

Your VPC also needs an **Internet Gateway**, which acts as the bridge between your VPC and the internet.

Without an Internet Gateway, your EC2 instance won't be reachable from outside AWS—even if it has a public IP address.

Think of it as the main entrance to your apartment building. Without the entrance, nobody can get in.

---

# Route Table

A **Route Table** tells AWS where network traffic should go.

For example:

* Local traffic stays inside the VPC.
* Internet traffic (`0.0.0.0/0`) is sent to the Internet Gateway.

Without the correct route, AWS simply doesn't know where to send your traffic.

---

# Security Group

A **Security Group** acts like a firewall for your EC2 instance.

It controls which traffic is allowed to enter and leave your server.

For a simple web server, we'll typically allow:

* **Port 22** → SSH (so we can connect to the server)
* **Port 80** → HTTP
* **Port 443** → HTTPS

Everything else stays blocked unless we explicitly allow it.

A good rule of thumb is to only open the ports you actually need.

---

# Elastic IP (Optional)

Normally, every time you stop and start an EC2 instance, its public IP address changes.

If you want a permanent public IP, AWS provides an **Elastic IP (EIP)**.

For a learning project, you can skip this. But for production workloads, having a static IP can be useful if your DNS points directly to the server.

---

# EC2 Instance

Finally, we arrive at the star of this tutorial: the **EC2 instance**.

EC2 is simply a virtual machine running in AWS.

This is where we'll install our web server (such as Nginx or Apache) and host our website.

To make the EC2 instance accessible from the internet, we need:

* A VPC
* A Public Subnet
* An Internet Gateway
* A Route Table that routes internet traffic to the Internet Gateway
* A Security Group that allows HTTP (and optionally SSH)
* A Public IP Address

Once all of these pieces are connected, visitors can simply open your server's public IP in their browser and see your website.

---

Now that we understand the networking architecture, it's time for the fun part—**writing Terraform code** to create everything automatically in just a few commands. One of the best things about Terraform is that every AWS resource is just a block of code. Instead of manually creating resources through the AWS Console, we simply define our infrastructure and let Terraform do the work.

Let's go through the configuration section by section.

---

# 1. Configure Terraform and AWS Provider

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}
```

The first block tells Terraform which provider we want to use.

In this case, we're using the **AWS Provider**, version **5.x**, and deploying everything into the **Singapore Region (`ap-southeast-1`)**.

Think of the provider as Terraform's translator—it knows how to communicate with AWS APIs.

---

# 2. Find the Latest Amazon Linux AMI

```hcl
data "aws_ami" "amazon_linux" {
    ...
}
```

Instead of hardcoding an AMI ID, we ask AWS to find the latest Amazon Linux 2 image automatically.

Why is this useful?

Because AMI IDs are different for every region and change over time. By using a data source, our Terraform configuration always launches the latest supported image without us updating the code.

---

# 3. Create a VPC

```hcl
resource "aws_vpc" "main" {
    ...
}
```

This creates our own private network with the CIDR block:

```
10.0.0.0/16
```

A `/16` network provides over **65,000 private IP addresses**, giving us plenty of room to create multiple subnets later.

Everything else in this project will live inside this VPC.

---

# 4. Create Public and Private Subnets

```hcl
resource "aws_subnet" "public_subnet" {
    ...
}

resource "aws_subnet" "private_subnet" {
    ...
}
```

Here we split our VPC into two smaller networks.

### Public Subnet

```
10.0.1.0/24
```

Notice this line:

```hcl
map_public_ip_on_launch = true
```

This tells AWS:

> "Whenever an EC2 instance is launched in this subnet, automatically assign it a public IP."

Since our web server needs to be accessible from the internet, we'll launch it here.

---

### Private Subnet

```
10.0.2.0/24
```

Resources inside this subnet won't receive public IP addresses.

This is where you would normally place databases, backend services, or anything that shouldn't be directly exposed to the internet.

Although we won't use it in this tutorial, it's good practice to build the network properly from the beginning.

---

# 5. Create an Elastic IP

```hcl
resource "aws_eip" "eip" {
    ...
}
```

A NAT Gateway requires a public IP address.

That's why we create an **Elastic IP (EIP)** first.

Unlike normal public IPs, an Elastic IP remains the same even if the resource is restarted.

---

# 6. Create an Internet Gateway

```hcl
resource "aws_internet_gateway" "igw" {
    ...
}
```

The Internet Gateway connects our VPC to the internet.

Without it, even an EC2 instance with a public IP would be unreachable.

---

# 7. Create a NAT Gateway

```hcl
resource "aws_nat_gateway" "nat" {
    ...
}
```

The NAT Gateway allows resources inside the **private subnet** to access the internet **without allowing the internet to access them**.

For example, a private EC2 instance can:

* Install software
* Download operating system updates
* Access external APIs

But nobody on the internet can initiate a connection to it.

Notice that the NAT Gateway is placed inside the **public subnet**.

That's because it needs internet access through the Internet Gateway.

---

# 8. Configure Route Tables

Next, we define how traffic flows through our network.

## Public Route Table

```hcl
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}
```

This means:

> Any traffic going outside the VPC should be sent to the Internet Gateway.

As a result, resources in the public subnet can communicate directly with the internet.

---

## Private Route Table

```hcl
route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
}
```

Instead of using the Internet Gateway directly, traffic first goes through the NAT Gateway.

This keeps the private subnet hidden while still allowing outbound internet access.

---

# 9. Associate Route Tables

```hcl
resource "aws_route_table_association" ...
```

Creating route tables isn't enough.

We must explicitly tell AWS which subnet should use which route table.

* Public Subnet → Public Route Table
* Private Subnet → Private Route Table

Think of it as assigning a GPS to each subnet.

---

# 10. Create a Security Group

```hcl
resource "aws_security_group" "allow_http" {
    ...
}
```

A Security Group acts as a firewall.

In this example, we allow:

```hcl
Port 80 (HTTP)
```

from anywhere:

```
0.0.0.0/0
```

We also allow all outbound traffic so the EC2 instance can communicate with the internet.

For a production environment, you'd usually add:

* Port 22 (SSH)
* Port 443 (HTTPS)

and restrict SSH access to your own IP address.

---

# 11. Launch the EC2 Instance

Finally, we create our server.

```hcl
resource "aws_instance" "example" {
    ...
}
```

Let's break down the important parts.

### Amazon Linux

```hcl
ami = data.aws_ami.amazon_linux.id
```

Launches the latest Amazon Linux image.

---

### Instance Type

```hcl
instance_type = "t3.micro"
```

A small, inexpensive virtual machine that's perfect for learning and eligible for the AWS Free Tier (in many accounts).

---

### Public Subnet

```hcl
subnet_id = aws_subnet.public_subnet.id
```

This places the EC2 instance inside the public subnet.

---

### Security Group

```hcl
vpc_security_group_ids = [
    aws_security_group.allow_http.id
]
```

Attaches the firewall we created earlier.

---

### User Data

One of the coolest features of EC2 is **User Data**.

```bash
yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd
```

These commands run automatically the first time the EC2 instance boots.

Terraform will:

* Update the operating system
* Install Apache
* Start Apache
* Configure Apache to start automatically after every reboot

Finally, we create a simple web page:

```bash
echo "<h1>Hello from Terraform</h1>" > /var/www/html/index.html
```

So the moment the EC2 instance is ready, our website is already online.

---

# The Final Architecture

Once Terraform finishes applying the configuration, AWS will look something like this:

```
                    Internet
                        │
                Internet Gateway
                        │
              ┌─────────────────┐
              │       VPC       │
              │                 │
              │ Public Subnet   │
              │   ├── EC2        │
              │   └── NAT GW     │
              │                 │
              │ Private Subnet  │
              │   (Future DB)    │
              └─────────────────┘
```

With just one `terraform apply`, we've created an entire AWS networking environment, launched an EC2 instance, installed Apache automatically, and deployed our first website—all without opening the AWS Console.

That's the power of Infrastructure as Code.
