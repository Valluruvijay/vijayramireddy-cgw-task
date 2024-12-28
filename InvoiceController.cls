public with sharing class InvoiceController {
    @AuraEnabled(cacheable=true)
    public static String getJsonForXero(String originRecordId) {
        system.debug('222222'+originRecordId);
        Opportunity opp = [SELECT Id, Name, Account.Name, CloseDate,Due_Date__c, 
                           (SELECT Id,Quantity, UnitPrice 
                            FROM OpportunityLineItems) 
                           FROM Opportunity 
                           WHERE Id =:originRecordId];
        

        Map<String, Object> invoiceJson = new Map<String, Object>();
        invoiceJson.put('Type', 'ACCREC');
        //invoiceJson.put('Contact', new Map<String, String>{'ContactID' => '00000000-0000-0000-0000-000000000000'});
        invoiceJson.put('Date', opp.CloseDate.format());
        invoiceJson.put('DueDate', opp.Due_Date__c.format());
        
        List<Map<String, Object>> lineItems = new List<Map<String, Object>>();
        for (OpportunityLineItem oli : opp.OpportunityLineItems) {
            Map<String, Object> lineItem = new Map<String, Object>();
            lineItem.put('Description', opp.Name);
            lineItem.put('Quantity', oli.Quantity);
            lineItem.put('UnitAmount', oli.UnitPrice);
            lineItems.add(lineItem);
        }
        invoiceJson.put('LineItems', lineItems);
            system.debug('json.serailize'+JSON.serialize(invoiceJson));
        return JSON.serialize(invoiceJson);
    }
    
    @AuraEnabled
    public static String createInvoice(String originRecordId, String invoiceDueDate,String requiredQuantity) {
        Opportunity opp = [SELECT Id, Name, Account.Name, AccountId, CloseDate,Due_Date__c, 
                           (SELECT Id, Product2.Name, Quantity, UnitPrice 
                            FROM OpportunityLineItems) 
                           FROM Opportunity 
                           WHERE Id = :originRecordId];

        Invoice__c newInvoice = new Invoice__c(
            Account__c = opp.AccountId,
            Invoice_Date__c = opp.CloseDate,
            Due_Date__c = opp.Due_Date__c,
            invoice_Reference__c= 'opportunity'
        );
        insert newInvoice;

        List<Line_Item__c> lineItems = new List<Line_Item__c>();
        for (OpportunityLineItem oli : opp.OpportunityLineItems) {
            Line_Item__c li = new Line_Item__c(
                Invoice__c = newInvoice.Id,
                Description__c = opp.Name,
                Quantity__c = Integer.valueOf(requiredQuantity),
                Unit_Price__c = oli.UnitPrice
                
            );
            lineItems.add(li);
        }
        insert lineItems;

        return newInvoice.Id;
    }
}