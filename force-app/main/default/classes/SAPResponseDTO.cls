public class SAPResponseDTO {
	public class Response {
		public String message;
		public Response response ;
		public Boolean success ;
	}

	public class WarningList {
		public String uuid_Flow;
		public String recordId;
		public String errorType;
		public String error_Description;
		public String operationType;
		public String operation_Name;
		public String originSystem;
		public String objectName;
		public String service;
		public String status;
		public String targetSystem;
	}

	public class ResultList {
		public Boolean success;
		public Log_event log_event;
		public String correlationID;
	}

	public Boolean success;
	public Response response;
	public List<ResultList> resultList;

	public class ErrorList {
		public String uuid_Flow;
		public String recordId;
		public String errorType;
		public String error_Description;
		public String operationType;
		public String operation_Name;
		public String originSystem;
		public String objectName;
		public String service;
		public String status;
		public String targetSystem;
	}

	public class Log_event {
		public List<WarningList> warningList;
		public List<ErrorList> errorList;
	}

	
	public static SAPResponseDTO parse(String json) {
		return (SAPResponseDTO) System.JSON.deserialize(json, SAPResponseDTO.class);
	}
}