//
//  socket_c.h
//  socket
//
//  Created by Kermit Mei on 10/11/14.
//  Copyright (c) 2014 Kermit Mei. All rights reserved.
//

#ifndef socket_socket_c_h
#define socket_socket_c_h

#define ERR_SOCKET_PORT        -1001    //端口号错误
#define ERR_SOCKET_HOSTIP      -1002    //主机地址错误
#define ERR_SOCKET_CONNECT     -1003    //socket连接错误
#define ERR_SOCKET_CREATE      -1004    //socket创建错误
#define ERR_SOCKET_SELECT_READ -1005    //select 返回负值
#define ERR_SOCKET_TIMEOUT     -1006    //socket访问超时
#define ERR_SOCKET_READ        -1007    //socket读错误
#define ERR_SOCKET_WRITE       -1008    //socket写错误



#ifdef __cplusplus
extern "C" {
#endif
    
    /**
     *    socket  方式连接服务器
     *
     *    @param serverIP    服务端IP
     *    @param serverPort  服务端端口号
     *    @param connectType 连接方式 tcp 、udp
     *    @param timeOut     超时时间,秒
     *
     *    @return > 0 成功，返回socket描述符
     *            < 0 错误，参考错误定义
     */
    int SocketConnect(const char *serverIP, const char *serverPort, const char *connectType, int timeOut);
    
    /**
     *    服务器监听
     *
     *    @param listenPort      端口号
     *    @param connectType     监听方式 tcp 、udp
     *    @param maxConnectCount 最大连接数
     *
     *    @return > 0 成功，返回socket描述符
     *            < 0 错误，参考错误定义
     */
    int SocketListen(const char *listenPort, const char *connectType, int maxConnectCount);
    
    /**
     *    等待客户端连接
     *
     *    @param socketFd socket描述符
     *    @param clientIp 客户端IP
     *
     *    @return > 0 成功，返回socket描述符
     *            < 0 错误，参考错误定义
     */
    int SocketAccept(int socketFd, char *clientIp);

    /**
     *    读socket数据
     *
     *    @param socketFd  socket描述符
     *    @param readBuff  数据缓冲区(回传)
     *    @param maxLength 读取最大长度
     *    @param timeOut   超时时间,秒
     *
     *    @return > 0 成功，返回收到数据长度
     *            < 0 错误，参考错误定义
     */
    int SocketRead(int socketFd, char *readBuff, int maxLength, int timeOut);
    
    /**
     *    读固定长度socket数据
     *
     *    @param socketFd   socket描述符
     *    @param readBuff    数据缓冲区(回传)
     *    @param readLength 读数据长度
     *    @param timeOut    超时时间,秒
     *
     *    @return > 0 成功，返回收到数据长度
     *            < 0 错误，参考错误定义
     */
    int SocketReadLength(int socketFd, char *readBuff, int readLength, int timeOut);
    
    /**
     *    写socket数据
     *
     *    @param socketFd    socket描述符
     *    @param writeLength 数据缓冲区
     *    @param timeOut     超时时间,秒
     *
     *    @return > 0 成功，返回收到数据长度
     *            < 0 错误，参考错误定义
     */
    int SocketWrite(int socketFd, const char *wiretBuff, int writeLength, int timeOut);
    
    /**
     *    断开socket连接
     *
     *    @param socketFd socket描述符
     */
    void DisSocketConnect(int socketFd);
    
#ifdef __cplusplus
}
#endif
#endif //SOCKET_C_H
