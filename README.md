# docker-htslib-bcftools-samtools

This is a Dockerfile that builds an image based on [amazonlinux:2](https://aws.amazon.com/amazon-linux-2) containing [htslib](http://www.htslib.org/) as well as bcftools and samtools.

To build it, use a command like:

```
docker build \
  --rm \
  --build-arg VERSION=1.15.1
  --tag htslib-bcftools-samtools:1.15.1 .
```

Note: `--rm` means to remove intermediate containers after a build. You may want to omit this if developing locally to utilize docker layer caching.
Note: `--progress=plain` may be useful to see all intermediate step logs.

Once built, push to AWS ECR with:

```
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 244834673510.dkr.ecr.eu-west-2.amazonaws.com
docker tag htslib-bcftools-samtools:1.15.1 244834673510.dkr.ecr.eu-west-2.amazonaws.com/htslib-bcftools-samtools:1.15.1
docker push 244834673510.dkr.ecr.eu-west-2.amazonaws.com/htslib-bcftools-samtools:1.15.1
```