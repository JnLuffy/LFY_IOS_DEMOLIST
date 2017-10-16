package action;

import java.io.IOException;
import java.util.Date;
import java.util.Timer;
import java.util.TimerTask;

public class SendMessagess {
	public  void send(String message, String toUserId) throws IOException {
		if (GlobalVar.webSocketSet != null) {
			for (WSServer s : GlobalVar.webSocketSet) {
				if (s != null && s.getSession().getId().equals(toUserId)) {
					s.sendMessage(message);
				}
			}
		}
	}

	public  void send(final String toUserId) {

		Timer timer = new Timer();
		timer.schedule(new TimerTask() {
			@Override
			public void run() {
				try {
					Date date=new Date();
					send("111::"+date.getTime(), toUserId);
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}

			}
		}, 1 * 1000);

	}

	
}
