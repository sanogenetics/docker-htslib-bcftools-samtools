# docker-htslib-bcftools-samtools

This is a Dockerfile that builds an image based on [amazonlinux:2](https://aws.amazon.com/amazon-linux-2) containing [htslib](http://www.htslib.org/) as well as bcftools and samtools.

To build it, use a command like:

```sh
docker build --pull --rm -f Dockerfile -t htslibbcftoolssamtools:latest .
```

Once built, push to AWS ECR by following [these instructions](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html).
