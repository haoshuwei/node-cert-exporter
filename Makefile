.PHONY: release
release:
	docker build -t registry-vpc.cn-hongkong.aliyuncs.com/haoshuwei/node-cert-exporter . -f Dockerfile
	docker push registry-vpc.cn-hongkong.aliyuncs.com/haoshuwei/node-cert-exporter