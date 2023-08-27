# elmWeb-docker

## 一键脚本搭建

#### 直接登录ssh后执行下面的命令
```bash
    wget https://ghproxy.com/https://raw.githubusercontent.com/zelang/elmWeb-docker/main/elmWeb.sh && bash elmWeb.sh
````

## 手动搭建：

#### 步骤一

- 手动下载本网页中的`config.ini`到`/etc/elmWeb/`目录下，然后修改`/etc/elmWeb/config.ini`中配置，如果没有此目录，先手动创建
- 手动命令创建：`mkdir -p /etc/elmWeb/`

#### 步骤二

- 一定要先修改此文件中的配置，确认`/etc/elmWeb/`目录下的配置文件已修改完毕，再执行以下命令：

```shell
docker run -dit \
  -v /etc/elmWeb/config.ini:/etc/elmWeb/config.ini \
  -p 8081:8081 \
  --name elmWeb \
  --restart unless-stopped \
  marisn/elmweb:latest
```

### 一些小提示：
1. 查看日志：`docker logs elmweb`
2. 重启：`docker restart elmweb`
3. 停止并删除：`docker stop elmweb && docker rm elmweb`
4. 更新：
- `docker stop elmweb && docker rm elmweb`
- `docker rmi marisn/elmweb`
- `docker pull marisn/elmweb`
- 执行步骤二