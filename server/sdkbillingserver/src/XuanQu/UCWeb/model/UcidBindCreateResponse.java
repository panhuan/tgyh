package XuanQu.UCWeb.model;

public class UcidBindCreateResponse {
	long id;
	UcidBindCreateResponseState state;
	UcidBindCreateResponseData data;
	
	public long getId(){
		return this.id;
	}
	public void setId(long id){
		this.id =id;
	}
	public UcidBindCreateResponseState getState(){
		return this.state;
	}
	public void setState(UcidBindCreateResponseState state){
		this.state = state;
	}
	
	public UcidBindCreateResponseData getData(){
		return this.data;
	}
	public void setData(UcidBindCreateResponseData data){
		this.data = data;
	}
	
	
	public class UcidBindCreateResponseState{
		int code;
		String msg;
		public int getCode(){
			return this.code;
		}
		public void setCode(int code){
			this.code = code;
		}
		public String getMsg(){
			return this.msg;
		}
		public void setMsg(String msg){
			this.msg = msg;
		}
	}
	public class UcidBindCreateResponseData{
		private int ucid;
		private String sid;
		public int getUcid(){
			return this.ucid;
		}
		
		public void setUcid(int ucid){
			this.ucid = ucid;
		}
		public String getSid(){
			return this.sid;
		}
		public void setSid(String sid){
			this.sid = sid;
		}
	}

}
