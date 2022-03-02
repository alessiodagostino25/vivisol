public class EmailMessageService {

    public static void updateAndCreateTasks(List<EmailMessage> emails) {
        System.debug('In updateAndCreateTasks');
        Map<Id, Task> taskMap = new Map<Id, Task>();
        List<Task> tasksToInsert = new List<Task>();
        List<Id> parentIds = new List<Id>();
        List<Id> caseIds = new List<Id>();
        List<Order> ordersRelatedToCases = new List<Order>();
        List<Quote__c> quotesRelatedToCases = new List<Quote__c>();
        List<String> queryFields = new List<String>{'Id', 'Case__c'};
        Map<Id, List<Id>> orderIdsMap = new Map<Id, List<Id>>();
        Map<Id, List<Id>> quoteIdsMap = new Map<Id, List<Id>>();
        List<EmailMessage> toUpdate = new List<EmailMessage>();
        List<EmailMessage> withOtherRef = new List<EmailMessage>();
        List<String> queryFieldsForCase = new List<String>{'AccountId', 'ContactId', 'Email2Case__c'};

        for(EmailMessage em : emails) {
            caseIds.add(em.ParentId);
        }

        ordersRelatedToCases = OrderDAO.getOrdersFromCases(queryFields, caseIds);
        quotesRelatedToCases = QuoteDAO.getQuotesFromCases(queryFields, caseIds);

        // Building maps to access, given EmailMessage.ParentId(i.e. a Case Id), the list of Orders/Quotes Ids associated to the case related to the EmailMessage
        if(!ordersRelatedToCases.isEmpty()) {
            for(Order order : ordersRelatedToCases) {
                if(orderIdsMap.get(order.Case__c) == null) {
                    orderIdsMap.put(order.Case__c, new List<Id>());
                }
                orderIdsMap.get(order.Case__c).add(order.Id);
            }
        }

        if(!quotesRelatedToCases.isEmpty()) {
            for(Quote__c quote : quotesRelatedToCases) {
                if(quoteIdsMap.get(quote.Case__c) == null) {
                    quoteIdsMap.put(quote.Case__c, new List<Id>());
                }
                quoteIdsMap.get(quote.Case__c).add(quote.Id);
            }
        }

        for(EmailMessage em : emails) {
            Id parentId = em.ParentId;
            if(parentId.getSObjectType().getDescribe().getName() == 'Case') {
                parentIds.add(em.ParentId);
            }
        }

        List<Case> relatedCases = CaseDAO.getCasesFromIds(queryFieldsForCase, parentIds);
        Map<Id, Case> caseMap = new Map<Id, Case>();

        for(Case c : relatedCases) {
            caseMap.put(c.Id, c);
        }

        for(EmailMessage em : emails) {
            Integer index = em.TextBody.indexOf('ref_id::');
            System.debug('Index: ' + index);
            String refId = em.TextBody.substring(index + 8, index + 26);

            List<Id> ordersRelatedToCase = orderIdsMap.get(em.ParentId);
            List<Id> quotesRelatedToCase = quoteIdsMap.get(em.ParentId);
            System.debug('refId: ' + refId);

            // If the Id in ref:{} is of an Order ora a Quote related to the Case related to the EmailMessage(via em.ParentId)
            if((ordersRelatedToCase != null && quotesRelatedToCase != null && (ordersRelatedToCase.contains(refId) || quotesRelatedToCase.contains(refId))) || 
            (ordersRelatedToCase == null && quotesRelatedToCase != null && quotesRelatedToCase.contains(refId)) ||
            (ordersRelatedToCase != null && quotesRelatedToCase == null && ordersRelatedToCase.contains(refId))) { 
                    
                System.debug('em.ParentId: ' + em.ParentId);
                System.debug('Contains order or quote id');
                em.RelatedToId = refId;
                System.debug('em.RelatedToId: ' + em.RelatedToId);
                DateTime toConvert = em.MessageDate;
                Date convertedDate = date.newinstance(toConvert.year(), toConvert.month(), toConvert.day());
                Case relatedCase = caseMap.get(em.ParentId);

                // Updating Email2Case__c on relatedCase

                relatedCase.Email2Case__c = em.ToAddress;

                //Creating a new Task for each incoming email
                String ccAddress = em.CcAddress;
                String bccAddress = em.BccAddress;
                String textBody = em.TextBody;

                if(em.CcAddress == null) {
                    ccAddress = '';
                }
                if(em.BccAddress == null) {
                    bccAddress = '';
                }
                if(em.TextBody == null) {
                    textBody = '';
                }
                
                Task newTask = new Task(
                    WhoId = relatedCase.ContactId,
                    ActivityDate = convertedDate,
                    Description = 'To: ' + em.ToAddress + '\n' +
                    'CC: ' +ccAddress + '\n' +
                    'BCC: ' + bccAddress + '\n' +
                    'Subject: ' + em.Subject + '\n' +
                    'Body: ' + textBody,
                    Priority = 'Normal',
                    Status = 'Completed',
                    Subject = 'Email: ' + em.Subject,
                    TaskSubtype = 'Email',
                    WhatId = refId,
                    Type__c = 'Email',
                    Account__c = relatedCase.AccountId
                );
    
                tasksToInsert.add(newTask);
                taskMap.put(em.Id, newTask);
                toUpdate.add(em);
                
            }
            else {
                System.debug('Non contenuto!!');
                withOtherRef.add(em);
            }
            
        }

        //Inserting new tasks and updating EmailMessage's ActivityId
    
        if(!tasksToInsert.isEmpty()) {
            insert tasksToInsert;

            for(EmailMessage em : toUpdate) {
                Task relatedTask = taskMap.get(em.Id);
                em.ActivityId = relatedTask.Id;
            }
        }

        if(!relatedCases.isEmpty()) {
            update relatedCases;
        }

        // If has a ref but it's not an Order or a Quote Id, act the same as if there was no ref in the EmailMessage
        
        if(!withOtherRef.isEmpty()) {
            updateAndCreateTasksNoRef(withOtherRef);
        }

    }

    public static void updateAndCreateTasksNoRef(List<EmailMessage> emailMessages) {
        List<Task> tasksToInsert = new List<Task>();
        Map<Id, Task> taskMap = new Map<Id, Task>();
        List<Id> parentIds = new List<Id>();
        List<String> queryFieldsForCase = new List<String>{'AccountId', 'ContactId', 'Email2Case__c'};

        for(EmailMessage em : emailMessages) {
            parentIds.add(em.ParentId);
        }

        List<Case> relatedCases = CaseDAO.getCasesFromIds(queryFieldsForCase, parentIds);
        Map<Id, Case> caseMap = new Map<Id, Case>();

        for(Case c : relatedCases) {
            caseMap.put(c.Id, c);
        }

        for(EmailMessage em : emailMessages) {

            DateTime toConvert = em.MessageDate;
            Date convertedDate = date.newinstance(toConvert.year(), toConvert.month(), toConvert.day());
            Case relatedCase = caseMap.get(em.ParentId);

            // Updating Email2Case__c on relatedCase

            relatedCase.Email2Case__c = em.ToAddress;

            Task newTask = new Task(
                    WhoId = relatedCase.ContactId,
                    ActivityDate = convertedDate,
                    Description = 'To: ' + em.ToAddress + '\n' +
                    'CC: ' + em.CcAddress + '\n' +
                    'BCC: ' + em.BccAddress + '\n' +
                    'Subject: ' + em.Subject + '\n' +
                    'Body: ' + em.TextBody,
                    Priority = 'Normal',
                    Status = 'Completed',
                    Subject = 'Email: ' + em.Subject,
                    TaskSubtype = 'Email',
                    WhatId = em.ParentId,
                    Type__c = 'Email',
                    Account__c = relatedCase.AccountId
                );

                tasksToInsert.add(newTask);
                taskMap.put(em.Id, newTask);
        }

        if(!tasksToInsert.isEmpty()) {
            insert tasksToInsert;

            for(EmailMessage em : emailMessages) {
                Task relatedTask = taskMap.get(em.Id);
                em.ActivityId = relatedTask.Id;
            }
        }

        if(!relatedCases.isEmpty()) {
            update relatedCases;
        }
    }

    public static void updateTasks(List<EmailMessage> emailMessages) {
        List<Id> taskIds = new List<Id>();
        List<String> queryFields = new List<String>{'AccountId', 'TaskSubtype', 'Account__c', 'Type__c'};

        for(EmailMessage em : emailMessages) {
            taskIds.add(em.ActivityId);
            System.debug('ActivityId: ' + em.ActivityId);
        }
        List<Task> relatedTasks = TaskDAO.getTasksFromIds(queryFields, taskIds);

        for(Task t : relatedTasks) {
            System.debug('Task.AccountId: ' + t.AccountId);
            System.debug('Task.TaskSubtype: ' + t.TaskSubtype);
            t.Account__c = t.AccountId;
            t.Type__c = t.TaskSubtype;
        }

        update relatedTasks;
    }

    public static void updateCaseParentId(List<Id> relatedToIdsSend, List<EmailMessage> sendingMails) {

        List<String> queryFields = new List<String>{'Case__c'};
        List<String> workOrderQueryFields = new List<String>{'CaseId'};
        List<String> serviceAppointmentQueryFields = new List<String>{'ParentRecordId'};
        List<Id> orderIds = new List<Id>();
        List<Id> quoteIds = new List<Id>();
        List<String> workOrderIds = new List<String>();
        List<String> serviceAppointmentIds = new List<String>();
        List<Order> orders = new List<Order>();
        List<Quote__c> quotes = new List<Quote__c>();
        List<WorkOrder> workOrders = new List<WorkOrder>();
        List<ServiceAppointment> serviceAppointments = new List<ServiceAppointment>();
        Map<Id, EmailMessage> emailMessageMap = new Map<Id, EmailMessage>();
        Map<String, WorkOrder> workOrderMap = new Map<String, WorkOrder>();

        for(EmailMessage em : sendingMails) {
            emailMessageMap.put(em.RelatedToId, em);
        }

        // Checking whether the RelatedToId is the Id of an Order or a Quote__c
        for(Id i : relatedToIdsSend) {
            String objectName = i.getSObjectType().getDescribe().getName();

            if(objectName == 'Order') {
                orderIds.add(i);
            }
            else if (objectName == 'Quote__c') {
                quoteIds.add(i);
            }
            else if(objectName == 'WorkOrder') {
                workOrderIds.add(i);
            }
            else if(objectName == 'ServiceAppointment') {
                serviceAppointmentIds.add(i);
            }
        }

        // Retrieving the related Orders and Quotes
        if(!orderIds.isEmpty()) {
            orders = OrderDAO.getOrdersFromIds(queryFields, orderIds);
        }

        if(!quoteIds.isEmpty()) {
            quotes = QuoteDAO.getQuotesFromIds(queryFields, quoteIds);
        }
        
        if(!workOrderIds.isEmpty()) {
            workOrders = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, workOrderIds);
        }

        if(!serviceAppointmentIds.isEmpty()) {
            serviceAppointments = ServiceAppointmentDAO.getSAsFromIds(serviceAppointmentQueryFields, serviceAppointmentIds);

            if(!serviceAppointments.isEmpty()) {
                for(ServiceAppointment sa : serviceAppointments) {
                    workOrderIds.add(sa.ParentRecordId);
                }

                if(!workOrderIds.isEmpty()) {
                    List<WorkOrder> workOrdersTmp = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, workOrderIds);

                    if(workOrdersTmp != null) {
                        for(WorkOrder wo : workOrdersTmp) {
                            workOrderMap.put(wo.Id, wo);
                        }
                    }
                }
            }
        }

        // Updating the ParentId of the related EmailMessages

        for(Order o : orders) {
            EmailMessage em = emailMessageMap.get(o.Id);
            em.ParentId = o.Case__c;
        }

        for(Quote__c q : quotes) {
            EmailMessage em = emailMessageMap.get(q.Id);
            em.ParentId = q.Case__c;
        }

        for(WorkOrder wo : workOrders) {
            EmailMessage em = emailMessageMap.get(wo.Id);
            em.ParentId = wo.CaseId;
        }

        for(ServiceAppointment sa : serviceAppointments) {
            WorkOrder relatedWorkOrder = workOrderMap.get(sa.ParentRecordId);
            EmailMessage relatedEmailMessage = emailMessageMap.get(sa.Id);

            if(relatedEmailMessage != null && relatedWorkOrder != null) {
                relatedEmailMessage.ParentId = relatedWorkOrder.CaseId;
            }  
        }
    }
}