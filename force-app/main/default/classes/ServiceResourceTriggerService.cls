public class ServiceResourceTriggerService {
    
    public static void validateServiceResources(List<ServiceResource> serviceResources) {
        List<String> serviceResourceQueryFields = new List<String>{'NextLocation__c'};

        String nextLocationErrorLabel = Label.ServiceResource_NextLocationError;
        List<String> nextLocationIds = new List<String>();
        List<String> serviceResourceIds = new List<String>();

        Map<String, List<ServiceResource>> nextLocationToSRsMap = new Map<String, List<ServiceResource>>();

        for(ServiceResource sr : serviceResources) {
            nextLocationIds.add(sr.NextLocation__c);

            // This is also used in before insert, Id could not exist

            if(sr.Id != null) {
                serviceResourceIds.add(sr.Id);
            }
        }

        List<ServiceResource> sameNextLocations = ServiceResourceDAO.getServiceResourcesFromNextLocationIds(serviceResourceQueryFields, nextLocationIds);

        System.debug('sameNextLocations: ' + sameNextLocations);

        if(sameNextLocations != null && !sameNextLocations.isEmpty()) {
            for(ServiceResource sr : sameNextLocations) {
                if(nextLocationToSRsMap.get(sr.NextLocation__c) == null) {
                    nextLocationToSRsMap.put(sr.NextLocation__c, new List<ServiceResource>());
                }
                nextLocationToSRsMap.get(sr.NextLocation__c).add(sr);
            }

            if(serviceResourceIds.isEmpty()) {
                for(ServiceResource sr : serviceResources) {
                    List<ServiceResource> duplicateSRs = nextLocationToSRsMap.get(sr.NextLocation__c);

                    if(duplicateSRs != null && !duplicateSRs.isEmpty()) {
                        sr.addError(nextLocationErrorLabel);
                    }
                }
            }
            else {
                for(ServiceResource sr : serviceResources) {
                    List<ServiceResource> duplicateSRs = nextLocationToSRsMap.get(sr.NextLocation__c);
                    System.debug('duplicateSRs: ' + duplicateSRs);

                    if(duplicateSRs != null && !duplicateSRs.isEmpty()) {
                        if(sr.Id != null) {
                            for(ServiceResource duplicateSR : duplicateSRs) {
                                if(duplicateSR.Id != sr.Id) {
                                    sr.addError(nextLocationErrorLabel);
                                    break;
                                }
                            }
                        }
                        else {
                            sr.addError(nextLocationErrorLabel);
                        }
                    }
                }
            }
        }
    }
}