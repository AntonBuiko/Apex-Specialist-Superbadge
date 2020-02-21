public with sharing class WarehouseCalloutService {

    public class EquipmentWrapper {
        public String id;
        public Boolean replacement;
        public Integer quantity;
        public String name;
        public Integer maintenanceperiod;
        public Integer lifespan;
        public Integer cost;
        public String sku;
    }

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    @future(callout = true)
    public static void runWarehouseEquipmentSync() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setHeader('Content-type', 'application/json');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            Map<String, EquipmentWrapper> mapSkuToEquipment = getMapSkuToEquipment(response);
            List<Product2> lsEquipment = new List<Product2>();
            for (EquipmentWrapper equipmentWrapper : mapSkuToEquipment.values()) {
                Product2 equipment = new Product2();
                generateEquipment(equipment, equipmentWrapper);
                lsEquipment.add(equipment);
            }
            if (lsEquipment.size() > 0) {   
                upsert lsEquipment;
            }
        }
    }

    private static Map<String,EquipmentWrapper> getMapSkuToEquipment(HttpResponse response){
        Map<String,EquipmentWrapper> mapSkuToEquipment = new Map<String,EquipmentWrapper>();
        List<EquipmentWrapper> results =  (List<EquipmentWrapper>)JSON.deserializeStrict(response.getBody().replaceAll('_id', 'id'),                
            List<EquipmentWrapper>.class); 
        for (EquipmentWrapper equipment : results) {
            mapSkuToEquipment.put(equipment.sku, equipment);
        }
        return mapSkuToEquipment;
    }
    
    private static void generateEquipment(Product2 equipment, EquipmentWrapper equipmentWrapper){
        equipment.Warehouse_SKU__c = equipmentWrapper.sku;
        equipment.Replacement_Part__c = true;
        equipment.Current_Inventory__c = equipmentWrapper.quantity;
        equipment.Name = equipmentWrapper.name;
        equipment.Maintenance_Cycle__c = equipmentWrapper.maintenanceperiod;
        equipment.Lifespan_Months__c = equipmentWrapper.lifespan;
        equipment.Cost__c = equipmentWrapper.cost;
    }

    
}