
/****************************************************************************
    NAME
        sockcomm2.c     - functions for socket communication

    MODIFIED    (YYYY.MM.DD)
    sjx          2000.11.30     - created
 ***************************************************************************/

#if 0 && (defined(WIN32) || defined(WINDOWS))
    #include <stdio.h>
    #include <string.h>
    #include <time.h>
    #include <sys/types.h>
    #include <winsock2.h>
#else
    #include <unistd.h>
    #include <stdio.h>
    #include <string.h>
    #include <sys/types.h>
    #include <sys/times.h>
//修改 开始
#include <sys/time.h>
#include <stdlib.h>
#include <fcntl.h>
//修改 结束
    #include <sys/select.h>
    #include <sys/socket.h>
    #include <netinet/in.h>
    #include <arpa/inet.h>
    #include <netdb.h>
    #define      SOCKET    int
#endif

#include "sockcomm.h"

/********************** Internal macros declaration ************************/
#ifndef MAXLONG
#define MAXLONG     0x7FFFFFFF
#endif

/********************* Internal functions declaration **********************/
static int iPassiveSock(const char *pszService, const char *pszTransport,
                        int iQlen);
static int iConnectSock(const char *pszHost, const char *pszService,
                        const char *pszTransport, int iTimeOut);


/****************************************************************************
*   Function:
*       connect to the desired server with TCP protocol
*   Arguments:
*       pszHost      -   name of host to which connection is desired
*       pszService   -   service associated with the desired port
*       iTimeout     -   time to wait (no use)
*   Returns:
*       >=0                 -   success
*       ERR_SOCK_PORT       -   error port
*       ERR_SOCK_HOST       -   error host
*       ERR_SOCK_PROTOCOL   -   error protocol
*       ERR_SOCK_SOCKET     -   create socket error
*       ERR_SOCK_CONNECT    -   connect error
****************************************************************************/
int iConnectTCP(const char *pszHost, const char *pszService, int iTimeout)
{
    return iConnectSock(pszHost, pszService, "tcp", iTimeout);
}


/****************************************************************************
*   Function:
*       make a passive socket with TCP protocol
*   Arguments:
*       pszService   -   service associated with the desired port
*       iQlen       -   maximum server request queue length
*       iTimeout    -   timeout seconds
*   Returns:
*       >=0                 -   success
*       ERR_SOCK_PORT       -   error port
*       ERR_SOCK_PROTOCOL   -   error protocol
*       ERR_SOCK_SOCKET     -   create socket error
*       ERR_SOCK_BIND       -   bind error
*       ERR_SOCK_LISTEN     -   listen error
****************************************************************************/
int iPassiveTCP( const char *pszService, int iQlen )
{
    return iPassiveSock(pszService, "tcp", iQlen);
}


/****************************************************************************
*   Function:
*       connect to the desired server with UDP protocol
*   Arguments:
*       pszHost      -   name of host to which connection is desired
*       pszService   -   service associated with the desired port
*       iTimeout     -   time to wait (no use)
*   Returns:
*       >=0                 -   success
*       ERR_SOCK_PORT       -   error port
*       ERR_SOCK_HOST       -   error host
*       ERR_SOCK_PROTOCOL   -   error protocol
*       ERR_SOCK_SOCKET     -   create socket error
*       ERR_SOCK_CONNECT    -   connect error
****************************************************************************/
int iConnectUDP(const char *pszHost, const char *pszService, int iTimeout)
{
    return iConnectSock(pszHost, pszService, "udp", iTimeout);
}


/****************************************************************************
*   Function:
*       make a passive socket with tcp protocol
*   Arguments:
*       pszService   -   service associated with the desired port
*       iQlen       -   maximum server request queue length
*       iTimeout    -   timeout seconds
*   Returns:
*       >=0                 -   success
*       ERR_SOCK_PORT       -   error port
*       ERR_SOCK_PROTOCOL   -   error protocol
*       ERR_SOCK_SOCKET     -   create socket error
*       ERR_SOCK_BIND       -   bind error
****************************************************************************/
int iPassiveUDP(const char *pszService)
{
    return iPassiveSock(pszService, "udp", 0);
}


/****************************************************************************
*   Function:
*       accept a socket
*   Arguments:
*       iSock            -   descriptor referencing the socket
*       szClientIP       -   client IP address
*       iTimeOut         -   microseconds to timeout while accepting
*   Returns:
*       >=0              -   success
*       ERR_SOCK_ACCEPT  -   accept error
*       ERR_SOCK_TIMEOUT -   accept timeout
****************************************************************************/
int iAcceptSock(int iSock, char *pszClientIP, int iTimeOut)
{
    struct  sockaddr_in addr;    /* client internet address */
    int     iNewSock;            /* descriptor for the accepted socket*/
    int     iAddrLen;            /* length if addr*/

#if 1
    struct  timeval stTimeVal;
    fd_set  setId;
	int		iRet;

    stTimeVal.tv_sec  = iTimeOut<0 ? MAXLONG : iTimeOut/1000;
    stTimeVal.tv_usec = iTimeOut<0 ? 0       : iTimeOut%1000;

    FD_ZERO(&setId);
    FD_SET((SOCKET)iSock, &setId);

    iRet = select(iSock+1, &setId, NULL, NULL, &stTimeVal);
    if( iRet<0 ){
        return (ERR_SOCK_ACCEPT);
    }
    if( iRet==0 ){
        return (ERR_SOCK_TIMEOUT);
    }
#endif

    iAddrLen = sizeof(addr);
    iNewSock = accept(iSock, (struct sockaddr*)&addr, &iAddrLen);
    if( iNewSock<0 ){
        return ERR_SOCK_ACCEPT;
    }

    if( pszClientIP!=NULL ){
        strcpy(pszClientIP, inet_ntoa(addr.sin_addr));
    }

    return iNewSock;
}


/****************************************************************************
*   Function:
*        read from socket(read until EOF or fit request length)
*   Arguments:
*       iSocket     -   descriptor referencing the socket
*       psBuf       -   read buffer
*       iReadLen    -   data byte length should be read
*       iTimeOut    -   seconds to timeout while reading
*
*   Returns:
*       >=0             -   success
*       ERR_SOCK_READ   -   read error or timeout
****************************************************************************/
int iReadSock(int iSock, char *psBuf, int iReadLen, int iTimeOut)
{
	int retval,iLen;
	struct timeval timeVal;
    time_t lCurrTime, lStartTime;

	fd_set setId;

    timeVal.tv_sec = iTimeOut;
    timeVal.tv_usec = 0;

    FD_ZERO(&setId);
    FD_SET((unsigned int)iSock,&setId);

    lStartTime = time(&lStartTime);

    while(iReadLen > 0) {
        lCurrTime = time(&lCurrTime);
        if(lCurrTime-lStartTime > iTimeOut)
            return(ERR_SOCK_TIMEOUT);

        retval=select(0, &setId, NULL, NULL, &timeVal);
	    if (retval < 0) {
		   return (ERR_SOCK_READ);
        }
	    if (retval == 0) {
		    return (ERR_SOCK_TIMEOUT);
        }
        iLen=recv(iSock,psBuf,iReadLen,0);
        if(iLen < 0)
            return ERR_SOCK_READ;
        psBuf += iLen;
        iReadLen -= iLen;
    }

    return 0;
}

/****************************************************************************
*   Function:
*        read from socket(read until EOF or fit request length)
*   Arguments:
*       iSocket     -   descriptor referencing the socket
*       psBuf       -   read buffer
*       iReadLen    -   data byte length should be read
*       iTimeOut    -   seconds to timeout while reading
*
*   Returns:
*       >=0             -   success
*       ERR_SOCK_READ   -   read error or timeout
****************************************************************************/
int iReadSockfromAs400(int iSock, char *psBuf, int iReadLen, int iTimeOut)
{
    int     iRet, iLen,iTmp;
	char	szBuf[8+1];
    struct  timeval stTimeVal;
    fd_set  setId;

    stTimeVal.tv_sec  = iTimeOut;
    stTimeVal.tv_usec = 0;

    FD_ZERO(&setId);
    FD_SET((SOCKET)iSock, &setId);

    iRet=select(iSock+1, &setId, NULL, NULL, &stTimeVal);
    if( iRet<0 ){
        return (ERR_SOCK_READ);
    }
    if( iRet==0 ){
        return (ERR_SOCK_TIMEOUT);
    }
	while(1){
		iLen = recv(iSock, psBuf, 1, 0);
		if(iLen<=0) return (ERR_SOCK_READ);
		if(*psBuf!=TPB) continue;
		else break;
	}
    iLen = recv(iSock, psBuf+1, 72, 0);
	if(iLen<=0) return (ERR_SOCK_READ);
	if(iLen!=72) return -1012;
	if(*(psBuf+72)!=TTB) return -1013;

	memcpy(szBuf,psBuf+21,8);
	szBuf[8]=0;
	iLen=atoi(szBuf);
	if(iLen<0) return -1014;

	if(iReadLen<iLen+74)
		return -1015;
	iRet=0;
	iTmp=iLen;
	while(1){
		iRet=recv(iSock, psBuf+1+72+iRet, iLen-iRet, 0);
		if(iRet<=0) return (ERR_SOCK_READ);
		if(iRet!=iTmp) {
			iTmp-=iRet;
			continue;
		}
		break;
	}
	iRet=recv(iSock, psBuf+1+72+iLen,1, 0);
	if(iRet<=0) return -1015;
	if(*(psBuf+73+iLen)!=TPE) return -1016;
    return (iLen+74);
}


/****************************************************************************
*   Function:
*        read from socket(only read once)
*   Arguments:
*       iSocket     -   descriptor referencing the socket
*       psBuf       -   read buffer
*       iReadLen    -   data byte length should be read
*       iTimeOut    -   seconds to timeout while reading
*
*   Returns:
*       >=0             -   bytes actually read
*       ERR_SOCK_READ   -   read error or timeout
****************************************************************************/
int iReadSock2(int iSock, char *psBuf, int iMaxReadLen, int iTimeOut)
{
    int     iRet, iLen;
    struct  timeval stTimeVal;
    fd_set  setId;

	char szErrMsg[1000];

    stTimeVal.tv_sec  = iTimeOut;
    stTimeVal.tv_usec = 0;

    FD_ZERO(&setId);
    FD_SET((SOCKET)iSock, &setId);

    iRet = select(iSock+1, &setId, NULL, NULL, &stTimeVal);
    if( iRet<0 ){
        //sprintf(szErrMsg,"%s %d","recv() failed:", WSAGetLastError());
        return (ERR_SOCK_READ);
    }
    if( iRet==0 ){
        return (ERR_SOCK_TIMEOUT);
    }

    iLen = recv(iSock, psBuf, iMaxReadLen, 0);
    if( iLen < 0 ){
        return (ERR_SOCK_READ);
    }

    return iLen;
}


/****************************************************************************
*   Function:
*        write to socket
*   Arguments:
*       iSocket     -   descriptor referencing the socket
*       psBuf       -   data buffer
*       iWriteLen    -  data byte length should be writen
*       iTimeOut    -   seconds to timeout while writing
*
*   Returns:
*       0               -   success
*       ERR_SOCK_WRITE  -   write error or timeout
****************************************************************************/
int iWriteSock(int iSock, char *psBuf, int iWriteLen, int iTimeOut)
{
    int     iRet, iLen;
    struct  timeval stTimeVal;
    fd_set  setId;

    stTimeVal.tv_sec  = iTimeOut;
    stTimeVal.tv_usec = 0;

    FD_ZERO(&setId);
    FD_SET((SOCKET)iSock, &setId);

    iRet=select(iSock+1, NULL, &setId, NULL, &stTimeVal);
    if( iRet<0 ){
        return (ERR_SOCK_WRITE);
    }
    if( iRet==0 ){
        return (ERR_SOCK_TIMEOUT);
    }

    while( iWriteLen>0 ){
        iLen = send(iSock, psBuf, iWriteLen, 0);
        if( iLen<0 ){
            return (ERR_SOCK_WRITE);
        }
        iWriteLen -= iLen;
        psBuf     += iLen;
    }

    return 0;
}


/****************************************************************************
*   Function:
*        close a socket
*   Arguments:
*       iSocket     -   descriptor referencing the socket
*       bRelease    -   if release library(for windows only)
*
*   Returns:
*       none
****************************************************************************/
void vCloseSock(int iSock, int bRelease)
{
#if defined(WIN32) || defined(WINDOWS)
    closesocket(iSock);
    if( bRelease ){
        WSACleanup();
    }
#else
    close(iSock);
#endif
}


/****************************************************************************
* Arguments:
*   pszService   -   service associated with the desired port
*   pszTransport -   transport protocol to use   ( "tcp" or "udp" )
*   iQlen        -   maximum server request queue length
* Returns:
*   >=0                 -   success
*   ERR_SOCK_PORT       -   error port
*   ERR_SOCK_PROTOCOL   -   error protocol
*   ERR_SOCK_SOCKET     -   create socket error
*   ERR_SOCK_BIND       -   bind error
*   ERR_SOCK_LISTEN     -   listen error
****************************************************************************/
int iPassiveSock(const char *pszService, const char *pszTransport, int iQlen)
{
    struct  servent      *pse;  /* pointer to service information entry */
    struct  protoent     *ppe;  /* pointer to protocol information entry */
    struct  sockaddr_in  addr;  /* an internet endpoint address */
    int     iSock, iType;       /* socket descripter and socket type */
#if defined(SO_REUSEADDR) || defined(SO_REUSEPORT)
    int     bFlag;              /* flag for set socket options */
#endif
#if defined(WIN32) || defined(WINDOWS)
    int     iRet;
    WSADATA wsaData;
#endif

#if defined(WIN32) || defined(WINDOWS)
    iRet = WSAStartup(MAKEWORD(2, 2), &wsaData);
    if( iRet<0 ){
        return ERR_SOCK_INIT;
    }
#endif

    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = INADDR_ANY;

    /* Map service name to port number */
    if( (pse=getservbyname(pszService, pszTransport))!=NULL ){
        addr.sin_port = htons(ntohs((u_short)pse->s_port));
    }else if( (addr.sin_port=htons((u_short)atoi(pszService)))==0 ){
        return ERR_SOCK_PORT;   /*can't get service entry */
    }

    /* Map protocol name to protocol number */
    if( (ppe=getprotobyname(pszTransport))==NULL ){
        return ERR_SOCK_PROTOCOL;   /*can't get protocol entry */
    }

    /* Use protocol to choose a socket type */
    if( strcmp(pszTransport, "udp")==0 ){
        iType = SOCK_DGRAM;
    }else{
        iType=SOCK_STREAM;
    }

    /* Allocate a socket */
    iSock = socket(PF_INET, iType, ppe->p_proto);
    if( iSock<0 ){
        return ERR_SOCK_SOCKET; /* can't create socket */
    }

#ifdef SO_REUSEADDR
    bFlag = 1;
    setsockopt(iSock, SOL_SOCKET, SO_REUSEADDR, (void *)&bFlag, sizeof(bFlag));
#endif
#ifdef SO_REUSEPORT
    bFlag = 1;
    setsockopt(iSock, SOL_SOCKET, SO_REUSEPORT, (void *)&bFlag, sizeof(bFlag));
#endif

    /* Bind the socket */
    if( bind(iSock, (struct sockaddr *)&addr, sizeof(addr))<0 ){
        vCloseSock(iSock, 0);
        return ERR_SOCK_BIND; /* can't bind to port */
    }

    if( iType==SOCK_STREAM && listen(iSock, iQlen)<0 ){
        vCloseSock(iSock, 0);
        return ERR_SOCK_LISTEN; /*can't listen on port*/
    }

    return iSock;
}


/****************************************************************************
* Arguments:
*   pszHost      -   name of host to which connection is desired
*   pszService   -   service associated with the desired port
*   pszTransport -   name of transport protocol to use ("tcp" or "udp")
*   iTimeOut     -   connect timeout microseconds
* Returns:
*   >=0                 -   success
*   ERR_SOCK_PORT       -   error port
*   ERR_SOCK_HOST       -   error host
*   ERR_SOCK_PROTOCOL   -   error protocol
*   ERR_SOCK_SOCKET     -   create socket error
*   ERR_SOCK_CONNECT    -   connect error
****************************************************************************/
int iConnectSock(const char *pszHost, const char *pszService,
                 const char *pszTransport, int iTimeOut)
{
    struct  hostent     *phe;   /* pointer to host information entry */
    struct  servent     *pse;   /*  pointer to service information entry */
    struct  protoent    *ppe;   /*  pointer to protocol information entry */
    struct  sockaddr_in addr;   /*  an internet endpoint address  */
    int     iSock, iType;       /*  socket descripter and socket type */
#if 1
    int     iRet;
    struct  timeval stTimeVal;
    fd_set  setId;
#endif
#if defined(WIN32) || defined(WINDOWS)
    int     iRet;
    WSADATA wsaData;
#endif

#if defined(WIN32) || defined(WINDOWS)
    iRet = WSAStartup(MAKEWORD(2, 2), &wsaData);
    if( iRet<0 ){
        return ERR_SOCK_INIT;
    }
#endif

    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;

    /* Map service name to port number*/
    if( (pse=getservbyname(pszService,pszTransport))!=NULL ){
        addr.sin_port=pse->s_port;
    }else if( (addr.sin_port=htons((u_short)atoi(pszService)))==0 ){
        return ERR_SOCK_PORT;    /*can't get service entry*/
    }

    /* Map host name to IP address,allowing for dotted decimal */
    if( (phe=gethostbyname(pszHost))!=NULL ){
        memcpy(&addr.sin_addr, phe->h_addr, phe->h_length);
    }else if( (addr.sin_addr.s_addr=inet_addr(pszHost))==INADDR_NONE ){
        return ERR_SOCK_HOST;   /*can't get host entry*/
    }

    /* Map transport protocol name to protocol number */
    if( (ppe=getprotobyname(pszTransport))==NULL ){
        return ERR_SOCK_PROTOCOL; /*can't get protocol entry */
    }

    /* Use protocol to choose a socket type */
    if( strcmp(pszTransport, "udp")==0 ){
        iType=SOCK_DGRAM;
    }else{
        iType=SOCK_STREAM;
    }
    /* Allocate a socket */
    iSock = socket(PF_INET, iType, ppe->p_proto);
    if( iSock<0 ){
        return ERR_SOCK_SOCKET; /*can't create socket*/
    }

    //修改socket connect方式
    //设置为非阻塞模式
    int   savefl   =   fcntl(iSock,F_GETFL);
    fcntl(iSock,   F_SETFL,   savefl   |   O_NONBLOCK);

    int ret = connect(iSock, (struct sockaddr *)&addr, sizeof(addr));
    if(ret == 0){
        return iSock;
    }
    
    stTimeVal.tv_sec  = iTimeOut<0 ? MAXLONG : iTimeOut;
    stTimeVal.tv_usec = 0;
    
    FD_ZERO(&setId);
    FD_SET((SOCKET)iSock, &setId);
    
    iRet = select(iSock + 1, NULL, &setId, NULL, &stTimeVal);
    if( iRet<0 ){
        return (ERR_SOCK_READ);
    }
    if( iRet==0 ){
        return (ERR_SOCK_TIMEOUT);
    }
    
    fcntl(iSock,   F_SETFL,savefl);
    return iSock;
    
#if 0
#if 1   // no need for block socket
    stTimeVal.tv_sec  = iTimeOut<0 ? MAXLONG : iTimeOut;
    stTimeVal.tv_usec = 0;

    FD_ZERO(&setId);
    FD_SET((SOCKET)iSock, &setId);

    iRet = select(iSock+1, &setId, &setId, &setId, &stTimeVal);
    if( iRet<0 ){
        return (ERR_SOCK_READ);
    }
    if( iRet==0 ){
        return (ERR_SOCK_TIMEOUT);
    }
#endif

    /* Connect the socket, for UDP it just put address information into IP
     * protocol stack & recv() or send() call can be used for UPD socket */
    printf("开始连接\n");
    int ret = connect(iSock, (struct sockaddr *)&addr, sizeof(addr));
    printf("ret = %d\n", ret);
    if(  ret <0 ){
        vCloseSock(iSock, 0);
        return ERR_SOCK_CONNECT; /* can't connect */
    }
#endif

    return iSock;
}


// end of file
