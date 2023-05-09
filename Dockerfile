# frondend_ws
FROM registry.cn-shanghai.aliyuncs.com/pub_space/nginx:latest

#添加build文件夹到工作目录
# ADD ./dist/spa/ /www
ADD ./aaa/ /www

#开启80端口
EXPOSE 80
