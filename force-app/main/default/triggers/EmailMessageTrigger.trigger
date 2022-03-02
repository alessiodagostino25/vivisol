trigger EmailMessageTrigger on EmailMessage (after insert, before insert) {
    List<Id> relatedToIdsSend = new List<Id>();
    List<EmailMessage> sendingMails = new List<EmailMessage>();
    List<EmailMessage> toCreateTask = new List<EmailMessage>();
    List<EmailMessage> toUpdateTask = new List<EmailMessage>();
    List<EmailMessage> toCreateTaskNoRef = new List<EmailMessage>();

    for(EmailMessage em : Trigger.new) {
        System.debug('RelatedToId: ' + em.RelatedToId);
        if(Trigger.isAfter) {
            if(em.Incoming == false) {
                toUpdateTask.add(em);
            }
        }
        if(Trigger.isBefore) {
            if(em.Incoming == false && em.ParentId == null && em.RelatedToId != null) {
                sendingMails.add(em);
                relatedToIdsSend.add(em.RelatedToId);
            }
            
            else if(em.Incoming == true) {
                System.debug('Incoming è true');
                if(em.TextBody.contains('ref_id::')) {
                    System.debug('Contiene ref');
                    toCreateTask.add(em); 
                }
                else if(!em.TextBody.contains('ref_id::')) {
                    System.debug('Non contiene ref');
                    toCreateTaskNoRef.add(em);
                }
                else {
                    System.debug('Non entra da nessuna parte');
                }
            }
        }
    }

    //If email is received, I need to update the RelatedToId with the Id of the order, coming from the template in "ref:{id}" and create a new Task

    if(!toCreateTask.isEmpty()) {
        EmailMessageService.updateAndCreateTasks(toCreateTask);
    }

    // This will be called from here for the messages without ref, and from updateAndCreateTasks if the ref isn't of an Order or a Quote
    if(!toCreateTaskNoRef.isEmpty()) {
        EmailMessageService.updateAndCreateTasksNoRef(toCreateTaskNoRef);
    }

    if(!toUpdateTask.isEmpty()) {
        EmailMessageService.updateTasks(toUpdateTask);
    }

    //If email is sent, I need to update the ParentId with the Id of the related Case

    if(!relatedToIdsSend.isEmpty()) {
        EmailMessageService.updateCaseParentId(relatedToIdsSend, sendingMails);
    }
}