## Ubuntu开启BBR  

```
wget --no-check-certificate -qO 'BBR.sh' 'https://github.com/smallwhiter/other/blob/master/BBR.sh' && chmod a+x BBR.sh && bash BBR.sh -f  
``` 

转自：https://moeclub.org/2017/06/06/249/

## Ubuntu开启BBR增强版

```
wget --no-check-certificate -qO 'BBR_POWERED.sh' 'https://github.com/smallwhiter/other/blob/master/BBR_POWERED.sh' && chmod a+x BBR_POWERED.sh && bash BBR_POWERED.sh
```

注意事项：需要事先安装开启普通版BBR  
转自:https://moeclub.org/2017/06/24/278/

## ocsrv+锐速一键脚本/用户管理

```
wget --no-check-certificate -qO ocserv.sh 'https://github.com/smallwhiter/other/blob/master/ocserv.sh' && chmod a+x ocserv.sh
```

- 使用方法：  
参数使用介绍:  
```
-install  
```  
 #在有其他参数时,第一步进行安装.  
```
-add 【用户名】【密码】
```  
 #密码登陆模式下添加一个用户.  
```
-del 【用户名】
```   
 #密码登录模式下删除一个用户.  
```
-use 【Cert/Password】
```  
 #切换登陆方式,密码或证书.  
```
-route/-noroute
```  
 #添加路由表,两个参数不能同时使用.
 #-route参数一般用于android机器(由于android平台限制).
 #-noroute参数推荐使用,除android机器外都使用此参数.

- 示例:


1. 安装并添加no-route路由表.  
```
bash ocserv.sh -install -noroute
```

2. 安装并添加route路由表.

```
bash ocserv.sh -install -route
```

3. 添加no-route路由表和一个用户名和密码均为Test的用户.

```
bash ocserv.sh -noroute -add Test Test
```

4. 删除一个用户名为Test的用户.

```
bash ocserv.sh -del Test
```

5.  切换使用证书登陆(cret不区分大小写.需要安装时选择配置为证书登录,否则可能无法正常运行.)  

```
bash ocserv.sh -use Cert
```

6. 切换使用密码登陆(password不区分大小写.)

```
bash ocserv.sh -use password
```


> 来源：https://moeclub.org/2017/06/22/268/

