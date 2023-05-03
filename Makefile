
version = latest
repository = registry.cn-shanghai.aliyuncs.com/wego/chatapp:${version}

run:
	npm run dev

build:
	rm -rf dist & npm run build

install:
	npm install --registry https://registry.npm.taobao.org

docker:
	docker build -f Dockerfile  -t ${repository} .

push:
	docker push ${repository}

deploy:
	./deploy.sh
