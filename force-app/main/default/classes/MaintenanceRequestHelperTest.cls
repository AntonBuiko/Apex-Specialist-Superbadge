@isTest
public with sharing class MaintenanceRequestHelperTest {
    public static final String TEST_SUBJECT = 'Test subject';
    public static final String TEST_EQUIPMENT_NAME = 'Equipment 1';
    
    @isTest static void createCaseFromClosedCase(){

        Vehicle__c vehicle = new Vehicle__c(
            Name = 'Test vehicle'
        );
        insert vehicle;

        List<Case> lsCases = new List<Case>();
        Case cs = new Case(
            Status = MaintenanceRequestService.CASE_STATUS_CLOSED,
            Type = MaintenanceRequestService.CASE_TYPE_ROUTINE_MAINTENANCE,
            Subject = TEST_SUBJECT,
            Vehicle__c = vehicle.Id
        );
        lsCases.add(cs);

        insert lsCases;

        Case theCase = [SELECT Id, Type, Subject, Status FROM Case LIMIT 1];

        Product2 equipment = new Product2(
            Name = TEST_EQUIPMENT_NAME,
            Cost__c = 1,
            IsActive = true,
            Description = TEST_SUBJECT,
            Replacement_Part__c = true,
            Maintenance_Cycle__c = 10
        );
        
        insert equipment;
        
        Product2 newEquipt = [SELECT Id FROM Product2];

        Work_Part__c workPart = new Work_Part__c(
            Maintenance_Request__c = theCase.Id,
            Equipment__c = newEquipt.Id
        );

        insert workPart;

        Work_Part__c workPart2 = new Work_Part__c(
            Maintenance_Request__c = theCase.Id,
            Equipment__c = newEquipt.Id
        );

        insert workPart2;


        theCase.Status = MaintenanceRequestService.CASE_STATUS_CLOSED;
        
        update theCase;


        System.assertEquals([SELECT Id FROM Case].size(), 2, 'The second case is not created');
    }

}
