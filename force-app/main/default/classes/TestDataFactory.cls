@isTest
public class TestDataFactory {
    
    public static Account initAccount(){
        Id personAccountRcId = [SELECT Id FROM RecordType WHERE Name = 'Person Account'].Id;
        Account acc = new Account(LastName='testAccount', Phone='4214214', RecordtypeId = personAccountRcId);
        insert acc;
        return acc;
    }

    public static Account createPersonAccount() {
        RecordType personAccountRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Person_Account'];

        Account a = new Account(
            FirstName = 'Test',
            LastName = 'PersonAccount',
            Phone = '12345678',
            ShippingCity='city',
            ShippingCountry='Italy',
            ShippingPostalCode='80000',
            ShippingStreet='via ',
            ShippingCountryCode='It'
        );

        return a;
    }

    public static Account createPersonAccountWithExternalId(String externalId) {
        RecordType personAccountRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Person_Account'];

        Account a = new Account(
            FirstName = 'Test',
            LastName = 'PersonAccount',
            Phone = '12345678',
            ShippingCity='city',
            ShippingCountry='Italy',
            ShippingPostalCode='80000',
            ShippingStreet='via ',
            ShippingCountryCode='It',
            Account_External_Id__c = externalId
        );

        return a;
    }

    public static Account createB2BAccount() {
        RecordType personAccountRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Account_B2B'];

        Account a = new Account(
            Name = 'Test B2B Account',
            Phone = '12345678',
            ShippingCity='city',
            ShippingCountry='Italy',
            ShippingPostalCode='80000',
            ShippingStreet='via ',
            ShippingCountryCode='It'
        );

        return a;
    }

    public static Contract_Framework__c initContractFramework(){

        Contract_Framework__c cF = new Contract_Framework__c(Name ='testContractFramework');
        insert cF;
        return cF;
    }

    public static Contract_Framework__c createContractFramework() {
        Contract_Framework__c contractFramework = new Contract_Framework__c(
            Name = 'Test Contract Framework'
        );

        return contractFramework;
    }

    public static Contract_Treatment__c initContractTreatment(String contractFrameworkId){

        //Contract_Framework__c contractFrameworkId = [SELECT Id FROM Contract_Framework__c WHERE Name = 'testFramework'].Id;
        Contract_Treatment__c cT = new Contract_Treatment__c(Name ='testContractTreatment', Contract_Framework__c = contractFrameworkId);
        insert cT;
        return cT;
    }

    //S: V4AT-189
    public static Contract_Treatment__c initContractTreatmentWithBusinessLine(String contractFrameworkId){
        Contract_Treatment__c cT = new Contract_Treatment__c(Name ='testContractTreatment', Contract_Framework__c = contractFrameworkId, Business_Line__c = 'SO');
        insert cT;
        return cT;
    }
    //E: V4AT-189

    public static Contract_Treatment__c initContractTreatmentWithExternalId(String contractFrameworkId, String externalId){

        //Contract_Framework__c contractFrameworkId = [SELECT Id FROM Contract_Framework__c WHERE Name = 'testFramework'].Id;
        Contract_Treatment__c cT = new Contract_Treatment__c(Name ='testContractTreatment', Contract_Framework__c = contractFrameworkId, External_id__c = externalId);
        insert cT;
        return cT;
    }

    public static Contract_Treatment__c createContractTreatment(Id contractFrameworkId) {
        Contract_Treatment__c contractTreatment = new Contract_Treatment__c(
            Name = 'Test Contract Treatment',
            Contract_Framework__c = contractFrameworkId
        );

        return contractTreatment;
    }

    public static Contract_Treatment_Job__c initContractTreatmentJob(String contractTreatmentId, String corporateTreatmentId){

        //Contract_Treatment__c contractTreatmentId = [SELECT Id FROM Contract_Treatment__c WHERE Name = 'testTreatment'].Id;
        
        Contract_Treatment_Job__c cTJ = new Contract_Treatment_Job__c(Name ='testContractTreatmentJob', Contract_Treatment__c = contractTreatmentId/*, Corporate_Treatment_Job__c = corporateTreatmentId*/);

        insert cTJ;
        return cTJ;
    }

    public static Contract_Treatment_Job__c createContractTreatmentJob(Id contractTreatmentId) {
        Contract_Treatment_Job__c CTJ = new Contract_Treatment_Job__c(
            Name = 'Test CTJ',
            Contract_Treatment__c = contractTreatmentId
        );

        return CTJ;
    }

    public static Contract_Treatment_Job_Product__c createCTJP(Id contractTreatmentJobId) {
        Contract_Treatment_Job_Product__c CTJP = new Contract_Treatment_Job_Product__c(
            Contract_Treatment_Job__c = contractTreatmentJobId
        );

        return CTJP;
    }
    
       public static Contract_Treatment_Job__c initContractTreatmentJob2(String contractTreatmentId, String corporateTreatmentId){

        //Contract_Treatment__c contractTreatmentId = [SELECT Id FROM Contract_Treatment__c WHERE Name = 'testTreatment'].Id;
        
        Contract_Treatment_Job__c cTJ = new Contract_Treatment_Job__c(Name ='testContractTreatmentJob', Contract_Treatment__c = contractTreatmentId /*, Corporate_Treatment_Job__c = corporateTreatmentId*/);

        return cTJ;
    }

    public static Corporate_Treatment_Job__c initCorporateTreatmentJob(String contractTreatmentJobId){
        //Contract_Treatment__c contractTreatmentId = [SELECT Id FROM Contract_Treatment__c WHERE Name = 'testTreatment'].Id;
        Corporate_Treatment_Job__c corTJ = new Corporate_Treatment_Job__c (Name = 'testCorporateTreatmentJob');
        insert corTJ;
        return corTJ;
    }
    
    public static Product2 initProduct2(){
        Product2 p1= new Product2();
        p1.Name='ProductForFamily';
        insert p1;
        Product2 p = new Product2();
        p.Type__c = 'ZA01';
        p.Name = 'prova';
        p.Product_Name_IT__c='pIT';
        p.Product_Family__c=p1.Id;
        p.isActive = true;
        insert p;
        return p;    
    }
    
    public static Account initAccount2(){
        String personAccountRcId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Account_Patient').getRecordTypeId();
        system.debug('personAccountRcId: ' +personAccountRcId);
        Account acc = new Account();
        acc.FirstName='first name'; 
        acc.LastName='lasta name'; 
        acc.RecordtypeId = personAccountRcId;
        acc.Language__c='I';
        acc.Billing_method__c='01';
        acc.PersonBirthdate=Date.newInstance(1990, 12, 01);
        acc.ShippingCity='city';
        acc.ShippingCountry='Italy';
        acc.ShippingPostalCode='80000';
        acc.ShippingStreet='via ';
        acc.ShippingCountryCode='It';
        insert acc;
        return acc;
    }    
        public static String getCfID(Contract_Framework__c cf){
        string id=cf.Id;
        return id;
    }
    
    public static Product2 initProduct(){        
        Product2 p=new Product2();
        p.name='prova';
        p.Product_Name_IT__c='pIt';
        insert p;
        return p;
    }
    
    public static Contract_Treatment_Job_Product__c initCTJP(Contract_Treatment_Job__c ctj, Product2 p){
        Contract_Treatment_Job_Product__c ctjp=new Contract_Treatment_Job_Product__c();
        ctjp.Product__c=p.id;
        ctjp.Contract_Treatment_Job__c=ctj.Id;
        insert ctjp;
        return ctjp;
    }
    
    public static Corporate_Treatment_Job__c initCorporateTreatmentJob(){
        Corporate_Treatment_Job__c cotj=new Corporate_Treatment_Job__c();
        cotj.Name='prova';
        insert cotj;
        return cotj;
    }

    public static Corporate_Treatment_Job__c createCorporateTJ() {
        Corporate_Treatment_Job__c corporateTJ = new Corporate_Treatment_Job__c(
            Name = 'Test Corporate Treatment Job'
        );

        return corporateTJ;
    }
    
    public static Pricebook2 initPricebook(){
    Pricebook2 pb = new Pricebook2(Name ='testPricebook2');
        insert pb;
        return pb;

    }

    public static Pricebook2 createPricebook() {
        Pricebook2 pricebook = new Pricebook2(
            Name = 'Test Pricebook2'
        );

        return pricebook;
    }

    public static List<Contract_Framework__c> getListCf(){
        List<Contract_Framework__c> lcf=[SELECT Id,Name FROM Contract_Framework__c where Name='VGZ Contract 0001' LIMIT 1];
        return lcf;
    }
    public static Contract_Framework__c getContractFramework(List<Contract_Framework__c> lcf, Pricebook2 pb){
        Contract_Framework__c cfc=new Contract_Framework__c();
        for(Contract_Framework__c cf:lcf){
            cf.Price_list_code__c=pb.Id;
            cfc=cf;
            update cfc;
        }
        return cfc;
    }
    
     public static Corporate_Treatment__c initCorporateTreatment(){
        Corporate_Treatment__c cot=new Corporate_Treatment__c();
        cot.Name='prova';
        insert cot;
        return cot;
    }

    public static Corporate_Treatment__c createCorporateTreatment() {
        Corporate_Treatment__c CT = new Corporate_Treatment__c(
            Name = 'Test Corporate Treatment'
        );

        return CT;
    }
    
    public static Contract_Framework__c initContractFramework2(Pricebook2 pb){
         Contract_Framework__c cF = new Contract_Framework__c();
        cF.Name='prova';
        cF.Price_list_code__c=pb.Id;
        insert cF;
        return cF;
    }
    
    public static Corporate_Treatment_Job_Product__c initCorporateTreatmentJobProduct(Corporate_Treatment_Job__c cotj,Product2 p){
        Corporate_Treatment_Job_Product__c cotjp=new Corporate_Treatment_Job_Product__c();
        cotjp.Corporate_Treatment_Job__c=cotj.Id;
        cotjp.Product_Activities_Family__c=p.Id;
        insert cotjp;
        return cotjp;
    }
    
     public static List<String> initListProductId(){
        List<String> listProductId = new List<String>();
        Product2 p1 = new Product2();
        p1.Name='product1'; 
        insert p1;
        listProductId.add(p1.Id);
        Product2 p2 = new Product2();
        p2.Name='product2';
        insert p2;
        listProductId.add(p2.Id);
        return listProductId;
        
    }
    
    public static Account_Treatment_Job__c initAccountTreatmentJob(Product2 p){
        Account_Treatment_Job__c AccountTreatmentJob = new Account_Treatment_Job__c();
        AccountTreatmentJob.Name='AccountTreatmentJob1';
        AccountTreatmentJob.Contract_Treatment_Job_Code__c=p.Id;   
        return AccountTreatmentJob;
        
    }
    public static Profile getVivisolBackofficeProfile(){
        Profile pr=[SELECT Id,Name from Profile where Name='Vivisol BackOffice NL' LIMIT 1];
        return pr;
    }

    public static Profile getVivisolAdminProfile(){
        Profile pr=[SELECT Id,Name from Profile where Name='SystemAdministrator_NL' LIMIT 1];
        return pr;
    }
    
    public static User initUser(Profile pr){
        User u = new User();
        u.Username = 'testuser@vivisol.prodTest';
        u.LastName='lastname';
        u.Email= 'asasasa@gmail.it';
        u.Alias = 'boh'; 
        u.TimeZoneSidKey = 'Europe/Rome'; 
        u.LocaleSidKey = 'it_IT' ;
        u.EmailEncodingKey = 'UTF-8';
        u.ProfileId = pr.Id;
        u.LanguageLocaleKey = 'it';
    	u.Country='ITALY';
    	u.CountryCode='IT';
        insert u;
        return u;
    }
    
    public static List<Asset> getAssetList(){
        List<Asset> assetList = [SELECT Id, Name from Asset WHERE Name='Asset N1' or Name='PwC Test Asset 2'];
        return assetList;
    }
    
    public static List<String> assetList(List<Asset> al){
        List<String> assetListId= new List<String>();
        for (Asset a:al){
            assetListId.add(a.Id);
        }
        return assetListId;
    }
    
    public static void initAccountTreatmentJobProduct(Account_Treatment_Job__c atj){
        Account_Treatment_Job_Product__c atjp= new Account_Treatment_Job_Product__c();
        //atjp.Account__c=a.Id;
        atjp.Patient_Treatment_Job__c=atj.Id;
        insert atjp;
    }

    public static Account_Treatment_Job_Product__c createATJP(Id accountTreatmentJobId) {
        Account_Treatment_Job_Product__c ATJP = new Account_Treatment_Job_Product__c(
            Patient_Treatment_Job__c = accountTreatmentJobId
        );

        return ATJP;
    }
    
    public static Account_Treatment_Job__c initAccountTreatmentJob2(Product2 p,  Contract_Treatment_Job__c contactTreatmentJob, Account_Treatment__c accountTreatment){
        Account_Treatment_Job__c accountTreatmentJob = new Account_Treatment_Job__c();
        accountTreatmentJob.Name='AccountTreatmentJob1';
        accountTreatmentJob.Contract_Treatment_Job__c=contactTreatmentJob.Id;
        accountTreatmentJob.Patient_Treatment__c=accountTreatment.Id;
        insert accountTreatmentJob;
        return accountTreatmentJob;
    }
    
    public static Account_Treatment__c initAccountTreatment(){
        Account_Treatment__c at = new Account_Treatment__c();
        at.Name='string1';
        insert at;
        return at;
        
    }

    public static Account_Treatment__c createMRDAccountTreatment(Account a) {
        RecordType therapyRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'AccountTreatment_Therapy'];
        System.debug('TherapyRecordType: ' + therapyRecordType);

        Account_Treatment__c accountTreatment = new Account_Treatment__c(
            Account__c = a.Id,
            Name = 'Test Account Treatment',
            RecordTypeId = therapyRecordType.Id,
            Business_Line__c = 'SDB',
            Treatment_Type__c = 'MRD'
        );

        return accountTreatment;
    }
    
    
    public static List<Contract_Treatment_Job_Product__c> initCTJPList(Contract_Treatment_Job__c ctj, List<Product2> productList){
        List<Contract_Treatment_Job_Product__c> ctjpList= new List<Contract_Treatment_Job_Product__c>();
        for(Product2 p: productList){
            Contract_Treatment_Job_Product__c ctjp=new Contract_Treatment_Job_Product__c();
            ctjp.Product__c=p.id;
            ctjp.Contract_Treatment_Job__c=ctj.Id;
            ctjpList.add(ctjp);
        }
        insert ctjpList;
        return ctjpList;
    }
    
    
    public static Asset initAsset(Account a){
        Asset at = new Asset();
        at.Name='asset1';
        at.AccountId=a.Id;
        insert at;
        return at;
        
    }

    public static Asset createAsset(Id accountId) {
        Asset asset = new Asset(
            Name = 'Test Asset',
            AccountId = accountId
        );

        return asset;
    }
    
    public static PricebookEntry initPricebookEntry(Pricebook2 pricebook, Product2 product){
        PricebookEntry pe = new PricebookEntry();
        pe.Pricebook2Id=pricebook.Id;
        pe.Product2Id=product.Id;
        pe.UseStandardPrice=false;
        pe.UnitPrice=12;
        insert pe;
        return pe;
    }

    public static PricebookEntry createActivePricebookEntry(Id pricebookId, Id productId) {
        PricebookEntry pe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = productId,
            isActive = true,
            UnitPrice = 10
        );

        return pe;
    }
    
    public static Pricebook2 initPricebookStandard (){
        Pricebook2 pricebook= initPricebook();
        pricebook.Id=Test.getStandardPricebookId();
        pricebook.Name='Standard Price Book';
        update pricebook;
        return pricebook;
    }
    
    public static Account_Treatment_Job__c initAccountTreatmentJob2(Product2 p, Account_Treatment__c at){
        Account_Treatment_Job__c AccountTreatmentJob = new Account_Treatment_Job__c();
        AccountTreatmentJob.Name='AccountTreatmentJob1';
        AccountTreatmentJob.Patient_Treatment__c=at.Id;
        insert AccountTreatmentJob;
        return AccountTreatmentJob;        
    }
    
    public static Account_Treatment_Job_Product__c initAccountTreatmentJobProduct2(Account_Treatment_Job__c atj, Product2 p){
        Account_Treatment_Job_Product__c atjp= new Account_Treatment_Job_Product__c();
        atjp.Patient_Treatment_Job__c=atj.Id;
        atjp.Product__c = p.Id;
        insert atjp;
        return atjp;
    }
    
    public static List<Product2> initProductList(){
        List<Product2> listProduct = new List<Product2>();
        Product2 p1= new Product2();
        p1.Name='prova1';
        p1.Type__c='ZS02';
       	listProduct.add(p1);
        Product2 p = new Product2();
        p.Type__c = 'ZA01';
        p.Name = 'prova2';
        p.Product_Name_IT__c='pIT';
        p.Product_Family__c=p1.Id;
        listProduct.add(p);
        Product2 p2 = new Product2();
        p2.Type__c = 'ZSER';
        p2.Name = 'prova3';
        p2.Product_Name_IT__c='pIT';
        p2.Product_Family__c=p1.Id;
        listProduct.add(p2);
        insert listProduct;
        return listProduct;
    }
    
    public static Contract_Product_Limit__c initContarctProductLimit(Contract_Treatment__c ct, Product2 p){
        Contract_Product_Limit__c cpl = new Contract_Product_Limit__c();
        cpl.Name='ContractProductLimit1';
  		cpl.Contract_Treatment__c=ct.Id;
        cpl.Product__c=p.Id;  
        cpl.Status__c='Inactive';
        insert cpl;
        return cpl;
    }

    public static Contract_Product_Limit__c createLimit(Id contractTreatmentId, Id productId) {
        Contract_Product_Limit__c CPL = new Contract_Product_Limit__c(
            Name = 'Test Limit',
            Contract_Treatment__c = contractTreatmentId,
            Product__c = productId,
            Status__c = 'Inactive'
        );

        return CPL;
    }
    
    public static Contract_Product_Limit__c initContarctProductLimit2(Contract_Treatment__c ct, Product2 p){
        Contract_Product_Limit__c cpl = new Contract_Product_Limit__c();
        cpl.Name='ContractProductLimit1';
  		cpl.Contract_Treatment__c=ct.Id;
        cpl.Product__c=p.Id;  
        cpl.Status__c='Inactive';
        return cpl;
    }
    
    public static Contract_Framework__c initContractFramework(Pricebook2 pb){
        Contract_Framework__c cF = new Contract_Framework__c(Name ='testContractFramework', Price_List_Code__c=pb.Id);
        insert cF;
        return cF;
    }
    
    public static Contract_Framework__c initContractFramework3(Pricebook2 pb){
        Contract_Framework__c cF = new Contract_Framework__c(Name ='testContractFramework', Price_List_Code__c=pb.Id);
        insert cF;
        return cF;
    }
    
    public static void initTreatmentJobSla(String contractTreatmentJobId){
        Contract_Treatment_Job_SLA__c ctjs=new Contract_Treatment_Job_SLA__c();
        ctjs.Contract_Treatment_Job__c =contractTreatmentJobId;
        ctjs.Name='prova';
        ctjs.Offset_End_Date__c = 7;
        ctjs.Offset_Start_Date__c = 7;
        ctjs.Offset_calculation_mode__c = 'Calendar';
        ctjs.Offset_unit_of_measure__c = 'Day';
        insert ctjs;
    }

    public static Contract_Treatment_Job_SLA__c createSLA(Id contractTreatmentJobId) {
        Contract_Treatment_Job_SLA__c sla = new Contract_Treatment_Job_SLA__c(
            Contract_Treatment_Job__c = contractTreatmentJobId,
            Name = 'Test SLA'
        );

        return sla;
    }

    public static Contract_Treatment_Job_SLA__c createFullCalendarSLA(Id contractTreatmentJobId) {
        Contract_Treatment_Job_SLA__c sla = new Contract_Treatment_Job_SLA__c(
            Contract_Treatment_Job__c = contractTreatmentJobId,
            Name = 'Test SLA',
            Offset_calculation_mode__c = 'Calendar',
            Offset_calculation_mode_Task__c = 'Calendar',
            Offset_End_Date__c = 1,
            Offset_End_Date_Task__c = 1,
            Offset_Start_Date__c = 1,
            Offset_Start_Date_Task__c = 1,
            Offset_unit_of_measure__c = 'Day',
            Offset_unit_of_measure_Task__c = 'Day',
            Task_Calculation_Mode__c = 'Calendar',
            Calculation_Mode__c = 'Calendar',
            Task_MaxTime_Execution__c = 1,
            Task_Unite_of_measure_Max_Time__c = 'Day',
            Unite_of_measure_Max_Time__c = 'Day'
        );

        return sla;
    }
    
    public static void initMeasurement(){
       
        Contact c = new Contact();
        c.LastName = 'contact';
        c.Phone = '323232323';
        c.Email = 'test@test.com';
       
        insert c;
        Account a = initAccount2();

        Schema.Location location = createLocation();
        insert location;
         
        Asset ass = new Asset();
        ass.Name = 'test';
        ass.Equipment_Key__c = '12';
        ass.AccountId = a.Id;
        ass.LocationId = location.Id;
       // ass.ContactId = c.Id;
        insert ass;
        
        Measurement__c m = new Measurement__c();
        m.Name = 'Measurement__c';
        m.isCreatedSAP__c = false;
        m.Serialized_Item__c = ass.Id;
        m.Date_Measurement__c =date.valueOf('2020-01-01');
        m.Measure__c = 'COUNTER';
        m.Parameter_1_Value__c = 10.00; 
        
        
        insert m;
        
    }
    
    public static Account initAccountWithAddress(){
        String personAccountRcId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Account_Patient').getRecordTypeId();
        system.debug('personAccountRcId: ' +personAccountRcId);
        Account acc = new Account();
        acc.FirstName='first name'; 
        acc.LastName='lasta name'; 
        acc.RecordtypeId = personAccountRcId;
        acc.Language__c='I';
        acc.Billing_method__c='01';
        acc.PersonBirthdate=Date.newInstance(1990, 12, 01);
        acc.ShippingCity='city';
        acc.ShippingCountry='Italy';
        acc.ShippingPostalCode='80000';
        acc.ShippingStreet='via ';
        acc.ShippingCountryCode='It';
        acc.Address_ID__c='idAddress';
        acc.MiddleName='mid1';
        acc.Shipping_Address_Type__c='XXDEFAULT';
        insert acc;
        return acc;
    }


    public static Schema.Address initAddress(Account a, Schema.Location location){
        Schema.Address newAddress = new Schema.Address(
                AddressType = 'VIVITRAVEL',
                LocationType = 'Site',
                ParentId = location.id,
                City = a.ShippingCity,
                Street = a.ShippingStreet,
                CountryCode = a.ShippingCountryCode,
                PostalCode = a.ShippingPostalCode,
                Is_Default__c = false
                );
        
        insert newAddress;
        return newAddress;
    }

    public static Schema.Address createDefaultAddress(Account a, Schema.Location location) {
        Schema.Address newAddress = new Schema.Address(
            AddressType = 'XXDEFAULT',
            LocationType = 'Site',
            ParentId = location.id,
            City = a.ShippingCity,
            Street = a.ShippingStreet,
            CountryCode = a.ShippingCountryCode,
            PostalCode = a.ShippingPostalCode,
            Is_Default__c = false
        );
        
        return newAddress;
    }
    
    public static Schema.Address initAddress2(Account a, Schema.Location location){
        Schema.Address newAddress = new Schema.Address(
                AddressType = 'VIVITRAVEL',
                LocationType = 'Site',
                ParentId = location.id,
                City = a.ShippingCity,
                Street = a.ShippingStreet,
                CountryCode = a.ShippingCountryCode,
                PostalCode = a.ShippingPostalCode,
                Is_Default__c = true
                );
        
        insert newAddress;
        return newAddress;
    }

    public static Schema.Location initLocation(Account a){
        Schema.Location location = new Schema.Location(Account__c = a.Id, 
                                                       City__c = a.ShippingCity, 
                                                       Country__c = a.ShippingCountry,
                                                       Street__c = a.ShippingStreet,
                                                       Name='location1',
                                                       LocationType='Holiday'
                                                      );
        insert location;
        return location;
    }

    public static Schema.Location createLocation() {
        Schema.Location location = new Schema.Location(
            Name = 'Test Location',
            LocationType = 'Site');

        return location;
    }

    public static Schema.Location initInventoryLocation(Account a){
        Schema.Location location = new Schema.Location(Account__c = a.Id, 
                                                       City__c = a.ShippingCity, 
                                                       Country__c = a.ShippingCountry,
                                                       Street__c = a.ShippingStreet,
                                                       Name='location1',
                                                       LocationType='Holiday',
                                                       isInventoryLocation = true
                                                      );
        insert location;
        return location;
    }
    
    public static Quote__c initQuote(Account acc, Pricebook2 pb, Contract_Treatment__c ct){
        Quote__c q = new Quote__c();
        q.Name = 'Test Quote';
        q.Account_Name__c = acc.Id;
        q.Price_Book__c = pb.id;
        q.Contract_Treatment__c = ct.id;
        insert q;
        return q;
    }
    
    public static Account insertAccountPatient(){
        String personAccountRcId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Account_Patient').getRecordTypeId();
        system.debug('personAccountRcId: ' +personAccountRcId);
        Account acc = new Account();
        acc.FirstName='first name'; 
        acc.LastName='lasta name'; 
        acc.RecordtypeId = personAccountRcId;
        acc.Language__c='I';
        acc.Billing_method__c='01';
        acc.PersonBirthdate=Date.newInstance(1990, 12, 01);
        acc.ShippingCity='City';
        acc.ShippingCountry='Italy';
        acc.ShippingPostalCode='80000';
        acc.ShippingStreet='via ';

        insert acc;
        return acc;
    }
    public static Account insertAccountVivisol(){
        String personAccountRcId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Account_Vivisol').getRecordTypeId();
        system.debug('personAccountRcId: ' +personAccountRcId);
        Account acc = new Account();
        acc.Name='test1'; 
        acc.RecordtypeId = personAccountRcId;
        acc.Language__c='I';
        acc.Billing_method__c='03';
        acc.ShippingCity='City';
        acc.ShippingCountry='Italy';
        acc.ShippingPostalCode='80000';
        acc.ShippingStreet='via ';

        insert acc;
        return acc;
    }
    
    public static Quote_Line_Item__c  initQuoteLineItem(Quote__c q, Pricebook2 pb, Product2 pr){
        Quote_Line_Item__c qli = new Quote_Line_Item__c();
        qli.Description__c = 'Test Description';
        qli.Quote_Name__c = q.Id;
        qli.Pricebook__c = pb.id;
        qli.Product__c = pr.id;
        qli.Quantity__c = 20;
        insert qli;
        return qli;
        
    }
    
    public static Account_Sales_Organization__c getAso(String accountId){
        Account_Sales_Organization__c aso=new Account_Sales_Organization__c();
        aso.Account__c=accountId;
        aso.Name='prova';
        aso.Payment_Terms__c='NL00';
        return aso;
    }
    
    public static Account initAccount3(){
        Account a=new Account();
        a.Name='prova';
        insert a;
        return a;
    }
    
     public static Account_Sales_Organization__c getAso2(String accountId){
        Account_Sales_Organization__c aso=new Account_Sales_Organization__c();
        aso.Account__c=accountId;
        aso.Name='prova2';
        aso.Payment_Terms__c='NL01';
        return aso;
    }
    
     public static Account_Sales_Organization__c getAso3(String accountId){
        Account_Sales_Organization__c aso=new Account_Sales_Organization__c();
        aso.Account__c=accountId;
        aso.Name='prova3';
        aso.Payment_Terms__c='NL08';
        return aso;
    }
    public static Order initOrder(Account acc, Pricebook2 pb, Contract_Treatment__c ct){
        Order o = new Order();
        o.Name = 'Test Order';
        o.AccountId = acc.Id;
        o.Status = 'New' ;
        o.EffectiveDate =  system.today();
        o.Pricebook2Id = pb.Id; 
        o.Pricebook__c = pb.Id ;
        o.Contract_Treatment__c = ct.Id;
        insert o;
        return o;
    }

    public static Order initOrder(Account acc, Pricebook2 pb){
        Order o = new Order();
        o.Name = 'Test Order';
        o.AccountId = acc.Id;
        o.Status = 'New';
        o.EffectiveDate =  system.today();
        o.Pricebook2Id = pb.Id; 
        o.Pricebook__c = pb.Id;
        insert o;
        return o;
    }

    public static OrderItem  initOrderItem(Order o, Pricebook2 pb, Product2 pr, PricebookEntry pe ){
        OrderItem oi = new OrderItem();
        oi.OrderId = o.Id ;
        oi.Description = 'Test Description';
        oi.Pricebook__c = pb.id;
        oi.PricebookEntryId = pe.Id ;
        oi.Product2Id = pr.id;
        oi.Quantity = 20;
        oi.UnitPrice = 1;
        insert oi;
        return oi;
    }

    public static OrderItem createOrderItem(Order order, String pricebookId, Product2 product, PricebookEntry pe) {
        OrderItem orderItem = new OrderItem(
            OrderId = order.Id,
            Description = 'Test Description',
            Pricebook__c = pricebookId,
            PricebookEntryId = pe.Id,
            Product2Id = product.Id,
            Quantity = 1,
            UnitPrice = 1
        );

        return orderItem;
    }
    public static Case  initCase(Account acc, Contract_Treatment__c ct){
        Case c = new Case();
        c.AccountId = acc.Id ;
        c.Contract_Treatment__c = ct.Id ;
        insert c;
        return c;
    }

    public static Picklist_Choise_Set_Flow__c createPCSF(String parentId, String value, String locationId, String code) {
        Picklist_Choise_Set_Flow__c pcsf = new Picklist_Choise_Set_Flow__c(
            Parent_Id__c = parentId,
            Value__c = value,
            Location__c = locationId,
            Code__c = code
        );

        return pcsf;
    }

    public static WorkOrder createWorkOrder() {
        WorkOrder wo = new WorkOrder(
            StartDate = Datetime.now(),
            EndDate = (Datetime.now()).addMonths(1)
        );

        return wo;
    }

    public static Task createTask() {
        Task t = new Task();

        return t;
    }

    public static OperatingHours createOperatingHours() {
        OperatingHours operatingHours = new OperatingHours(
            Name = 'Test OperatingHours'
        );

        return operatingHours;
    }

    public static ServiceTerritory createServiceTerritory(Id operatingHoursId, Boolean isActive) {
        ServiceTerritory serviceTerritory = new ServiceTerritory(
            Name = 'Test ServiceTerritory',
            OperatingHoursId = operatingHoursId,
            IsActive = isActive
        );

        return serviceTerritory;
    }

    public static ServiceAppointment createServiceAppointment(Id parentRecordId, Id serviceTerritoryId, String status) {
        ServiceAppointment serviceAppointment = new ServiceAppointment(
            ParentRecordId = parentRecordId,
            Status = status,
            SchedStartTime = Datetime.now(),
            SchedEndTime = (Datetime.now()).addDays(1),
            ServiceTerritoryId = serviceTerritoryId
        );

        return serviceAppointment;
    }

    public static Contract_Treatment_Job__c createDependentContractTreatmentJob(Id contractTreatmentId, Id fatherCTJId) {
        Contract_Treatment_Job__c ctj = new Contract_Treatment_Job__c(
            Contract_Treatment__c = contractTreatmentId,
            Contract_Treatment_Job__c = fatherCTJId,
            Scheduling_Rule__c = 'Autoscheduled',
            SADependency__c = 'Same Start'
        );

        return ctj;
    }

    public static Account_Treatment_Job__c createAccountTreatmentJob(Id accountTreatmentId) {
        Account_Treatment_Job__c atj = new Account_Treatment_Job__c(
            Name = 'Test ATJ',
            Patient_Treatment__c = accountTreatmentId
        );

        return atj;
    }

    public static AssignedResource createAssignedResource(Id serviceAppointmentId, Id serviceResourceId) {
        AssignedResource ar = new AssignedResource(
            ServiceAppointmentId = serviceAppointmentId,
            ServiceResourceId = serviceResourceId
        );

        return ar;
    }

    public static ServiceResource createServiceResource() {
        ServiceResource sr = new ServiceResource(
            RelatedRecordId = UserInfo.getUserId(),
            Name = 'Test ServiceResource',
            IsActive = true
        );

        return sr;
    }

    public static ServiceTerritoryMember createServiceTerritoryMember(Id operatingHoursId, Id serviceResourceId, Id serviceTerritoryId) {
        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            EffectiveStartDate = (Datetime.now()).addDays(-1),
            EffectiveEndDate = (Datetime.now()).addYears(1),
            OperatingHoursId = operatingHoursId,
            ServiceResourceId = serviceResourceId,
            ServiceTerritoryId = serviceTerritoryId,
            TerritoryType = 'P'
        );

        return stm;
    }

    public static Entitlement createEntitlement(Id accountId, Id svcApptBookingWindowsId) {
        Entitlement e = new Entitlement(
            AccountId = accountId,
            Name = 'Test Entitlement',
            SvcApptBookingWindowsId = svcApptBookingWindowsId
        );

        return e;
    }

    // ERROR!! Data structure invalid (???)
    public static FSL__Polygon__c createPolygon(Id serviceTerritoryId) {
        FSL__Polygon__c polygon = new FSL__Polygon__c(
            FSL__Service_Territory__c = serviceTerritoryId,
            FSL__Ma_La__c = 51.653555037233005,
            FSL__Ma_Lo__c = 5.304068685131718,
            FSL__Mi_La__c = 51.48255332499477,
            FSL__Mi_Lo__c = 4.824790120678593,
            Name = 'tilburg',
            FSL__Color__c = '#5679C0',
            FSL__KML__c = '	<?xml version="1.0" encoding="UTF-8"?> <kml xmlns="http://www.opengis.net/kml/2.2"> <Style id="tilburgStyle"> <LineStyle> <width>1</width> </LineStyle> <PolyStyle> <color>80C07956</color> </PolyStyle> </Style> <Placemark> <name>tilburg</name> <styleUrl>#tilburgStyle</styleUrl> <Polygon> <outerBoundaryIs> <LinearRing> <coordinates>4.824790120678593,51.48789814288317,0 5.304068685131718,51.48255332499477,0 5.283125997143436,51.60234038160352,0 5.017700113704584,51.653555037233005,0 4.9181365150717715,51.57851610257048,0 4.824790120678593,51.48789814288317,0 </coordinates> </LinearRing> </outerBoundaryIs> </Polygon> </Placemark> </kml>'
        );

        return polygon;
    }

    public static Product2 createProduct() {
        Product2 product = new Product2(
            Name = 'Test Product'
        );

        return product;
    }

    public static WorkOrderLineItem createWOLI(Id workOrderId, Id pricebookEntryId) {
        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = workOrderId,
            PricebookEntryId = pricebookEntryId
        );

        return woli;
    }

    public static Questionnaire__c createQuestionnaire() {
        Questionnaire__c q = new Questionnaire__c();

        return q;
    }

    public static ProductItem createProductItem() {
        Account account = createPersonAccount();
        insert account;

        Product2 product = createProduct();
        insert product;

        Schema.Location location = [SELECT Id FROM Location WHERE Account__c =: account.Id];

        ProductItem pi = new ProductItem(
            Product2Id = product.Id,
            LocationId = location.Id,
            QuantityOnHand = 3
        );

        return pi;
    }

    public static Product_Asset_Patient_History__c createPAPH(Id assetId) {
        Product_Asset_Patient_History__c PAPH = new Product_Asset_Patient_History__c(
            Serialized_Item__c = assetId
        );

        return PAPH;
    }

    public static Account_Company__c createAccountCompany() {
        Account a = createPersonAccount();
        insert a;

        Account_Company__c accountCompany = new Account_Company__c(
            Payment_Terms__c = 'NL00',
            Account__c = a.Id,
            Company_Code__c = '6300'
        );

        return accountCompany;
    }

    public static ProductRequest createProductRequest(){
        ProductRequest pr = new ProductRequest();

        return pr;
    }

    public static ProductRequest createPickingListProductRequest(){
        RecordType pickingListRT = [SELECT Id FROM RecordType WHERE Name = 'ProductRequest_PickingList'];
        ProductRequest pr = new ProductRequest();
        pr.RecordTypeId = pickingListRT.Id;
        return pr;
    }

    public static ProductRequest createProductRequestExtraLoading(){
        RecordType extraLoadingRT = [SELECT Id FROM RecordType WHERE Name = 'ProductRequest_ExtraLoading'];

        ProductRequest pr = new ProductRequest(
            RecordTypeId = extraLoadingRT.Id
        );

        return pr;
    }

    public static ProductRequestLineItem createPRLI() {
        Product2 product = createProduct();
        insert product;

        ProductRequest pr = createProductRequest();
        pr.Status = '1';
        pr.Outbound_Delivery_Number__c = '12345';
        insert pr;

        ProductRequestLineItem PRLI = new ProductRequestLineItem(
            ParentId = pr.Id,
            Product2Id = product.Id,
            QuantityRequested = 3
        );

        return PRLI;
    }

    public static ProductRequestLineItem createPRLIExtraLoading() {
        Product2 product = createProduct();
        insert product;

        ProductRequest pr = createProductRequestExtraLoading();
        pr.Status = '1';
        pr.Outbound_Delivery_Number__c = '12345';
        insert pr;

        ProductRequestLineItem PRLI = new ProductRequestLineItem(
            ParentId = pr.Id,
            Product2Id = product.Id,
            QuantityRequested = 3
        );

        return PRLI;
    }

    public static EmailMessage createSentEmailMessage(Id relatedToId) {
        EmailMessage em = new EmailMessage(
            Incoming = false,
            RelatedToId = relatedToId
        );

        return em;
    }

    public static EmailMessage createIncomingEmailMessage(Id relatedToId) {
        EmailMessage em = new EmailMessage(
            Incoming = true,
            RelatedToId = relatedToId
        );

        return em;
    }

    public static Order createOrder() {
        Account a = createPersonAccount();
        insert a;

        Order o = new Order(
            AccountId = a.Id,
            EffectiveDate = Date.today(),
            Status = 'New'
        );

        return o;
    }

    public static Case createCase() {
        Case c = new Case();

        return c;
    }

    public static Quote__c createQuote() {
        Quote__c quote = new Quote__c();

        return quote;
    }

    public static Sales_Organization__c createSalesOrganization() {
        Sales_Organization__c so = new Sales_Organization__c();

        return so;
    }

    public static Account_Treatment_History__c createATH() {
        Account_Treatment_History__c ath = new Account_Treatment_History__c();

        return ath;
    }

    public static Account_Treatment_Address__c createATA(Account_Treatment__c accountTreatment) {
        Schema.Location location = createLocation();
        location.Account__c = accountTreatment.Account__c;
        insert location;

        Account_Treatment_Address__c ata = new Account_Treatment_Address__c(
            Account_Treatment__c = accountTreatment.Id,
            Account__c = accountTreatment.Account__c,
            Location__c = location.Id
        );

        return ata;
    }

    public static Contract_Treatment_Default_BOM__c createDefaultBOM(Id CTJPId, Id productId) {
        Contract_Treatment_Default_BOM__c defaultBOM = new Contract_Treatment_Default_BOM__c(
            Contract_Treatment_Job_Product__c = CTJPId,
            Product__c = productId
        );

        return defaultBOM;
    }

    public static Account_Tax_Classification__c createAccountTaxClassification(Account_Sales_Organization__c ASO) {
        Account_Tax_Classification__c ATC = new Account_Tax_Classification__c(
            Account_Sales_Organization__c = ASO.Id
        );

        return ATC;
    }

    public static Account_Treatment__c createAccountTreatmentWithJobFull() {
        Account a = createPersonAccount();
        insert a;

        Contract_Framework__c contractFramework = createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = createContractTreatmentJob(contractTreatment.Id);
        insert CTJ;

        Account_Treatment__c accountTreatment = createMRDAccountTreatment(a);
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
        insert accountTreatment;

        Account_Treatment_Job__c ATJ = createAccountTreatmentJob(accountTreatment.Id);
        ATJ.Contract_Treatment_Job__c = CTJ.Id;
        insert ATJ;

        return accountTreatment;
    }


    public static Callout_Logger__c initCalloutLogger() {
        Callout_Logger__c cl = new Callout_Logger__c(); 

        return cl;
    }

    public static QuestionnaireSection__c initQuestionnaireSection(Questionnaire__c inputQuestionnaire) {
        QuestionnaireSection__c q = new QuestionnaireSection__c();
        q.Questionnaire__c = inputQuestionnaire.Id;
        q.Order_Number__c = 1;
        q.Name = 'Test QuestionnaireSection';
        return q;
    }

    
    public static Question__c initQuestion(Questionnaire__c inputQuestionnaire, QuestionnaireSection__c inputQuestionnaireSection) {
        Question__c q = new Question__c();
        q.Questionnaire__c = inputQuestionnaire.Id;
        q.QuestionnaireSection__c = inputQuestionnaireSection.Id;
        return q;
    }

    public static QuestionChoice__c initQuestionChoice(Question__c inputQuestion, Question__c inputNextQuestion) {
        QuestionChoice__c q = new QuestionChoice__c();
        q.Name = 'Test QuestionChoice';
        q.Question__c = inputQuestion.Id;
        if (inputNextQuestion != null){
            q.NextQuestion__c = inputNextQuestion.Id;
        }
        return q;
    }

    public static ProductItem initProductItem(Product2 p, Schema.Location loc) {
        ProductItem pi = new ProductItem(
            Product2Id = p.Id,
            LocationId = loc.Id,
            QuantityOnHand = 3
        );
        return pi;
    }

    public static Company__c initCompany(){
        Company__c company = new Company__c();
        company.Company_Code__c = '6400';
        return company;
    } 

    public static Merit_Policy_Header__c initMeritPolicyHeader(Company__c inputCompany){
        Merit_Policy_Header__c mph = new Merit_Policy_Header__c();
        mph.Company__c = inputCompany.Id;
        mph.Year__c = '2020';
        return mph;
    } 

    public static Employee__c initEmployee(Company__c inputCompany){
        Employee__c employee = new Employee__c();
        employee.Company__c = inputCompany.Id;
        employee.Employee_Code__c = '0578931';
        employee.Status__c = 'A';
        return employee;
    } 

    public static Annual_Budget__c initAnnualBudget(Company__c inputCompany){
        Annual_Budget__c budget = new Annual_Budget__c();
        budget.Company__c = inputCompany.Id;
        budget.Year__c = '2020';
        return budget;
    } 

    public static Contract_Treatment_Modality__c createContractTreatmentModality(Contract_Treatment__c contractTreatment) {
        Contract_Treatment_Modality__c ctm = new Contract_Treatment_Modality__c(
            Contract_Treatment__c = contractTreatment.Id
        );

        return ctm;
    }
}