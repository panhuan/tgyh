package XuanQu.gamecenter;

/**
 * @author banshuai
 *
 */
public class ResponseReceived {
	private String status;
	private String receipt;
	
	public ResponseReceived(String status, String receipt) {
		super();
		this.status = status;
		this.receipt = receipt;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getReceipt() {
		return receipt;
	}

	public void setReceipt(String receipt) {
		this.receipt = receipt;
	}

}
