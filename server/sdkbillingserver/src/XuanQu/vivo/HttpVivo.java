package XuanQu.vivo;

import java.net.InetSocketAddress;
import org.apache.mina.filter.codec.ProtocolCodecFilter;
import org.apache.mina.filter.logging.LoggingFilter;
import org.apache.mina.transport.socket.nio.NioSocketAcceptor;

import XuanQu.httpserver.HttpServerProtocolCodecFactory;

public class HttpVivo {
   /** Default HTTP port */
   private static final int DEFAULT_PORT = 8079;

   /** Tile server revision number */
   public static final String VERSION_STRING = "$Revision: 600461 $ $Date: 2007-12-03 18:55:52 +0900 (?, 03 12? 2007) $";
   
   public void RunHttp() {
       int port = DEFAULT_PORT;
       try {
           // Create an acceptor
           NioSocketAcceptor acceptor = new NioSocketAcceptor();

           // Create a service configuration
           acceptor.getFilterChain().addLast(
                   "protocolFilter",
                   new ProtocolCodecFilter(
                           new HttpServerProtocolCodecFactory()));
           acceptor.getFilterChain().addLast("logger", new LoggingFilter());
           acceptor.setHandler(new HttpVivoHandler());
           acceptor.bind(new InetSocketAddress(port));

           System.out.println("Server now listening Vivo on port " + port);
       } catch (Exception ex) {
           ex.printStackTrace();
       }
   }
}