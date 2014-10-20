package XuanQu.kingsoft.model;

public class Data {
	private String uid;
	private Actors actors;
	private String oid;
	public String getOid() {
		return oid;
	}

	public void setOid(String oid) {
		this.oid = oid;
	}

	public Actors getActors() {
		return actors;
	}

	public void setActors(Actors actors) {
		this.actors = actors;
	}

	public String getUid() {
		return uid;
	}

	public void setUid(String uid) {
		this.uid = uid;
	}

	public Data() {
		super();
		// TODO Auto-generated constructor stub
	}

	@Override
	public String toString() {
		return "Data [uid=" + uid + ", actors=" + actors + ", oid=" + oid + "]";
	}

	public Data(String uid, Actors actors, String oid) {
		super();
		this.uid = uid;
		this.actors = actors;
		this.oid = oid;
	}

	
	

	
}
