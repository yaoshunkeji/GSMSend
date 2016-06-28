/*
 * FB_fun_unit.h
 *
 *  Created on: 2015年8月20日
 *      Author: vlan1
 */


 /*
  修改位置
  修改代码后，添加

//FB添加修正
  //FB添加

  //FB添加完成

<1>
yate/engine/TelEngine.cpp

static void common_output(int level,char* buf) 中添加
	//printf("================================%s\n",buf);
//FB添加
	if ( SendData_Log(level,buf) ==0)
	{
		return;
	}
//FB添加完成


<2>
ybts.cpp 4345   电话挂断
        void YBTSSignalling::dropConn(uint16_t connId, bool notifyPeer)

void YBTSSignalling::processLoop()


teengine.cpp  OUTPUT  日志
或 void YBTSLog::processLoop()


void YBTSLocationUpd::run()
     这里调用js代码进行注册，  直接K掉             代码上（或者说老代） 有点浪费，看看有没有更前面的，更早的T掉
{
printf("===================6020====IMEI===%s\n",m_ue->imei().c_str());
	notify(false, false);
	return;


decodeRP			大概 2947行附近，  *b  是编码类型   00 7bit  4 8bit     8 UCS2

if (!len)
	return 0;
// Data Coding scheme, handle only GSM 7bit
if (*b)		//编码类型
	return 0;



1.申请验证  ,拒绝，或同意  OK!
2.T人，  待试
3.接收，应该 OK      ,但编码要处理。。。。
        void YBTSDriver::handleSmsCPData

4.发消息

    void YBTSSubmit::notify(bool final)


5.信号情况
	mbts/Control/DCCHDispatch.cpp
				static void sendPhyInfo(LogicalChannel* chan, unsigned int id)



    1.打开调试模式，允许调整分配号码
    2.允许修改分配号码方式   +86123xxxxx  （自动分配）
    3.手工入网时，允许手工设置入网号码  允许入网，或是保存imei时，可设置号码
            2+3 用于防止短信猫有号码检测功能
    4.允许设置一些号码的回复短信，比如发来10086 ，内容是11,  回复xxx        10001内容xx，回复xxxxxx
    5.允许几个号码之间，电话功能, 测试网络用
    6.允许修改系统时间，短信猫，可能用于检测时间     (GSM流量中，是有时间截的)
    7.修改短信中心地址
    8.编码可修改,或提示,以防止有些短信猫代码不完整，只支持部分编码



TelEngin.cpp->
		static void common_output(int level,char* buf)

修改日志
#include "/opt/new/FB_fun_unit.cpp"

*/


#ifndef FB_FUN_UNIT_H_
#define FB_FUN_UNIT_H_


#include <stdio.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <pthread.h>				//makefile   YATELIBS:= -lyate -lpthread
//#include <stdint.h>






//#define FB_Print_SendData
#define FB_STOPPrintMSG
//#define FB_UseGeneralSendList

#ifdef FB_STOPPrintMSG

    #define FB_DEBUG      		 					 NULL_Code()
    #define FB_DEBUG_S(a,b)  					 NULL_Code(a,b)
    #define FB_DEBUG_I(a,b)   					 NULL_Code(a,b)
    #define FB_DEBUG_ERROR					 NULL_Code()

#else

    #define FB_DEBUG      		 printf("===========FB====%s:%d,fun=%s\n",__FILE__,__LINE__,__FUNCTION__)
    #define FB_DEBUG_S(a,b)  printf("===========FB====%s:%d,fun=%s, %s=%s \n",__FILE__,__LINE__,__FUNCTION__,a,(char *)b)
    #define FB_DEBUG_I(a,b)   printf("===========FB====%s:%d,fun=%s, %s=%d \n",__FILE__,__LINE__,__FUNCTION__,a,b)
    #define FB_DEBUG_ERROR					 printf("===========FB====%s:%d,fun=%s,ERROR:%s\n",__FILE__,__LINE__,__FUNCTION__,strerror(errno))

#endif






#define AppConntErr_AllowNoLogin			//如果定义了。app连接失败，不允许入网

#define FB_GSM_UCS2	0x80000
#define FB_GSM_8BIT	0x40000

#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))


#define FB_printbuf(a,b,c)  \
		{	\
	String tmp_FB_STR;	\
	tmp_FB_STR.hexify((void * )a,b);	\
	printf("=========%s: %d ,FUN: %s===Name:%s ,Len:%d Value= %s\n", __FILE__,__LINE__,__FUNCTION__, c,b,tmp_FB_STR.c_str());	\
	}	\

/*

//class YBTSGprsAttach; 放在下面

void ShowMsgInfo(int CodeLine,	Message& msg)
{
	int i=0;
	int l=msg.count();
	const char * s;
	const char * s2;
	for (;i<l;i++)
	{
		s=msg.getParam(i)->name().c_str();
		s2=msg.getParam(i)->c_str();
		printf("=========Line=%d==msg(%d)  , %s  :   %s\n",CodeLine	,	i,	s,	s2);
	}
}

*/

#define ServerPort_BTS		8000
///#define ServerPort_APP		8008
#define ServerPort_APP		8008

#define ServerAddr_APP		"127.0.0.1"
#define ServerAddr_BTS  		"127.0.0.1"




pthread_t  CheckAppMsg_SMS_id=-1;
pthread_t  CheckAppMsg_Call_id=-1;
pthread_t  CheckAppMsg_ForceUplink_id=-1;
pthread_t  CheckAppMsg_ForceUplink_Loop_id=-1;
pthread_t  CheckAppMsg_OtherTask_Loop_id=-1;




enum TMsgType {
  mt_none                =  0,
  mt_log				        =	1,
  mt_ConnRequest=	2,
  mt_TickConn		    =	3,      //BTS端接收
  mt_SendSms			=	4,      	//BTS端接收			//客户端收到，表示发送成功
  mt_Register			=	5,
  mt_UnRegister		=	6,

  mt_RecvSms		    =	7,
  mt_ConnLost		=	8,
  mt_ConnRelease	=	9,
  mt_RadioReady	=	10,
  mt_ProgEnd		    =	11,
  mt_progStart        =	12,
  mt_sig                      =	13,
  mt_Conn_Allow 	 =	14,		//允许时，反回		//res=1同样是允许
  mt_Conn_deny     =	15,		//拒绝时，反回

  mt_SetConfig    = 16,
  mt_GetConfig    = 17,

  mt_GetConnList  = 18,

  mt_MeasurementReport    = 20,
  mt_SendSms_ClearList    = 21,
  mt_SendSms_GetListCount = 22,
  mt_SendSms_GetList      = 23,

  mt_SendCall            		 = 24,   //拨号
  mt_RecvCall             		= 25,
  mt_ForceUplink			=26,
  mt_ForceUplink_Stop     = 27,
  mt_NewLocation            =28,
  mt_askIMEI                     =29
};

#define MsgFlag	"FLAG"

#define MSG_SETCHECK

#define MSG_CRCKEY 	"MSGKEY"			//CRC16时，加这个，防别人折腾


typedef struct TMSG
{
  char 	Flag[8];		//标记        但只用最后7位，避免处理时麻烦
  int32_t  	MsgType;			//数据类型
  int32_t   	DataSize;			//数据大小，不包括包头头头
  uint16_t	CRC16;				//crc16		防别人折腾
  int8_t	xor1;					//xor值， 防折腾
  int8_t	data;					//占位
  int32_t   	Res;                    //结果值，或是其它

  //data;
}tagMsg  ;

typedef struct TSMS
{
    char tmei[32];
    char tmsi[32];
    char imsi[32];
    char msisdn[32];
    char pdu[2048];
    char sms[2048];
}tagSMS;


typedef struct TConectInfo
{
  int			sockfd;
  int			Connfd;
  socklen_t		CliLen;
  struct sockaddr 	CliAddr;
}tagConectInfo;


typedef struct TSmsInfo
{
	int fun;			//用途		0	没用,1 短信，2 T人	,3 电话
	const char * smsKey;				//唯一性，  用于回复时，告诉，是哪条发送成功
	const char * imei;
	const char * imsi;
	const char * smsc;		//中心号码
	int 		 smscTimeOffset;		//	时差

	const char * tmsi;
	const char * sms;
	const char * tel;
	const char * pdu;		//pdu
	int encode;			//0	4	8
	const char * text;		//文字  unicode/ascii!!		如果
	int	textlen;
	const char * textHex;		//
	const char * textPDU;		//文字  unicode/ascii!!		如果有，就用这个，没有用用text来转
	int MaxPPD;				//多少ms后，还没发成功，算失败,=0默认>0线程等，  <0  是等abs(x)后再返回


	const char * caller;
	const char * called;
	int UpLinkMode;
	int SmsSentOK_KickOut;      //发完短信，是否T掉
                  const char * KickOut_RL3Message;          //踢时，发什么消息

                  int NewLocationMethod;
                  int NewMCC;
                  int NewMNC;
                  int NewLAC;
                  int NewCID;
                  
                  int askIMEI;          //-1表示 不使用

	int connid;
	const char * conn;

}tagSmsInfo;

#define FunDef_NoUsed		0
#define FunDef_SendSms		1
#define FunDef_TickConn		2
#define FunDef_BTS_Call		3
#define FunDef_ForceUplink                        4

#define FunDef_OtherTask_Start                 1000

#define FunDef_NewLocation                      1000
#define FunDef_askIMEI                               1001

#define FunDef_OtherTask_End                   1001


        
#define FunDef_NewLocationMethod_LoopLac            0
#define FunDef_NewLocationMethod_RandomLac      1



//发送 =表示成功(无返回值时)	1表示返回值
//-1表示 失败

void NULL_Code(...);			//为了ifdef

int StartServer();			//启动服务器，接受命令
int StopServer();

//int SendData(void * buf,int len);
int SendData(void * buf,int len,int *conn);		//实际发送数据的,  如果conn<>0  内部不关闭conn，返回，供程序继续收发数据

//int SendData_log(int status,const char * str);		//发送日志,
int SendData_ConnLost(const char * imei,const char * imsi,const char * tmsi);		//连接丢失
int SendData_ConnRelease(const char * imei, const char * imsi, const char * tmsi);

int SendData_ConnRequest(const char *imei,const char * imsi,const char * tmsi);       //问app 是否同意，如果是,返回 1，0不同意  -1错误

int SendData_sig(const char *imei,const char * imsi,const char * tmsi ,int ta,float TimeError,float UpRSSI,int DnRSSIdBm) ;     //发送信号质量
int SendData_progEnd();
int SendData_progStart();
int SendData_RecvSms(const TSmsInfo * sms);			//终端往外发的消息		text放在最后,防止0x00,		数据，如果有问题，考虑用hex发送
int SendData_RadioReady();

int SendData_SendSms(char * buf,int len);			//发给server		返回队列中有多少条短信未发送              only test


int SendData_Event(TMsgType Msg,const char *imei,const char * imsi,const char * tmsi);       //问app 是否同意，如果是,返回 1，0不同意  -1错误

int SendData_h_d(struct TMSG *msg,const void * data,int len,int * conn);		//-1  失败 >=0成功

TSmsInfo  FB_popTick();
TSmsInfo  FB_popMsg();

TSmsInfo  FB_MsgList_pop(int Fun);

TSmsInfo FB_GetMsg(char *buf,int len);
int FB_MsgList_push(TSmsInfo * sms);			//从APP收到发送请求，暂时放在列表中


typedef  struct TItem
{
    char * key;
    char * text;
}tagItem;

int GetDataIdx(TItem * item,int arraysize,char * key) ;
int AnalysisStr(char * str,int strlen,TItem * Item,int arraysize) ;         //IMEI:xxx,IMSI:xxx, 分离

int FB_GetMsg(char *buf,int len, TSmsInfo *msg);
void FREE_SmsInfo( TSmsInfo * sms);     //翻译子项目，不包括sms

int FB_STRCMP(const char *a,const char *b,int Max);				//imei,tmsi等条件判断， 如果有一个空或strlen=0，返回0,  如果有数据，才会，返回strcmp值
int FB_STRCMP_2(const char *a,const char *b,int Max);					//imei等比较，需要多个条件中一个对上时....当有一个是0时，没对上,继续下一个用

int HexStr2Bin(const char * hex,unsigned char * bin);				//pdu转成bin

int tel2pdu (const char * tel,char * pdu);                //+86123456  转成81/91xxxxfx,返回转换后的长度
int text2UCS2 (const char * txt,int len,char * pdu);



void FB_SendSmsOK(TSmsInfo *sms,int ok, char * Reason);    //告诉客户端，发送成功
void FB_SendSms_Status(const char * SrcTel,const char * DestTmsi,const char * SMSkey,int ok, const char * Reason);    //告诉客户端，发送结果

const char * FreeOld_mallocNew(const char * oldstr,const char * newstr,int OnlyNewStrOK);		//释放掉原来的数据，分配新数据

int Msg_CheckRestore(TMSG * msg, uint8_t * buf);
void Msg_SetCheck(TMSG * msg,uint8_t * buf);

int SendData_Log(int level,const char *log) ;			//返回0表示成功发送

#endif /* FB_FUN_UNIT_H_ */
