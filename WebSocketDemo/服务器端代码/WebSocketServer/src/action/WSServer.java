package action;

import java.io.IOException;


import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

//ws://127.0.0.1:8087/Demo1/ws/张三
//ws://127.0.0.1:8080/WebSocketServer/ws/张三
@ServerEndpoint("/ws")
public class WSServer {

	// 静态变量，用来记录当前在线连接数。应该把它设计成线程安全的。
	private static int onlineCount = 0;

	// 与某个客户端的连接会话，需要通过它来给客户端发送数据
	private Session session;
	private String userId;

	public String getUserId() {
		return userId;
	}

	public Session getSession() {
		return session;
	}

	/**
	 * 连接建立成功调用的方法
	 * 
	 * @param session
	 *            可选的参数。session为与某个客户端的连接会话，需要通过它来给客户端发送数据
	 */
	@OnOpen
	public void onOpen(Session session) {
		this.session = session;
		GlobalVar.webSocketSet.add(this); // 加入set中
		addOnlineCount(); // 在线数加1
		System.out.println("******************************");
		System.out.println("id:" + session.getId());
		System.out.println("socket_count::" + GlobalVar.webSocketSet.size());
		System.out.println("**********************************");
	}

	/**
	 * 连接关闭调用的方法
	 */
	@OnClose
	public void onClose() {
		GlobalVar.webSocketSet.remove(this); // 从set中删除
		subOnlineCount(); // 在线数减1
		System.out.println("有一连接关闭！当前在线人数为" + getOnlineCount());
	}

	/**
	 * 收到客户端消息后调用的方法
	 * 
	 * @param message
	 *            客户端发送过来的消息
	 * @param session
	 *            可选的参数
	 */
	@OnMessage
	public void onMessage(String message, Session session) {
		System.out.println("来自客户端的消息:" + message);
		SendMessagess sendMessagess = new SendMessagess();
		System.out.println("userid= :" + session.getId());

		sendMessagess.send(session.getId());
	}

	private void parseMsg(String msg) {
	
	}

	/**
	 * 发生错误时调用
	 * 
	 * @param session
	 * @param error
	 */
	@OnError
	public void onError(Session session, Throwable error) {
		System.out.println("发生错误");
		error.printStackTrace();
	}

	/**
	 * 这个方法与上面几个方法不一样。没有用注解，是根据自己需要添加的方法。
	 * 
	 * @param message
	 * @throws IOException
	 */
	public void sendMessage(String message) throws IOException {
		this.session.getBasicRemote().sendText(message);
		// this.session.getAsyncRemote().sendText(message);
	}

	public static synchronized int getOnlineCount() {
		return onlineCount;
	}

	public static synchronized void addOnlineCount() {
		WSServer.onlineCount++;
	}

	public static synchronized void subOnlineCount() {
		WSServer.onlineCount--;
	}

	// private String currentUser;
	//
	// //连接打开时执行
	// @OnOpen
	// public void onOpen(@PathParam("user") String user, Session session) {
	// currentUser = user;
	// System.out.println("Connected ... " + session.getId());
	// // System.out.println("Connected ... " );
	// }
	//
	// //收到消息时执行
	// @OnMessage
	// public String onMessage(String message, Session session) {
	// System.out.println( "message:" + message);
	// return currentUser + "：" + message;
	// // return message + "：" + message;
	// }
	//
	// //连接关闭时执行
	// @OnClose
	// public void onClose(Session session, CloseReason closeReason) {
	// System.out.println(String.format("Session %s closed because of %s",
	// session.getId(), closeReason));
	// }
	//
	// //连接错误时执行
	// @OnError
	// public void onError(Throwable t) {
	// t.printStackTrace();
	// }
}
