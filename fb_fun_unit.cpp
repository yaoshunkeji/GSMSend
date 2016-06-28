/*
 * FB_fun_unit.cpp
 *
 *  Created on: 2015年8月20日
 *      Author: root
 *
 *
 *      1。服务器接
 *      	接收T终端，或是发短信命令
 *      2。客户端
 *      	向app问，是否同意入网
 *      	发送yatebts事件给app
 *      	发送程序运行日志，发送程序启动，退出等日志
 *
 *
 */

#ifndef FB_FUN_UNIT_C_
#define FB_FUN_UNIT_C_

#define MODE_INCLUDE      //不用头文件方式，直接 在源代码中 #include xxx.cpp 方式 ,省的改其它文件


//#define FB_NoApp



#include <string.h>
#include <pthread.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include <sys/types.h>
#include <sys/socket.h>

#include <netinet/in.h>
#include <arpa/inet.h>

#include <unistd.h>
#include <errno.h>
#include <fcntl.h>


#include "/opt/new/crc16_unit.c"
#include "/opt/new/FB_fun_unit.h"


//int FB_ProcMsg(TSmsInfo * sms);


#define FB_MAXBUF_SIZE 16384

//待发送的消息
#define  FB_MsgList_Max 8192
TSmsInfo FB_MsgList[FB_MsgList_Max] = {0};
int FB_MsgList_Count = 0;
pthread_mutex_t FB_MsgList_Lock = {0};

//待踢手机的列表
#define  FB_TickList_Max 8192
TSmsInfo FB_TickList[FB_TickList_Max] = {0};
int FB_TickList_Count = 0;
pthread_mutex_t FB_TickList_Lock = {0};


#define  FB_CallList_Max 4096
TSmsInfo FB_CallList[FB_CallList_Max] = {0};
int FB_CallList_Count = 0;
pthread_mutex_t FB_CallList_Lock = {0};


#define  FB_ForceUplink_Max 4096
TSmsInfo FB_ForceUplinkList[FB_ForceUplink_Max] = {0};
int FB_ForceUplink_Count = 0;
pthread_mutex_t FB_ForceUplink_Lock = {0};

#define  FB_OtherTask_Max 4096
TSmsInfo FB_OtherTaskList[FB_OtherTask_Max] = {0};
int FB_OtherTask_Count = 0;
pthread_mutex_t FB_OtherTask_Lock = {0};

typedef struct TSendData_General
    {
    TMSG msg;
    void * buf;
    int buflen;
    } tagSendData_General;

#define  FB_SendData_General_List_Max 16384

int FB_GeneralSendList_Inited = 0;
TSendData_General FB_GeneralSendList[FB_SendData_General_List_Max] = {0};
int FB_SendData_General_List_Count = 0;
pthread_mutex_t FB_SendData_General_List_Lock = {0};
pthread_t FB_GeneralSendList_Threadid = -1;


pthread_t FB_ServerThread_id = -1;
int FB_ServerSocket;


#define DEF_ListPointer(Fun) \
pthread_mutex_t * lock=0; \
TSmsInfo *List=0; \
int ListSize=0; \
int * Count=0; \
if (Fun==FunDef_SendSms) \
{ \
  lock=&FB_MsgList_Lock; \
  List=&FB_MsgList[0]; \
  ListSize=FB_MsgList_Max; \
  Count=&FB_MsgList_Count; \
} \
if (Fun==FunDef_TickConn) \
{ \
  lock=&FB_TickList_Lock; \
  List=&FB_TickList[0]; \
  ListSize=FB_TickList_Max; \
  Count=&FB_TickList_Count; \
} \
if (Fun==FunDef_BTS_Call) \
{ \
  lock=&FB_CallList_Lock; \
  List=&FB_CallList[0]; \
  ListSize=FB_CallList_Max; \
  Count=&FB_CallList_Count; \
} \
if (Fun==FunDef_ForceUplink) \
{ \
  lock=&FB_ForceUplink_Lock; \
  List=&FB_ForceUplinkList[0]; \
  ListSize=FB_ForceUplink_Max; \
  Count=&FB_ForceUplink_Count; \
} \
if (Fun>=FunDef_OtherTask_Start) \
{ \
  lock=&FB_OtherTask_Lock; \
  List=&FB_OtherTaskList[0]; \
  ListSize=FB_OtherTask_Max; \
  Count=&FB_OtherTask_Count; \
} \


int DoConect(int sockfd, struct sockaddr * address, int timeout_ms)
    {
    int r = -1;
    fd_set fdset;
    struct timeval tv;
    int flags = fcntl(sockfd, F_GETFL, 0);
    int blBLOCK = (flags and O_NONBLOCK);

    if (blBLOCK)
        fcntl(sockfd, F_SETFL, O_NONBLOCK);


    FD_ZERO(&fdset);
    FD_SET(sockfd, &fdset);
    tv.tv_sec = timeout_ms / 1000; /* 10 second timeout */
    tv.tv_usec = timeout_ms % 1000;

    connect(sockfd, address, sizeof (*address));

    if (select(sockfd + 1, NULL, &fdset, NULL, &tv) == 1)
        {
        int so_error = 1;
        socklen_t len = sizeof (so_error);

        getsockopt(sockfd, SOL_SOCKET, SO_ERROR, &so_error, &len);

        if (so_error == 0)
            {
            r = 0; //printf("%s:%d is open\n", addr, port);
            }
        }
    if (blBLOCK)
        fcntl(sockfd, F_SETFL, flags&~O_NONBLOCK);


    if (setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, (void *) &tv, sizeof (tv)) < 0)
        printf("setsockopt failed\n");

    if (setsockopt(sockfd, SOL_SOCKET, SO_SNDTIMEO, (void *) &tv, sizeof (tv)) < 0)
        printf("setsockopt failed\n");

    return r;

    }

void fill_msg(struct TMSG *msg)
    {
    memset(msg, 0, sizeof (TMSG));
    int l = strlen(MsgFlag);
    char *p = &msg->Flag[0];
    strncpy(p, MsgFlag, l);
    }

void NULL_Code(...)
    {


    }

TSendData_General FB_SendData_General_List_pop()
    {
    TSendData_General data = {0};

    pthread_mutex_lock(&FB_SendData_General_List_Lock);

    if (FB_SendData_General_List_Count > 0)
        {
        data = FB_GeneralSendList[0];
        FB_SendData_General_List_Count = FB_SendData_General_List_Count - 1;
        int l = FB_SendData_General_List_Count * sizeof (TSmsInfo);
        memmove(&FB_GeneralSendList[0], &FB_GeneralSendList[1], l);
        }
    else
        {
        data.msg.MsgType = 0;
        }
    pthread_mutex_unlock(&FB_SendData_General_List_Lock);

    return data;
    }

void * SendGeneralData(void * p)
    {
    TSendData_General data = {0};
    int r = 0;
    int con = -1;
    while (true)
        {
        data = FB_SendData_General_List_pop();
        if (data.msg.MsgType == 0)
            {
            usleep(1000);
            continue;
            }
        con = -1;
        data.msg.DataSize = data.buflen;

        r = SendData_h_d(&data.msg, data.buf, data.buflen, 0);
        if (data.buf)
            free(data.buf);

        //usleep(10)
        }

    }

void FB_SendData_General_List_CheckInited()
    {
    if (FB_GeneralSendList_Inited)
        return;

    pthread_mutex_init(&FB_MsgList_Lock, 0);
    pthread_create(&FB_GeneralSendList_Threadid, NULL, SendGeneralData, 0);

    FB_GeneralSendList_Inited = 1;

    }

TSendData_General FB_SendData_General_List_push(TMSG msg, void * buf, int buflen)
    {
    FB_SendData_General_List_CheckInited();

    pthread_mutex_lock(&FB_SendData_General_List_Lock);

    if (FB_SendData_General_List_Count < FB_SendData_General_List_Max)
        {
        TSendData_General * data;
        data = &FB_GeneralSendList[FB_SendData_General_List_Count];
        data->msg = msg;
        data->buf = 0;
        data->buflen = 0;
        if (buflen > 0)
            {
            data->buf = malloc(buflen + 1);
            memset(data->buf, 0, buflen + 1);
            memcpy(data->buf, buf, buflen);
            data->buflen = buflen;
            }

        FB_SendData_General_List_Count = FB_SendData_General_List_Count + 1;
        }
    pthread_mutex_unlock(&FB_SendData_General_List_Lock);

    }

int FB_STRCMP(const char *a, const char *b, int Max)
    {
    if ((a == 0) || (b == 0))
        return 0;
    if (strlen(a) == 0)
        return 0;
    if (strlen(b) == 0)
        return 0;
    if (Max > 0)
        {
        int l1 = strlen(a);
        int l2 = strlen(a);
        l1 = MIN(l1, l2);
        l1 = MIN(l1, Max);
        return strncmp(a, b, l1);
        }
    else
        {
        return strcmp(a, b);
        }
    }

int Msg_CheckRestore(TMSG * msg, uint8_t * buf)
    {
    uint16_t z;

    if (msg->DataSize == 0)
        return 0;

#ifndef MSG_SETCHECK
    return 0;
#endif


    if ((msg->CRC16 != 0xffff) and (msg->CRC16 != 0))
        {
        z = crc16(0, buf, msg->DataSize);
        z = crc16(z, (uint8_t *) MSG_CRCKEY, strlen(MSG_CRCKEY));
        if (z != msg->CRC16)
            return -1;
        }
    for (int i = 0; i < msg->DataSize; i++)
        {
        buf[i] = buf[i] ^ msg->xor1;
        }
    return 0;
    }

void Msg_SetCheck(TMSG * msg, uint8_t * buf)
    {
    uint16_t z = 0;
    uint8_t x = 0;
    if (msg->DataSize == 0)
        {
        msg->xor1 = 0;
        msg->CRC16 = 0;
        return;
        }

    srand(time(NULL)); //设置随机数种子。
    z = rand() % 255;
    z = MAX(z, 20);
    msg->xor1 = z;
    for (int i = 0; i < msg->DataSize; i++)
        {
        buf[i] = buf[i] ^ msg->xor1;
        }

    z = crc16(0, buf, msg->DataSize);
    z = crc16(z, (uint8_t *) MSG_CRCKEY, strlen(MSG_CRCKEY));
    msg->CRC16 = z;

    }

void FB_SendSmsOK(TSmsInfo *sms, int ok, char * Reason) //告诉客户端，发送成功
    {
    const char nullstr[] = "";
    char s[1024] = {0};
    struct TMSG msg = {0};
    fill_msg(&msg);
    msg.MsgType = mt_SendSms;
    msg.Res = ok;

    const char *imei = sms->imei;
    const char *imsi = sms->imsi;
    const char *tel = sms->tel;
    const char *smskey = sms->smsKey;
    if (!smskey)
        smskey = nullstr;
    if (!imei)
        imei = nullstr;
    if (!imsi)
        imsi = nullstr;
    if (!tel)
        tel = nullstr;
    if (Reason)
        snprintf(s, 1024 - 1, "smskey=%s,imsi=%s,imei=%s,tel=%s,Reason=%s", smskey, imsi, imei, tel, Reason);
    msg.DataSize = strlen(s);
    SendData_h_d(&msg, (void *) &s[0], strlen(s), 0);
    }

void FB_SendSms_Status(const char * SrcTel, const char * DestTmsi, const char * SMSkey, int ok, const char * Reason) //告诉客户端，发送结果
    {

    const char nullstr[] = "";
    char buf[1024] = {0};
    struct TMSG msg = {0};
    fill_msg(&msg);
    msg.MsgType = mt_SendSms;
    msg.Res = ok;

    const char *aSrcTel = SrcTel;
    const char *aDestTmsi = DestTmsi;
    const char *aSMSkey = SMSkey;
    const char *aReason = Reason;
    if (!aSrcTel)
        aSrcTel = nullstr;

    if (!aDestTmsi)
        aDestTmsi = nullstr;
    if (!aSMSkey)
        aSMSkey = nullstr;
    if (!aReason)
        aReason = nullstr;

    snprintf(buf, 1024 - 1, "smskey=%s,OK=%d,SrcTel=%s,DestTmsi=%s,Reason=%s", aSMSkey, ok, aSrcTel, aDestTmsi, aReason);
    msg.DataSize = strlen(buf);

#ifdef FB_UseGeneralSendList
    FB_SendData_General_List_push(msg, (void *) buf, strlen(buf));

    return;
#endif

    SendData_h_d(&msg, (void *) &buf[0], strlen(buf), 0);
    }

int FB_SendSms(char * buf, int len) //成功返回1
    {
    int r = 0;
    TSmsInfo msg = {0};
    if (FB_GetMsg(buf, len, &msg))
        return -1;

    msg.MaxPPD = MAX(abs(msg.MaxPPD), 2000);
    msg.MaxPPD = MIN(abs(msg.MaxPPD), 20000);

    return FB_MsgList_push(&msg);
    }

int FB_SendCall(char * buf, int len) //成功返回1
    {
    int r = 0;
    TSmsInfo msg = {0};
    if (FB_GetMsg(buf, len, &msg))
        return -1;

    return FB_MsgList_push(&msg);
    }

int FB_ForceUplink(char * buf, int len) //成功返回1
    {
    int r = 0;
    TSmsInfo msg = {0};
    if (FB_GetMsg(buf, len, &msg))
        return -1;

    return FB_MsgList_push(&msg);
    }

int FB_OtherTask(char * buf, int len) //成功返回1
    {
    int r = 0;
    TSmsInfo msg = {0};
    if (FB_GetMsg(buf, len, &msg))
        {
            return -1;
        }

    return FB_MsgList_push(&msg);
    }

int FB_TickConn(char * buf, int len)
    {
    int r = 0;
    TSmsInfo msg = {0};
    if (FB_GetMsg(buf, len, &msg))
        return -1;

    if (msg.MaxPPD < 0)
        {
        msg.MaxPPD = -MAX(abs(msg.MaxPPD), 1000);
        msg.MaxPPD = -MIN(abs(msg.MaxPPD), 60000);
        }
    if (msg.MaxPPD > 0)
        {
        msg.MaxPPD = MAX(abs(msg.MaxPPD), 1000);
        msg.MaxPPD = MIN(abs(msg.MaxPPD), 60000);
        }

    if (msg.MaxPPD > 0)
        {
        //r=FB_ProcMsg(&msg);
        //FREE_SmsInfo(&msg);
        //return r;
        }
    return FB_MsgList_push(&msg);
    }

int GetDataIdx(TItem * item, int arraysize, char * key)
    {
    int i = 0;
    for (i = 0; i < arraysize; i++)
        {
        if (strcasecmp(item[i].key, key) == 0)
            {
            return i;
            }
        }
    return -1;
    }

char * GetDataVal(TItem * item, int arraysize, char * key, char * DelHead = 0)
    {
    int R = GetDataIdx(item, arraysize, key);
    if (R >= 0)
        {
        char *c = item[R].text;
        if (DelHead)
            {
            int l = strlen(DelHead);
            l = MIN(l, strlen(c));
            if (strncmp(c, DelHead, l) == 0)
                {
                c = &c[l];
                }
            }
        return c;
        }
    else
        return 0;
    }

const char * Cpy_New(const char * key)
    {
    if (key == 0)
        return "";

    int l = strlen(key);

    char *d = (char *) malloc(l + 1); // new char[l+1];
    strcpy(d, key);
    return d;
    }

char * GetDataVal_New(TItem * item, int arraysize, char * key, int CheckNullVal = 0, char * DelHead = 0)
    {
    char * r = GetDataVal(item, arraysize, key, DelHead);
    if (r)
        {
        if (CheckNullVal)
            {
            if (strcmp(r, "(null)") == 0)
                return 0;
            }
        int l = strlen(r);

        char *d = (char *) malloc(l + 1); // new char[l+1];
        strcpy(d, r);
        return d;
        }
    else
        {
        return 0;
        }
    }

int GetDataVal_New_int(TItem * item, int arraysize, char * key, int NullVal = 0)
    {
    char * r = GetDataVal(item, arraysize, key);
    if (r)
        {
        if (strlen(r) == 0)
            return NullVal;
        else
            return atoi(r);
        }
    else
        {
        return NullVal;
        }
    }

TSmsInfo FB_MsgList_pop(int Fun)
    {
    DEF_ListPointer(Fun);
    TSmsInfo msg = {0};

    pthread_mutex_lock(lock);
    int c = *Count;
    if (c > 0)
        {
        msg = List[0];
        c = c - 1;
        *Count = c;
        int l = c * sizeof (TSmsInfo);
        memmove(&List[0], &List[1], l);

        //printf("FB_MsgList_pop  fun=%d\n",msg.fun);
        }
    pthread_mutex_unlock(lock);

    return msg;
    }

TSmsInfo FB_popTick()
    {
    return FB_MsgList_pop(FunDef_TickConn);
    }

TSmsInfo FB_popMsg()
    {
    return FB_MsgList_pop(FunDef_SendSms);
    }

TSmsInfo FB_popCall()
    {
    return FB_MsgList_pop(FunDef_BTS_Call);
    }

TSmsInfo FB_popForceUplink()
    {
    return FB_MsgList_pop(FunDef_ForceUplink);
    }

TSmsInfo FB_popOtherTask()
    {
    return FB_MsgList_pop(FunDef_OtherTask_Start);
    }

int FB_CpyMsg(TSmsInfo *src, TSmsInfo *msg)
    {
    memset(msg, 0, sizeof (TSmsInfo));
    msg->smsKey = Cpy_New(src->smsKey);
    msg->imei = Cpy_New(src->imei);
    msg->imsi = Cpy_New(src->imsi);
    msg->smsc = Cpy_New(src->smsc);
    msg->smscTimeOffset = src->smscTimeOffset;
    msg->tmsi = Cpy_New(src->tmsi);
    msg->sms = Cpy_New(src->sms);
    msg->tel = Cpy_New(src->tel);
    msg->pdu = Cpy_New(src->pdu);
    msg->encode = src->encode;
    msg->text = Cpy_New(src->text);
    msg->textlen = src->textlen;
    msg->textHex = Cpy_New(src->textHex);
    msg->textPDU = Cpy_New(src->textPDU);
    msg->MaxPPD = src->MaxPPD;
    msg->caller = Cpy_New(src->caller);
    msg->called = Cpy_New(src->called);
    msg->UpLinkMode = src->UpLinkMode;
    msg->SmsSentOK_KickOut = src->SmsSentOK_KickOut;
    msg->connid = src->connid;
    msg->conn = Cpy_New(src->conn);
    msg->KickOut_RL3Message = Cpy_New(src->KickOut_RL3Message);

    msg->NewLocationMethod = src->NewLocationMethod;
    msg->NewMCC = src->NewMCC;
    msg->NewMNC = src->NewMNC;
    msg->NewLAC = src->NewLAC;
    msg->NewCID = src->NewCID;

    msg->askIMEI = src->askIMEI;
    }

int FB_GetMsg(char *buf, int len, TSmsInfo *msg)
    {
    memset(msg, 0, sizeof (TSmsInfo));
    TItem itm[128] = {0};
    int r = AnalysisStr(buf, len, &itm[0], 64);
    if (r == 0)
        return -1;

    int l = 0;

    msg->fun = GetDataVal_New_int(&itm[0], r, "Fun");


    msg->imei = GetDataVal_New(&itm[0], r, "IMEI", 1);
    msg->tmsi = GetDataVal_New(&itm[0], r, "TMSI", 1);
    msg->imsi = GetDataVal_New(&itm[0], r, "IMSI", 1);

    msg->pdu = GetDataVal_New(&itm[0], r, "PDU");
    msg->sms = GetDataVal_New(&itm[0], r, "SMS");
    msg->smsc = GetDataVal_New(&itm[0], r, "SMSC", 0, "+"); //可能不能超过15位

    msg->tel = GetDataVal_New(&itm[0], r, "Tel");
    msg->text = GetDataVal_New(&itm[0], r, "Text");
    msg->textlen = GetDataVal_New_int(&itm[0], r, "TextLen");

    msg->encode = GetDataVal_New_int(&itm[0], r, "EnCode");
    msg->textHex = GetDataVal_New(&itm[0], r, "textHex");
    msg->textPDU = GetDataVal_New(&itm[0], r, "textPDU");
    if ((!msg->text) && (msg->textHex) && (msg->encode == 0))
        {
        if (msg->text)
            {
            free((char *) msg->text);
            }
        int l = strlen(msg->textHex) / 2;
        msg->text = (char *) malloc(l + 1);
        memset((void *) msg->text, 0, l + 1);
        msg->textlen = HexStr2Bin(msg->textHex, (unsigned char *) msg->text);
        }

    msg->MaxPPD = GetDataVal_New_int(&itm[0], r, "MaxPPD");
    msg->smscTimeOffset = GetDataVal_New_int(&itm[0], r, "smscTimeOffset");

    msg->smsKey = GetDataVal_New(&itm[0], r, "smsKey");

    msg->caller = GetDataVal_New(&itm[0], r, "caller");
    msg->called = GetDataVal_New(&itm[0], r, "called");

    msg->UpLinkMode = GetDataVal_New_int(&itm[0], r, "UpLinkMode");
    msg->SmsSentOK_KickOut = GetDataVal_New_int(&itm[0], r, "SmsSentOK_KickOut");

    msg->connid = GetDataVal_New_int(&itm[0], r, "ConnID");
    msg->conn = GetDataVal_New(&itm[0], r, "Conn");
    msg->KickOut_RL3Message = GetDataVal_New(&itm[0], r, "KickOut_RL3Message");

    msg->NewLocationMethod = GetDataVal_New_int(&itm[0], r, "NewLocationMethod");
    msg->NewMCC = GetDataVal_New_int(&itm[0], r, "NewMCC", -1);
    msg->NewMNC = GetDataVal_New_int(&itm[0], r, "NewMNC", -1);
    msg->NewLAC = GetDataVal_New_int(&itm[0], r, "NewLAC", -1);
    msg->NewCID = GetDataVal_New_int(&itm[0], r, "NewCID", -1);

    msg->askIMEI = GetDataVal_New_int(&itm[0], r, "askIMEI", -1);

    //    printf("635,fun=%d,up=%d\n",msg->fun,msg->UpLinkMode);

    if (msg->MaxPPD == 0)
        {
        msg->MaxPPD = 5000;
        }

    if (msg->imei)
        {
        //		if (strlen(msg->imei)>=15)
        //		{
        //			msg->imei[14]=0;
        //		}
        }
    int b=0;
    if ((msg->fun >=FunDef_SendSms) and (msg->fun<=FunDef_ForceUplink))
        b=1;
            
    if ((msg->fun >=FunDef_OtherTask_Start) and (msg->fun<=FunDef_OtherTask_End))
        b=1;
    
    if (! b)
        {
            FREE_SmsInfo(msg);
            return -1;
        }

    return 0;
    }

void FB_MsgList_Clear(int fun)
    {
    DEF_ListPointer(fun);
    pthread_mutex_lock(lock);
    *Count = 0;

    pthread_mutex_unlock(lock);

    }

int FB_MsgList_GetCount(int fun)
    {
    int R = 0;
    DEF_ListPointer(fun);
    pthread_mutex_lock(lock);
    R = *Count;
    pthread_mutex_unlock(lock);
    return R;
    }

int FB_MsgList_push(TSmsInfo *msg)
    {
    DEF_ListPointer(msg->fun);
    //	printf("fun=%d\n",msg->fun);

    if ((lock == 0) || (List == 0) || (Count == 0))
        {
        printf("DEF_ListPointer error!!!\n");
        return 0;
        }

    int r = -1;
    pthread_mutex_lock(lock);
    r = *Count;
    if (r < ListSize)
        {
        List[r] = *msg;
        r = r + 1;
        *Count = r;
        }
    else
        {
        FREE_SmsInfo(msg);
        r = -1;
        }
    pthread_mutex_unlock(lock);

    return r;
    }

char * trim(char * src)
    {
    int i = 0;
    char *begin = src;
    while (src[i] != '\0')
        {
        if (src[i] != ' ')
            {
            break;
            }
        else
            {
            begin++;
            }
        i++;
        }
    for (i = strlen(src) - 1; i >= 0; i--)
        {
        if (src[i] != ' ')
            {
            break;
            }
        else
            {
            src[i] = '\0';
            }
        }
    return begin;
    }

//IMEI:xxx,IMSI:xxx, 分离

int AnalysisStr(char * str, int strlen, TItem * item, int arraysize)
    {
    int r = 0;
    char *pp;
    char * str2 = str;
    str = str + strlen;
    TItem itm = {0};
    int flag = 0;
    while (str2 < str)
        {
        //"IMEI:1221212121112121zz,IMSI:123245678,ABC:797787979a";
        if (r >= arraysize)
            break;

        pp = (char *) memchr((void *) str2, '=', str - str2);
        if (!pp)
            break;

        *pp = 0;
        itm.key = str2;

        str2 = pp + 1;

        pp = (char *) memchr((void *) str2, ',', str - str2);
        if (!pp)
            flag = 1;

        itm.text = str2;

        itm.key = trim(itm.key);
        itm.text = trim(itm.text);

        item[r] = itm;
        r++;

        if (flag == 1)
            break;

        *pp = 0;
        str2 = pp + 1;

        }
    return r;
    }

void * Server_SubThread(void * p)
    {
    //struct TConectInfo * T=(struct TConectInfo *)p;
    struct TConectInfo ci = {0};
    //memcpy(&ci,p,sizeof(ci));
    ci.Connfd = *(int *) p;
    char buf[FB_MAXBUF_SIZE] = {0};
    int c;
    //char buf[1024]={0};
    struct TMSG msg = {0};
    c = recv(ci.Connfd, &msg, sizeof (msg), 0);
    //printf("%s type=%d \n",msg.Flag,msg.MsgType);

    if (c == sizeof (msg))
        {
        switch (msg.MsgType)
            {
            case mt_TickConn: //踢人
            {
                c = recv(ci.Connfd, (void *) &buf[0], msg.DataSize, 0);
                if (c == msg.DataSize)
                    {
                    if (Msg_CheckRestore(&msg, (uint8_t *) & buf[0]))
                        break;

                    msg.Res = FB_TickConn(&buf[0], c);
                    msg.DataSize = 0;
                    }
                break;
            }
            case mt_SendSms:
            {
                c = recv(ci.Connfd, (void *) &buf[0], msg.DataSize, 0);
                if (c == msg.DataSize)
                    {
                    if (Msg_CheckRestore(&msg, (uint8_t *) & buf[0]))
                        break;
#ifdef FB_Print_SendData
                    printf("mt_SendSms=%s\n", buf);
#endif
                    msg.Res = FB_SendSms(&buf[0], c);
                    msg.DataSize = 0;
                    //send(ci.Connfd,&msg,sizeof(msg),0);
                    }
                break;
            }
            case mt_SendSms_ClearList:
            {
                FB_MsgList_Clear(FunDef_SendSms);
                msg.Res = 0;
                msg.DataSize = 0;
                break;
            }
            case mt_SendSms_GetListCount:
            {
                msg.Res = FB_MsgList_GetCount(FunDef_SendSms);
                msg.DataSize = 0;
                send(ci.Connfd, &msg, sizeof (msg), 0);
                break;
            }
            case mt_SendCall:
            {
                c = recv(ci.Connfd, (void *) &buf[0], msg.DataSize, 0);
                if (c == msg.DataSize)
                    {
                    if (Msg_CheckRestore(&msg, (uint8_t *) & buf[0]))
                        break;
#ifdef FB_Print_SendData
                    printf("mt_SendCall=%s\n", buf);
#endif
                    msg.Res = FB_SendCall(&buf[0], c);
                    msg.DataSize = 0;
                    //send(ci.Connfd,&msg,sizeof(msg),0);
                    }
                break;
            }

            case mt_ForceUplink:
            {
                if (CheckAppMsg_ForceUplink_Loop_id != -1)
                    {
                    pthread_cancel(CheckAppMsg_ForceUplink_Loop_id);
                    CheckAppMsg_ForceUplink_Loop_id = -1;
                    }

                c = recv(ci.Connfd, (void *) &buf[0], msg.DataSize, 0);
                if (c == msg.DataSize)
                    {
                    if (Msg_CheckRestore(&msg, (uint8_t *) & buf[0]))
                        break;
#ifdef FB_Print_SendData
                    printf("mt_ForceUplink=%s\n", buf);
#endif
                    msg.Res = FB_ForceUplink(&buf[0], c);
                    msg.DataSize = 0;
                    //send(ci.Connfd,&msg,sizeof(msg),0);
                    }
                break;
            }
            case mt_ForceUplink_Stop:
            {
                msg.DataSize = 0;
                msg.Res = 0;
                FB_MsgList_Clear(FunDef_ForceUplink);
                if (CheckAppMsg_ForceUplink_Loop_id != -1)
                    {
                    pthread_cancel(CheckAppMsg_ForceUplink_Loop_id);
                    CheckAppMsg_ForceUplink_Loop_id = -1;
                    }
                break;
            }
            case  mt_NewLocation:
            case  mt_askIMEI:
            {
                c = recv(ci.Connfd, (void *) &buf[0], msg.DataSize, 0);
                if (c == msg.DataSize)
                    {                                        
                    if (Msg_CheckRestore(&msg, (uint8_t *) & buf[0]))
                        break;
                    #ifdef FB_Print_SendData
                    printf("msg.DataSize=[ %d ]\n", msg.DataSize);                    
                    printf("NewLocation/askIMEI=[ %s ]\n", buf);
                    printf("NewLocation/askIMEI=[ %d%d%d%d ]\n", buf[0],buf[1],buf[2],buf[3]);
                    #endif
                    msg.Res = FB_OtherTask(&buf[0], c);
                    msg.DataSize = 0;
                    
                    }
                break;
            }
           }
        }
    close(ci.Connfd);
    pthread_exit(NULL);
    }

void * ServerThread(void * p)
    {
#define ConectInfo_MAX 512

    struct TConectInfo ConectInfo[ConectInfo_MAX] = {0};
    int idx = 0;

    FB_DEBUG;

    //int sockfd=*(int *)p;
    socklen_t clilen;
    struct sockaddr cliaddr;
    //int  connfd;
    pthread_t subthreads;

    while (1)
        {
        pthread_testcancel();

        memset(&ConectInfo[idx], 0, sizeof (TConectInfo));
        clilen = sizeof (cliaddr);
        ConectInfo[idx].Connfd = accept(FB_ServerSocket, &cliaddr, &clilen);
        ConectInfo[idx].sockfd = FB_ServerSocket;
        ConectInfo[idx].CliAddr = cliaddr;
        ConectInfo[idx].CliLen = clilen;
        //        FB_DEBUG;

        if (ConectInfo[idx].Connfd == -1)
            {
            //perror("accept");
            continue;
            }
        pthread_create(&subthreads, NULL, Server_SubThread, &ConectInfo[idx].Connfd);
        idx++;
        if (idx >= ConectInfo_MAX)
            idx = 0;
        }
    pthread_exit(NULL);
    }

int StartServer()
    {

    //需要避免多少启动

    SendData_Log(-1, "====启动低层通讯服务====");

    pthread_mutex_init(&FB_MsgList_Lock, 0);
    pthread_mutex_init(&FB_TickList_Lock, 0);
    FB_SendData_General_List_CheckInited();


    //int FB_ServerSocket;
    struct sockaddr_in serverAddr;
    struct sockaddr_in clientAddr;

    // 用port保存使用的端口
    // 建立Socket，并设置
    FB_ServerSocket = socket(AF_INET, SOCK_STREAM, 0);

    // 设置socket选项，这是可选的，可以避免服务器程序结束后无法快速重新运行
    int val = 1;
    setsockopt(FB_ServerSocket, SOL_SOCKET, SO_REUSEADDR, &val, sizeof (val));

    // 定义端口和监听的地址
    memset(&serverAddr, 0, sizeof (serverAddr));
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_port = htons(ServerPort_BTS);
    serverAddr.sin_addr.s_addr = htonl(INADDR_ANY);
    int rc = bind(FB_ServerSocket, (struct sockaddr*) &serverAddr, sizeof (struct sockaddr));
    usleep(200 * 1000);
    if (rc == -1)
        {
        perror("============bind ERROR");
        exit(1);
        }

    rc = listen(FB_ServerSocket, 5);
    usleep(500 * 1000);
    if (rc == -1)
        {
        perror("============listen ERROR");
        exit(1);
        }

    // 等待客户连接
    int sock;
    int clientAddrSize = sizeof (struct sockaddr_in);
    pthread_create(&FB_ServerThread_id, NULL, ServerThread, NULL);

    }

int SendData(void * buf, int len, int *conn)
    {
    int cfd = -1;
    int c;
    struct sockaddr_in s_add;

    if (conn)
        {
        cfd = *conn;
        }

    if (cfd < 0)
        {
        cfd = socket(AF_INET, SOCK_STREAM, 0);
        if (-1 == cfd)
            {
            printf("========ERROR========= socket fail ! \r\n");
            return -1;
            }

        bzero(&s_add, sizeof (struct sockaddr_in));

        s_add.sin_family = AF_INET;
        s_add.sin_addr.s_addr = inet_addr(ServerAddr_APP);
        s_add.sin_port = htons(ServerPort_APP);

        c = DoConect(cfd, (struct sockaddr *) &s_add, 5000);

        //    c=connect(cfd,(struct sockaddr *)(&s_add), sizeof(struct sockaddr));

        if (-1 == c)
            {
            printf("========ERROR=========Connect APP Fail !\r\n");
            return -1;
            }
        //            struct timeval timeout= {30,0}; //3s

        //int retA=setsockopt(cfd,SOL_SOCKET,SO_SNDTIMEO,&timeout,sizeof(timeout));
        //int retB=setsockopt(cfd,SOL_SOCKET,SO_RCVTIMEO,&timeout,sizeof(timeout));
        }

    c = send(cfd, buf, len, 0);

    if (c == len)
        {
        if (conn)
            *conn = cfd;
        else
            close(cfd);

        return c;
        }
    else
        {
        printf("========ERROR=========Send(%d)=%d\n", len, c);
        close(cfd);
        return -1;
        }
    }

int SendData_h_d(struct TMSG *msg, const void * data, int len, int * conn)
    {
    msg->DataSize = len;

    Msg_SetCheck(msg, (uint8_t *) data);

    int l1 = sizeof (TMSG);
    int l2 = len;
    char *buf = (char *) malloc(l1 + l2 + 1); //new char[l1+l2+1];
    memset(buf, 0, l1 + l2 + 1);
    memcpy(&buf[0], msg, l1);
    memcpy(&buf[l1], data, l2);
    l1 = SendData(buf, l1 + l2 + 1, conn);
    free(buf);


    if (l1 >= 0)
        return 0;
    else
        return -1;
    }

int SendData_ConnLost(const char * imei, const char * imsi, const char * tmsi)
    {
    TMSG msg = {0};
    fill_msg(&msg);
    msg.MsgType = mt_ConnLost;
    char buf[FB_MAXBUF_SIZE] = {0};

    snprintf(buf, FB_MAXBUF_SIZE, "Event=%d,IMEI=%s,IMSI=%s,TMSI=%s", mt_ConnLost, imei, imsi, tmsi);
#ifdef FB_Print_SendData
    FB_DEBUG_S("buf", buf);
#endif


#ifdef FB_UseGeneralSendList
    FB_SendData_General_List_push(msg, &buf[0], strlen(buf));
    return 0;
#endif

    return SendData_h_d(&msg, buf, strlen(buf), 0);
    }

int SendData_ConnRelease(const char * imei, const char * imsi, const char * tmsi)
    {
    TMSG msg = {0};
    fill_msg(&msg);
    msg.MsgType = mt_ConnRelease;
    char buf[FB_MAXBUF_SIZE] = {0};

    snprintf(buf, FB_MAXBUF_SIZE, "Event=%d,IMEI=%s,IMSI=%s,TMSI=%s", mt_ConnRelease, imei, imsi, tmsi);
#ifdef FB_Print_SendData
    FB_DEBUG_S("buf", buf);
#endif


#ifdef FB_UseGeneralSendList
    FB_SendData_General_List_push(msg, (void *) buf, strlen(buf));
    return 0;
#endif

    return SendData_h_d(&msg, buf, strlen(buf), 0);
    }

int SendData_RadioReady()
    {
    TMSG msg = {0};
    fill_msg(&msg);
    msg.MsgType = mt_RadioReady;
    return SendData_h_d(&msg, 0, 0, 0);
    }

int SendData_ConnRequest(const char *imei, const char * imsi, const char * tmsi)
    {
#ifdef FB_NoApp
    return 1;
#endif

    TMSG msg = {0};
    fill_msg(&msg);
    msg.MsgType = mt_ConnRequest;

    char buf[FB_MAXBUF_SIZE] = {0};
    snprintf(buf, FB_MAXBUF_SIZE, "Event=%d,IMEI=%s,IMSI=%s,TMSI=%s", mt_ConnRequest, imei, imsi, 0);
    //    printf("%s\n",buf);

#ifdef FB_Print_SendData
    FB_DEBUG_S("buf", buf);
#endif

    int conn = -1;
    int l = strlen(buf);
    int r = SendData_h_d(&msg, buf, l, &conn);

    if (r == -1)
        return -1;

    l = sizeof (msg);
    r = recv(conn, (void *) &msg, l, 0);
    close(conn);

    if ((r != l))
        {
        printf("========ERROR=========recv(%d)=%d\n", l, r);
        return -1;
        }
    close(conn);

    if (strcasecmp(msg.Flag, MsgFlag))
        {
        return -1;
        }

    if ((msg.MsgType == mt_Conn_Allow) or (msg.Res == 1))
        return 1;
    else
        return 0;

    }

int SendData_RecvSms(const TSmsInfo * sms)
    {

#ifdef FB_NoApp
    return 1;
#endif
    TMSG msg = {0};
    fill_msg(&msg);
    msg.MsgType = mt_RecvSms;
    char buf[FB_MAXBUF_SIZE * 2] = {0};
    char buf2[64] = {0};
    snprintf(buf, FB_MAXBUF_SIZE, "Event=%d,IMEI=%s,IMSI=%s,TMSI=%s,PDU=%s", mt_RecvSms, sms->imei, sms->imsi, sms->tmsi, sms->pdu);

    if (sms->tel)
        {
        strcat(buf, ",TEL=");
        strcat(buf, sms->tel);
        }
    if (sms->smsc)
        {
        strcat(buf, ",SMSC=");
        strcat(buf, sms->smsc);
        }
    //if (sms->encode)
    {
        sprintf(buf2, ",encode=%d", sms->encode);
        strcat(buf, buf2);
    }
    if ((sms->text) and (sms->textlen > 0))
        {
        //应该改成hex
        sprintf(buf2, ",TEXTLEN=%d", sms->textlen);
        strcat(buf, buf2);
        strcat(buf, ",TEXT=");
        strcat(buf, sms->text);
        }

#ifdef FB_Print_SendData
    FB_DEBUG_S("buf", buf);
#endif

#ifdef FB_UseGeneralSendList
    FB_SendData_General_List_push(msg, (void *) buf, strlen(buf));
    return 0;
#endif

    int conn = -1;
    int r = SendData_h_d(&msg, buf, strlen(buf), &conn);

    if (r == -1)
        return -1;

    int l = sizeof (msg);
    r = recv(conn, (void *) &msg, l, 0);
    close(conn);

    if ((r != l))
        {
        return -1;
        }
    close(conn);

    if (msg.Res == 1)
        return 1;
    else
        return 0;


    }

int SendData_progStart()
    {
    TMSG msg = {0};
    fill_msg(&msg);
    msg.MsgType = mt_progStart;
    return SendData_h_d(&msg, 0, 0, 0);
    }

int SendData_progEnd()
    {
    TMSG msg = {0};
    fill_msg(&msg);
    msg.MsgType = mt_ProgEnd;
    return SendData_h_d(&msg, 0, 0, 0);
    }

//mbts/Control/DCCHDispath.cpp   sendPhyInfo

int SendData_sig(const char *imei, const char * imsi, const char * tmsi, int ta, float TimeError, float UpRSSI, int DnRSSIdBm)
    {
    //<PhysicalInfo>TA=3 TE=0.105 UpRSSI=1 TxPwr=5 DnRSSIdBm=-111  time=1440032839.828</PhysicalInfo>

    TMSG msg = {0};
    fill_msg(&msg);
    msg.MsgType = mt_sig;

    char buf[FB_MAXBUF_SIZE] = {0};
    snprintf(buf, FB_MAXBUF_SIZE, "Event=%d,IMEI=%s,IMSI=%s,TMSI=%s,actualMSTiming=%d,TimingError=%0.000f,UpRSSI=%0.000f,%d=%d ", mt_sig, imei, imsi, tmsi,
             ta, TimeError, UpRSSI, DnRSSIdBm);

    return SendData_h_d(&msg, buf, strlen(buf), 0);

    }

int APP_SendData(void * buf, int len, int * conn)
    {
    int cfd;
    int c;
    struct sockaddr_in s_add;

    cfd = socket(AF_INET, SOCK_STREAM, 0);
    if (-1 == cfd)
        {
        printf("========ERROR========= socket fail ! \r\n");
        return -1;
        }

    bzero(&s_add, sizeof (struct sockaddr_in));
    s_add.sin_family = AF_INET;
    s_add.sin_addr.s_addr = inet_addr(ServerAddr_BTS);
    s_add.sin_port = htons(ServerPort_BTS);

    if (-1 == connect(cfd, (struct sockaddr *) (&s_add), sizeof (struct sockaddr)))
        {
        //printf("========ERROR=========Connect APP Fail !\r\n");
        return -1;
        }
    c = send(cfd, buf, len, 0);

    if (c == len)
        {
        if (conn)
            *conn = cfd;
        else
            close(cfd);

        return 0;
        }
    else
        {
        close(cfd);
        return -1;
        }


    }

int SendData_SendSms(char * buf, int len) //发给server		返回队列中有多少条短信未发送
    {
    int conn = 0;
    TMSG msg = {0};
    fill_msg(&msg);
    msg.MsgType = mt_SendSms;
    msg.DataSize = len;
    int r = APP_SendData(&msg, sizeof (msg), &conn);
    r = send(conn, buf, len, 0);
    if (r != len)
        return -1;

    len = sizeof (msg);
    r = recv(conn, (void *) &msg, len, 0);
    close(conn);
    return msg.Res;
    }

void FREE_SmsInfo(TSmsInfo * sms)
    {
    if (!sms)
        {
        return;
        }
    sms->fun = FunDef_NoUsed;
    if (sms->conn)
        free((void *) sms->conn);
    if (sms->imei)
        free((void *) sms->imei);
    if (sms->imsi)
        free((void *) sms->imsi);
    if (sms->pdu)
        free((void *) sms->pdu);
    if (sms->sms)
        free((void *) sms->sms);
    if (sms->smsc)
        free((void *) sms->smsc);
    if (sms->tel)
        free((void *) sms->tel);
    if (sms->text)
        free((void *) sms->text);
    if (sms->tmsi)
        free((void *) sms->tmsi);

    if (sms->smsKey)
        free((void *) sms->smsKey);

    if (sms->textHex)
        free((void *) sms->textHex);
    if (sms->textPDU)
        free((void *) sms->textPDU);

    if (sms->caller)
        free((void *) sms->caller);
    if (sms->called)
        free((void *) sms->called);

    if (sms->KickOut_RL3Message)
        free((void *) sms->KickOut_RL3Message);

    memset((void*) sms, 0, sizeof (TSmsInfo));
    }

int SendData_TickConn(char * buf, int len) //发给server
    {
    int conn = 0;
    TMSG msg = {0};
    fill_msg(&msg);
    msg.MsgType = mt_TickConn;
    msg.DataSize = len;
    int r = APP_SendData(&msg, sizeof (msg), &conn);
    r = send(conn, buf, len, 0);
    if (r != len)
        return -1;

    len = sizeof (msg);
    r = recv(conn, (void *) &msg, len, 0);
    close(conn);
    return msg.Res;
    }

int HexStr2Bin(const char * hex, unsigned char * bin)
    {
    int len = strlen(hex) / 2;
    char x[5] = {0};
    x[0] = '0';
    x[1] = 'x';
    x[4] = '\0';
    char *xx = 0;
    int t = 0;
    for (int i = 0; i < len; i++)
        {
        x[2] = hex[0];
        x[3] = hex[1];
        //		 printf("%s\n",x);
        //		 sscanf(&x[0],"%x",&t);
        t = strtol(x, &xx, 16);
        bin[i] = t;

        hex++;
        hex++;
        }
    return len;
    }

int tel2pdu(const char * tel, char * pdu)
    {
    int i = 0;
    int r = 0;
    int l = strlen(tel);
    const char *b1 = tel;
    char *b2 = pdu;
    if (l == 0)
        return 0;
    if (tel[0] == '+')
        {
        if (l == 1)
            return 0;
        b2[0] = '9';
        b2[1] = '1';
        b2++;
        b2++;
        b1++;
        l--;
        r = 2;
        }
    else
        {
        b2[0] = '8';
        b2[1] = '1';
        b2++;
        b2++;
        r = 2;
        }
    if (l == 0)
        return 0;
    while (l > 0)
        {
        if (l == 1)
            {
            b2[0] = 'f';
            b2[1] = b1[0];
            r = r + 2;
            break;
            }
        else
            {
            b2[0] = b1[1];
            b2[1] = b1[0];
            l = l - 2;
            b2++;
            b2++;
            b1++;
            b1++;
            r = r + 2;
            }
        }
    return r;
    }

int text2UCS2(const char * txt, int len, char * pdu)
    {
    //未考虑abcdef时 是badcfe 还是abcdef
    //未考虑汉字是ABCD 还是CDAB保存
    int i = len;
    int r = 0;
    int l = len;
    const char *b1 = txt;
    char *b2 = pdu;
    if (l == 0)
        return 0;
    while (l > 0)
        {
        while (l > 0)
            {
            if (l == 1)
                {
                b2[0] = '0';
                b2[1] = b1[0];
                r = r + 2;
                break;
                }
            else
                {
                b2[0] = b1[1];
                b2[1] = b1[0];
                l = l - 2;
                b2++;
                b2++;
                b1++;
                b1++;
                r = r + 2;
                }
            }

        }

    }

int FB_STRCMP_2(const char *a, const char *b, int Max)
    {
    if ((a == 0) || (b == 0))
        return -1;
    if (strlen(a) == 0)
        return -1;
    if (strlen(b) == 0)
        return -1;

    if (Max > 0)
        {
        int l1 = strlen(a);
        int l2 = strlen(a);
        l1 = MIN(l1, l2);
        l1 = MIN(l1, Max);
        return strncmp(a, b, l1);
        }
    else
        {
        return strcmp(a, b);
        }
    }

const char * FreeOld_mallocNew(const char * oldstr, const char * newstr, int OnlyNewStrOK)
    {
    if (OnlyNewStrOK)
        {
        if (!newstr)
            return oldstr;
        if (strlen(newstr) == 0)
            return oldstr;
        }
    char *R = 0;
    int b = 0;
    if (newstr)
        {
        if (strlen(newstr) > 0)
            {
            if (oldstr)
                free((void*) oldstr);
            int l = strlen(newstr) + 1;
            R = (char *) malloc(l);
            strcpy(R, newstr);
            b = 1;
            }
        }
    if (b)
        return R;
    else
        return oldstr;
    }

int SendData_Event(TMsgType Msg, const char *imei, const char * imsi, const char * tmsi) //问app 是否同意，如果是,返回 1，0不同意  -1错误
    {
    TMSG msg = {0};
    fill_msg(&msg);
    msg.MsgType = Msg;
    char buf[FB_MAXBUF_SIZE] = {0};

    snprintf(buf, FB_MAXBUF_SIZE, "Event=%d,IMEI=%s,IMSI=%s,TMSI=%s", msg.MsgType, imei, imsi, tmsi);
#ifdef FB_Print_SendData
    FB_DEBUG_S("buf", buf);
#endif


#ifdef FB_UseGeneralSendList
    FB_SendData_General_List_push(msg, (void *) buf, strlen(buf));
    return 0;
#endif

    return SendData_h_d(&msg, buf, strlen(buf), 0);

    }

int SendData_Log(int level, const char *log)
    {
    return 0;


    TMSG msg = {0};
    fill_msg(&msg);
    msg.MsgType = mt_log;
    msg.data = level;

#ifdef FB_UseGeneralSendList
    FB_SendData_General_List_push(msg, (void *) log, strlen(log));
    return 0;
#endif

    char buf[FB_MAXBUF_SIZE] = {0};

    snprintf(buf, FB_MAXBUF_SIZE, "%s", log);

    int r = 0;

    r = SendData_h_d(&msg, &buf[0], strlen(buf), 0);

    //    r=SendData_h_d(&msg,log,strlen(log),0);

    return r;

    }



#endif /* FB_FUN_UNIT_C_ */
