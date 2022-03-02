public with sharing class ServiceAppointmentDAO {
    
    public static List<ServiceAppointment> getNoneSAsFromParentIds(List<String> queryFields, List<Id> parentIds) {
		String query = 'SELECT ';
		for(Integer i = 0; i < queryFields.size(); i++) {
			query += queryFields[i] + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM ServiceAppointment WHERE ParentRecordId IN: parentIds AND Status = \'None\'';
		System.debug('getNoneSAsFromParentIds QUERY: ' + query);
		
		return Database.query(query);
	}

	public static List<ServiceAppointment> getNoneAndNewSAsFromParentIds(List<String> queryFields, List<Id> parentIds) {
		String query = 'SELECT ';
		for(Integer i = 0; i < queryFields.size(); i++) {
			query += queryFields[i] + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM ServiceAppointment WHERE ParentRecordId IN: parentIds AND (Status = \'None\' OR Status = \'New\')';
		System.debug('getNoneAndNewSAsFromParentIds QUERY: ' + query);
		
		return Database.query(query);
	}

	public static List<ServiceAppointment> getAllSAsFromParentIds(List<String> queryFields, List<Id> parentIds) {
		String query = 'SELECT ';
		for(Integer i = 0; i < queryFields.size(); i++) {
			query += queryFields[i] + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM ServiceAppointment WHERE ParentRecordId IN: parentIds';
		System.debug('getSAsFromParentIds QUERY: ' + query);
		
		return Database.query(query);
	}

	public static List<ServiceAppointment> getSAsFromIds(List<String> queryFields, List<Id> relatedIds) {
		String query = 'SELECT ';
		for(Integer i = 0; i < queryFields.size(); i++) {
			query += queryFields[i] + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM ServiceAppointment WHERE Id IN: relatedIds'; 
		System.debug('getSAsFromIds QUERY: ' + query);
		
		return Database.query(query);
    }

	public static List<ServiceAppointment> getNotCanceledSAsFromParentIds(List<String> queryFields, List<String> parentIds) {
		String query = 'SELECT ';
		for(Integer i = 0; i < queryFields.size(); i++) {
			query += queryFields[i] + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM ServiceAppointment WHERE ParentRecordId IN: parentIds AND Status != \'Canceled\''; 
		System.debug('getNotCanceledSAsFromParentIds QUERY: ' + query);
		
		return Database.query(query);
    }
    
}