# terraform-sandbox
Proof of concept with Terraform

## WARNING  
This project is _not_ functional.  It is here to collaborate with various Terraform gurus to start understanding the Hashicorp goodness.

## Goal #1: Single File / Static Objects  
The current goal of this project is to create ONE SINGLE `main.tf` file WITHOUT the use of `data` objects, `forEach` loops, custom modules, or anything dynamic.  Humans need to crawl before we can walk.  In my opinion, a single file, with hard-coded static objects, forces the reader to see the exact sequence and priority of the document's syntax without having to _imagine_ the result.  In theory, this should help provide a more easy-to-understand document.  Granted, it _will_ be longer and more rigid than a dynamic version, but we are looking for simplicity.

## Goal #2: Security Boundaries  
It is important to implement boundary functionality to ensure less-privledged artifacts are maintained in public-facing areas while more sentitive artifacts are tucked away behind one or many other layers.  This first draft will use subnetting and AWS security groups to accomplish this.  The end result will be 

```
    Public Subnet -> Public ALB -> Publix APIs (UX) ->
    Private Subnet -> Private ALB -> Private APIs (App Logic) ->  
    Data Subnet -> Data ALB -> Data APIs -> RDS or other data source
```

## Goal #3: Load-Balanced APIs  
Each API in this example is a simple Node-based API designed to return a "status" object with its environment variables.  Intances of this example API is initialized as a scaled and load-balanced ECS instance.  Each API is able to call into the upstream APIs via their load balancer.   