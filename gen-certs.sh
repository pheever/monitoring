###
ELASTICSEARCH_IMAGE=docker.elastic.co/elasticsearch/elasticsearch:7.9.3
###

kubectl create secret generic elastic-credentials --from-literal=username=elastic --from-literal=password=$(docker run --rm busybox:1.31.1 /bin/sh -c "< /dev/urandom tr -cd '[:alnum:]' | head -c20")

kubectl create secret generic kibana-enc --from-literal=encryptionkey=$(docker run --rm busybox:1.31.1 /bin/sh -c "< /dev/urandom tr -cd _A-Z-a-z-0-9 | head -c50")

TMP_DIR=/tmp/gen-certs-$(< /dev/urandom tr -cd '[:alpha:]' | head -c5)
mkdir -p $TMP_DIR
docker run --rm -u $(id -u) -v $TMP_DIR:/tmp/certs -w /tmp/certs "$ELASTICSEARCH_IMAGE" \
  /bin/sh -c "elasticsearch-certutil ca --out /tmp/certs/elastic-stack-ca.p12 --pass '' && \
              elasticsearch-certutil cert --name security-master --dns security-master --ca /tmp/certs/elastic-stack-ca.p12 --pass '' --ca-pass '' --out /tmp/certs/elastic-certificates.p12"
docker run --rm -u $(id -u) -v $TMP_DIR:/tmp/certs -w /tmp/certs nginx \
  bash -c "openssl pkcs12 -nodes -passin pass:'' -in elastic-certificates.p12 -out elastic-certificate.pem; openssl x509 -outform der -in elastic-certificate.pem -out elastic-certificate.crt"
kubectl create secret generic elastic-certificates \
  --from-file=$TMP_DIR/elastic-certificates.p12 \
  --from-file=$TMP_DIR/elastic-certificate.pem \
  --from-file=$TMP_DIR/elastic-certificate.crt
rm -rf $TMP_DIR
