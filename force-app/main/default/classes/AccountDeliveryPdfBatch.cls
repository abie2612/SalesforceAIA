global class AccountDeliveryPdfBatch implements Database.Batchable<sObject>, Database.Stateful {
    private Set<Id> opportunityIds;
    private List<ContentDocument> contentDocumentList;
    private Map<Id, List<Id>> oppIdWithConDocumenMap;
    private List<Opportunity> opportunitiesToUpdate;

    private static final String US_MARKETPLACE = 'US';
    private static final String UK_MARKETPLACE = 'UK';
    private static final String DELIVERY_STAGE = 'Delivery';
    private static final String PDF_TITLE_PREFIX = 'CUSTOPP%Account Delivery Pdf';

    public AccountDeliveryPdfBatch(Set<Id> opportunityIds, Map<Id, List<Id>> oppIdWithConDocumenMap) {
        this.opportunityIds = opportunityIds;
        this.oppIdWithConDocumenMap = oppIdWithConDocumenMap;
        this.contentDocumentList = new List<ContentDocument>();
        this.opportunitiesToUpdate = new List<Opportunity>();
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString = 'SELECT Id, Name, StageName, Opportunity_Number_Text__c, Marketplace__c FROM Opportunity';
        if (!opportunityIds.isEmpty()) {
            queryString += ' WHERE Id IN :opportunityIds';
        }
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> opportunityList) {
        // Collect all ContentDocument IDs to query in bulk
        Set<Id> allContentDocIds = new Set<Id>();
        for (Opportunity opp : opportunityList) {
            System.debug('oppIdWithConDocumenMap '+oppIdWithConDocumenMap);
            System.debug('opp '+opp.Id);
            if (oppIdWithConDocumenMap.containsKey(opp.Id)) {
                allContentDocIds.addAll(oppIdWithConDocumenMap.get(opp.Id));
            }
        }

        // Query all ContentDocuments in bulk
        Map<Id, List<ContentDocument>> contentDocumentsMap = new Map<Id, List<ContentDocument>>();
        if (!allContentDocIds.isEmpty()) {
            for (ContentDocument contentDocument : [
                SELECT Id, Title FROM ContentDocument 
                WHERE Id IN :allContentDocIds AND Title LIKE :PDF_TITLE_PREFIX
            ]) {
                if (!contentDocumentsMap.containsKey(contentDocument.Id)) {
                    contentDocumentsMap.put(contentDocument.Id, new List<ContentDocument>());
                }
                contentDocumentsMap.get(contentDocument.Id).add(contentDocument);
            }
        }

        // Process each opportunity
        for (Opportunity opp : opportunityList) {
            processOpportunity(opp, contentDocumentsMap);
        }
    }

    private void processOpportunity(Opportunity opp, Map<Id, List<ContentDocument>> contentDocumentsMap) {
        PageReference pdfPage;
        String titleName;

        if (String.isNotBlank(opp.Marketplace__c)) {
            if (opp.Marketplace__c == US_MARKETPLACE) {
                pdfPage = Page.USAccountDeliveryPdf;
                titleName = opp.Opportunity_Number_Text__c + '- US Account Delivery Pdf';
            } else if (opp.Marketplace__c == UK_MARKETPLACE) {
                pdfPage = Page.UKAccountDeliveryPdf;
                titleName = opp.Opportunity_Number_Text__c + '- UK Account Delivery Pdf';
            } else {
                return; // Skip if marketplace is not US or UK
            }
        } else {
            return; // Skip if marketplace is blank
        }
        updateContentDocuments(opp, contentDocumentsMap);
        if (DELIVERY_STAGE.equals(opp.StageName) && pdfPage != null && String.isNotBlank(titleName)) {
            createPDF(opp.Id, pdfPage, titleName);
            opportunitiesToUpdate.add(new Opportunity(Id = opp.Id, Delivery_PDF_Generated__c = false));
        }
    }

    private void updateContentDocuments(Opportunity opp, Map<Id, List<ContentDocument>> contentDocumentsMap) {
        List<Id> contentDocIds = oppIdWithConDocumenMap.get(opp.Id);
        if (contentDocIds != null && !contentDocIds.isEmpty()) {
            for (Id contentDocId : contentDocIds) {
                List<ContentDocument> contentDocs = contentDocumentsMap.get(contentDocId);
                if (contentDocs != null) {
                    for (ContentDocument contentDocument : contentDocs) {
                        contentDocument.Title += '_null_' + contentDocIds.size();
                        contentDocumentList.add(contentDocument);
                    }
                }
            }
        }

        if (!contentDocumentList.isEmpty()) {
            update contentDocumentList;
        }
    }

    global void finish(Database.BatchableContext BC) {
        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
        }
    }

    public static void createPDF(String recId, PageReference pdfPage, String titleName) {
        pdfPage.getParameters().put('id', recId);
        ContentVersion cv = new ContentVersion();
        cv.Title = titleName;
        cv.PathOnClient = 'AccountDelivery.pdf';
        cv.VersionData = !Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('Test content');
        insert cv;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
        cdl.ShareType = 'V';
        cdl.LinkedEntityId = recId;
        insert cdl;
    }
}