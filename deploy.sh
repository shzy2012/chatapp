#!/usr/bin/env bash
ssh root@shzy "sh /root/workplace/chatapp/deploy_server.sh; exit;"
echo "✅远程服务,发布成功 https://chatapp.dunji.tech"
exit
