# docker-htslib-bcftools-samtools

[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/sanogenetics/htslib-bcftools-samtools/1.15.1?style=plastic)](https://hub.docker.com/r/sanogenetics/htslib-bcftools-samtools)

This is a Dockerfile that builds an image based on [ubuntu:focal](https://hub.docker.com/_/ubuntu) containing [htslib](http://www.htslib.org/) as well as bcftools and samtools. This also contains the AWS CLI tool.

To read/write from S3 and htslib/bcftools/samtools see the [official instructions](http://www.htslib.org/doc/htslib-s3-plugin.html). In particular, note that it does not support role-based IAM access. A consequence of this is that using AWS Batch execution roles will not allow access to private S3 objects. 

There is an [issue](https://github.com/samtools/htslib/issues/344) on htslib for this. In there a comment describes using a shell script to set the role credentials before invoking the intended htslib/bcftools/samtools command. It could be used like:

```
docker run --rm htslib-bcftools-samtools:1.15.1 s3role bcftools view --header-only s3://bucket/key.vcf.gz
```

Note: long running tasks may have problems, since the credentials are automatically rotated periodically by AWS but the container does not refresh them.

## developers

To build this container, use a command like:

```
docker build \
  --rm \
  --build-arg VERSION=1.15.1 \
  --tag htslib-bcftools-samtools:1.15.1 \
  --tag htslib-bcftools-samtools:latest \
  .
```

Note: `--rm` means to remove intermediate containers after a build. You may want to omit this if developing locally to utilize docker layer caching.

Note: `--progress=plain` may be useful to see all intermediate step logs.

Push to AWS ECR with:

```
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 244834673510.dkr.ecr.eu-west-2.amazonaws.com
docker tag htslib-bcftools-samtools:1.15.1 244834673510.dkr.ecr.eu-west-2.amazonaws.com/htslib-bcftools-samtools:1.15.1
docker push 244834673510.dkr.ecr.eu-west-2.amazonaws.com/htslib-bcftools-samtools:1.15.1
docker tag htslib-bcftools-samtools:latest 244834673510.dkr.ecr.eu-west-2.amazonaws.com/htslib-bcftools-samtools:latest
docker push 244834673510.dkr.ecr.eu-west-2.amazonaws.com/htslib-bcftools-samtools:latest
docker logout
```

Push to DockerHub with:

```
docker login --username sanogenetics
docker tag htslib-bcftools-samtools:1.15.1 sanogenetics/htslib-bcftools-samtools:1.15.1
docker push sanogenetics/htslib-bcftools-samtools:1.15.1
docker tag htslib-bcftools-samtools:latest sanogenetics/htslib-bcftools-samtools:latest
docker push sanogenetics/htslib-bcftools-samtools:latest
docker logout
```

Note: will prompt for password.