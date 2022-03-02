public class TreatmentListCardController {
    
    @AuraEnabled(cacheable=true)
    public static List<Account_Treatment__c> getAccountTreatmentList() {
         return AccountTreatmentDAO.getAccountTreatmentListbyId() ;
     }

     @AuraEnabled
     public static List<AccountTreatmentListDTO> newGetAccountTreatmentList(String accountId) {
          List<Account_Treatment__c> queriedAccountTreatments = AccountTreatmentDAO.getAccountTreatmentListbyAccountIdWithLimit(accountId) ;
          List<AccountTreatmentListDTO> accountTreatmentDTOs = new List<AccountTreatmentListDTO>();
          if (!queriedAccountTreatments.isEmpty()) {
               for (Account_Treatment__c treatment : queriedAccountTreatments) {
                    accountTreatmentDTOs.add(new AccountTreatmentListDTO(treatment));
               }        
          }
          return accountTreatmentDTOs;
     }

     @AuraEnabled
     public static String newGetAccountTreatmentListNumber(String accountId) {
          List<Account_Treatment__c> queriedAccountTreatments = AccountTreatmentDAO.getAccountTreatmentListbyAccountId(accountId) ;
          Integer size =  queriedAccountTreatments.size();
          if (size < 4){
               return String.valueOf(size);
          } else {
               return '3+';
          }
     }
     @AuraEnabled
     public static void assignPermSetNew(){
         AccountTreatmentService.assignPermSetNew();
     }
 
     @AuraEnabled
     public static void removePermSet() {
         AccountTreatmentService.removePermSet();
     }

}