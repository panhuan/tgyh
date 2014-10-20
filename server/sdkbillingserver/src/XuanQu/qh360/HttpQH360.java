package XuanQu.qh360;

import java.net.InetSocketAddress;

import org.apache.mina.filter.codec.ProtocolCodecFilter;
import org.apache.mina.filter.logging.LoggingFilter;
import org.apache.mina.transport.socket.nio.NioSocketAcceptor;

import XuanQu.httpserver.HttpServerProtocolCodecFactory;


public class HttpQH360 {
   /** Default HTTP port */
   private static final int DEFAULT_PORT = 8240;

   /** Tile server revision number */
   public static final String VERSION_STRING = "$Revision: 600461 $ $Date: 2007-12-03 18:55:52 +0900 (?, 03 12? 2007) $";
   
   public void RunHttp() {
       int port = DEFAULT_PORT;
       try {
    	   // 创建一个非阻塞的Server端Socket
           NioSocketAcceptor acceptor = new NioSocketAcceptor();

           // 接收数据的过滤器,设定一行一行(/r/n)的读取数据
           acceptor.getFilterChain().addLast(
                   "protocolFilter",
                   new ProtocolCodecFilter(
                           new HttpServerProtocolCodecFactory()));
           
           acceptor.getFilterChain().addLast("logger", new LoggingFilter());
           
           // 设定服务器端的消息处理器
           acceptor.setHandler(new HttpQH360Handler());
           
           // 绑定端口,启动服务器
           acceptor.bind(new InetSocketAddress(port));

           System.out.println("Server now listening 360 on port " + port);
       } catch (Exception ex) {
           ex.printStackTrace();
       }
   }
}