public class DNPageController {
    public List<DNWrapper> directoryNumbersList {get; set;}
    public String directoryName {get; set;}
    public String directoryPhone {get; set;}
    public String directoryDescription {get; set;}
    public String directorySearch{get;set;}
    public Integer limitNumber{get;set;}    
    public Integer totalPageNumber{get;set;} 
    public Integer currPageNumber{get;set;} 
    public String arrowName{get;set;} 
    public String arrowPhone{get;set;} 
    public String arrowDescription{get;set;} 
    public Boolean showPrevious{get;set;} 
    public Boolean showNext{get;set;} 
    public Boolean pageMess{get;set;} 
    public Boolean noMatch{get;set;} 
    public Boolean Match{get;set;}  
    public Boolean hasPermission{get;set;}  
    public String query{get;set;}
    public Boolean ccNotFound { get; set; }
    public Boolean ccFound{get;set;}  
    public String sortParam{get;set;} 

    public List<PermissionSetAssignment> checkPermissionSet;
    public Integer offsetNumber;
    public Integer sortName;
    public Integer sortPhone;
    public Integer sortDescription;
    public String orderColumn;
    public String descending;
    public String ccId;
    public String moveOperation;
    public String firstRecord;
    public String lastRecord;
    public String firstId; 
    public String lastId; 
    
    public DNPageController() {
        query='';
        sortParam = '';
        directoryName = '';
        directoryPhone = '';
        directoryDescription = '';
        directorySearch = '';
        sortName = 0;
        sortPhone = 0;
        sortDescription = 0;
        orderColumn = 'Id';
        descending = 'DESC';
        currPageNumber = 1;
        arrowName = '';
        arrowPhone = '';
        arrowDescription = '';
        showPrevious = false;
        showNext = true;
        pageMess=false;
        limitNumber = 10;
        offsetNumber = 0;
        noMatch = false;
        Match = true;
        hasPermission = false;   
        initialize();
    }
    
    @TestVisible void initialize(){
        ccId = [SELECT CallCenterId FROM USER WHERE id =: userinfo.getUserId()].CallCenterId;  
        checkPermissionSet = [SELECT AssigneeId, Assignee.username FROM PermissionSetAssignment WHERE PermissionSet.name= 'DirectoryNumbersSupervisor' AND AssigneeId= :userinfo.getUserId()];       
        callCenterCheck();      
    }
    
    
    @TestVisible void callCenterCheck()
    {
        if ((ccId == NULL) || (ccId == '')){
            ccNotFound = true;
            ccFound = false;
        } else {
            ccFound = true;
            ccNotFound = false;
            permissionSetCheck();
            runQuery();
        }       
    }
    
    void permissionSetCheck()
    {    
        if (checkPermissionSet.isEmpty())
        {
            hasPermission = false;
        } else
        {
            hasPermission = true;
        }
    }
    
    public List<SelectOption> getlimitNumbers() {
        List<SelectOption> limitOptions = new List<SelectOption>();
        limitOptions.add(new SelectOption('10','10'));
        limitOptions.add(new SelectOption('20','20'));
        limitOptions.add(new SelectOption('50','50'));
        limitOptions.add(new SelectOption('100','100'));
        return limitOptions; 
        
    }    
    
    public void sorting(){
        offsetNumber = 0;
        currPageNumber = 1; 
        List<AdditionalNumber> additionalNumbersList = new List<AdditionalNumber>();     
        if (sortParam == 'Name')  {	
            sortByName();
        } else if (sortParam == 'Phone')  {
            sortByPhone();
        } else if (sortParam == 'Description') {	
            sortByDescription();
        } 
        runQuery();
    }
    
    void sortByName(){
        sortPhone = 0;
        sortDescription = 0;  
        arrowPhone = '';
        arrowDescription = '';
        if (sortName == 0) {
            arrowName = String.fromCharArray( new List<integer> {9650});
            orderColumn = 'name';
            descending = ', id';
            sortName++;
        } else if (sortName == 1) {
            arrowName = String.fromCharArray( new List<integer> {9660});
            orderColumn = 'name';
            descending = 'DESC, id DESC';
            sortName++;    
        } else if (sortName == 2) {
            arrowName = '';
            orderColumn = 'Id';
            descending = 'DESC';
            sortName = 0;
        }
    }
    
    void sortByPhone() {
        arrowName = '';
        arrowDescription = '';
        sortName = 0;
        sortDescription = 0;
        if(sortPhone == 0) {
            arrowPhone = String.fromCharArray( new List<integer> {9650});
            orderColumn = 'phone';
            descending = ', id';
            sortPhone++;
        } else if(sortPhone == 1) {
            arrowPhone = String.fromCharArray( new List<integer> {9660});
            orderColumn = 'phone';
            descending = 'DESC, id DESC';
            sortPhone++; 
        } else if(sortPhone == 2) {
            arrowPhone = '';
            orderColumn = 'Id';
            descending = 'DESC';
            sortPhone = 0;
        }
    }
    
    void sortByDescription() {
        sortName = 0;
        sortPhone = 0;
        arrowName = '';
        arrowPhone = '';
        if(sortDescription == 0) {
            arrowDescription = String.fromCharArray( new List<integer> {9650});
            orderColumn = 'Description';
            descending = 'NULLS FIRST, id';
            sortDescription++;
        } else if(sortDescription == 1) {
            arrowDescription = String.fromCharArray( new List<integer> {9660});
            orderColumn = 'Description';
            descending = 'DESC NULLS LAST, id DESC';
            sortDescription++;
        } else if(sortDescription == 2) {
            arrowDescription = '';
            orderColumn = 'Id';
            descending = 'DESC';
            sortDescription = 0;
        }
    }
    
    public void setFirstPage() {
        offsetNumber = 0;
        currPageNumber = 1;
        runQuery();
    }
    
    @TestVisible private void runQuery() {
        Decimal discListSize = 0;
        String queryAll;
        String sortBy ='';
        String searchText = '%'+directorySearch+'%';
        String searchQuery = 'AND (Name LIKE :searchText OR Phone LIKE :searchText OR Description Like :searchText)';
        List<AdditionalNumber> additionalNumbersList =  new List<AdditionalNumber>();
        List<AdditionalNumber> toReverseList =  new List<AdditionalNumber>();      
        if(moveOperation == 'NEXT') {
            moveOperation = '';
            if(descending == ', id' || descending == 'NULLS FIRST, id') {    
                sortBy = 'AND '+ orderColumn +' >= :lastRecord AND (id > :lastId OR '+ orderColumn +' <> :lastRecord)';  
            } else {     
                sortBy = 'AND '+ orderColumn +' <= :lastRecord AND (id < :lastId OR '+ orderColumn +' <> :lastRecord)';  
            }
            query = 'SELECT Name, Phone, Description FROM AdditionalNumber WHERE CallCenterId = :ccId '+ sortBy +' '+ searchQuery +' ORDER BY '+ orderColumn +' '+ descending +' LIMIT :limitNumber';            
            additionalNumbersList = database.query(query);
        } else if(moveOperation == 'PREV') {
            moveOperation = '';      
            if(descending == ', id' || descending == 'NULLS FIRST, id') {        
                query = 'SELECT Name, Phone, Description FROM AdditionalNumber WHERE CallCenterId = :ccId AND '+ orderColumn +' <= :firstRecord AND (id < :firstId OR '+ orderColumn +' <> :firstRecord) '+ searchQuery +' ORDER BY '+ orderColumn +' DESC NULLS LAST, id DESC LIMIT :limitNumber';
            } else {     
                query = 'SELECT Name, Phone, Description FROM AdditionalNumber WHERE CallCenterId = :ccId AND '+ orderColumn +' >= :firstRecord AND (id > :firstId OR '+ orderColumn +' <> :firstRecord) '+ searchQuery +' ORDER BY '+ orderColumn +' NULLS FIRST, id LIMIT :limitNumber';
            }
            toReverseList = database.query(query);
            for(Integer i = toReverseList.size() - 1; i >= 0; i--) {
                additionalNumbersList.add(toReverseList[i]);
            }             
        }  else {
            query = 'SELECT Name, Phone, Description FROM AdditionalNumber WHERE CallCenterId = :ccId '+ sortBy +' '+ searchQuery +' ORDER BY '+ orderColumn +' '+ descending +' LIMIT :limitNumber';
            additionalNumbersList = database.query(query);          
        }       
        queryAll = 'SELECT Name, Phone, Description FROM AdditionalNumber WHERE CallCenterId = :ccId '+ searchQuery;        
        for(List<AdditionalNumber> queryAllChunks : database.query(queryAll))
            discListSize += queryAllChunks.size();                
        Decimal listLimit = limitNumber;       
        Decimal calc = discListSize/listLimit;
        totalPageNumber = Integer.valueOf(calc.round(System.RoundingMode.UP));
        buttonsShowing();       
        setOffset(additionalNumbersList);
        tableVisibility(additionalNumbersList);
        populateWrapper(additionalNumbersList);
    }
    
    public void populateWrapper(List<AdditionalNumber> query) {
        List<AdditionalNumber> additionalNumbersList = query;
        directoryNumbersList = new List<DNWrapper>();
        DNWrapper directoryNumberWrapperRecord;
        for(AdditionalNumber additionalNumberRecord : additionalNumbersList) {
            directoryNumberWrapperRecord = new DNWrapper(additionalNumberRecord,false);
            directoryNumbersList.add(directoryNumberWrapperRecord);
        }        
    }
    
    public void tableVisibility(List<AdditionalNumber> additionalNumbersList) {
        if(additionalNumbersList.size() > 0) {
            noMatch = false;
            Match = true;
        } else {
            noMatch = true;
            Match = false;
        }
    }
    
    public void setOffset(List<AdditionalNumber> additionalNumbersList) {        
        Integer listSize = additionalNumbersList.size();
        if(listSize > 0) {
            firstId = additionalNumbersList[0].Id;
            lastId =additionalNumbersList[listSize-1].Id;
            if(orderColumn == 'name') {
                firstRecord = additionalNumbersList[0].Name;
                lastRecord = additionalNumbersList[listSize-1].Name;
            } else if(orderColumn == 'phone') {
                firstRecord = additionalNumbersList[0].Phone;
                lastRecord = additionalNumbersList[listSize-1].Phone;   
            } else if(orderColumn == 'description' ) {            
                firstRecord = additionalNumbersList[0].Description;
                lastRecord = additionalNumbersList[listSize-1].Description;
            } else if(orderColumn == 'id') {
                firstRecord = additionalNumbersList[0].Id;
                lastRecord =additionalNumbersList[listSize-1].Id;
            }
        }
    }
    
    
    public void previous() { 
        moveOperation = 'PREV';
        if(offsetNumber > 0) {
            currPageNumber--;
            offsetNumber -= limitNumber;
        }
        runQuery();
    }
    
    
    
    public void next() {      
        moveOperation = 'NEXT';       
        if(currPageNumber < totalPageNumber) {
            currPageNumber++;
            offsetNumber += limitNumber;
        }
        runQuery();
    }
    
    public void buttonsShowing() {
        if(currPageNumber == 1 && totalPageNumber != 1) {
            showPrevious = false;
            showNext = true;
        } else if(currPageNumber == totalPageNumber  && totalPageNumber != 1) {
            showPrevious = true;
            showNext = false;
        } else if(currPageNumber == totalPageNumber && totalPageNumber == 1) {
            showPrevious = false;
            showNext = false; 
        } else {
            showPrevious = true;
            showNext = true;   	
        }
    }
    
    @TestVisible void clearFields() {
        directoryName = '';
        directoryPhone = '';
        directoryDescription = '';
    }
    
    public partnerSoapSforceCom.Soap logging() {    
        partnerSoapSforceCom.Soap sp = new partnerSoapSforceCom.Soap();     
        String username = DNPageCred__c.getValues('Credentials').username__c;
        String password = (EncodingUtil.base64Decode((EncodingUtil.base64Decode(DNPageCred__c.getValues('Credentials').password__c)).toString())).toString();
        partnerSoapSforceCom.LoginResult loginResult = sp.login(username, password);
        System.debug('Login result'+ loginResult);
        partnerSoapSforceCom.SessionHeader_element sh = new partnerSoapSforceCom.SessionHeader_element();
        sh.sessionId = userinfo.getsessionid();
        sp.SessionHeader = sh;
        sp.endpoint_x = DNPageCred__c.getValues('Credentials').EndPoint__c;
        return sp;      
    }
    
    public void addRecord() {
        try {
            if(directoryName=='') {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter directory number Name'));
            } else if(directoryPhone=='') {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter directory number  phone'));        
            }
            Boolean correctPhone = true;
            pageMess= false;
            String emailRegex = '^\\+\\+?[1-9]\\d{1,14}$'; 
            Pattern MyPattern = Pattern.compile(emailRegex);
            Matcher MyMatcher = MyPattern.matcher(directoryPhone);
            //if(!MyMatcher.matches()) {
            //    pageMess= true;    
            //} else if(MyMatcher.matches() == true && directoryName!= '') {
                pageMess= false;
                partnerSoapSforceCom.Soap sp = logging();
                DNPageController.sObject_x newRecord = new DNPageController.sObject_x();
                newRecord.type_x = 'AdditionalNumber';
                newRecord.Name = directoryName;
                newRecord.Phone = directoryPhone;
                newRecord.Description = directoryDescription;
                newRecord.CallCenterId = ccId;
                partnerSoapSforceCom.SaveResult[] res = sp.create(new DNPageController.sObject_x[] { newRecord });
                clearFields();
            //}
            offsetNumber = 0;
            currPageNumber = 1;
            runQuery();
            buttonsShowing();
        } catch(Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage()));
        }
    }
    
    public void removeRecord() {
        try {
            List<AdditionalNumber> selectedRecordsList = new List<AdditionalNumber>();
            for(DNWrapper directoryNumber : directoryNumbersList) {
                if(directoryNumber.selectedRecord) selectedRecordsList.add(directoryNumber.directoryNumberRecord);
            }
            List<String> ids = new List<String>();
            for(AdditionalNumber a : selectedRecordsList) {
                ids.add(a.id);
            }
            partnerSoapSforceCom.Soap sp = logging();     
            partnerSoapSforceCom.DeleteResult[] res = sp.delete_x(ids);       
            offsetNumber = 0;
            currPageNumber = 1;
            runQuery();
            buttonsShowing();
        } catch(Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage()));
        }
    }
    
    public class DNWrapper {       
        public AdditionalNumber directoryNumberRecord {get; set;}
        public Boolean selectedRecord {get; set;}
        public DNWrapper(AdditionalNumber dnRecord, boolean selected) {
            directoryNumberRecord = dnRecord;
            selectedRecord = selected;
        }
    }
    
    public class sObject_x {
        public String type_x;
        public String[] fieldsToNull;
        public String Id;
        public String Name;
        public String Phone;
        public String Description;
        public String CallCenterId;
        private String[] type_x_type_info = new String[]{'type','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] fieldsToNull_type_info = new String[]{'fieldsToNull','urn:sobject.partner.soap.sforce.com',null,'0','-1','true'};
        private String[] Id_type_info = new String[]{'Id','urn:sobject.partner.soap.sforce.com',null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{'urn:sobject.partner.soap.sforce.com','true','false'};
        private String[] Name_type_info = new String[]{'Name','urn:sobject.partner.soap.sforce.com',null,'1','1','true'};
        private String[] Phone_type_info = new String[]{'Phone','urn:sobject.partner.soap.sforce.com',null,'1','1','true'};
        private String[] Description_type_info = new String[]{'Description','urn:sobject.partner.soap.sforce.com',null,'1','1','true'};
        private String[] CallCenterId_type_info = new String[]{'CallCenterId','urn:sobject.partner.soap.sforce.com',null,'1','1','true'};
        private String[] field_order_type_info = new String[]{'type_x','fieldsToNull','Id','Name','Phone','Description','CallCenterId'};
    }  
}