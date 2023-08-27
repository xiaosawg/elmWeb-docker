# elmWeb-docker

## 一键脚本搭建

#### 直接登录ssh后执行下面的命令
```bash
    wget https://ghproxy.com/https://raw.githubusercontent.com/zelang/elmWeb-docker/main/elmWeb.sh && bash elmWeb.sh
````

#### 搭建成功后，默认账号admin 密码 elmWeb2023 请及时访问后台修改密码

## 手动搭建：

#### 步骤一

- 手动下载本网页中的`config.ini`到`/etc/elmWeb/`目录下，然后修改`/etc/elmWeb/config.ini`中配置，如果没有此目录，先手动创建
- 手动命令创建：`mkdir -p /etc/elmWeb/`

#### 步骤二

- 一定要先修改此文件中的配置，确认`/etc/elmWeb/`目录下的配置文件已修改完毕，再执行以下命令：

```shell
docker run -dit \
  -v /etc/elmWeb/config.ini:/etc/elmWeb/config.ini \
  --network host \
  --name elmWeb \
  --restart unless-stopped \
  marisn/elmweb:latest
```

### 一些小提示：
1. 查看日志：`docker logs elmWeb`
2. 重启：`docker restart elmWeb`
3. 停止并删除：`docker stop elmWeb && docker rm elmWeb`
4. 更新：
- `docker stop elmWeb && docker rm elmWeb`
- `docker rmi marisn/elmweb`
- `docker pull marisn/elmweb`
- 执行步骤二