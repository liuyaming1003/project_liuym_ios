
/****************************************************************************
    NAME
        sockcomm2.h     - functions for socket communication

    MODIFIED    (YYYY.MM.DD)
    sjx          2000.11.30     - created
 ***************************************************************************/

#ifndef __SOCKCOMM2_H
#define __SOCKCOMM2_H

/* define error return code */
#define ERR_SOCK_INIT       -1000       /* can't initialize dll */
#define ERR_SOCK_PORT       -1001       /* can't get service entry  */
#define ERR_SOCK_PROTOCOL   -1002       /* can't get protocol entry */
#define ERR_SOCK_SOCKET     -1003       /* can't create socket */
#define ERR_SOCK_BIND       -1004       /* can't bind to port */
#define ERR_SOCK_LISTEN     -1005       /* can't listen on port */
#define ERR_SOCK_HOST       -1006       /* can't get host entry */
#define ERR_SOCK_CONNECT    -1007       /* can't connect */
#define ERR_SOCK_READ       -1008       /* read error or timeout */
#define ERR_SOCK_WRITE      -1009       /* write error or timeout */
#define ERR_SOCK_ACCEPT     -1010       /* accept error */
#define ERR_SOCK_TIMEOUT    -1011	    /* time out */

#define TPB 0x01
#define TTB 0x02
#define TPE 0x03

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */


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
int iConnectTCP(const char *pszHost, const char *pszService, int iTimeout);


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
int iPassiveTCP(const char *pszService, int iQlen);


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
int iConnectUDP(const char *pszHost, const char *pszService, int iTimeout);


/****************************************************************************
*   Function:
*       make a passive socket with UDP protocol
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
int iPassiveUDP(const char *pszService);


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
int iAcceptSock(int iSock, char *pszClientIP, int iTimeOut);


/****************************************************************************
*   Function:
*        read from socket(read until EOF or fit request length)
*   Arguments:
*       iSocket     -   descriptor referencing the socket
*       psBuf       -   read buffer
*       iReadLen    -   data byte length should be read
*       iTimeOut    -   microseconds to timeout while reading
*
*   Returns:
*       >=0             -   success
*       ERR_SOCK_READ   -   read error or timeout
****************************************************************************/
int iReadSock(int iSock, char *psBuf, int iReadLen, int iTimeOut);


/****************************************************************************
*   Function:
*        read from socket(only read once)
*   Arguments:
*       iSocket     -   descriptor referencing the socket
*       psBuf       -   read buffer
*       iReadLen    -   data byte length should be read
*       iTimeOut    -   microseconds to timeout while reading
*
*   Returns:
*       >=0             -   bytes actually read
*       ERR_SOCK_READ   -   read error or timeout
****************************************************************************/
int iReadSock2(int iSock, char *psBuf, int iMaxReadLen, int iTimeOut);

int iReadSockfromAs400(int iSock, char *psBuf, int iReadLen, int iTimeOut);
/****************************************************************************
*   Function:
*        write to socket
*   Arguments:
*       iSocket     -   descriptor referencing the socket
*       psBuf       -   data buffer
*       iWriteLen    -  data byte length should be writen
*       iTimeOut    -   microseconds to timeout while writing
*
*   Returns:
*       0               -   success
*       ERR_SOCK_WRITE  -   write error or timeout
****************************************************************************/
int iWriteSock(int iSock, char *psBuf, int iWriteLen, int iTimeOut);


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
void vCloseSock(int iSock, int bRelease);


#ifdef __cplusplus
}
#endif  /* __cplusplus */

#if defined(WIN32) || defined(WINDOWS)
#pragma comment(lib, "ws2_32.lib")
#pragma message("Automaticly linking with ws2_32.lib")
#endif

#endif  /* __SOCKCOMM2_H */


// end of file
