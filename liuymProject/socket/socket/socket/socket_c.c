//
//  socket_c.c
//  socket
//
//  Created by Kermit Mei on 10/11/14.
//  Copyright (c) 2014 Kermit Mei. All rights reserved.
//

#include "socket_c.h"
#include <netinet/in.h>
#include <stdlib.h>
#include <stdio.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <fcntl.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <unistd.h>
#include <errno.h>
#include <signal.h>

#include <sys/ioctl.h>



void connect_timeout()
{
    printf("connect timeout \n");
}

int isConnect(int socketFd)
{
    char buff[32];
    int recvLength = (int)recv(socketFd, buff, sizeof(buff), MSG_DONTWAIT|MSG_PEEK);
    
    if(recvLength == 0 || (recvLength < 0 && errno != EAGAIN))
        return -1;
    
    return 0;
}

/**
 *    socket tcp 方式连接服务器
 *
 *    @param serverIP    服务端IP
 *    @param serverPort  服务端端口号
 *    @param connectType 连接方式 TCP 、UDP
 *    @param timeOut     超时时间,秒
 *
 *    @return > 0 成功，返回socket描述符
 *            < 0 错误，参考错误定义
 */
int SocketConnect(const char *serverIP, const char *serverPort, const char *connectType, int timeOut)
{
    struct  hostent     *phe;
    struct  servent      *pse;
    struct  sockaddr_in addr;
    
    int protocol;
    int socketType;
    int socketFd;
    
    struct  timeval stTimeVal;
    fd_set  setId;
    
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = INADDR_ANY;
    
    //端口是否可用
    if( (pse=getservbyname(serverPort, connectType))!=NULL ){
        addr.sin_port = htons(ntohs((u_short)pse->s_port));
    }else if( (addr.sin_port=htons((u_short)atoi(serverPort)))==0 ){
        return ERR_SOCKET_PORT;
    }
    
    if( (phe=gethostbyname(serverIP))!=NULL ){
        memcpy(&addr.sin_addr, phe->h_addr, phe->h_length);
    }else if( (addr.sin_addr.s_addr=inet_addr(serverIP))==INADDR_NONE ){
        return ERR_SOCKET_HOSTIP;
    }
    
    if( strcmp(connectType, "tcp") == 0 ){
        protocol = 6;
        socketType = SOCK_STREAM;
    }else{
        protocol = 17;
        socketType = SOCK_DGRAM;
    }
    
    //创建socket
    socketFd = socket(PF_INET, socketType, protocol);
    if( socketFd < 0 ){
        return ERR_SOCKET_CREATE;
    }
    
#if 1
    //设置为非阻塞模式
    int   saveFcntl   =   fcntl(socketFd, F_GETFL);
    fcntl(socketFd,   F_SETFL,   saveFcntl   |   O_NONBLOCK);
    
    int ret = connect(socketFd, (struct sockaddr *)&addr, sizeof(addr));
    if(ret == 0){
        return socketFd;
    }

    if(errno != EINPROGRESS ){
        return ERR_SOCKET_CONNECT;
    }
    
    stTimeVal.tv_sec  = timeOut<0 ? 10 : timeOut;
    stTimeVal.tv_usec = 0;
    
    FD_ZERO(&setId);
    FD_SET(socketFd, &setId);
    
    ret = select(socketFd + 1 , NULL, &setId, NULL, &stTimeVal);
    if( ret < 0 ){
        return ERR_SOCKET_SELECT_READ;
    }
    if( ret == 0 ){
        return ERR_SOCKET_TIMEOUT;
    }
    
    if(isConnect(socketFd) < 0){
        return ERR_SOCKET_CONNECT;
    }
    
    //int error = -1, len;
    
    //getsockopt(socketFd, SOL_SOCKET, SO_ERROR, &error, (socklen_t *)&len);
    //if(error != 0){
    //return ERR_SOCKET_CONNECT;
//}
    
    fcntl(socketFd, F_SETFL, saveFcntl);
#else
    //使用信号量方式设置超时
    sigset(SIGALRM, connect_timeout);
    alarm(timeOut);
    int ret = connect(socketFd, (struct sockaddr *)&addr, sizeof(addr));
    alarm(0);
    sigrelse(SIGALRM);
    if(ret < 0){
        DisSocketConnect(socketFd);
        return ERR_SOCKET_CONNECT;
    }
#endif
    return socketFd;
}

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
int SocketListen(const char *listenPort, const char *connectType, int maxConnectCount)
{
    struct  hostent     *phe;
    struct  servent      *pse;
    struct  sockaddr_in addr;
    
    int protocol;
    int socketType;
    int socketFd;
    
    struct  timeval stTimeVal;
    fd_set  setId;
    
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = INADDR_ANY;
    
    //端口是否可用
    if( (pse=getservbyname(listenPort, connectType))!=NULL ){
        addr.sin_port = htons(ntohs((u_short)pse->s_port));
    }else if( (addr.sin_port=htons((u_short)atoi(listenPort)))==0 ){
        return ERR_SOCKET_PORT;
    }
    
    if( strcmp(connectType, "tcp") == 0 ){
        protocol = 6;
        socketType = SOCK_STREAM;
    }else{
        protocol = 17;
        socketType = SOCK_DGRAM;
    }
    
    //创建socket
    socketFd = socket(PF_INET, socketType, protocol);
    if( socketFd < 0 ){
        return ERR_SOCKET_CREATE;
    }
    
    /* Bind the socket */
    if( bind(socketFd, (struct sockaddr *)&addr, sizeof(addr))<0 ){
        DisSocketConnect(socketFd);
        return -1111;//ERR_SOCK_BIND; /* can't bind to port */
    }
    
    if( socketType==SOCK_STREAM && listen(socketFd, maxConnectCount)<0 ){
        DisSocketConnect(socketFd);
        return -123123;//ERR_SOCK_LISTEN; /*can't listen on port*/
    }
    return socketFd;
}

/**
 *    等待客户端连接
 *
 *    @param socketFd socket描述符
 *    @param clientIp 客户端IP
 *
 *    @return > 0 成功，返回socket描述符
 *            < 0 错误，参考错误定义
 */
int SocketAccept(int socketFd, char *clientIp)
{
    struct  sockaddr_in addr;
    int addrLen = sizeof(addr);

#if 1
    struct  timeval stTimeVal;
    fd_set  setId;
    int		iRet;
    
    stTimeVal.tv_sec  = 300000;
    stTimeVal.tv_usec = 0;
    
    FD_ZERO(&setId);
    FD_SET(socketFd, &setId);
    
    iRet = select(socketFd + 1, &setId, NULL, NULL, &stTimeVal);
    if( iRet<0 ){
        return -123123;//ERR_SOCK_ACCEPT;
    }
    if( iRet==0 ){
        return ERR_SOCKET_TIMEOUT;
    }
#endif
    
    //等待客户端连接
    int newSocketFd = accept(socketFd, (struct sockaddr*)&addr, &addrLen);
    if( newSocketFd<0 ){
        return -133423;//ERR_SOCK_ACCEPT;
    }
    
    if( clientIp != NULL ){
        strcpy(clientIp, inet_ntoa(addr.sin_addr));
    }
    
    return newSocketFd;
}

/**
 *    读socket数据
 *
 *    @param socketFd socket描述符
 *    @param readBuff  数据缓冲区(回传)
 *    @param timeOut  超时时间,秒
 *
 *    @return > 0 成功，返回收到数据长度
 *            < 0 错误，参考错误定义
 */
int SocketRead(int socketFd, char *readBuff, int maxLength, int timeOut)
{
    int     ret, readLength;
    struct  timeval stTimeVal;
    fd_set  setId;
    
    if(isConnect(socketFd) == -1){
        DisSocketConnect(socketFd);
        return ERR_SOCKET_CONNECT;
    }
    
    stTimeVal.tv_sec  = timeOut;
    stTimeVal.tv_usec = 0;
    
    FD_ZERO(&setId);
    FD_SET(socketFd, &setId);
    
    ret = select(socketFd + 1, &setId, NULL, NULL, &stTimeVal);
    if( ret < 0 ){
        return ERR_SOCKET_SELECT_READ;
    }
    if( ret == 0 ){
        return ERR_SOCKET_TIMEOUT;
    }
    
    readLength = (int)recv(socketFd, readBuff, maxLength, 0);
    if( readLength < 0 ){
        return ERR_SOCKET_READ;
    }
    
    return readLength;
}

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
int SocketReadLength(int socketFd, char *readBuff, int readLength, int timeOut)
{
    int retval,iLen;
    struct timeval timeVal;
    time_t lCurrTime, lStartTime;
    
    fd_set setId;
    
    if(isConnect(socketFd) == -1){
        DisSocketConnect(socketFd);
        return ERR_SOCKET_CONNECT;
    }
    
    timeVal.tv_sec  = timeOut;
    timeVal.tv_usec = 0;

    FD_ZERO(&setId);
    FD_SET(socketFd, &setId);

    lStartTime      = time(&lStartTime);
    
    while(readLength > 0) {
        lCurrTime = time(&lCurrTime);
        if(lCurrTime-lStartTime > timeOut)
            return ERR_SOCKET_TIMEOUT;
        
        retval=select(socketFd + 1, &setId, NULL, NULL, &timeVal);
        if (retval < 0) {
            return ERR_SOCKET_SELECT_READ;
        }
        if (retval == 0) {
            return ERR_SOCKET_TIMEOUT;
        }
        iLen = (int)recv(socketFd, readBuff, readLength, 0);
        if(iLen < 0)
            return ERR_SOCKET_READ;
        readBuff   += iLen;
        readLength -= iLen;
    }
    
    return iLen;
}

/**
 *    写socket数据
 *
 *    @param socketFd    socket描述符
 *    @param writeLength 数据缓冲区
 *    @param timeOut     超时时间,秒
 *
 *    @return = 0 成功
 *            < 0 错误，参考错误定义
 */
int SocketWrite(int socketFd, const char *wiretBuff, int writeLength, int timeOut)
{
    int     iRet, iLen;
    struct  timeval stTimeVal;
    fd_set  setId;
    
    if(isConnect(socketFd) == -1){
        DisSocketConnect(socketFd);
        return ERR_SOCKET_CONNECT;
    }
    
    stTimeVal.tv_sec  = timeOut;
    stTimeVal.tv_usec = 0;
    
    FD_ZERO(&setId);
    FD_SET(socketFd, &setId);
    
    iRet=select(socketFd + 1, NULL, &setId, NULL, &stTimeVal);
    if( iRet<0 ){
        return ERR_SOCKET_SELECT_READ;
    }
    if( iRet==0 ){
        return ERR_SOCKET_TIMEOUT;
    }
    
    while( writeLength > 0 ){
        iLen = (int)send(socketFd, wiretBuff, writeLength, 0);
        if( iLen<0 ){
            return ERR_SOCKET_WRITE;
        }
        writeLength -= iLen;
        wiretBuff   += iLen;
    }
    
    return 0;
}

/**
 *    断开socket连接
 *
 *    @param socketFd socket描述符
 */
void DisSocketConnect(int socketFd)
{
    close(socketFd);
}
