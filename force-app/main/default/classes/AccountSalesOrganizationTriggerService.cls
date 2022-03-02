public class AccountSalesOrganizationTriggerService {
    
    public void afterInsertOperation(List<Account_Sales_Organization__c> triggerNew){
        if(trigger.isInsert){
            List<Account_Partner_Function__c > listToInsert=new List<Account_Partner_Function__c >();
            for(Account_Sales_Organization__c aso:triggerNew){
                for(integer i=0;i<4;i++){
                    Account_Partner_Function__c apf=new Account_Partner_Function__c();
                    apf.Account_Sales_Organization__c=aso.id;
                    apf.Account__c=aso.Account__c;
                    if(i==0){ 
                        apf.Partner_Function__c='AG';
                    }
                    else if(i==1){
                        apf.Partner_Function__c='RE';
                    }
                     else if(i==2){
                        apf.Partner_Function__c='RG';
                    }
                     else if(i==3){
                        apf.Partner_Function__c='WE';
                    }
                    listToInsert.add(apf);
                }
            }
            insert listToInsert;
        }
        
    }

}