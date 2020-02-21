@IsTest
private class WarehouseCalloutServiceTest {
    
    @isTest static void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

        Test.startTest();
            WarehouseCalloutService.runWarehouseEquipmentSync();
        Test.stopTest();
        
        System.assertEquals([SELECT Id FROM Product2].size(), 2, 'Error');
    }

}