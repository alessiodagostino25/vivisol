public class WAMDocumentRequestDTO {
    public String ID;

    public static AccountCreateDTO parse(String json) {
		return (AccountCreateDTO) System.JSON.deserialize(json, AccountCreateDTO.class);
    }
    
    public WAMDocumentRequestDTO(Stored_Document__c storedDocument) {
        this.ID = storedDocument.WAM_Id__c;
    }
}