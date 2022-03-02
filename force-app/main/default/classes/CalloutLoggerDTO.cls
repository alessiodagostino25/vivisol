public class CalloutLoggerDTO {
    
    @AuraEnabled
    public String Id {get; set;}

    @AuraEnabled
    public Datetime createdDate { get; set; }

    @AuraEnabled
    public String errorMessage { get; set; }

    @AuraEnabled
    public String errorType { get; set; }

    public CalloutLoggerDTO(String id, Datetime createdDate, String errorMessage, String errorType) {
        this.Id = id;
        this.createdDate = createdDate;
        this.errorMessage = errorMessage;
        this.errorType = errorType;
    }
}