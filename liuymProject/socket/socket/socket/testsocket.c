#include <stdio.h>

int main()
{
    /*int ret = SocketListen("9000", "tcp", 10);
    printf("ret = %d\n", ret);

    if(ret > 0)
    {
        char ip[20];
        ret = SocketAccept(ret, ip);
        printf("ret = %d\n", ret);

        if(ret > 0){
            ret = SocketWrite(ret, "123123123", 9, 10);
            printf("ret = %d\n", ret);
        }

        DisSocketConnect(ret);
        }*/
    
    int i = 0;
    int socketRet;
    char buff[10240];
    memset(buff, 0, sizeof(buff));
    socketRet = SocketConnect("192.168.2.109", "9000", "tcp", 2);
    for(i = 0 ; i < 1; i++){
        if(socketRet > 0){
            int ret = SocketWrite(socketRet, "\x00\x04\x00\x01\x02\x03", 6, 2);
            printf("write.......%d\n", ret);
            ret = SocketReadLength(socketRet, buff, 2, 4);
            int length = buff[0] * 256 + 255;
            printf("read = %d, %d, length = %d %02x,%02x\n", socketRet, ret, length, buff[0], buff[1]);
            ret = SocketReadLength(socketRet, buff, length, 10);
            printf("read = %d, %d\n", socketRet, ret);
            /*if(ret == length){
                for(int j = 0; j < length; j++){
                    printf("%02X", buff[j]);
                }
                }*/
            //DisSocketConnect(socketRet);
          
        }else{
            printf("socketRet = %d, i = %d\n", socketRet, i);
            //break;
        }
        
    }
    //DisSocketConnect(socketRet);
    
    while(1){}

    return 0;
}
