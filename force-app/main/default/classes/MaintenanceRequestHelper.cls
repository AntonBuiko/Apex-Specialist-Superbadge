public with sharing class MaintenanceRequestHelper {
    
    public static void beforeUpdate(){
        updateWorkOrders();
    }

    public static void updateWorkOrders() {
        Map<Id, Case> mapRepairRoutineCases = getMapOldCaseToNew(Trigger.new);
        List<Work_Part__c> lsWorkParts = getWorkPartForCases(mapRepairRoutineCases.keySet());
        System.debug('lsWorkParts ----> ' + lsWorkParts);
        Map<Id, List<Decimal>> mapCaseIdToMaintenanceCycle = getMapCaseIdToMaintenanceCycle(lsWorkParts);
        if (mapCaseIdToMaintenanceCycle.size() > 0) {     
            for (Id caseId : mapRepairRoutineCases.keySet()) {
                List<Decimal> lsDays = mapCaseIdToMaintenanceCycle.get(caseId);
                lsDays.sort();
                Case newCase = mapRepairRoutineCases.get(caseId);
                Integer intDays = (Integer)lsDays[0];
                newCase.Date_Due__c = Date.today().addDays(intDays);
            }
        }
        insert mapRepairRoutineCases.values();
    }
    
    private static Map<Id, Case> getMapOldCaseToNew(List<Case> listCs){
        Map<Id, Case> newCases = new Map<Id, Case>();
        for (Case theCase : listCs) {
            System.debug('theCase ---> ' + theCase);
            if (theCase.Status == MaintenanceRequestService.CASE_STATUS_CLOSED && isRepairOrRoutine(theCase)) {
                newCases.put(theCase.Id, generateRepairOrRoutineCase(theCase));
            }
        }
        System.debug('newCases ----> ' +  newCases);
        return newCases;
    }

    private static Case generateRepairOrRoutineCase(Case theCase){
        Case newCase = theCase.clone(false, true, false, false);
        newCase.Type = MaintenanceRequestService.CASE_TYPE_ROUTINE_MAINTENANCE;
        newCase.Status = MaintenanceRequestService.CASE_STATUS_NEW;
        newCase.Date_Reported__c = Date.today();
        return newCase;
    }

    private static Boolean isRepairOrRoutine(Case theCase){
        return (theCase.Type == MaintenanceRequestService.CASE_TYPE_REPAIR 
            || theCase.Type == MaintenanceRequestService.CASE_TYPE_ROUTINE_MAINTENANCE) ? true : false;
    }

    private static Map<Id, List<Decimal>> getMapCaseIdToMaintenanceCycle(List<Work_Part__c> lsWorkPart){
        Map<Id, List<Decimal>> mapCaseIdtoMaintenanceCycle = new Map<Id, List<Decimal>>();
        for (Work_Part__c workPart : lsWorkPart) {
            if (workPart.Equipment__r != null && workPart.Equipment__r.Maintenance_Cycle__c != null) {
                Id caseId = workPart.Maintenance_Request__c;
                List<Decimal> dueDays = new List<Decimal>();    
                    if (mapCaseIdtoMaintenanceCycle.containsKey(workPart.Maintenance_Request__c)) {
                        dueDays = mapCaseIdtoMaintenanceCycle.get(caseId);
                    }
                dueDays.add(workPart.Equipment__r.Maintenance_Cycle__c);
                mapCaseIdtoMaintenanceCycle.put(caseId, dueDays);
            }
        }
        System.debug('mapCaseIdtoMaintenanceCycle ---> ' + mapCaseIdtoMaintenanceCycle);
        return mapCaseIdtoMaintenanceCycle; 
    }

    private static List<Work_Part__c> getWorkPartForCases(Set<Id> caseIds){
        return [
            SELECT Id, Maintenance_Request__c, Equipment__c, Equipment__r.Maintenance_Cycle__c
            FROM Work_Part__c 
            WHERE Maintenance_Request__c IN :caseIds
        ];
    }
}