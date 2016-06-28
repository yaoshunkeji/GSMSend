#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>

#include <linux/limits.h>
#include <pty.h>
#include <utmp.h>
#include <pthread.h>


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



#define BUFF_LEN 1024*16
#define MaxOutStrLen 4096
char recvstr[BUFF_LEN]= {0};
char *recvp=0;
char *recv_p1=0;
char *recv_p2=0;


int PrintOut=0;

char CMD[4096]= {0};
char HEADFLAG[128]= {0};
char Dest[128]= {"127.0.0.1:7788"};
char DestIP[128]= {"127.0.0.1"};
int DestPort=7788;
int PrintSendErr=0;
int NoSend=0;

#define _MsgList_Max_ 1*1024
//#define _MsgList_Max_ 8*1
char* msgList[_MsgList_Max_]= {0};
int msgListCount=0;
pthread_mutex_t MsgListLock= {0};
pthread_t MsgList_SendThread_ID= {0};


int SendData(const void * buf,int len,int *conn );

int SendTimeOut=5000;
int ConnTimeOut=5000;
int TryCount=5;
int TryInterval=50000;

pthread_t pty_Thread_ID= {0};


int GetMsgListCount()
{
  int R=0;
  pthread_mutex_lock( &MsgListLock );
  R=msgListCount;
  pthread_mutex_unlock( &MsgListLock );
  return R;
}

const char * PopMsg()
{
  int i=0;
  int L=0;
  const char * R=0;
  pthread_mutex_lock( &MsgListLock );
  if( msgListCount>0 )
    {
      R=msgList[0];
      L=msgListCount-1;
      L=L*sizeof( char * );
      memmove( &msgList[0],&msgList[1],L );
      msgListCount--;
      msgList[msgListCount]=0;
//           printf("free_1(%p)\n",R);
    }
  pthread_mutex_unlock( &MsgListLock );
  return R;

}

void * SendThread( void * )
{
  const char * str=0;
  char buff[8192]={0};
  int conn=-1;
  int i=0;
  int blHead=0;

  if (strlen(HEADFLAG)>0)
  blHead=1;

  while( true )
    {
      pthread_testcancel();
      str=PopMsg();
      if( str==0 )
        {
          usleep( 10000 );
          continue;
        }
      if (blHead)
      snprintf(buff,8192,"%s,%s\n",HEADFLAG,str);
      else
      snprintf(buff,8192,"%s\n",str);

//      printf("free(%p)\n",str);
      free((void *)str);

      for( i=0; i<TryCount; i++ )
        {
          if( SendData( ( void * )buff,strlen( buff ),&conn ) ==-1 )
            {
              if( conn !=-1 )
                {
                  close( conn );
                }
                  conn=-1;
              usleep( TryInterval );
//              sleep(1);
            }
          else
            {
              break;
            }
        }
    }
}


void PushMsg(const char * str )
{
  int i=0;
  int L=0;
  pthread_mutex_lock( &MsgListLock );
  if( msgListCount>=_MsgList_Max_ )
    {
      for( i=0; i<10; i++ )
        {
          free( msgList[i] );
      printf("free_(%p)\n",msgList[i]);
        }
      L=msgListCount-10;
      L=L*sizeof( char * );
      memcpy( &msgList[0],&msgList[10],L );
      msgListCount=msgListCount-10;
    }

  L=strlen( str )+1;
  msgList[msgListCount]=( char * )malloc( L );
//  printf("%d=%p\n",msgListCount,msgList[msgListCount]);
  memset( msgList[msgListCount],0,L );
  strcpy( msgList[msgListCount],str );

  msgListCount++;
  pthread_mutex_unlock( &MsgListLock );

}


int rdline_file( char * str,FILE *fp )
{
  int c=0;
  unsigned char cc;
  char *s;
  s=fgets( str,BUFF_LEN,fp );
  c=strlen( str );
  if( c>0 )
    {
//    if (str[c-1]=='\n')
//    str[c-1]='\0';
    }
  return c;
}



int DoConect( int sockfd,struct sockaddr * address,int timeout_ms )
{
  int r=-1;
  fd_set fdset;
  struct timeval tv;
  int flags = fcntl( sockfd, F_GETFL, 0 );
  int blBLOCK=( flags and O_NONBLOCK );

  if( blBLOCK )
    fcntl( sockfd, F_SETFL, O_NONBLOCK );


  FD_ZERO( &fdset );
  FD_SET( sockfd, &fdset );
  tv.tv_sec = timeout_ms / 1000;             /* 10 second timeout */
  tv.tv_usec = timeout_ms % 1000;

  connect( sockfd, address, sizeof( *address ) );

  if( select( sockfd + 1, NULL, &fdset, NULL, &tv ) == 1 )
    {
      int so_error=1;
      socklen_t len = sizeof( so_error );

      getsockopt( sockfd, SOL_SOCKET, SO_ERROR, &so_error, &len );

      if( so_error == 0 )
        {
          r=0;    //printf("%s:%d is open\n", addr, port);
        }
    }
  if( blBLOCK )
    fcntl( sockfd,F_SETFL,flags&~O_NONBLOCK );


  tv.tv_sec = SendTimeOut / 1000;             /* 10 second timeout */
  tv.tv_usec = SendTimeOut % 1000;


  if( setsockopt( sockfd, SOL_SOCKET, SO_RCVTIMEO, ( void * )&tv,sizeof( tv ) ) < 0 )
    {
      if( PrintSendErr )
        printf( "setsockopt failed\n" );
    }

  if( setsockopt( sockfd, SOL_SOCKET, SO_SNDTIMEO, ( void * )&tv,sizeof( tv ) ) < 0 )
    {
      if( PrintSendErr )
        printf( "setsockopt failed\n" );
    }

  return r;

}


int proc_recvLine( char * str )
{
  if (NoSend==0)
  {
    PushMsg( str );
  }
  return 0;


}

int SendData(const void * buf,int len,int *conn )
{
  int cfd=-1;
  int c;
  struct sockaddr_in s_add;

  if( conn )
    {
      cfd=*conn;
    }

  if( cfd<0 )
    {
      cfd = socket( AF_INET, SOCK_STREAM, 0 );
      if( -1 == cfd )
        {
          if( PrintSendErr )
            printf( "========ERROR========= socket fail ! \r\n" );
          return -1;
        }

      bzero( &s_add,sizeof( struct sockaddr_in ) );

      s_add.sin_family=AF_INET;
      s_add.sin_addr.s_addr= inet_addr( DestIP );
      s_add.sin_port=htons( DestPort );

      c=DoConect( cfd,( struct sockaddr * )&s_add,ConnTimeOut );
//  sleep(1000);
//    c=connect(cfd,(struct sockaddr *)(&s_add), sizeof(struct sockaddr));

      if( -1 == c )
        {
          if( PrintSendErr )
            printf( "========ERROR=========Connect APP Fail !\r\n" );
          return -1;
        }
//            struct timeval timeout= {30,0}; //3s

      //int retA=setsockopt(cfd,SOL_SOCKET,SO_SNDTIMEO,&timeout,sizeof(timeout));
      //int retB=setsockopt(cfd,SOL_SOCKET,SO_RCVTIMEO,&timeout,sizeof(timeout));
    }

  c=send( cfd,buf,len,0 );

  if( c==len )
    {
      if( conn )
        *conn=cfd;
      else
        close( cfd );

      return c;
    }
  else
    {
      if( PrintSendErr )
        printf( "========ERROR=========Send(%d)=%d\n",len,c );
      close( cfd );
      return -1;
    }
}

int rdline( char * buff,int bufflen,int file )
{
  int c=0;
  unsigned char cc;
  memset( buff,0,bufflen );
  char *s;
  int z;


  while( c<bufflen )
    {
      z=read( file,&cc,1 );
      if( z<=0 )
        break;

      if( c==-1 )
        c=0;

//      printf( "%c",cc );
//      if( cc==0xBF )
//        {
     //     sleep( 1 );
//        }

      if( cc=='\n' )
        break;
//    if (cc=='\r')
//        break;
      if( cc==255 )
        break;

      buff[c]=cc;
      c++;
    }

  if( bufflen>=c )
    buff[c]='\0';
  if( c>0 )
    {
      if( buff[c-1]=='\r' )
        {
          buff[c-1]='\0';
//      c--;
        }
      if( buff[c-1]=='\n' )
        {
          buff[c-1]='\0';
//      c--;
        }
    }
    if (PrintOut && (c !=-1))
    printf("%s\n",buff);
  return c;
}

void dopty_read( int pty )
{
  char str[MaxOutStrLen]= {0};
  int ret=0;
  fd_set reads;

  struct stat tStat= {0};
  while( 1 )
    {
      FD_ZERO( &reads );
      FD_SET( pty, &reads );

      ret = select( pty+1, &reads, NULL, NULL, NULL );

      if( ret == -1 )
        {
          //perror( "select11" );
//          exit(0);
          break;
        }

      ret = rdline( str, MaxOutStrLen-1,pty );
      if( strcmp( str,"select: Bad file descriptor" )==0 )
        break;
      if( ( ret <= 0 ) || ( ret==4096 ) )
        {

//          exit(0);
          break;
        }
      proc_recvLine( str );

    }
  return;
}

void * pty_Thread_Proc( void * p )
{
  dopty_read( ( int )p );
}

int Start_SendThread()
{
  pthread_mutex_init( &MsgListLock,0 );
  msgListCount=0;
  pthread_create( &MsgList_SendThread_ID,0,SendThread,0 );

}

void getdata_exec( char * cmd )
{
  Start_SendThread();


  int pty, slave;
  char pty_name[4096]= {0};
  int ret;
  pid_t child;
  int stat=0;
  int c=0;

  ret = openpty( &pty, &slave, pty_name, NULL, NULL );
  if( ret == -1 )
    {
      perror( "openpty" );
      exit( EXIT_FAILURE );
    }
//  pthread_create(&pty_Thread_ID, 0, pty_Thread_Proc, (void *)pty);



  child = fork();
  if( child == -1 )
    {
      perror( "fork" );
      exit( EXIT_FAILURE );
    }
  else
    if( child == 0 )
      {
        close( pty );

        login_tty( slave );
        //execl("/bin/ls","ls","-l","/");
        system( cmd );
//      exit(0) ;
      }
  close( slave );
  if( child != 0 )
    {
      dopty_read( pty );

    c=0;
    while( GetMsgListCount() )
    {
//    printf("aa=%d\n",GetMsgListCount());
      usleep( 10000 );
      c=c+10000;
      if( c>=10000000 )
        break;

    }


//   sleep(10);
    }

  //printf( "pty name: %s\n", pty_name );
  if( child !=0 )
    exit( EXIT_SUCCESS );




}

  const char * GetCompiledDate_yyyymmdd()
  {
      static char _buf[11] = {0};
      if(_buf[0] == 0)
      {
          static const char * _month[] =
          {
              "Jan",
              "Feb",
              "Mar",
              "Apr",
              "May",
              "Jun",
              "Jul",
              "Aug",
              "Sep",
              "Oct",
              "Nov",
              "Dec",
          };
          const char * _date = __DATE__;
          strncat(_buf,_date+7,4);
          _buf[4]='-';

          int month = 0;
          for(int i = 0; i < 12; i++)
          {
              if(strncasecmp(_month[i], _date, 3) == 0)
              {
                  month = i+1;
                  break;
              }
          }
          _buf[5] = month / 10 % 10 + '0';
          _buf[6] = month % 10 + '0';
          //day
          _buf[7]='-';
          strncat(_buf,_date+4,2);
          if (_buf[8]==' ')
          _buf[8]='0';
      }
      return _buf;
  }

void getdata_file( FILE *fp )
{
  int l;
  char str1[1024]= {0};


  while( ! feof( fp ) )
    {
      memset( recvstr,0,BUFF_LEN );
      l=rdline_file( str1,fp );
      if( l<=0 )
        break;

      if( strlen( str1 )==0 )
        {
          continue;
        }
      proc_recvLine( str1 );
    }
}


void printhelp()
{

  printf( " Exec Redirect Ver 1.0\n" );
  printf( "   TimeUnit ：ms \n" );
  printf( "   /HELP  Show Help\n" );
  printf( "   /EXEC \"CMD Param\" /Dest IP:Port [/HeadFlag Str] [/PrintSendErr] [/PrintOut] [/SendTimeOut 5000] [/ConnTimeOut 5000] [/TryCount 5] [/NoSend] [/TryInterval 10]\n" );
  printf( "\n" );

}




int main( int argc,char **argv )
{
  if( argc ==1 )
    {
      printhelp();
      return 0;
    }
  int i=0;
  int l=0;
  char *c;
  for( i=1; i<argc; i++ )
    {

      if( strcasecmp( argv[i],"/help" )==0 )
        {
          printhelp();
          return 0;
        }
      if( strcasecmp( argv[i],"/?" )==0 )
        {
          printhelp();
          return 0;
        }

      if( ( strcasecmp( argv[i],"/exec" )==0 ) || ( strcasecmp( argv[i],"-exec" )==0 ) )
        {
          i++;
          if( i>=argc )
            {
              printhelp();
              return 255;
            }
          l=strlen( argv[i] );
          if( l>=sizeof( CMD ) )
            {
              printf( "sizeof(cmd)=%d,cmd too Long,strlen(cmd)<=%d\n",l,sizeof( CMD )-1 );
              return 255;
            }
          strcpy( CMD,argv[i] );
          continue;

        }
      if( ( strcasecmp( argv[i],"/HEADFLAG" )==0 ) || ( strcasecmp( argv[i],"-HEADFLAG" )==0 ) )
        {
          i++;
          if( i>=argc )
            {
              printhelp();
              return 255;
            }
          l=strlen( argv[i] );
          if( l>=sizeof( HEADFLAG ) )
            {
              printf( "sizeof(headflag)=%d,headflag too Long,strlen(HEADFLAG)<=%d\n",l,sizeof( HEADFLAG )-1 );;
              return 255;
            }
          strcpy( HEADFLAG,argv[i] );
          continue;

        }

      if( ( strcasecmp( argv[i],"/Dest" )==0 ) || ( strcasecmp( argv[i],"-Dest" )==0 ) )
        {
          i++;
          if( i>=argc )
            {
              printhelp();
              return 255;
            }
          l=strlen( argv[i] );
          if( l>=sizeof( Dest ) )
            {
              printf( "sizeof(dest)=%d,cmd too Long,strlen(Dest)<=%d\n",l,sizeof( Dest )-1 );
              return 255;
            }
          strcpy( Dest,argv[i] );
          memset(&DestIP[0],0,sizeof(DestIP));
          strcpy( DestIP,argv[i] );
          c=strstr( DestIP,":" );
          {
            if( c )
              {
                c[0]=0;
                c++;
                DestPort=atol( c );

                if( ( DestPort<=0 ) || ( DestPort>=65534 ) )
                  {
                    printf( "port=%d,error, port is 1..65534\n",DestPort );
                    return -1;
                  }
              }
          }

          continue;

        }
      if( ( strcasecmp( argv[i],"/PrintSendErr" )==0 ) || ( strcasecmp( argv[i],"-PrintSendErr" )==0 ) )
        {
          PrintSendErr=1;
          continue;
        }

      if( ( strcasecmp( argv[i],"/NoSend" )==0 ) || ( strcasecmp( argv[i],"-NoSend" )==0 ) )
        {
          NoSend=1;
          continue;
        }

      if( ( strcasecmp( argv[i],"/PrintOut" )==0 ) || ( strcasecmp( argv[i],"-PrintOut" )==0 ) )
        {
          PrintOut=1;
          continue;

        }

      if( ( strcasecmp( argv[i],"/SendTimeOut" )==0 ) || ( strcasecmp( argv[i],"-SendTimeOut" )==0 ) )
        {
          i++;
          if( i>=argc )
            {
              printhelp();
              return 255;
            }
          l=strlen( argv[i] );
          SendTimeOut=l;
          continue;

        }

      if( ( strcasecmp( argv[i],"/ConnTimeOut" )==0 ) || ( strcasecmp( argv[i],"-ConnTimeOut" )==0 ) )
        {
          i++;
          if( i>=argc )
            {
              printhelp();
              return 255;
            }
          l=strlen( argv[i] );
          ConnTimeOut=l;
          continue;

        }
      if( ( strcasecmp( argv[i],"/TryCount" )==0 ) || ( strcasecmp( argv[i],"-TryCount" )==0 ) )
        {
          i++;
          if( i>=argc )
            {
              printhelp();
              return 255;
            }
          l=strlen( argv[i] );
          TryCount=l;
          continue;

        }

      if( ( strcasecmp( argv[i],"/TryInterval" )==0 ) || ( strcasecmp( argv[i],"-TryInterval" )==0 ) )
        {
          i++;
          if( i>=argc )
            {
              printhelp();
              return 255;
            }
          l=strlen( argv[i] );
          if (TryInterval>60000)
            TryInterval=60000;
          if (TryInterval<1)
            TryInterval=1;

          TryInterval=l*1000;

          continue;

        }
    }

  int e=0;
  if( strlen( CMD )==0 )
    {
      printf( "CMD err\n" );
      e++;
    }
  if( strlen( Dest )==0 )
    {
      printf( "dest err\n" );
      e++;
    }

  if( strlen( DestIP )==0 )
    {
      printf( "destIP err\n" );
      e++;
    }


  if( ( DestPort<=0 ) || ( DestPort>=65534 ) )
    {
      printf( "destPort err\n" );
      e++;
    }

  if( e )
    {
      printhelp();
      return 255;
    }

  getdata_exec( CMD );


}
