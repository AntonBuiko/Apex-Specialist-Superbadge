trigger MaintenanceRequest on Case (before update, after update) {
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            MaintenanceRequestHelper.beforeUpdate();
        }
    }
}