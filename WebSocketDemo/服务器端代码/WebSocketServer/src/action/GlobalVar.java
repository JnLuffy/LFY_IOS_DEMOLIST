package action;

import java.util.concurrent.CopyOnWriteArraySet;

public class GlobalVar {
	//concurrent�����̰߳�ȫSet���������ÿ���ͻ��˶�Ӧ��MyWebSocket������Ҫʵ�ַ�����뵥һ�ͻ���ͨ�ŵĻ�������ʹ��Map����ţ�����Key����Ϊ�û���ʶ
	public static CopyOnWriteArraySet<WSServer> webSocketSet = new CopyOnWriteArraySet<WSServer>();

}
